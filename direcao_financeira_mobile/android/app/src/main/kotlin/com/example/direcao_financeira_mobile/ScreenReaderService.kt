package com.example.direcao_financeira_mobile

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityService.TakeScreenshotCallback
import android.app.KeyguardManager
import android.content.Context
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
import com.example.direcao_financeira_mobile.parsers.MoveSjParser
import com.example.direcao_financeira_mobile.parsers.NinetyNineOcrParser
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.plugin.common.MethodChannel
import java.text.Normalizer

class ScreenReaderService : AccessibilityService() {
    private val logTag = "DF-MoveSjDebug"
    private val lockLogPrefix = "LOCK_DEBUG"
    private val ninetyNineDriverPackage = "com.app99.driver"
    private val moveSjDriverPackage = "br.com.devbase.movesj.prestador"
    private val minimumProcessingIntervalMs = 350L
    private val minimumOcrIntervalMs = 3000L
    private val minimumMoveSjOcrIntervalMs = 1000L
    private val ninetyNineReadDelayMs = 450L
    private val moveSjReadDelayMs = 450L
    private val overlayDisplayDelayMs = 1000L
    private val repeatedOfferQuietWindowMs = 2500L
    private val duplicateOfferWindowMs = 20000L

    private val moveSjParser = MoveSjParser()
    private val ninetyNineOcrParser = NinetyNineOcrParser()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var floatingOverlay: FloatingOverlay? = null
    private var rideOfferNotificationDispatcher: RideOfferNotificationDispatcher? = null
    private var lastOfferData: Map<String, Any>? = null
    private var lastProcessedPackage: String? = null
    private var lastProcessedAtElapsed = 0L
    private var lastOcrAtElapsed = 0L
    private var lastAcceptedOfferAtElapsed = 0L
    private var lastAcceptedOfferSignature = ""
    private var lastAcceptedMoveSjCoreSignature = ""
    private var lastAcceptedAppKey: String? = null
    private var lastAcceptedScreenFingerprint = ""
    private var ocrInFlight = false
    private var pendingNinetyNineRunnable: Runnable? = null
    private var pendingMoveSjRunnable: Runnable? = null
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
        rideOfferNotificationDispatcher = RideOfferNotificationDispatcher(this)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        logLockscreenEvent("event_received", event = event)

        if (!SettingsManager.shouldKeepRuntimeActive()) {
            pendingOverlayRunnable?.let(mainHandler::removeCallbacks)
            pendingMoveSjRunnable?.let(mainHandler::removeCallbacks)
            pendingOverlayRunnable = null
            pendingMoveSjRunnable = null
            floatingOverlay?.hide()
            lastOfferData = null
            logLockscreenMessage("runtime_inactive_skip")
            return
        }

        if (!SettingsManager.shouldShowTrafficLight()) {
            logLockscreenMessage("traffic_light_disabled_skip")
            return
        }

        val packageName = event.packageName?.toString()
        if (
            packageName.isNullOrBlank() ||
                !isSupportedRidePackage(packageName) ||
                !isRelevantMonitoredPackage(packageName)
        ) {
            logLockscreenEvent(
                "package_filtered",
                event = event,
                extra =
                    mapOf(
                        "isSupportedRidePackage" to (!packageName.isNullOrBlank() && isSupportedRidePackage(packageName)),
                        "isRelevantMonitoredPackage" to (!packageName.isNullOrBlank() && isRelevantMonitoredPackage(packageName)),
                    ),
            )
            return
        }

        if (shouldThrottle(packageName) || shouldRespectQuietWindow(packageName)) {
            logLockscreenEvent(
                "throttled_or_quiet_window",
                event = event,
                extra =
                    mapOf(
                        "shouldThrottle" to shouldThrottle(packageName),
                        "shouldRespectQuietWindow" to shouldRespectQuietWindow(packageName),
                    ),
            )
            return
        }

        if (isNinetyNineContext(packageName)) {
            logLockscreenEvent("schedule_99_processing", event = event)
            scheduleNinetyNineProcessing(packageName, event.displayId)
            return
        }

