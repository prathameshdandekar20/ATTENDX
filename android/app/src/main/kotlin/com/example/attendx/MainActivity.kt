package com.example.attendx

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableHighRefreshRate()
    }

    override fun onResume() {
        super.onResume()
        enableHighRefreshRate()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        enableHighRefreshRate()
    }

    private fun enableHighRefreshRate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val currentDisplay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    display
                } else {
                    @Suppress("DEPRECATION")
                    windowManager.defaultDisplay
                }

                currentDisplay?.supportedModes?.let { modes ->
                    val highestMode = modes.maxByOrNull { it.refreshRate }
                    if (highestMode != null && highestMode.refreshRate > 60f) {
                        val layoutParams = window.attributes
                        layoutParams.preferredDisplayModeId = highestMode.modeId
                        window.attributes = layoutParams
                    }
                }
            } catch (e: Exception) {
                // Fallback gracefully on devices that restrict display mode changes
            }
        }
    }
}
