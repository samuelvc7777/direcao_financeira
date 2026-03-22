package com.example.direcao_financeira_mobile

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.max
import kotlin.math.min

class FloatingOverlay(
    private val context: Context,
) {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var currentLayoutParams: WindowManager.LayoutParams? = null
    private var isShowing = false
    private val handler = Handler(Looper.getMainLooper())
    private var hideRunnable: Runnable? = null

    fun show(data: Map<String, Any>) {
        if (isShowing) {
            hide()
        }

        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val screenWidth = context.resources.displayMetrics.widthPixels
        val screenHeight = context.resources.displayMetrics.heightPixels
        val horizontalMargin = dpToPx(12f)
        val sidePosition =
            SettingsManager.position == 1 || SettingsManager.position == 2
        val cardWidth =
            min(
                screenWidth - (horizontalMargin * 2),
                if (sidePosition) dpToPx(260f) else dpToPx(340f),
            )
        val container = FrameLayout(context)
        val alpha = SettingsManager.opacity / 100f

        val card =
            LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                background =
                    GradientDrawable().apply {
                        setColor(Color.parseColor(resolveBackgroundColor()))
                        cornerRadius = dpToPx(20f).toFloat()
                        setStroke(dpToPx(2.5f), Color.parseColor(resolveStrokeColor()))
                    }
                this.alpha = alpha
                setPadding(dpToPx(16f), dpToPx(16f), dpToPx(16f), dpToPx(16f))
                layoutParams =
                    FrameLayout.LayoutParams(
                        cardWidth,
                        FrameLayout.LayoutParams.WRAP_CONTENT,
                    )
            }

        val valorBrutoText = data["valor_bruto"]?.toString() ?: "R$ 0,00"
        val valorBruto =
            valorBrutoText
                .replace(Regex("[^0-9,]"), "")
                .replace(",", ".")
                .toDoubleOrNull() ?: 0.0
        val kmTotal = (data["km_total"] as? Number)?.toDouble() ?: 0.0
        val minTotal = (data["minutos_total"] as? Number)?.toInt() ?: 0
        val motorista = data["motorista"]?.toString()?.takeIf { it.isNotBlank() } ?: "99"
        val avaliacao = data["avaliacao"]?.toString()?.takeIf { it.isNotBlank() } ?: "5,00"
        val corridasTotal = (data["corridas_total"] as? Number)?.toInt() ?: 0
        val perfilPassageiro = data["perfil_passageiro"]?.toString()?.takeIf { it.isNotBlank() }
        val tipoCorrida = data["tipo_corrida"]?.toString()?.takeIf { it.isNotBlank() }
        val formaPagamento = data["forma_pagamento"]?.toString()?.takeIf { it.isNotBlank() }

        val ganhoKm = if (kmTotal > 0) valorBruto / kmTotal else 0.0
        val ganhoHora = if (minTotal > 0) (valorBruto / minTotal) * 60 else 0.0

        val title =
            listOfNotNull(tipoCorrida, formaPagamento).takeIf { it.isNotEmpty() }
                ?.joinToString(" | ")
                ?: motorista

        card.addView(
            TextView(context).apply {
                text = title
                setTextColor(Color.parseColor(resolveSecondaryTextColor()))
                textSize = SettingsManager.fontSize - 3f
                typeface = Typeface.DEFAULT_BOLD
            },
        )

        val metaParts = mutableListOf<String>()
        metaParts.add(avaliacao.replace("\u2605", ""))
        if (corridasTotal > 0) {
            metaParts.add("$corridasTotal corridas")
        }
        perfilPassageiro?.let(metaParts::add)

        if (metaParts.isNotEmpty()) {
            card.addView(
                TextView(context).apply {
                    text = metaParts.joinToString(" | ")
                    setTextColor(Color.parseColor(resolveMutedTextColor()))
                    textSize = SettingsManager.fontSize - 4f
                    setPadding(0, dpToPx(4f), 0, 0)
                },
            )
        }

        card.addView(spacer(8f))

        val metricsRow =
            LinearLayout(context).apply {
                orientation =
                    if (sidePosition) LinearLayout.VERTICAL else LinearLayout.HORIZONTAL
                if (!sidePosition) {
                    weightSum =
                        SettingsManager.indicators.values.count { it }.toFloat().let {
                            if (it == 0f) 1f else it
                        }
                }
            }

        if (SettingsManager.indicators["R$/Km"] == true) {
            metricsRow.addView(
                createMetricView("R$/Km", String.format("%.2f", ganhoKm), sidePosition),
            )
        }
        if (SettingsManager.indicators["R$/Hora"] == true) {
            metricsRow.addView(
                createMetricView("R$/Hora", String.format("%.2f", ganhoHora), sidePosition),
            )
        }
        if (SettingsManager.indicators["Lucro/H"] == true) {
            metricsRow.addView(
                createMetricView("Lucro/H", String.format("%.2f", valorBruto), sidePosition),
            )
        }
        if (SettingsManager.indicators["Nota"] == true) {
            metricsRow.addView(
                createMetricView(
                    "Nota",
                    avaliacao.replace("\u2605", "").replace(",", "."),
                    sidePosition,
                ),
            )
        }

        card.addView(metricsRow)
        card.addView(spacer(12f))

        val footer =
            LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
            }

        footer.addView(createBadge(motorista))

        footer.addView(
            if (sidePosition) {
                LinearLayout(context).apply {
                    orientation = LinearLayout.VERTICAL
                    layoutParams =
                        LinearLayout.LayoutParams(
                            0,
                            LinearLayout.LayoutParams.WRAP_CONTENT,
                            1f,
                        )

                    addView(
                        TextView(context).apply {
                            text = "${minTotal}min"
                            setTextColor(Color.parseColor(resolvePrimaryTextColor()))
                            textSize = SettingsManager.fontSize
                            typeface = Typeface.DEFAULT_BOLD
                        },
                    )

                    addView(
                        TextView(context).apply {
                            text = "${String.format("%.1f", kmTotal)}km"
                            setTextColor(Color.parseColor(resolveSecondaryTextColor()))
                            textSize = SettingsManager.fontSize - 1f
                            typeface = Typeface.DEFAULT_BOLD
                        },
                    )
                }
            } else {
                TextView(context).apply {
                    text = "  ${minTotal}min | ${String.format("%.1f", kmTotal)}km"
                    setTextColor(Color.parseColor(resolvePrimaryTextColor()))
                    textSize = SettingsManager.fontSize
                    typeface = Typeface.DEFAULT_BOLD
                    layoutParams =
                        LinearLayout.LayoutParams(
                            0,
                            LinearLayout.LayoutParams.WRAP_CONTENT,
                            1f,
                        )
                }
            },
        )

        footer.addView(
            TextView(context).apply {
                text = "X"
                setTextColor(Color.parseColor(resolvePrimaryTextColor()))
                textSize = 18f
                setPadding(dpToPx(10f), dpToPx(10f), dpToPx(10f), dpToPx(10f))
                setOnClickListener { hide() }
            },
        )

        card.addView(footer)
        container.addView(card)
        overlayView = container

        attachDragBehavior(card)

        container.measure(
            View.MeasureSpec.makeMeasureSpec(screenWidth, View.MeasureSpec.AT_MOST),
            View.MeasureSpec.makeMeasureSpec(screenHeight, View.MeasureSpec.AT_MOST),
        )

        val overlayWidth = container.measuredWidth
        val overlayHeight = container.measuredHeight
        val initialPosition =
            resolveInitialPosition(
                screenWidth = screenWidth,
                screenHeight = screenHeight,
                overlayWidth = overlayWidth,
                overlayHeight = overlayHeight,
                margin = horizontalMargin,
            )

        val params =
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                x = initialPosition.first
                y = initialPosition.second
            }

        currentLayoutParams = params
        windowManager?.addView(overlayView, params)
        isShowing = true

        hideRunnable =
            Runnable {
                hide()
            }.also {
                handler.postDelayed(it, (SettingsManager.duration * 1000).toLong())
            }
    }

    private fun attachDragBehavior(view: View) {
        var startX = 0
        var startY = 0
        var touchStartX = 0f
        var touchStartY = 0f
        var hasMoved = false

        view.setOnTouchListener { touchedView, event ->
            val params = currentLayoutParams ?: return@setOnTouchListener false
            val overlay = overlayView ?: return@setOnTouchListener false
            val maxX = max(0, context.resources.displayMetrics.widthPixels - overlay.width)
            val maxY = max(0, context.resources.displayMetrics.heightPixels - overlay.height)

            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    startX = params.x
                    startY = params.y
                    touchStartX = event.rawX
                    touchStartY = event.rawY
                    hasMoved = false
                    true
                }

                MotionEvent.ACTION_MOVE -> {
                    val deltaX = (event.rawX - touchStartX).toInt()
                    val deltaY = (event.rawY - touchStartY).toInt()
                    hasMoved = hasMoved || deltaX != 0 || deltaY != 0

                    params.x = (startX + deltaX).coerceIn(0, maxX)
                    params.y = (startY + deltaY).coerceIn(0, maxY)
                    windowManager?.updateViewLayout(overlay, params)
                    true
                }

                MotionEvent.ACTION_UP,
                MotionEvent.ACTION_CANCEL -> {
                    if (hasMoved) {
                        SettingsManager.updateOverlayOffset(context, params.x, params.y)
                    } else {
                        touchedView.performClick()
                    }
                    true
                }

                else -> false
            }
        }
    }

    private fun createMetricView(
        label: String,
        value: String,
        stacked: Boolean,
    ): View {
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams =
                if (stacked) {
                    LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                    ).apply {
                        bottomMargin = dpToPx(6f)
                    }
                } else {
                    LinearLayout.LayoutParams(
                        0,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                        1f,
                    )
                }

            addView(
                TextView(context).apply {
                    text = label
                    setTextColor(Color.parseColor(resolveMutedTextColor()))
                    textSize = 10f
                },
            )

            val row =
                LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    gravity = Gravity.CENTER_VERTICAL
                    setPadding(0, dpToPx(4f), 0, 0)
                }

            row.addView(
                View(context).apply {
                    layoutParams = LinearLayout.LayoutParams(dpToPx(3f), dpToPx(20f))
                    setBackgroundColor(Color.parseColor(resolveAccentColor()))
                },
            )

            row.addView(
                TextView(context).apply {
                    text = " $value"
                    setTextColor(Color.parseColor(resolvePrimaryTextColor()))
                    textSize = SettingsManager.fontSize + 1f
                    typeface = Typeface.DEFAULT_BOLD
                    setPadding(dpToPx(6f), 0, 0, 0)
                },
            )

            addView(row)
        }
    }

    private fun createBadge(text: String): TextView {
        return TextView(context).apply {
            this.text = text
            setTextColor(Color.WHITE)
            textSize = 10f
            typeface = Typeface.DEFAULT_BOLD
            setPadding(dpToPx(6f), dpToPx(2f), dpToPx(6f), dpToPx(2f))
            background =
                GradientDrawable().apply {
                    setColor(Color.parseColor("#FF6D00"))
                    cornerRadius = dpToPx(4f).toFloat()
                }
        }
    }

    private fun spacer(heightDp: Float): View {
        return View(context).apply {
            layoutParams = LinearLayout.LayoutParams(1, dpToPx(heightDp))
        }
    }

    private fun resolveBackgroundColor(): String {
        return when (SettingsManager.theme) {
            0 -> "#FFFFFF"
            2 -> "#034D35"
            else -> "#121212"
        }
    }

    private fun resolveStrokeColor(): String {
        return if (SettingsManager.colorBlind) "#3498DB" else "#00C853"
    }

    private fun resolvePrimaryTextColor(): String {
        return if (SettingsManager.theme == 0) "#111111" else "#FFFFFF"
    }

    private fun resolveSecondaryTextColor(): String {
        return if (SettingsManager.theme == 0) "#80000000" else "#CCFFFFFF"
    }

    private fun resolveMutedTextColor(): String {
        return if (SettingsManager.theme == 0) "#66000000" else "#99FFFFFF"
    }

    private fun resolveAccentColor(): String {
        return if (SettingsManager.colorBlind) "#3498DB" else "#2ECC71"
    }

    private fun resolveInitialPosition(
        screenWidth: Int,
        screenHeight: Int,
        overlayWidth: Int,
        overlayHeight: Int,
        margin: Int,
    ): Pair<Int, Int> {
        if (SettingsManager.hasCustomPosition) {
            val customX = SettingsManager.overlayOffsetX.coerceIn(0, max(0, screenWidth - overlayWidth))
            val customY = SettingsManager.overlayOffsetY.coerceIn(0, max(0, screenHeight - overlayHeight))
            return customX to customY
        }

        val topY = dpToPx(40f)
        val centeredX = ((screenWidth - overlayWidth) / 2).coerceAtLeast(0)
        val centeredY = ((screenHeight - overlayHeight) / 2).coerceAtLeast(0)
        val rightX = (screenWidth - overlayWidth - margin).coerceAtLeast(0)
        val bottomY = (screenHeight - overlayHeight - dpToPx(40f)).coerceAtLeast(0)

        return when (SettingsManager.position) {
            1 -> margin to centeredY
            2 -> rightX to centeredY
            3 -> centeredX to bottomY
            else -> centeredX to topY
        }
    }

    private fun dpToPx(dp: Float): Int {
        return TypedValue
            .applyDimension(
                TypedValue.COMPLEX_UNIT_DIP,
                dp,
                context.resources.displayMetrics,
            ).toInt()
    }

    fun hide() {
        hideRunnable?.let(handler::removeCallbacks)
        hideRunnable = null

        if (isShowing && overlayView != null) {
            try {
                windowManager?.removeView(overlayView)
            } catch (_: Exception) {
            }
            isShowing = false
            overlayView = null
            currentLayoutParams = null
        }
    }
}
