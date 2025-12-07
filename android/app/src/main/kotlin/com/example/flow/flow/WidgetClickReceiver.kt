package com.example.flow.flow

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

/**
 * Explicit BroadcastReceiver for widget click events.
 * This is required for compatibility with Chinese ROM (vivo, OPPO, Xiaomi, etc.)
 * which block implicit broadcasts.
 */
class WidgetClickReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "WidgetClickReceiver"
        const val ACTION_WIDGET_CLICK = "com.example.flow.WIDGET_CLICK"
        const val ACTION_TOGGLE_TIMER = "com.example.flow.TOGGLE_TIMER"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive: action=${intent.action}")
        
        when (intent.action) {
            ACTION_TOGGLE_TIMER -> {
                Log.d(TAG, "Toggle timer clicked")
                // Trigger the home_widget background callback using the same mechanism
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("pomoflow://toggle")
                )
                try {
                    backgroundIntent.send()
                    Log.d(TAG, "Background intent sent successfully")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to send background intent", e)
                }
            }
            ACTION_WIDGET_CLICK -> {
                Log.d(TAG, "Widget clicked, opening app")
                // Open the main activity
                val appIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                try {
                    context.startActivity(appIntent)
                    Log.d(TAG, "MainActivity started successfully")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to start MainActivity", e)
                }
            }
        }
    }
}
