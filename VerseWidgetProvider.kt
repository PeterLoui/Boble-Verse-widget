package com.example.bible_verse_widget

import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * الويدجت اللي بيتحط على الشاشة الرئيسية.
 * بيقرأ آخر آية اتخزنت من فلاتر (عن طريق home_widget) ويعرضها
 * على تصميم زجاجي شفاف (شوف res/drawable/widget_glass_background.xml).
 */
class VerseWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: android.appwidget.AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.verse_widget).apply {
                val verseText = widgetData.getString(
                    "verse_text",
                    "افتح التطبيق عشان تشوف آية اليوم"
                )
                val verseReference = widgetData.getString("verse_reference", "")

                setTextViewText(R.id.widget_verse_text, verseText)
                setTextViewText(R.id.widget_verse_reference, verseReference)

                // لما المستخدم يضغط على الويدجت، يفتح التطبيق
                setOnClickPendingIntent(
                    R.id.widget_root,
                    android.app.PendingIntent.getActivity(
                        context,
                        0,
                        context.packageManager.getLaunchIntentForPackage(context.packageName),
                        android.app.PendingIntent.FLAG_IMMUTABLE
                    )
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