        logLockscreenEvent("movesj_schedule_ocr_processing", event = event)
        scheduleMoveSjOcrProcessing(event.displayId)
    }

    private fun scheduleMoveSjOcrProcessing(displayId: Int) {
        pendingMoveSjRunnable?.let(mainHandler::removeCallbacks)

        val runnable =
            Runnable {
                pendingMoveSjRunnable = null
                logLockscreenMessage("movesj_ocr_delayed_processing", extra = mapOf("displayId" to displayId))
                requestMoveSjOcr(displayId)
            }

        pendingMoveSjRunnable = runnable
        mainHandler.postDelayed(runnable, moveSjReadDelayMs)
    }

    private fun scheduleNinetyNineProcessing(
        packageName: String,
        displayId: Int,
    ) {
        pendingNinetyNineRunnable?.let(mainHandler::removeCallbacks)

        val runnable =
            Runnable {
                pendingNinetyNineRunnable = null
                logLockscreenMessage(
                    "99_ocr_delayed_processing",
                    extra =
                        mapOf(
                            "eventPackage" to packageName,
                            "displayId" to displayId,
                        ),
                )
                requestNinetyNineOcr(displayId)
            }

        pendingNinetyNineRunnable = runnable
        mainHandler.postDelayed(runnable, ninetyNineReadDelayMs)
    }

    private fun processOffer(offerData: Map<String, Any>) {
        if (offerData.isEmpty()) {
            logLockscreenMessage("process_offer_empty_payload")
            return
        }
        if (!SettingsManager.shouldShowTrafficLight()) {
            logLockscreenMessage("process_offer_traffic_light_disabled")
            return
        }
        if (!isMeaningfulOffer(offerData)) {
            logLockscreenMessage("process_offer_not_meaningful", extra = offerData)
            return
        }

        val signature = buildOfferSignature(offerData)
        val appKey = resolveOfferAppKey(offerData)
        val moveSjCoreSignature = buildMoveSjCoreSignature(offerData)
        Log.d(logTag, "MoveSj processOffer signature=$signature payload=$offerData")
        if (
            isDuplicateOffer(signature) ||
                (appKey == "MoveSj" && isDuplicateMoveSjCoreOffer(moveSjCoreSignature))
        ) {
            Log.d(logTag, "MoveSj oferta ignorada por assinatura duplicada.")
            logLockscreenMessage("process_offer_duplicate_signature", extra = offerData)
            return
        }

        lastOfferData = offerData
        lastAcceptedOfferSignature = signature
        if (appKey == "MoveSj") {
            lastAcceptedMoveSjCoreSignature = moveSjCoreSignature
        }
        lastAcceptedOfferAtElapsed = SystemClock.elapsedRealtime()
        lastAcceptedAppKey = appKey
        lastAcceptedScreenFingerprint = buildOfferScreenFingerprint(offerData)

        pendingOverlayRunnable?.let(mainHandler::removeCallbacks)
        pendingOverlayRunnable =
            Runnable {
                logLockscreenMessage("overlay_show_attempt", extra = offerData)
                floatingOverlay?.show(offerData)
                pendingOverlayRunnable = null
            }.also { runnable ->
                mainHandler.postDelayed(runnable, overlayDisplayDelayMs)
            }

        rideOfferNotificationDispatcher?.show(offerData)
        notifyFlutter(offerData)
    }

    private fun isSupportedRidePackage(packageName: String): Boolean {
        return isNinetyNineContext(packageName) ||
            packageName == moveSjDriverPackage
    }

    private fun isNinetyNinePackage(packageName: String): Boolean {
        return packageName == ninetyNineDriverPackage
    }

    private fun isNinetyNineContext(packageName: String): Boolean {
        return isNinetyNinePackage(packageName)
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

    private fun isDuplicateMoveSjCoreOffer(coreSignature: String): Boolean {
        if (coreSignature.isBlank() || lastAcceptedMoveSjCoreSignature.isBlank()) {
            return false
        }

        if (coreSignature != lastAcceptedMoveSjCoreSignature) {
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

    private fun buildMoveSjCoreSignature(offerData: Map<String, Any>): String {
        return listOf(
            normalizeFingerprintValue(resolveOfferAppKey(offerData)),
            normalizeFingerprintValue(offerData["valor_bruto"]?.toString()),
            normalizeFingerprintValue(offerData["km_total"]?.toString()),
            normalizeFingerprintValue(offerData["minutos_total"]?.toString()),
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

    private fun requestMoveSjOcr(displayId: Int) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            logLockscreenMessage("ocr_skip_sdk_too_old")
            return
        }

        if (ocrInFlight) {
            logLockscreenMessage("ocr_skip_in_flight")
            return
        }

        val now = SystemClock.elapsedRealtime()
        if (now - lastOcrAtElapsed < minimumMoveSjOcrIntervalMs) {
            logLockscreenMessage(
                "ocr_skip_cooldown",
                extra = mapOf("elapsedSinceLastOcrMs" to (now - lastOcrAtElapsed)),
            )
            return
        }

        lastOcrAtElapsed = now
        ocrInFlight = true
        logLockscreenMessage("ocr_request_start", extra = mapOf("displayId" to displayId))

        val screenshotDisplayId = if (displayId >= 0) displayId else Display.DEFAULT_DISPLAY

        takeScreenshot(
            screenshotDisplayId,
            mainExecutor,
            object : TakeScreenshotCallback {
                override fun onSuccess(screenshot: ScreenshotResult) {
                    logLockscreenMessage("ocr_screenshot_success")
                    val bitmap = screenshotToBitmap(screenshot)
                    if (bitmap == null) {
                        logLockscreenMessage("ocr_bitmap_null")
                        ocrInFlight = false
                        return
                    }

                    runMoveSjOcr(bitmap)
                }

                override fun onFailure(errorCode: Int) {
                    logLockscreenMessage("ocr_screenshot_failure", extra = mapOf("errorCode" to errorCode))
                    ocrInFlight = false
                }
            },
        )
    }

    private fun requestNinetyNineOcr(displayId: Int) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            logLockscreenMessage("ocr_skip_sdk_too_old")
            return
        }

        if (ocrInFlight) {
            logLockscreenMessage("ocr_skip_in_flight")
            return
        }

        val now = SystemClock.elapsedRealtime()
        if (now - lastOcrAtElapsed < minimumOcrIntervalMs) {
            logLockscreenMessage(
                "ocr_skip_cooldown",
                extra = mapOf("elapsedSinceLastOcrMs" to (now - lastOcrAtElapsed)),
            )
            return
        }

        lastOcrAtElapsed = now
        ocrInFlight = true
        logLockscreenMessage("ocr_request_start", extra = mapOf("displayId" to displayId))

        val screenshotDisplayId = if (displayId >= 0) displayId else Display.DEFAULT_DISPLAY

        takeScreenshot(
            screenshotDisplayId,
            mainExecutor,
            object : TakeScreenshotCallback {
                override fun onSuccess(screenshot: ScreenshotResult) {
                    logLockscreenMessage("ocr_screenshot_success")
                    val bitmap = screenshotToBitmap(screenshot)
                    if (bitmap == null) {
                        logLockscreenMessage("ocr_bitmap_null")
                        ocrInFlight = false
                        return
                    }

                    runNinetyNineOcr(bitmap)
                }

                override fun onFailure(errorCode: Int) {
                    logLockscreenMessage("ocr_screenshot_failure", extra = mapOf("errorCode" to errorCode))
                    ocrInFlight = false
                }
            },
        )
    }

    private fun runMoveSjOcr(bitmap: Bitmap) {
        val image = InputImage.fromBitmap(bitmap, 0)
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

        recognizer
            .process(image)
            .addOnSuccessListener { visionText ->
                val ocrLines =
                    visionText.textBlocks
                        .flatMap { block -> block.lines }
                        .sortedWith(
                            compareBy(
                                { line -> line.boundingBox?.top ?: Int.MAX_VALUE },
                                { line -> line.boundingBox?.left ?: Int.MAX_VALUE },
                            ),
                        )
                        .mapNotNull { line ->
                            val text = line.text.trim()
                            val box = line.boundingBox
                            if (text.isEmpty() || box == null) {
                                null
                            } else {
                                MoveSjParser.OcrLine(
                                    text = text,
                                    left = box.left,
                                    top = box.top,
                                    right = box.right,
                                    bottom = box.bottom,
                                )
                            }
                        }
                val lines = ocrLines.map { it.text }

                val offerData = moveSjParser.parsePositionedOcrOffer(visionText.text, ocrLines)
                logLockscreenMessage(
                    "ocr_result",
                    extra =
                        mapOf(
                            "lineCount" to lines.size,
                            "parsedOffer" to (offerData != null),
                            "sampleLines" to lines.take(8).joinToString(" | "),
                        ),
                )
                if (offerData != null) {
                    logLockscreenMessage("ocr_offer_parsed", extra = offerData)
                    processOffer(offerData)
                }
            }
            .addOnFailureListener { error ->
                logLockscreenMessage("ocr_failure", extra = mapOf("message" to (error.message ?: "")))
            }
            .addOnCompleteListener {
                bitmap.recycle()
                ocrInFlight = false
                recognizer.close()
            }
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
                logLockscreenMessage(
                    "ocr_result",
                    extra =
                        mapOf(
                            "lineCount" to lines.size,
                            "parsedOffer" to (offerData != null),
                            "sampleLines" to lines.take(8).joinToString(" | "),
                        ),
                )
                if (offerData != null) {
                    logLockscreenMessage("ocr_offer_parsed", extra = offerData)
                    processOffer(offerData)
                }
            }
            .addOnFailureListener { error ->
                logLockscreenMessage("ocr_failure", extra = mapOf("message" to (error.message ?: "")))
            }
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
        pendingMoveSjRunnable?.let(mainHandler::removeCallbacks)
        pendingOverlayRunnable = null
        pendingMoveSjRunnable = null
        floatingOverlay?.hide()
        logLockscreenMessage("service_interrupt")
    }

    private fun logLockscreenEvent(
        stage: String,
        event: AccessibilityEvent,
        extra: Map<String, Any?> = emptyMap(),
    ) {
        logLockscreenMessage(
            stage,
            extra =
                buildMap {
                    put("eventType", event.eventType)
                    put("eventPackage", event.packageName?.toString().orEmpty())
                    put("isKeyguardLocked", isKeyguardLocked())
                    put("isDeviceLocked", isDeviceLockedCompat())
                    putAll(extra)
                },
        )
    }

    private fun logLockscreenMessage(
        stage: String,
        extra: Map<String, Any?> = emptyMap(),
    ) {
        Log.d(logTag, "$lockLogPrefix stage=$stage ${extra.entries.joinToString(" ") { "${it.key}=${it.value}" }}")
    }

    private fun isKeyguardLocked(): Boolean {
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        return keyguardManager?.isKeyguardLocked == true
    }

    private fun isDeviceLockedCompat(): Boolean {
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            keyguardManager?.isDeviceLocked == true
        } else {
            false
        }
    }
}
