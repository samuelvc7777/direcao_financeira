package com.example.direcao_financeira_mobile

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityService.TakeScreenshotCallback
import android.graphics.Bitmap
import android.graphics.ColorSpace
import android.hardware.HardwareBuffer
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.view.Display
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.example.direcao_financeira_mobile.parsers.MoveSjParser
import com.example.direcao_financeira_mobile.parsers.NinetyNineOcrParser
import com.example.direcao_financeira_mobile.parsers.NinetyNineParser
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.plugin.common.MethodChannel
import java.text.Normalizer

class ScreenReaderService : AccessibilityService() {
    private val logTag = "DF-MoveSjDebug"
    private val ninetyNinePackageKeywords = listOf("99")
    private val moveSjDriverPackage = "br.com.devbase.movesj.prestador"
    private val samsungGalleryPackage = "com.sec.android.gallery3d"
    private val minimumProcessingIntervalMs = 350L
    private val minimumOcrIntervalMs = 3000L
    private val ninetyNineReadDelayMs = 450L
    private val overlayDisplayDelayMs = 1000L
    private val repeatedOfferQuietWindowMs = 2500L
    private val duplicateOfferWindowMs = 20000L

    private val moveSjParser = MoveSjParser()
    private val ninetyNineParser = NinetyNineParser()
    private val ninetyNineOcrParser = NinetyNineOcrParser()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var floatingOverlay: FloatingOverlay? = null
    private var lastOfferData: Map<String, Any>? = null
    private var lastProcessedPackage: String? = null
    private var lastProcessedAtElapsed = 0L
    private var lastOcrAtElapsed = 0L
    private var lastAcceptedOfferAtElapsed = 0L
    private var lastAcceptedOfferSignature = ""
    private var lastAcceptedAppKey: String? = null
    private var lastAcceptedScreenFingerprint = ""
    private var ocrInFlight = false
    private var pendingNinetyNineRunnable: Runnable? = null
    private var pendingOverlayRunnable: Runnable? = null

