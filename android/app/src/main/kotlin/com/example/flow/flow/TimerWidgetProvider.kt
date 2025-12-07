package com.example.flow.flow

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.example.flow.flow.R

class TimerWidgetProvider : HomeWidgetProvider() {
    companion object {
        private const val TAG = "TimerWidgetProvider"
        // Cache only time and progress to detect changes
        private val widgetCache = mutableMapOf<Int, WidgetCache>()
    }
    
    data class WidgetCache(
        val time: String,
        val progress: Int
    )
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        Log.d(TAG, "onUpdate called for ${appWidgetIds.size} widgets")
        
        appWidgetIds.forEach { widgetId ->
            try {
                updateWidget(context, appWidgetManager, widgetId, widgetData)
            } catch (e: Exception) {
                Log.e(TAG, "Error updating widget $widgetId", e)
            }
        }
    }
    
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "Widget enabled, clearing cache")
        widgetCache.clear()
    }
    
    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        appWidgetIds.forEach { widgetId ->
            widgetCache.remove(widgetId)
            Log.d(TAG, "Widget $widgetId deleted, removed from cache")
        }
    }
    
    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: SharedPreferences
    ) {
        // --- Data Retrieval ---
        val isRunning = widgetData.getBoolean("isRunning", false)
        val status = widgetData.getString("status", "Focusing") ?: "Focusing"
        
        // Determine display time based on running state
        val time = if (isRunning) {
            // Running: show current countdown time
            widgetData.getString("time", "25:00") ?: "25:00"
        } else {
            // Not running: show initial time based on mode
            val focusMinutes = widgetData.getInt("focusMinutes", 25)
            val shortBreakMinutes = widgetData.getInt("shortBreakMinutes", 5)
            val longBreakMinutes = widgetData.getInt("longBreakMinutes", 15)
            
            val minutes = when (status) {
                "Break" -> shortBreakMinutes
                "Long Break" -> longBreakMinutes
                else -> focusMinutes
            }
            String.format("%02d:00", minutes)
        }
        
        val progress = if (isRunning) {
            widgetData.getInt("progress", 100)
        } else {
            100 // Full progress when not running
        }
        
        // Style Data
        val contentColor = getColorFromPrefs(widgetData, "contentColor", Color.WHITE)
        val backgroundColor = getColorFromPrefs(widgetData, "backgroundColor", 0xFF2196F3.toInt())
        val backgroundType = widgetData.getString("backgroundType", "default") ?: "default"
        
        // Check cache to see if we need to update
        val cachedData = widgetCache[widgetId]
        val isFirstUpdate = cachedData == null
        val timeChanged = cachedData?.time != time
        val progressChanged = cachedData?.progress != progress
        
        if (!isFirstUpdate && !timeChanged && !progressChanged) {
            Log.d(TAG, "Widget $widgetId: No changes in time/progress, skipping update")
            return
        }
        
        Log.d(TAG, "Updating widget $widgetId: time=$time, progress=$progress, isRunning=$isRunning, status=$status")
        
        // Create RemoteViews for partial update
        val views = RemoteViews(context.packageName, R.layout.widget_layout)
        
        // Update time if changed
        if (isFirstUpdate || timeChanged) {
            views.setTextViewText(R.id.timer_display, time)
            views.setTextColor(R.id.timer_display, contentColor)
            Log.d(TAG, "Widget $widgetId: Updated time to $time")
        }
        
        // Update progress if changed
        if (isFirstUpdate || progressChanged) {
            views.setProgressBar(R.id.widget_progress_bar, 100, progress, false)
            Log.d(TAG, "Widget $widgetId: Updated progress to $progress")
        }
        
        // Apply content color to chronometer
        views.setTextColor(R.id.timer_display, contentColor)
        
        // --- Update Progress Bar ---
        views.setProgressBar(R.id.widget_progress_bar, 100, progress, false)
        
        // --- Background ---
        if (backgroundType == "color") {
            views.setInt(R.id.widget_background_layer, "setColorFilter", backgroundColor)
        } else {
            views.setInt(R.id.widget_background_layer, "setColorFilter", 0)
        }
        
        // --- Click Handler: Open App ---
        // Entire widget opens the app when clicked
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val openAppPendingIntent = PendingIntent.getActivity(
            context,
            widgetId,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, openAppPendingIntent)
        
        // Use partiallyUpdateAppWidget to avoid UI flicker
        appWidgetManager.partiallyUpdateAppWidget(widgetId, views)
        
        // Update cache
        widgetCache[widgetId] = WidgetCache(time, progress)
        
        Log.d(TAG, "Widget $widgetId updated successfully (partial update)")
    }
    
    private fun getColorFromPrefs(prefs: SharedPreferences, key: String, defaultVal: Int): Int {
        return try {
            prefs.getInt(key, defaultVal)
        } catch (e: Exception) {
            try {
                prefs.getLong(key, defaultVal.toLong()).toInt()
            } catch (e2: Exception) {
                defaultVal
            }
        }
    }
}
