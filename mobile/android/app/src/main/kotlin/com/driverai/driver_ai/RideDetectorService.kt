package com.driverai.driver_ai

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log

/**
 * Accessibility Service for detecting ride offers on Uber, 99, InDrive
 * 
 * This service monitors the screen for ride information and extracts:
 * - Ride value (R$)
 * - Distance (km)
 * - Duration (min)
 * - Origin and destination addresses
 */
class RideDetectorService : AccessibilityService() {

    companion object {
        private const val TAG = "RideDetector"
        
        // Package names for ride-hailing apps
        private val MONITORED_PACKAGES = setOf(
            "com.ubercab.driver",           // Uber Driver
            "com.ninety_nine.driver",       // 99 Driver
            "sinet.startup.inDriver"        // InDrive
        )
        
        // Patterns for detecting ride values
        private val VALUE_PATTERN = Regex("""R\$\s*(\d+[.,]\d{2})""")
        private val DISTANCE_PATTERN = Regex("""(\d+[.,]?\d*)\s*(km|quilômetros)""", RegexOption.IGNORE_CASE)
        private val DURATION_PATTERN = Regex("""(\d+)\s*(min|minutos?)""", RegexOption.IGNORE_CASE)
    }

    private var overlayManager: OverlayManager? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.i(TAG, "RideDetectorService connected")

        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                         AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            notificationTimeout = 300
            packageNames = MONITORED_PACKAGES.toTypedArray()
        }
        serviceInfo = info

        overlayManager = OverlayManager(this)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        
        val packageName = event.packageName?.toString() ?: return
        if (packageName !in MONITORED_PACKAGES) return

        val source = event.source ?: return
        
        try {
            val screenText = extractAllText(source)
            val rideData = parseRideData(screenText, packageName)
            
            if (rideData != null) {
                Log.d(TAG, "Ride detected: $rideData")
                analyzeAndShowOverlay(rideData)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error processing event", e)
        } finally {
            source.recycle()
        }
    }

    override fun onInterrupt() {
        Log.w(TAG, "RideDetectorService interrupted")
    }

    override fun onDestroy() {
        overlayManager?.dismiss()
        super.onDestroy()
    }

    /**
     * Recursively extracts all text from the accessibility node tree
     */
    private fun extractAllText(node: AccessibilityNodeInfo, depth: Int = 0): String {
        val builder = StringBuilder()
        
        node.text?.let { builder.append(it).append(" ") }
        node.contentDescription?.let { builder.append(it).append(" ") }
        
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            if (depth < 15) {
                builder.append(extractAllText(child, depth + 1))
            }
            child.recycle()
        }
        
        return builder.toString()
    }

    /**
     * Parses ride data from the extracted screen text
     */
    private fun parseRideData(text: String, packageName: String): RideData? {
        val valueMatch = VALUE_PATTERN.find(text)
        val distanceMatch = DISTANCE_PATTERN.find(text)
        
        if (valueMatch == null) return null
        
        val value = valueMatch.groupValues[1].replace(",", ".").toDoubleOrNull() ?: return null
        val distance = distanceMatch?.groupValues?.get(1)?.replace(",", ".")?.toDoubleOrNull()
        val durationMatch = DURATION_PATTERN.find(text)
        val duration = durationMatch?.groupValues?.get(1)?.toIntOrNull()
        
        val platform = when (packageName) {
            "com.ubercab.driver" -> "Uber"
            "com.ninety_nine.driver" -> "99"
            "sinet.startup.inDriver" -> "InDrive"
            else -> "Unknown"
        }

        return RideData(
            value = value,
            distance = distance ?: 0.0,
            duration = duration,
            platform = platform
        )
    }

    /**
     * Analyzes ride and shows floating overlay
     */
    private fun analyzeAndShowOverlay(rideData: RideData) {
        // Get stored vehicle data (cost per km)
        val prefs = getSharedPreferences("driver_ai_prefs", MODE_PRIVATE)
        val costPerKm = prefs.getFloat("cost_per_km", 0.49f).toDouble()
        val goalTarget = prefs.getFloat("daily_goal", 280f).toDouble()
        val goalCurrent = prefs.getFloat("daily_current", 0f).toDouble()

        val valuePerKm = if (rideData.distance > 0) rideData.value / rideData.distance else 0.0
        val fuelCost = costPerKm * rideData.distance
        val estimatedProfit = rideData.value - fuelCost
        
        val profitRatio = if (costPerKm > 0) valuePerKm / costPerKm else 0.0
        val compensa = profitRatio >= 1.5
        
        val rating = when {
            profitRatio >= 3.0 -> "EXCELENTE"
            profitRatio >= 2.0 -> "BOA"
            profitRatio >= 1.2 -> "MÉDIA"
            else -> "RUIM"
        }

        overlayManager?.show(
            valuePerKm = valuePerKm,
            estimatedProfit = estimatedProfit,
            compensa = compensa,
            rating = rating,
            rideValue = rideData.value,
            distance = rideData.distance,
            platform = rideData.platform
        )
    }
}

data class RideData(
    val value: Double,
    val distance: Double,
    val duration: Int?,
    val platform: String,
    val origin: String? = null,
    val destination: String? = null
)