    companion object {
        private var channel: MethodChannel? = null

        fun setMethodChannel(methodChannel: MethodChannel) {
            channel = methodChannel
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        SettingsManager.initialize(this)
        floatingOverlay = FloatingOverlay(this)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (!SettingsManager.shouldKeepRuntimeActive()) {
            pendingOverlayRunnable?.let(mainHandler::removeCallbacks)
            pendingOverlayRunnable = null
            floatingOverlay?.hide()
            lastOfferData = null
            return
        }

        if (!SettingsManager.shouldShowTrafficLight()) {
            return
        }

        val packageName = event.packageName?.toString()
        if (
            packageName.isNullOrBlank() ||
                !isSupportedRidePackage(packageName) ||
                !isRelevantMonitoredPackage(packageName)
        ) {
            return
        }

        if (shouldThrottle(packageName) || shouldRespectQuietWindow(packageName)) {
            return
        }

        if (isNinetyNineContext(packageName)) {
            scheduleNinetyNineProcessing(packageName, event.displayId)
            return
        }

        val sourceNode = event.source
        val rootNode = rootInActiveWindow
        val targetNode = resolveTargetNode(sourceNode, rootNode)

        if (targetNode != null) {
            val screenFingerprint = moveSjParser.buildScreenFingerprint(targetNode)
            Log.d(
                logTag,
                "MoveSj screenFingerprint=$screenFingerprint package=$packageName source=${sourceNode != null} root=${rootNode != null}",
            )
            if (shouldIgnoreMatchingScreen(appKey = "MoveSj", screenFingerprint = screenFingerprint)) {
                Log.d(logTag, "MoveSj tela ignorada por fingerprint repetido.")
                return
            }
        }

        if (targetNode != null && moveSjParser.isOfferScreen(targetNode)) {
            val parserDebugSnapshot = moveSjParser.buildDebugSnapshot(targetNode)
            Log.d(logTag, "MoveSj parserSnapshot=$parserDebugSnapshot")
            val offerData = moveSjParser.parseOffer(targetNode).toMutableMap()
            offerData.putIfAbsent("app", "MoveSj")
            offerData.putIfAbsent("platform_name", "MoveSj")
            Log.d(logTag, "MoveSj offerData=$offerData")
            processOffer(offerData)
        }
    }

    private fun scheduleNinetyNineProcessing(
        packageName: String,
        displayId: Int,
    ) {
        pendingNinetyNineRunnable?.let(mainHandler::removeCallbacks)

        val runnable =
            Runnable {
                pendingNinetyNineRunnable = null
                val sourceNode = rootInActiveWindow
                val rootNode = rootInActiveWindow
                val targetNode = resolveTargetNode(sourceNode, rootNode)

                if (!shouldContinueDelayedProcessing(packageName, targetNode, rootNode)) {
                    return@Runnable
                }

                handleNinetyNineEvent(
                    packageName = packageName,
                    displayId = displayId,
                    sourceNode = sourceNode,
                    rootNode = rootNode,
                    targetNode = targetNode,
                )
            }

        pendingNinetyNineRunnable = runnable
        mainHandler.postDelayed(runnable, ninetyNineReadDelayMs)
    }

    private fun shouldContinueDelayedProcessing(
        packageName: String,
        targetNode: AccessibilityNodeInfo?,
        rootNode: AccessibilityNodeInfo?,
    ): Boolean {
        val currentPackage = targetNode?.packageName?.toString()
            ?: rootNode?.packageName?.toString()
            ?: ""

        if (isNinetyNineContext(currentPackage)) {
            return true
        }

        return false
    }

    private fun handleNinetyNineEvent(
        packageName: String,
        displayId: Int,
        sourceNode: AccessibilityNodeInfo?,
        rootNode: AccessibilityNodeInfo?,
        targetNode: AccessibilityNodeInfo?,
    ) {
        val sourcePackage = sourceNode?.packageName?.toString().orEmpty()
        val rootPackage = rootNode?.packageName?.toString().orEmpty()
        val targetPackage = targetNode?.packageName?.toString().orEmpty()

        if (targetNode != null) {
            val screenFingerprint = ninetyNineParser.buildScreenFingerprint(targetNode)
            if (shouldIgnoreMatchingScreen(appKey = "99", screenFingerprint = screenFingerprint)) {
                return
            }

            val isOfferScreen = ninetyNineParser.isOfferScreen(targetNode)

            if (isOfferScreen) {
                val offerData = ninetyNineParser.parseOffer(targetNode)
                processOffer(offerData)
                return
            }
        }

        requestNinetyNineOcr(displayId)
    }

    private fun resolveTargetNode(
        sourceNode: AccessibilityNodeInfo?,
        rootNode: AccessibilityNodeInfo?,
    ): AccessibilityNodeInfo? {
        val appPackage = applicationContext.packageName
        val sourcePackage = sourceNode?.packageName?.toString()
        val rootPackage = rootNode?.packageName?.toString()

        if (sourceNode != null && sourcePackage != appPackage) {
            return sourceNode
        }

        if (rootNode != null && rootPackage != appPackage) {
            return rootNode
        }

        return null
    }

    private fun processOffer(offerData: Map<String, Any>) {
        if (offerData.isEmpty()) {
            return
        }
        if (!SettingsManager.shouldShowTrafficLight()) {
            return
        }
        if (!isMeaningfulOffer(offerData)) {
            return
        }

        val signature = buildOfferSignature(offerData)
        Log.d(logTag, "MoveSj processOffer signature=$signature payload=$offerData")
        if (isDuplicateOffer(signature)) {
            Log.d(logTag, "MoveSj oferta ignorada por assinatura duplicada.")
            return
        }

        lastOfferData = offerData
        lastAcceptedOfferSignature = signature
        lastAcceptedOfferAtElapsed = SystemClock.elapsedRealtime()
        lastAcceptedAppKey = resolveOfferAppKey(offerData)
        lastAcceptedScreenFingerprint = buildOfferScreenFingerprint(offerData)

        pendingOverlayRunnable?.let(mainHandler::removeCallbacks)
        pendingOverlayRunnable =
            Runnable {
                floatingOverlay?.show(offerData)
                pendingOverlayRunnable = null
            }.also { runnable ->
                mainHandler.postDelayed(runnable, overlayDisplayDelayMs)
            }

        notifyFlutter(offerData)
    }

    private fun isSupportedRidePackage(packageName: String): Boolean {
        return isNinetyNineContext(packageName) ||
            packageName == moveSjDriverPackage ||
            packageName == samsungGalleryPackage
    }

    private fun isNinetyNinePackage(packageName: String): Boolean {
        val lowerPackage = packageName.lowercase()
        return ninetyNinePackageKeywords.any { keyword -> lowerPackage.contains(keyword) }
    }

    private fun isNinetyNineContext(packageName: String): Boolean {
        return isNinetyNinePackage(packageName) || packageName == samsungGalleryPackage
    }

    private fun isRelevantMonitoredPackage(packageName: String): Boolean {
        return when {
            packageName == moveSjDriverPackage -> SettingsManager.isMonitoredAppEnabled("MoveSj")
            isNinetyNineContext(packageName) -> SettingsManager.isMonitoredAppEnabled("99")
            else -> false
        }
    }

    private fun shouldThrottle(packageName: String): Boolean {
        val now = SystemClock.elapsedRealtime()
        val shouldSkip =
            packageName == lastProcessedPackage &&
                now - lastProcessedAtElapsed < minimumProcessingIntervalMs

        if (!shouldSkip) {
            lastProcessedPackage = packageName
            lastProcessedAtElapsed = now
        }

        return shouldSkip
    }

    private fun shouldRespectQuietWindow(packageName: String): Boolean {
        if (lastAcceptedOfferAtElapsed == 0L) {
            return false
        }

        val currentApp = resolveAppKey(packageName) ?: return false
        val lastApp =
            lastOfferData?.get("platform_name")?.toString()?.takeIf { it.isNotBlank() }
                ?: lastOfferData?.get("app")?.toString()?.takeIf { it.isNotBlank() }
                ?: return false
        if (currentApp != lastApp) {
            return false
        }

        return SystemClock.elapsedRealtime() - lastAcceptedOfferAtElapsed <
            repeatedOfferQuietWindowMs
    }

    private fun isMeaningfulOffer(offerData: Map<String, Any>): Boolean {
        val priceText = offerData["valor_bruto"]?.toString().orEmpty()
        val priceValue =
            priceText.replace(Regex("[^0-9,]"), "")
                .replace(",", ".")
                .toDoubleOrNull() ?: 0.0
        val kmTotal = (offerData["km_total"] as? Number)?.toDouble() ?: 0.0
        val minTotal = (offerData["minutos_total"] as? Number)?.toInt() ?: 0

        return priceValue > 0.0 && (kmTotal > 0.0 || minTotal > 0)
    }

    private fun buildOfferSignature(offerData: Map<String, Any>?): String {
        if (offerData == null) {
            return ""
        }

        return listOf(
            offerData["app"]?.toString().orEmpty(),
            offerData["valor_bruto"]?.toString().orEmpty(),
            offerData["km_total"]?.toString().orEmpty(),
            offerData["minutos_total"]?.toString().orEmpty(),
            offerData["passenger_name"]?.toString().orEmpty(),
            offerData["origin_address"]?.toString().orEmpty(),
            offerData["destination_address"]?.toString().orEmpty(),
        ).joinToString("|")
    }

    private fun isDuplicateOffer(signature: String): Boolean {
        if (signature.isBlank() || lastAcceptedOfferSignature.isBlank()) {
            return false
        }

        if (signature != lastAcceptedOfferSignature) {
            return false
        }

        return SystemClock.elapsedRealtime() - lastAcceptedOfferAtElapsed <
            duplicateOfferWindowMs
    }

    private fun shouldIgnoreMatchingScreen(
        appKey: String,
        screenFingerprint: String,
    ): Boolean {
        if (screenFingerprint.isBlank() || lastAcceptedScreenFingerprint.isBlank()) {
            return false
        }

        if (appKey != lastAcceptedAppKey) {
            return false
        }

        if (screenFingerprint != lastAcceptedScreenFingerprint) {
            return false
        }

        return SystemClock.elapsedRealtime() - lastAcceptedOfferAtElapsed <
            duplicateOfferWindowMs
    }

    private fun resolveAppKey(packageName: String): String? {
        return when {
            packageName == moveSjDriverPackage -> "MoveSj"
            isNinetyNineContext(packageName) -> "99"
            else -> null
        }
    }

    private fun resolveOfferAppKey(offerData: Map<String, Any>): String? {
        val appValue =
            offerData["platform_name"]?.toString()?.takeIf { it.isNotBlank() }
                ?: offerData["app"]?.toString()?.takeIf { it.isNotBlank() }
                ?: return null

        return when {
            appValue.equals("MoveSj", ignoreCase = true) -> "MoveSj"
            appValue.contains("99", ignoreCase = true) -> "99"
            else -> appValue
        }
    }

    private fun buildOfferScreenFingerprint(offerData: Map<String, Any>): String {
        return listOf(
            normalizeFingerprintValue(resolveOfferAppKey(offerData)),
            normalizeFingerprintValue(offerData["valor_bruto"]?.toString()),
            normalizeFingerprintValue(offerData["km_total"]?.toString()),
            normalizeFingerprintValue(offerData["minutos_total"]?.toString()),
            normalizeFingerprintValue(offerData["passenger_name"]?.toString()),
            normalizeFingerprintValue(offerData["origin_address"]?.toString()),
            normalizeFingerprintValue(offerData["destination_address"]?.toString()),
        ).joinToString("|")
    }

    private fun normalizeFingerprintValue(value: String?): String {
        if (value.isNullOrBlank()) {
            return ""
        }

        val normalized =
            Normalizer.normalize(value.trim(), Normalizer.Form.NFD)
                .replace("\\p{InCombiningDiacriticalMarks}+".toRegex(), "")

        return normalized.lowercase().replace(" ", "")
    }

    private fun requestNinetyNineOcr(displayId: Int) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            return
        }

