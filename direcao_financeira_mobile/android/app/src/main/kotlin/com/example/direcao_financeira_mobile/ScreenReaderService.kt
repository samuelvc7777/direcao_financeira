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

class ScreenReaderService : AccessibilityService() {
    private val debugTag = "ScreenReader99"
    private val ninetyNinePackageKeywords = listOf("99")
    private val moveSjDriverPackage = "br.com.devbase.movesj.prestador"
    private val samsungGalleryPackage = "com.sec.android.gallery3d"
    private val minimumProcessingIntervalMs = 350L
    private val minimumOcrIntervalMs = 1500L
    private val ninetyNineReadDelayMs = 450L

    private val moveSjParser = MoveSjParser()
    private val ninetyNineParser = NinetyNineParser()
    private val ninetyNineOcrParser = NinetyNineOcrParser()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var floatingOverlay: FloatingOverlay? = null
    private var lastOfferData: Map<String, Any>? = null
    private var lastProcessedPackage: String? = null
    private var lastProcessedAtElapsed = 0L
    private var lastOcrAtElapsed = 0L
    private var ocrInFlight = false
    private var pendingNinetyNineRunnable: Runnable? = null

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
        Log.d("ScreenReader", "Servico de acessibilidade conectado")
        emitDebugLog(
            "Servico conectado. trafficLight=${SettingsManager.trafficLightActive} journey=${SettingsManager.journeyActive}",
        )
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (!SettingsManager.shouldKeepRuntimeActive()) {
            floatingOverlay?.hide()
            lastOfferData = null
            return
        }

        if (!SettingsManager.shouldShowTrafficLight()) {
            return
        }

        val packageName = event.packageName?.toString()
        if (packageName.isNullOrBlank() || !isSupportedRidePackage(packageName)) {
            return
        }

        if (shouldThrottle(packageName)) {
            return
        }

        if (isNinetyNinePackage(packageName) || packageName == samsungGalleryPackage) {
            scheduleNinetyNineProcessing(packageName, event.displayId)
            return
        }

        val sourceNode = event.source
        val rootNode = rootInActiveWindow
        val targetNode = resolveTargetNode(sourceNode, rootNode)

        if (targetNode != null && moveSjParser.isOfferScreen(targetNode)) {
            val offerData = moveSjParser.parseOffer(targetNode).toMutableMap()
            offerData.putIfAbsent("app", "MoveSj")
            offerData.putIfAbsent("platform_name", "MoveSj")
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
        if (packageName == samsungGalleryPackage) {
            val currentPackage = targetNode?.packageName?.toString()
                ?: rootNode?.packageName?.toString()
                ?: ""

            if (currentPackage == samsungGalleryPackage) {
                return true
            }

            emitDebugLog("galeria ignorada apos delay currentPkg=$currentPackage")
            return false
        }

        val currentPackage = targetNode?.packageName?.toString()
            ?: rootNode?.packageName?.toString()
            ?: ""

        if (isNinetyNinePackage(currentPackage)) {
            return true
        }

        emitDebugLog("99 ignorada apos delay currentPkg=$currentPackage")
        return false
    }

    private fun handleNinetyNineEvent(
        packageName: String,
        displayId: Int,
        sourceNode: AccessibilityNodeInfo?,
        rootNode: AccessibilityNodeInfo?,
        targetNode: AccessibilityNodeInfo?,
    ) {
        if (packageName == samsungGalleryPackage) {
            emitDebugLog("galeria samsung ativa; executando OCR do print")
            requestNinetyNineOcr(displayId)
            return
        }

        val sourcePackage = sourceNode?.packageName?.toString().orEmpty()
        val rootPackage = rootNode?.packageName?.toString().orEmpty()
        val targetPackage = targetNode?.packageName?.toString().orEmpty()

        if (targetNode != null) {
            val debugSnapshot = ninetyNineParser.buildDebugSnapshot(targetNode)
            val isOfferScreen = ninetyNineParser.isOfferScreen(targetNode)
            emitDebugLog(
                "99 package=$packageName sourcePkg=$sourcePackage rootPkg=$rootPackage targetPkg=$targetPackage offer=$isOfferScreen price='${debugSnapshot["priceText"]}' stats=${debugSnapshot["statsCount"]} tipo='${debugSnapshot["offerType"]}' pagamento='${debugSnapshot["paymentMethod"]}' rating='${debugSnapshot["rating"]}' corridas=${debugSnapshot["ridesCount"]} passageiro='${debugSnapshot["passengerName"]}' origem='${debugSnapshot["originAddress"]}' destino='${debugSnapshot["destinationAddress"]}'",
            )
            emitDebugLog("99 sampleTexts=${debugSnapshot["sampleTexts"]}")

            if (isOfferScreen) {
                val offerData = ninetyNineParser.parseOffer(targetNode)
                emitDebugLog("99 payload=$offerData")
                processOffer(offerData)
                return
            }
        } else {
            emitDebugLog(
                "99 sem targetNode sourcePkg=$sourcePackage rootPkg=$rootPackage; tentando OCR",
            )
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
            emitDebugLog("oferta descartada por dados insuficientes app=${offerData["app"]}")
            return
        }

        if (buildOfferSignature(offerData) == buildOfferSignature(lastOfferData)) {
            return
        }

        lastOfferData = offerData
        Log.d("ScreenReader", "Oferta detectada (${offerData["app"]}): $offerData")

        Handler(Looper.getMainLooper()).post {
            floatingOverlay?.show(offerData)
        }

        notifyFlutter(offerData)
    }

