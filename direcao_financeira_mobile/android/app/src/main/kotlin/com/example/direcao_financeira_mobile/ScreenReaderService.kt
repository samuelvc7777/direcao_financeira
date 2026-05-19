package com.example.direcao_financeira_mobile

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityService.TakeScreenshotCallback
import android.app.KeyguardManager
import android.content.Context
import android.content.pm.ApplicationInfo
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
    private val minimumMoveSjOcrIntervalMs = 2000L
    private val ninetyNineReadDelayMs = 300L
    private val moveSjReadDelayMs = 450L
    private val moveSjRetryDelayMs = 650L
    private val maxMoveSjOcrAttempts = 2
    private val ocrWatchdogTimeoutMs = 8000L
    private val overlayDisplayDelayMs = 200L
    private val repeatedOfferQuietWindowMs = 2500L
    private val duplicateOfferWindowMs = 20000L
    private val duplicateOcrFingerprintWindowMs = 6000L
    private val maxOcrPrefilterLines = 80

    private val moveSjParser = MoveSjParser()
    private val ninetyNineOcrParser = NinetyNineOcrParser()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var floatingOverlay: FloatingOverlay? = null
    private var rideOfferNotificationDispatcher: RideOfferNotificationDispatcher? = null
    private var lastOfferData: Map<String, Any>? = null
    private var lastProcessedPackage: String? = null
    private var lastProcessedAtElapsed = 0L
    private var lastOcrAtElapsed = 0L
    private var lastOcrFingerprint = ""
    private var lastOcrFingerprintAtElapsed = 0L
    private var lastAcceptedOfferAtElapsed = 0L
    private var lastAcceptedOfferSignature = ""
    private var lastAcceptedMoveSjCoreSignature = ""
    private var lastAcceptedAppKey: String? = null
    private var lastAcceptedScreenFingerprint = ""
    private var ocrInFlight = false
    private var activeOcrToken = 0
    private var ocrWatchdogRunnable: Runnable? = null
    private var pendingNinetyNineRunnable: Runnable? = null
    private var pendingMoveSjRunnable: Runnable? = null
    private var pendingOverlayRunnable: Runnable? = null

    private data class OcrScreenCandidate(
        val shouldRunOcr: Boolean,
        val fingerprint: String,
        val strongSignalCount: Int,
        val lineCount: Int,
    )

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
            pendingNinetyNineRunnable?.let(mainHandler::removeCallbacks)
            ocrWatchdogRunnable?.let(mainHandler::removeCallbacks)
            pendingOverlayRunnable = null
            pendingMoveSjRunnable = null
            pendingNinetyNineRunnable = null
            ocrWatchdogRunnable = null
            ocrInFlight = false
            floatingOverlay?.hide()
            restoreAppBubbleAfterRideOffer()
            lastOfferData = null
            logLockscreenMessage("runtime_inactive_skip")
            return
        }

        if (!SettingsManager.shouldShowTrafficLight()) {
            restoreAppBubbleAfterRideOffer()
            logLockscreenMessage("traffic_light_disabled_skip")
            return
        }

        val packageName = event.packageName?.toString()
        if (
            packageName.isNullOrBlank() ||
                !isSupportedRidePackage(packageName) ||
                !isRelevantMonitoredPackage(packageName)
        ) {
            restoreAppBubbleAfterRideOffer()
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

    private fun scheduleMoveSjOcrProcessing(
        displayId: Int,
        attempt: Int = 1,
    ) {
        pendingMoveSjRunnable?.let(mainHandler::removeCallbacks)

        val safeAttempt = attempt.coerceIn(1, maxMoveSjOcrAttempts)
        val delayMs = if (safeAttempt == 1) moveSjReadDelayMs else moveSjRetryDelayMs
        val runnable =
            Runnable {
                pendingMoveSjRunnable = null
                logLockscreenMessage(
                    "movesj_ocr_delayed_processing",
                    extra =
                        mapOf(
                            "displayId" to displayId,
                            "attempt" to safeAttempt,
                        ),
                )
                val candidate = buildOcrScreenCandidate("MoveSj")
                if (!candidate.shouldRunOcr) {
                    restoreAppBubbleAfterRideOffer()
                    logLockscreenMessage(
                        "ocr_skip_prefilter",
                        extra =
                            mapOf(
                                "source" to "MoveSj",
                                "attempt" to safeAttempt,
                                "lineCount" to candidate.lineCount,
                                "strongSignalCount" to candidate.strongSignalCount,
                            ),
                    )
                    return@Runnable
                }
                requestMoveSjOcr(displayId, safeAttempt, candidate)
            }

        pendingMoveSjRunnable = runnable
        mainHandler.postDelayed(runnable, delayMs)
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
                val candidate = buildOcrScreenCandidate("99")
                if (!candidate.shouldRunOcr) {
                    restoreAppBubbleAfterRideOffer()
                    logLockscreenMessage(
                        "ocr_skip_prefilter",
                        extra =
                            mapOf(
                                "source" to "99",
                                "lineCount" to candidate.lineCount,
                                "strongSignalCount" to candidate.strongSignalCount,
                            ),
                    )
                    return@Runnable
                }
                requestNinetyNineOcr(displayId, candidate)
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
            logLockscreenMessage("process_offer_not_meaningful", extra = offerLogSummary(offerData))
            return
        }

        val signature = buildOfferSignature(offerData)
        val appKey = resolveOfferAppKey(offerData)
        val moveSjCoreSignature = buildMoveSjCoreSignature(offerData)
        debugLog("MoveSj processOffer signature=$signature summary=${offerLogSummary(offerData)}")
        if (
            isDuplicateOffer(signature) ||
                (appKey == "MoveSj" && isDuplicateMoveSjCoreOffer(moveSjCoreSignature))
        ) {
            debugLog("MoveSj oferta ignorada por assinatura duplicada.")
            logLockscreenMessage("process_offer_duplicate_signature", extra = offerLogSummary(offerData))
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
        hideAppBubbleForRideOffer()

        pendingOverlayRunnable?.let(mainHandler::removeCallbacks)
        pendingOverlayRunnable =
            Runnable {
                logLockscreenMessage("overlay_show_attempt", extra = offerLogSummary(offerData))
                runCatching {
                    floatingOverlay?.show(offerData)
                }.onFailure { error ->
                    logLockscreenMessage(
                        "overlay_show_failure",
                        extra = mapOf("message" to (error.message ?: error::class.java.simpleName)),
                    )
                }
                pendingOverlayRunnable = null
            }.also { runnable ->
                mainHandler.postDelayed(runnable, overlayDisplayDelayMs)
            }

        rideOfferNotificationDispatcher?.show(offerData)
        notifyFlutter(offerData)
    }

    private fun offerLogSummary(offerData: Map<String, Any>): Map<String, Any?> {
        return mapOf(
            "app" to (offerData["platform_name"] ?: offerData["app"]),
            "valor" to offerData["valor_bruto"],
            "km" to offerData["km_total"],
            "min" to offerData["minutos_total"],
        )
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

    private fun normalizedText(value: String?): String {
        if (value.isNullOrBlank()) {
            return ""
        }

        val normalized =
            Normalizer.normalize(value, Normalizer.Form.NFD)
                .replace("\\p{InCombiningDiacriticalMarks}+".toRegex(), "")

        return normalized.lowercase()
    }

    private fun buildOcrScreenCandidate(source: String): OcrScreenCandidate {
        val root = rootInActiveWindow
            ?: return OcrScreenCandidate(
                shouldRunOcr = true,
                fingerprint = "",
                strongSignalCount = 0,
                lineCount = 0,
            )
        val lines = collectVisibleNodeTexts(root).distinct().take(maxOcrPrefilterLines)
        if (lines.isEmpty()) {
            return OcrScreenCandidate(
                shouldRunOcr = true,
                fingerprint = "",
                strongSignalCount = 0,
                lineCount = 0,
            )
        }

        val normalizedLines = lines.map(::normalizedText)
        val strongSignalCount =
            normalizedLines.count { line ->
                line.contains("r$") ||
                    line.contains("aceitar") ||
                    line.contains("recusar") ||
                    line.contains("km") ||
                    line.contains("min") ||
                    line.contains("preco") ||
                    line.contains("perfil")
            }
        val shouldRunOcr = strongSignalCount > 0 || lines.size < 4
        val fingerprint =
            normalizedLines
                .filter { line ->
                    line.contains("r$") ||
                        line.contains("aceitar") ||
                        line.contains("recusar") ||
                        line.contains("km") ||
                        line.contains("min") ||
                        line.contains("preco") ||
                        line.contains("perfil")
                }
                .take(16)
                .joinToString("|")
                .ifBlank {
                    normalizedLines.take(12).joinToString("|")
                }

        return OcrScreenCandidate(
            shouldRunOcr = shouldRunOcr,
            fingerprint = "$source|${normalizeFingerprintValue(fingerprint)}",
            strongSignalCount = strongSignalCount,
            lineCount = lines.size,
        )
    }

    private fun collectVisibleNodeTexts(
        node: AccessibilityNodeInfo,
        result: MutableList<String> = mutableListOf(),
    ): List<String> {
        val text = node.text?.toString()?.trim()
        if (!text.isNullOrEmpty()) {
            result.add(text)
        }

        val description = node.contentDescription?.toString()?.trim()
        if (!description.isNullOrEmpty()) {
            result.add(description)
        }

        if (result.size >= maxOcrPrefilterLines) {
            return result
        }

        for (index in 0 until node.childCount) {
            if (result.size >= maxOcrPrefilterLines) {
                break
            }
            val child = node.getChild(index) ?: continue
            collectVisibleNodeTexts(child, result)
        }

        return result
    }

    private fun shouldSkipDuplicateOcr(candidate: OcrScreenCandidate): Boolean {
        if (candidate.fingerprint.isBlank() || lastOcrFingerprint.isBlank()) {
            return false
        }

        return candidate.fingerprint == lastOcrFingerprint &&
            SystemClock.elapsedRealtime() - lastOcrFingerprintAtElapsed <
            duplicateOcrFingerprintWindowMs
    }

    private fun markOcrFingerprint(candidate: OcrScreenCandidate) {
        if (candidate.fingerprint.isBlank()) {
            return
        }

        lastOcrFingerprint = candidate.fingerprint
        lastOcrFingerprintAtElapsed = SystemClock.elapsedRealtime()
    }

    private fun requestMoveSjOcr(
        displayId: Int,
        attempt: Int = 1,
        candidate: OcrScreenCandidate = buildOcrScreenCandidate("MoveSj"),
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            logLockscreenMessage("ocr_skip_sdk_too_old")
            return
        }

        if (ocrInFlight) {
            logLockscreenMessage(
                "ocr_skip_in_flight",
                extra = mapOf("attempt" to attempt),
            )
            if (attempt < maxMoveSjOcrAttempts) {
                scheduleMoveSjOcrProcessing(displayId, attempt)
            }
            return
        }

        val now = SystemClock.elapsedRealtime()
        if (attempt == 1 && shouldSkipDuplicateOcr(candidate)) {
            logLockscreenMessage(
                "ocr_skip_duplicate_prefingerprint",
                extra =
                    mapOf(
                        "source" to "MoveSj",
                        "attempt" to attempt,
                        "lineCount" to candidate.lineCount,
                        "strongSignalCount" to candidate.strongSignalCount,
                    ),
            )
            return
        }
        val isSameOcrScreen = candidate.fingerprint.isNotBlank() &&
            candidate.fingerprint == lastOcrFingerprint
        if (
            attempt == 1 &&
            isSameOcrScreen &&
            now - lastOcrAtElapsed < minimumMoveSjOcrIntervalMs
        ) {
            logLockscreenMessage(
                "ocr_skip_cooldown",
                extra =
                    mapOf(
                        "source" to "MoveSj",
                        "elapsedSinceLastOcrMs" to (now - lastOcrAtElapsed),
                    ),
            )
            return
        }

        lastOcrAtElapsed = now
        markOcrFingerprint(candidate)
        val ocrToken =
            beginOcrRequest(
                extra =
                    mapOf(
                        "source" to "MoveSj",
                        "displayId" to displayId,
                        "attempt" to attempt,
                        "strongSignalCount" to candidate.strongSignalCount,
                    ),
            )

        val screenshotDisplayId = if (displayId >= 0) displayId else Display.DEFAULT_DISPLAY

        try {
            takeScreenshot(
                screenshotDisplayId,
                mainExecutor,
                object : TakeScreenshotCallback {
                    override fun onSuccess(screenshot: ScreenshotResult) {
                        logLockscreenMessage(
                            "ocr_screenshot_success",
                            extra = mapOf("ocrToken" to ocrToken, "source" to "MoveSj"),
                        )
                        val bitmap = screenshotToBitmap(screenshot)
                        if (bitmap == null) {
                            logLockscreenMessage(
                                "ocr_bitmap_null",
                                extra = mapOf("ocrToken" to ocrToken, "source" to "MoveSj"),
                            )
                            finishOcrRequest(ocrToken, "ocr_request_finished_bitmap_null")
                            scheduleMoveSjRetry(displayId, attempt, "bitmap_null")
                            return
                        }

                        runCatching {
                            runMoveSjOcr(
                                bitmap = bitmap,
                                displayId = displayId,
                                attempt = attempt,
                                ocrToken = ocrToken,
                            )
                        }.onFailure { error ->
                            runCatching { bitmap.recycle() }
                            logLockscreenMessage(
                                "ocr_start_failure",
                                extra =
                                    mapOf(
                                        "ocrToken" to ocrToken,
                                        "source" to "MoveSj",
                                        "message" to (error.message ?: error::class.java.simpleName),
                                    ),
                            )
                            finishOcrRequest(ocrToken, "ocr_request_finished_start_failure")
                            scheduleMoveSjRetry(displayId, attempt, "start_failure")
                        }
                    }

                    override fun onFailure(errorCode: Int) {
                        logLockscreenMessage(
                            "ocr_screenshot_failure",
                            extra =
                                mapOf(
                                    "ocrToken" to ocrToken,
                                    "source" to "MoveSj",
                                    "errorCode" to errorCode,
                                ),
                        )
                        finishOcrRequest(ocrToken, "ocr_request_finished_screenshot_failure")
                        scheduleMoveSjRetry(displayId, attempt, "screenshot_failure")
                    }
                },
            )
        } catch (error: Throwable) {
            logLockscreenMessage(
                "ocr_screenshot_request_throw",
                extra =
                    mapOf(
                        "ocrToken" to ocrToken,
                        "source" to "MoveSj",
                        "message" to (error.message ?: error::class.java.simpleName),
                    ),
            )
            finishOcrRequest(ocrToken, "ocr_request_finished_request_throw")
            scheduleMoveSjRetry(displayId, attempt, "request_throw")
        }
    }

    private fun requestNinetyNineOcr(
        displayId: Int,
        candidate: OcrScreenCandidate = buildOcrScreenCandidate("99"),
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            logLockscreenMessage("ocr_skip_sdk_too_old")
            return
        }

        if (ocrInFlight) {
            logLockscreenMessage("ocr_skip_in_flight", extra = mapOf("source" to "99"))
            return
        }

        val now = SystemClock.elapsedRealtime()
        if (shouldSkipDuplicateOcr(candidate)) {
            logLockscreenMessage(
                "ocr_skip_duplicate_prefingerprint",
                extra =
                    mapOf(
                        "source" to "99",
                        "lineCount" to candidate.lineCount,
                        "strongSignalCount" to candidate.strongSignalCount,
                    ),
            )
            return
        }
        val isSameOcrScreen = candidate.fingerprint.isNotBlank() &&
            candidate.fingerprint == lastOcrFingerprint
        if (isSameOcrScreen && now - lastOcrAtElapsed < minimumOcrIntervalMs) {
            logLockscreenMessage(
                "ocr_skip_cooldown",
                extra =
                    mapOf(
                        "source" to "99",
                        "elapsedSinceLastOcrMs" to (now - lastOcrAtElapsed),
                    ),
            )
            return
        }

        lastOcrAtElapsed = now
        markOcrFingerprint(candidate)
        val ocrToken =
            beginOcrRequest(
                extra =
                    mapOf(
                        "source" to "99",
                        "displayId" to displayId,
                        "strongSignalCount" to candidate.strongSignalCount,
                    ),
            )

        val screenshotDisplayId = if (displayId >= 0) displayId else Display.DEFAULT_DISPLAY

        try {
            takeScreenshot(
                screenshotDisplayId,
                mainExecutor,
                object : TakeScreenshotCallback {
                    override fun onSuccess(screenshot: ScreenshotResult) {
                        logLockscreenMessage(
                            "ocr_screenshot_success",
                            extra = mapOf("ocrToken" to ocrToken, "source" to "99"),
                        )
                        val bitmap = screenshotToBitmap(screenshot)
                        if (bitmap == null) {
                            logLockscreenMessage(
                                "ocr_bitmap_null",
                                extra = mapOf("ocrToken" to ocrToken, "source" to "99"),
                            )
                            finishOcrRequest(ocrToken, "ocr_request_finished_bitmap_null")
                            return
                        }

                        runCatching {
                            runNinetyNineOcr(bitmap, ocrToken)
                        }.onFailure { error ->
                            runCatching { bitmap.recycle() }
                            logLockscreenMessage(
                                "ocr_start_failure",
                                extra =
                                    mapOf(
                                        "ocrToken" to ocrToken,
                                        "source" to "99",
                                        "message" to (error.message ?: error::class.java.simpleName),
                                    ),
                            )
                            finishOcrRequest(ocrToken, "ocr_request_finished_start_failure")
                        }
                    }

                    override fun onFailure(errorCode: Int) {
                        logLockscreenMessage(
                            "ocr_screenshot_failure",
                            extra =
                                mapOf(
                                    "ocrToken" to ocrToken,
                                    "source" to "99",
                                    "errorCode" to errorCode,
                                ),
                        )
                        finishOcrRequest(ocrToken, "ocr_request_finished_screenshot_failure")
                    }
                },
            )
        } catch (error: Throwable) {
            logLockscreenMessage(
                "ocr_screenshot_request_throw",
                extra =
                    mapOf(
                        "ocrToken" to ocrToken,
                        "source" to "99",
                        "message" to (error.message ?: error::class.java.simpleName),
                    ),
            )
            finishOcrRequest(ocrToken, "ocr_request_finished_request_throw")
        }
    }

    private fun beginOcrRequest(extra: Map<String, Any?>): Int {
        activeOcrToken += 1
        val ocrToken = activeOcrToken
        ocrInFlight = true

        ocrWatchdogRunnable?.let(mainHandler::removeCallbacks)
        ocrWatchdogRunnable =
            Runnable {
                if (ocrInFlight && activeOcrToken == ocrToken) {
                    logLockscreenMessage(
                        "ocr_watchdog_timeout",
                        extra = extra + mapOf("ocrToken" to ocrToken),
                    )
                    ocrInFlight = false
                    ocrWatchdogRunnable = null
                }
            }.also { runnable ->
                mainHandler.postDelayed(runnable, ocrWatchdogTimeoutMs)
            }

        logLockscreenMessage(
            "ocr_request_start",
            extra = extra + mapOf("ocrToken" to ocrToken),
        )
        return ocrToken
    }

    private fun finishOcrRequest(
        ocrToken: Int,
        stage: String,
        extra: Map<String, Any?> = emptyMap(),
    ) {
        if (ocrToken != activeOcrToken) {
            logLockscreenMessage(
                "ocr_request_stale_finish",
                extra = extra + mapOf("ocrToken" to ocrToken, "activeOcrToken" to activeOcrToken),
            )
            return
        }

        ocrWatchdogRunnable?.let(mainHandler::removeCallbacks)
        ocrWatchdogRunnable = null
        ocrInFlight = false
        logLockscreenMessage(stage, extra = extra + mapOf("ocrToken" to ocrToken))
    }

    private fun scheduleMoveSjRetry(
        displayId: Int,
        attempt: Int,
        reason: String,
        extra: Map<String, Any?> = emptyMap(),
    ) {
        if (attempt >= maxMoveSjOcrAttempts) {
            logLockscreenMessage(
                "movesj_ocr_retry_exhausted",
                extra = extra + mapOf("attempt" to attempt, "reason" to reason),
            )
            return
        }
        if (!SettingsManager.shouldKeepRuntimeActive() || !SettingsManager.shouldShowTrafficLight()) {
            logLockscreenMessage(
                "movesj_ocr_retry_runtime_inactive",
                extra = extra + mapOf("attempt" to attempt, "reason" to reason),
            )
            return
        }

        logLockscreenMessage(
            "movesj_ocr_retry_scheduled",
            extra =
                extra +
                    mapOf(
                        "attempt" to attempt,
                        "nextAttempt" to (attempt + 1),
                        "reason" to reason,
                    ),
        )
        scheduleMoveSjOcrProcessing(displayId, attempt + 1)
    }

    private fun shouldRetryMoveSjParse(
        lines: List<String>,
        attempt: Int,
    ): Boolean {
        if (attempt >= maxMoveSjOcrAttempts) {
            return false
        }

        val normalized = lines.joinToString(" ").lowercase()
        return normalized.contains("r$") ||
            normalized.contains("aceitar") ||
            normalized.contains("recusar") ||
            normalized.contains("km") ||
            normalized.contains("min")
    }

    private fun runMoveSjOcr(
        bitmap: Bitmap,
        displayId: Int,
        attempt: Int,
        ocrToken: Int,
    ) {
        val image = InputImage.fromBitmap(bitmap, 0)
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

        recognizer
            .process(image)
            .addOnSuccessListener { visionText ->
                runCatching {
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
                                "ocrToken" to ocrToken,
                                "source" to "MoveSj",
                                "attempt" to attempt,
                                "lineCount" to lines.size,
                                "parsedOffer" to (offerData != null),
                            ),
                    )
                    if (offerData != null) {
                        logLockscreenMessage("ocr_offer_parsed", extra = offerLogSummary(offerData))
                        processOffer(offerData)
                    } else if (shouldRetryMoveSjParse(lines, attempt)) {
                        scheduleMoveSjRetry(
                            displayId = displayId,
                            attempt = attempt,
                            reason = "parse_incomplete",
                            extra = mapOf("lineCount" to lines.size),
                        )
                    } else {
                        restoreAppBubbleAfterRideOffer()
                    }
                }.onFailure { error ->
                    logLockscreenMessage(
                        "ocr_parse_failure",
                        extra =
                            mapOf(
                                "ocrToken" to ocrToken,
                                "source" to "MoveSj",
                                "attempt" to attempt,
                                "message" to (error.message ?: error::class.java.simpleName),
                            ),
                    )
                    scheduleMoveSjRetry(displayId, attempt, "parse_failure")
                }
            }
            .addOnFailureListener { error ->
                logLockscreenMessage(
                    "ocr_failure",
                    extra =
                        mapOf(
                            "ocrToken" to ocrToken,
                            "source" to "MoveSj",
                            "attempt" to attempt,
                            "message" to (error.message ?: ""),
                        ),
                )
                scheduleMoveSjRetry(displayId, attempt, "ocr_failure")
            }
            .addOnCompleteListener {
                runCatching { bitmap.recycle() }
                runCatching { recognizer.close() }
                finishOcrRequest(
                    ocrToken,
                    "ocr_request_complete",
                    mapOf("source" to "MoveSj", "attempt" to attempt),
                )
            }
    }

    private fun runNinetyNineOcr(
        bitmap: Bitmap,
        ocrToken: Int,
    ) {
        val croppedBitmap = cropOfferRegion(bitmap)
        bitmap.recycle()

        val image = InputImage.fromBitmap(croppedBitmap, 0)
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

        recognizer
            .process(image)
            .addOnSuccessListener { visionText ->
                runCatching {
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
                                "ocrToken" to ocrToken,
                                "source" to "99",
                                "lineCount" to lines.size,
                                "parsedOffer" to (offerData != null),
                            ),
                    )
                    if (offerData != null) {
                        logLockscreenMessage("ocr_offer_parsed", extra = offerLogSummary(offerData))
                        processOffer(offerData)
                    } else {
                        restoreAppBubbleAfterRideOffer()
                    }
                }.onFailure { error ->
                    logLockscreenMessage(
                        "ocr_parse_failure",
                        extra =
                            mapOf(
                                "ocrToken" to ocrToken,
                                "source" to "99",
                                "message" to (error.message ?: error::class.java.simpleName),
                            ),
                    )
                }
            }
            .addOnFailureListener { error ->
                logLockscreenMessage(
                    "ocr_failure",
                    extra =
                        mapOf(
                            "ocrToken" to ocrToken,
                            "source" to "99",
                            "message" to (error.message ?: ""),
                        ),
                )
            }
            .addOnCompleteListener {
                runCatching { croppedBitmap.recycle() }
                runCatching { recognizer.close() }
                finishOcrRequest(
                    ocrToken,
                    "ocr_request_complete",
                    mapOf("source" to "99"),
                )
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
        mainHandler.post {
            runCatching {
                val currentChannel = channel
                if (currentChannel == null) {
                    logLockscreenMessage("flutter_notify_channel_null", extra = offerLogSummary(data))
                    return@runCatching
                }

                currentChannel.invokeMethod("onRaceDetected", data)
                debugLog("MoveSj invokeMethod onRaceDetected summary=${offerLogSummary(data)}")
            }.onFailure { error ->
                logLockscreenMessage(
                    "flutter_notify_failure",
                    extra = mapOf("message" to (error.message ?: error::class.java.simpleName)),
                )
            }
        }
    }

    override fun onInterrupt() {
        pendingOverlayRunnable?.let(mainHandler::removeCallbacks)
        pendingMoveSjRunnable?.let(mainHandler::removeCallbacks)
        pendingNinetyNineRunnable?.let(mainHandler::removeCallbacks)
        ocrWatchdogRunnable?.let(mainHandler::removeCallbacks)
        pendingOverlayRunnable = null
        pendingMoveSjRunnable = null
        pendingNinetyNineRunnable = null
        ocrWatchdogRunnable = null
        ocrInFlight = false
        floatingOverlay?.hide()
        restoreAppBubbleAfterRideOffer()
        logLockscreenMessage("service_interrupt")
    }

    private fun hideAppBubbleForRideOffer() {
        AppBubbleService.hideForRideOffer(this)
    }

    private fun restoreAppBubbleAfterRideOffer() {
        AppBubbleService.restoreAfterRideOffer(this)
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
        debugLog("$lockLogPrefix stage=$stage ${extra.entries.joinToString(" ") { "${it.key}=${it.value}" }}")
    }

    private fun debugLog(message: String) {
        if (isDebugBuild()) {
            Log.d(logTag, message)
        }
    }

    private fun isDebugBuild(): Boolean {
        return (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
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
