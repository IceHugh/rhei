package com.example.flow.flow

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * BootReceiver handles system events that require widget PendingIntent re-registration.
 * This is critical for Android 15 compatibility where PendingIntents are cancelled
 * when the app enters a "stopped" state.
 */
class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BootReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Received broadcast: ${intent.action}")
        
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                // Re-register all widget PendingIntents
                updateAllWidgets(context)
            }
        }
    }
    
    private fun updateAllWidgets(context: Context) {
        try {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, TimerWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            Log.d(TAG, "Updating ${appWidgetIds.size} widgets after system event")
            
            if (appWidgetIds.isNotEmpty()) {
                // Trigger widget update to re-register PendingIntents
                val updateIntent = Intent(context, TimerWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                }
                context.sendBroadcast(updateIntent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widgets", e)
        }
    }
}