        if (ocrInFlight) {
            return
        }

        val now = SystemClock.elapsedRealtime()
        if (now - lastOcrAtElapsed < minimumOcrIntervalMs) {
            return
        }

        lastOcrAtElapsed = now
        ocrInFlight = true

        val screenshotDisplayId = if (displayId >= 0) displayId else Display.DEFAULT_DISPLAY

        takeScreenshot(
            screenshotDisplayId,
            mainExecutor,
            object : TakeScreenshotCallback {
                override fun onSuccess(screenshot: ScreenshotResult) {
                    val bitmap = screenshotToBitmap(screenshot)
                    if (bitmap == null) {
                        ocrInFlight = false
                        return
                    }

                    runNinetyNineOcr(bitmap)
                }

                override fun onFailure(errorCode: Int) {
                    ocrInFlight = false
                }
            },
        )
    }

    private fun runNinetyNineOcr(bitmap: Bitmap) {
        val croppedBitmap = cropOfferRegion(bitmap)
        bitmap.recycle()

        val image = InputImage.fromBitmap(croppedBitmap, 0)
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

        recognizer
            .process(image)
            .addOnSuccessListener { visionText ->
                val lines =
                    visionText.textBlocks
                        .flatMap { block -> block.lines }
                        .map { line -> line.text.trim() }
                        .filter { it.isNotEmpty() }

                val offerData = ninetyNineOcrParser.parseOffer(visionText.text, lines)
                if (offerData != null) {
                    processOffer(offerData)
                }
            }
            .addOnFailureListener { _ -> }
            .addOnCompleteListener {
                croppedBitmap.recycle()
                ocrInFlight = false
                recognizer.close()
            }
    }

    private fun cropOfferRegion(bitmap: Bitmap): Bitmap {
        val top = (bitmap.height * 0.32f).toInt().coerceIn(0, bitmap.height - 1)
        val height = (bitmap.height - top).coerceAtLeast(1)
        return Bitmap.createBitmap(bitmap, 0, top, bitmap.width, height)
    }

    private fun screenshotToBitmap(screenshot: ScreenshotResult): Bitmap? {
        return try {
            val hardwareBuffer: HardwareBuffer = screenshot.hardwareBuffer
            val colorSpace: ColorSpace = screenshot.colorSpace
            val hardwareBitmap = Bitmap.wrapHardwareBuffer(hardwareBuffer, colorSpace)
            val bitmap = hardwareBitmap?.copy(Bitmap.Config.ARGB_8888, false)
            hardwareBuffer.close()
            hardwareBitmap?.recycle()
            bitmap
        } catch (_: Throwable) {
            null
        }
    }

    private fun notifyFlutter(data: Map<String, Any>) {
        Handler(Looper.getMainLooper()).post {
        channel?.invokeMethod("onRaceDetected", data)
        Log.d(logTag, "MoveSj invokeMethod onRaceDetected payload=$data")
    }
    }

    override fun onInterrupt() {
        pendingOverlayRunnable?.let(mainHandler::removeCallbacks)
        pendingOverlayRunnable = null
        floatingOverlay?.hide()
    }
}
