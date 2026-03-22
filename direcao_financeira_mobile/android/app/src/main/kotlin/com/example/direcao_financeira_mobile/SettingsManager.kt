package com.example.direcao_financeira_mobile

import android.content.Context

object SettingsManager {
    private const val PREFS_NAME = "traffic_light_settings"
    private const val KEY_POSITION = "position"
    private const val KEY_OVERLAY_OFFSET_X = "overlay_offset_x"
    private const val KEY_OVERLAY_OFFSET_Y = "overlay_offset_y"
    private const val KEY_HAS_CUSTOM_POSITION = "overlay_has_custom_position"
    private const val KEY_THEME = "theme"
    private const val KEY_FONT_SIZE = "font_size"
    private const val KEY_OPACITY = "opacity"
    private const val KEY_DURATION = "duration"
    private const val KEY_COLOR_BLIND = "color_blind"
    private const val KEY_INDICATOR_R_KM = "indicator_r_km"
    private const val KEY_INDICATOR_R_HORA = "indicator_r_hora"
    private const val KEY_INDICATOR_LUCRO_H = "indicator_lucro_h"
    private const val KEY_INDICATOR_NOTA = "indicator_nota"
    private const val KEY_TRAFFIC_LIGHT_ACTIVE = "traffic_light_active"
    private const val KEY_JOURNEY_ACTIVE = "journey_active"

    var position: Int = 0
    var overlayOffsetX: Int = 0
    var overlayOffsetY: Int = 0
    var hasCustomPosition: Boolean = false
    var theme: Int = 1
    var fontSize: Float = 15f
    var opacity: Float = 100f
    var duration: Int = 10
    var colorBlind: Boolean = false
    var indicators: Map<String, Boolean> = mapOf(
        "R$/Km" to true,
        "R$/Hora" to true,
        "Lucro/H" to true,
        "Nota" to true
    )
    var trafficLightActive: Boolean = false
    var journeyActive: Boolean = false

    fun initialize(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        position = prefs.getInt(KEY_POSITION, position)
        overlayOffsetX = prefs.getInt(KEY_OVERLAY_OFFSET_X, overlayOffsetX)
        overlayOffsetY = prefs.getInt(KEY_OVERLAY_OFFSET_Y, overlayOffsetY)
        hasCustomPosition = prefs.getBoolean(KEY_HAS_CUSTOM_POSITION, hasCustomPosition)
        theme = prefs.getInt(KEY_THEME, theme)
        fontSize = prefs.getFloat(KEY_FONT_SIZE, fontSize)
        opacity = prefs.getFloat(KEY_OPACITY, opacity)
        duration = prefs.getInt(KEY_DURATION, duration)
        colorBlind = prefs.getBoolean(KEY_COLOR_BLIND, colorBlind)
        indicators = mapOf(
            "R$/Km" to prefs.getBoolean(KEY_INDICATOR_R_KM, true),
            "R$/Hora" to prefs.getBoolean(KEY_INDICATOR_R_HORA, true),
            "Lucro/H" to prefs.getBoolean(KEY_INDICATOR_LUCRO_H, true),
            "Nota" to prefs.getBoolean(KEY_INDICATOR_NOTA, true),
        )
        trafficLightActive = prefs.getBoolean(KEY_TRAFFIC_LIGHT_ACTIVE, false)
        journeyActive = prefs.getBoolean(KEY_JOURNEY_ACTIVE, false)
    }

    fun update(context: Context, data: Map<String, Any>) {
        val newPosition = (data["position"] as? Int) ?: position
        if (newPosition != position) {
            overlayOffsetX = 0
            overlayOffsetY = 0
            hasCustomPosition = false
        }

        position = newPosition
        theme = (data["theme"] as? Int) ?: 1
        fontSize = (data["font_size"] as? Double)?.toFloat() ?: 15f
        opacity = (data["opacity"] as? Double)?.toFloat() ?: 100f
        duration = (data["duration"] as? Double)?.toInt() ?: 10
        colorBlind = (data["color_blind"] as? Boolean) ?: false
        
        val rawIndicators = data["indicators"] as? Map<String, Boolean>
        if (rawIndicators != null) {
            indicators = rawIndicators
        }

        persist(context)
    }

    fun updateOverlayOffset(
        context: Context,
        x: Int,
        y: Int,
    ) {
        overlayOffsetX = x
        overlayOffsetY = y
        hasCustomPosition = true
        persist(context)
    }

    fun updateRuntimeState(
        context: Context,
        trafficLightActive: Boolean? = null,
        journeyActive: Boolean? = null,
    ) {
        if (trafficLightActive != null) {
            this.trafficLightActive = trafficLightActive
        }

        if (journeyActive != null) {
            this.journeyActive = journeyActive
        }

        persist(context)
    }

    fun shouldKeepRuntimeActive(): Boolean {
        return trafficLightActive || journeyActive
    }

    fun shouldShowTrafficLight(): Boolean {
        return trafficLightActive
    }

    private fun persist(context: Context) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putInt(KEY_POSITION, position)
            .putInt(KEY_OVERLAY_OFFSET_X, overlayOffsetX)
            .putInt(KEY_OVERLAY_OFFSET_Y, overlayOffsetY)
            .putBoolean(KEY_HAS_CUSTOM_POSITION, hasCustomPosition)
            .putInt(KEY_THEME, theme)
            .putFloat(KEY_FONT_SIZE, fontSize)
            .putFloat(KEY_OPACITY, opacity)
            .putInt(KEY_DURATION, duration)
            .putBoolean(KEY_COLOR_BLIND, colorBlind)
            .putBoolean(KEY_INDICATOR_R_KM, indicators["R$/Km"] == true)
            .putBoolean(KEY_INDICATOR_R_HORA, indicators["R$/Hora"] == true)
            .putBoolean(KEY_INDICATOR_LUCRO_H, indicators["Lucro/H"] == true)
            .putBoolean(KEY_INDICATOR_NOTA, indicators["Nota"] == true)
            .putBoolean(KEY_TRAFFIC_LIGHT_ACTIVE, trafficLightActive)
            .putBoolean(KEY_JOURNEY_ACTIVE, journeyActive)
            .apply()
    }
}