    private fun isSupportedRidePackage(packageName: String): Boolean {
        return isNinetyNinePackage(packageName) ||
            packageName == moveSjDriverPackage ||
            packageName == samsungGalleryPackage
    }

    private fun isNinetyNinePackage(packageName: String): Boolean {
        val lowerPackage = packageName.lowercase()
        return ninetyNinePackageKeywords.any { keyword -> lowerPackage.contains(keyword) }
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

    private fun requestNinetyNineOcr(displayId: Int) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            emitDebugLog("99 ocr ignorado sdk=${Build.VERSION.SDK_INT}")
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
        emitDebugLog("99 ocr screenshot displayId=$screenshotDisplayId")

        takeScreenshot(
            screenshotDisplayId,
            mainExecutor,
            object : TakeScreenshotCallback {
                override fun onSuccess(screenshot: ScreenshotResult) {
                    val bitmap = screenshotToBitmap(screenshot)
                    if (bitmap == null) {
                        ocrInFlight = false
                        emitDebugLog("99 ocr screenshot sem bitmap")
                        return
                    }

                    runNinetyNineOcr(bitmap)
                }

                override fun onFailure(errorCode: Int) {
                    ocrInFlight = false
                    emitDebugLog("99 ocr screenshot falhou code=$errorCode")
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

                val debugSnapshot = ninetyNineOcrParser.buildDebugSnapshot(visionText.text, lines)
                emitDebugLog(
                    "99 ocr price='${debugSnapshot["priceText"]}' stats=${debugSnapshot["statsCount"]} tipo='${debugSnapshot["offerType"]}' pagamento='${debugSnapshot["paymentMethod"]}' rating='${debugSnapshot["rating"]}' corridas=${debugSnapshot["ridesCount"]} passageiro='${debugSnapshot["passengerName"]}' origem='${debugSnapshot["originAddress"]}' destino='${debugSnapshot["destinationAddress"]}'",
                )
                emitDebugLog("99 ocr lines=${debugSnapshot["sampleLines"]}")

                val offerData = ninetyNineOcrParser.parseOffer(visionText.text, lines)
                if (offerData != null) {
                    emitDebugLog("99 ocr payload=$offerData")
                    processOffer(offerData)
                }
            }
            .addOnFailureListener { error ->
                emitDebugLog("99 ocr erro=${error.message ?: error.javaClass.simpleName}")
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
        } catch (error: Throwable) {
            emitDebugLog(
                "99 ocr conversao bitmap falhou=${error.message ?: error.javaClass.simpleName}",
            )
            null
        }
    }

    private fun notifyFlutter(data: Map<String, Any>) {
        Handler(Looper.getMainLooper()).post {
            channel?.invokeMethod("onRaceDetected", data)
        }
    }

    private fun emitDebugLog(message: String) {
        Log.d(debugTag, message)
        Handler(Looper.getMainLooper()).post {
            channel?.invokeMethod("onAccessibilityDebugLog", message)
        }
    }

    override fun onInterrupt() {
        floatingOverlay?.hide()
        Log.e("ScreenReader", "Servico de acessibilidade interrompido")
    }
}
