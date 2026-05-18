package com.example.direcao_financeira_mobile

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val accessibilityChannelName = "com.direcao_financeira/accessibility"
    private val appBubbleChannelName = "com.direcao_financeira/app_bubble"
    private val appBubbleActionsChannelName = "com.direcao_financeira/app_bubble_actions"
    private val locationPermissionsChannelName = "com.direcao_financeira/location_permissions"
    private var backgroundLocationPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        SettingsManager.initialize(this)
        
        val accessibilityChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, accessibilityChannelName)
        ScreenReaderService.setMethodChannel(accessibilityChannel)
        
        accessibilityChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled(this, ScreenReaderService::class.java))
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "updateSettings" -> {
                    val settings = call.arguments as? Map<String, Any>
                    if (settings != null) {
                        SettingsManager.update(this, settings)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Settings data is null", null)
                    }
                }
                "updateRuntimeState" -> {
                    val state = call.arguments as? Map<String, Any>
                    if (state != null) {
                        SettingsManager.updateRuntimeState(
                            this,
                            trafficLightActive = state["traffic_light_active"] as? Boolean,
                            journeyActive = state["journey_active"] as? Boolean,
                        )
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Runtime state data is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appBubbleChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isOverlayPermissionGranted" -> {
                        result.success(Settings.canDrawOverlays(this))
                    }
                    "openOverlayPermissionSettings" -> {
                        startActivity(AppBubbleService.createOverlayPermissionIntent(this))
                        result.success(true)
                    }
                    "isBubbleRunning" -> {
                        result.success(AppBubbleService.isRunning())
                    }
                    "startBubble" -> {
                        if (!Settings.canDrawOverlays(this)) {
                            result.error(
                                "PERMISSION_DENIED",
                                "A permissao de sobreposicao nao foi concedida.",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        AppBubbleService.start(this)
                        result.success(true)
                    }
                    "stopBubble" -> {
                        AppBubbleService.stop(this)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, locationPermissionsChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openBackgroundLocationPermissionSettings" -> {
                        openBackgroundLocationPermissionSettings(result)
                    }
                    else -> result.notImplemented()
                }
            }

        AppBubbleActionBridge.attach(
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                appBubbleActionsChannelName,
            ),
        )
        AppBubbleService.startIfEnabled(this)
        handleAppBubbleIntent(intent, deliverImmediately = false)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_BACKGROUND_LOCATION_PERMISSION) {
            backgroundLocationPermissionResult?.success(true)
            backgroundLocationPermissionResult = null
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleAppBubbleIntent(intent, deliverImmediately = true)
    }

    private fun handleAppBubbleIntent(
        intent: Intent?,
        deliverImmediately: Boolean,
    ) {
        val rawAction = intent?.getStringExtra(AppBubbleService.EXTRA_BUBBLE_ACTION)
        if (rawAction.isNullOrBlank()) {
            return
        }

        val action =
            when (rawAction) {
                AppBubbleService.ACTION_OPEN_JOURNEY_SHIFTS -> "open_journey_shifts"
                AppBubbleService.ACTION_OPEN_JOURNEY_RIDES -> "open_journey_rides"
                AppBubbleService.ACTION_TOGGLE_TRAFFIC_LIGHT -> "toggle_traffic_light"
                else -> null
            }

        if (action != null) {
            val payload = mapOf("action" to action)
            if (deliverImmediately) {
                AppBubbleActionBridge.dispatch(payload)
            } else {
                AppBubbleActionBridge.setPending(payload)
            }
        }
        intent.removeExtra(AppBubbleService.EXTRA_BUBBLE_ACTION)
    }

    private fun isAccessibilityServiceEnabled(context: Context, service: Class<out android.accessibilityservice.AccessibilityService?>): Boolean {
        val expectedComponentName = android.content.ComponentName(context, service)
        val enabledServicesSetting = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
            ?: return false
        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)
        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledService = android.content.ComponentName.unflattenFromString(componentNameString)
            if (enabledService != null && enabledService == expectedComponentName) {
                return true
            }
        }
        return false
    }

    private fun openBackgroundLocationPermissionSettings(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.success(openAppDetailsSettings())
            return
        }

        if (!hasForegroundLocationPermission()) {
            result.success(openAppDetailsSettings())
            return
        }

        if (backgroundLocationPermissionResult != null) {
            result.error(
                "REQUEST_IN_PROGRESS",
                "Ja existe uma solicitacao de localizacao em andamento.",
                null,
            )
            return
        }

        backgroundLocationPermissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
            REQUEST_BACKGROUND_LOCATION_PERMISSION,
        )
    }

    private fun hasForegroundLocationPermission(): Boolean {
        val fineGranted =
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION,
            ) == PackageManager.PERMISSION_GRANTED
        val coarseGranted =
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_COARSE_LOCATION,
            ) == PackageManager.PERMISSION_GRANTED
        return fineGranted || coarseGranted
    }

    private fun openAppDetailsSettings(): Boolean {
        val intent =
            Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:$packageName"),
            ).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

        return runCatching {
            startActivity(intent)
            true
        }.getOrDefault(false)
    }

    companion object {
        private const val REQUEST_BACKGROUND_LOCATION_PERMISSION = 7301
    }
}

private object AppBubbleActionBridge {
    private var channel: MethodChannel? = null
    private var pendingPayload: Map<String, Any?>? = null

    fun attach(methodChannel: MethodChannel) {
        channel = methodChannel
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "consumePendingAction" -> {
                    result.success(pendingPayload)
                    pendingPayload = null
                }
                else -> result.notImplemented()
            }
        }
    }

    fun dispatch(payload: Map<String, Any?>) {
        val currentChannel = channel
        if (currentChannel == null) {
            pendingPayload = payload
            return
        }

        currentChannel.invokeMethod("onBubbleAction", payload)
    }

    fun setPending(payload: Map<String, Any?>) {
        pendingPayload = payload
    }
}
