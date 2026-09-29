package com.bobleverse
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class BibleVerseWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_bible_verse)
            views.setTextViewText(R.id.verse_text, VerseManager.getVerseOfDay(context))
            views.setTextViewText(R.id.coptic_date, CopticCalendar.getCopticDate())
            views.setTextViewText(R.id.synaxarium_text, "تذكار: " + VerseManager.getSynaxarium(context))
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}