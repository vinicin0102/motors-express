package com.driverai.driver_ai

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.view.animation.AnimationUtils
import android.view.animation.AlphaAnimation
import android.view.animation.TranslateAnimation
import android.graphics.drawable.GradientDrawable
import android.graphics.Color
import android.util.TypedValue

/**
 * Manages the floating overlay that shows ride analysis results.
 * 
 * The overlay appears on top of other apps (Uber, 99, InDrive)
 * and shows whether the ride is worth accepting.
 */
class OverlayManager(private val context: Context) {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isShowing = false

    init {
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    fun show(
        valuePerKm: Double,
        estimatedProfit: Double,
        compensa: Boolean,
        rating: String,
        rideValue: Double,
        distance: Double,
        platform: String
    ) {
        dismiss() // Remove existing overlay

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            y = dpToPx(80)
        }

        overlayView = createOverlayView(valuePerKm, estimatedProfit, compensa, rating, rideValue, distance, platform)

        try {
            windowManager?.addView(overlayView, params)
            isShowing = true
            
            // Animate in
            val fadeIn = AlphaAnimation(0f, 1f).apply { duration = 300 }
            val slideIn = TranslateAnimation(0f, 0f, -100f, 0f).apply { duration = 300 }
            overlayView?.startAnimation(fadeIn)

            // Auto dismiss after 15 seconds
            overlayView?.postDelayed({ dismiss() }, 15000)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun dismiss() {
        if (isShowing && overlayView != null) {
            try {
                val fadeOut = AlphaAnimation(1f, 0f).apply { duration = 200 }
                overlayView?.startAnimation(fadeOut)
                overlayView?.postDelayed({
                    try {
                        windowManager?.removeView(overlayView)
                    } catch (e: Exception) { }
                    overlayView = null
                    isShowing = false
                }, 200)
            } catch (e: Exception) {
                overlayView = null
                isShowing = false
            }
        }
    }

    private fun createOverlayView(
        valuePerKm: Double,
        estimatedProfit: Double,
        compensa: Boolean,
        rating: String,
        rideValue: Double,
        distance: Double,
        platform: String
    ): View {
        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpToPx(16), dpToPx(12), dpToPx(16), dpToPx(12))

            // Background with glassmorphism effect
            val bgDrawable = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(20).toFloat()
                if (compensa) {
                    setColor(Color.parseColor("#1A1F3A"))
                    setStroke(dpToPx(2), Color.parseColor("#00E676"))
                } else {
                    setColor(Color.parseColor("#1A1F3A"))
                    setStroke(dpToPx(2), Color.parseColor("#FF5252"))
                }
            }
            background = bgDrawable
            elevation = dpToPx(8).toFloat()
        }

        val marginParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            setMargins(dpToPx(16), 0, dpToPx(16), 0)
        }
        container.layoutParams = marginParams

        // Platform + Close button row
        val headerRow = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val platformText = TextView(context).apply {
            text = "🚗 $platform"
            setTextColor(Color.parseColor("#B0B8D1"))
            textSize = 12f
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }
        headerRow.addView(platformText)

        val closeBtn = TextView(context).apply {
            text = "✕"
            setTextColor(Color.parseColor("#6B7394"))
            textSize = 16f
            setPadding(dpToPx(8), 0, 0, 0)
            setOnClickListener { dismiss() }
        }
        headerRow.addView(closeBtn)
        container.addView(headerRow)

        // Main value per km
        val mainValue = TextView(context).apply {
            text = "💰 R\$ ${"%.2f".format(valuePerKm)}/km"
            setTextColor(Color.WHITE)
            textSize = 22f
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, dpToPx(8), 0, dpToPx(4))
        }
        container.addView(mainValue)

        // Profit line
        val profitText = TextView(context).apply {
            text = "⛽ Lucro estimado: R\$ ${"%.2f".format(estimatedProfit)}"
            setTextColor(if (estimatedProfit > 0) Color.parseColor("#00E676") else Color.parseColor("#FF5252"))
            textSize = 14f
            setPadding(0, 0, 0, dpToPx(8))
        }
        container.addView(profitText)

        // Rating badge
        val ratingRow = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val emoji = when (rating) {
            "EXCELENTE", "BOA" -> "🟢"
            "MÉDIA" -> "🟡"
            else -> "🔴"
        }

        val ratingBadge = TextView(context).apply {
            text = if (compensa) "$emoji COMPENSA" else "$emoji NÃO COMPENSA"
            val badgeBg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(8).toFloat()
                if (compensa) setColor(Color.parseColor("#1B5E20")) else setColor(Color.parseColor("#B71C1C"))
            }
            background = badgeBg
            setTextColor(Color.WHITE)
            textSize = 14f
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(dpToPx(12), dpToPx(6), dpToPx(12), dpToPx(6))
        }
        ratingRow.addView(ratingBadge)

        // Details
        val detailText = TextView(context).apply {
            text = "  R\$ ${"%.2f".format(rideValue)} • ${"%.1f".format(distance)}km"
            setTextColor(Color.parseColor("#6B7394"))
            textSize = 12f
        }
        ratingRow.addView(detailText)

        container.addView(ratingRow)

        return FrameLayout(context).apply { addView(container) }
    }

    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            context.resources.displayMetrics
        ).toInt()
    }
}
