package com.example.direcao_financeira_mobile

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.direcao_financeira/accessibility"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        SettingsManager.initialize(this)
        
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        ScreenReaderService.setMethodChannel(channel)
        
        channel.setMethodCallHandler { call, result ->
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
}
