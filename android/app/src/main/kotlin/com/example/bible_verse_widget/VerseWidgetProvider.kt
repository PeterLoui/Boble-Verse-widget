package com.example.bible_verse_widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.util.Calendar

/**
 * الويدجت اللي بيتحط على الشاشة الرئيسية.
 *
 * الويدجت بيحسب آية اليوم بنفسه من القائمة اللي فلاتر خزّنتها، فمش محتاج
 * التطبيق يفضل يفتح عشان الآية تتغيّر. النظام بينده onUpdate كل
 * updatePeriodMillis (شوف res/xml/verse_widget_info.xml) فالآية بتتقلب
 * لوحدها مع بداية كل يوم.
 */
class VerseWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val verse = resolveVerse(widgetData)
        val verseText = verse?.first?.takeIf { it.isNotBlank() }
            ?: context.getString(R.string.widget_placeholder)
        val verseReference = verse?.second.orEmpty()

        // لما المستخدم يضغط على الويدجت، يفتح التطبيق.
        //
        // مش بنستخدم HomeWidgetLaunchIntent.getActivity هنا: في home_widget 0.6.0
        // بيحطّ pendingIntentBackgroundActivityStartMode على الـ ActivityOptions،
        // وده أندرويد 35+ بيرفضه بـ IllegalArgumentException وبيقع الـ receiver.
        // بنبني الـ PendingIntent بنفسنا، ومحتفظين بنفس الـ action عشان
        // HomeWidget.initiallyLaunchedFromHomeWidget() تفضل شغالة.
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.verse_widget).apply {
                setTextViewText(R.id.widget_verse_text, verseText)
                setTextViewText(R.id.widget_verse_reference, verseReference)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /** يرجّع (نص الآية، الشاهد) أو null لو مفيش أي بيانات لسه. */
    private fun resolveVerse(data: SharedPreferences): Pair<String, String>? {
        val today = todayEpochDay()

        // 1) لو المخزّن بتاع النهاردة، نعرضه زي ما هو. كده لو المستخدم ضغط
        //    "آية جديدة" جوه التطبيق، اختياره بيفضل ظاهر على الويدجت لحد بكرة.
        val storedDay = data.getString(KEY_VERSE_DAY, null)?.toLongOrNull()
        if (storedDay == today) {
            storedVerse(data)?.let { return it }
        }

        // 2) غير كده نحسب آية النهاردة من القائمة المخزّنة.
        verseForDay(data, today)?.let { return it }

        // 3) آخر حل: آخر آية اتخزنت أيًا كان يومها (مثلاً القائمة لسه ما اتخزنتش
        //    لأن المستخدم لسه على نسخة قديمة من التطبيق).
        return storedVerse(data)
    }

    private fun storedVerse(data: SharedPreferences): Pair<String, String>? {
        val text = data.getString(KEY_VERSE_TEXT, null)
        if (text.isNullOrBlank()) return null
        return text to data.getString(KEY_VERSE_REFERENCE, "").orEmpty()
    }

    private fun verseForDay(data: SharedPreferences, day: Long): Pair<String, String>? {
        val raw = data.getString(KEY_VERSES, null)
        if (raw.isNullOrBlank()) return null

        return try {
            val verses = JSONArray(raw)
            if (verses.length() == 0) return null
            val verse = verses.getJSONObject(indexForDay(day, verses.length()))
            val text = verse.optString("text")
            if (text.isBlank()) null else text to verse.optString("reference")
        } catch (error: Exception) {
            // بيانات بايظة مش سبب إن الويدجت يقع — نرجع null ونسيب الـ fallback يشتغل.
            Log.w(TAG, "Could not read the stored verses list", error)
            null
        }
    }

    private companion object {
        private const val TAG = "VerseWidgetProvider"

        // لازم تطابق المفاتيح في lib/services/widget_service.dart
        const val KEY_VERSE_TEXT = "verse_text"
        const val KEY_VERSE_REFERENCE = "verse_reference"
        const val KEY_VERSE_DAY = "verse_day"
        const val KEY_VERSES = "verses_json"

        /** عدد الأيام من 1970-01-01 بالتاريخ المحلي للجهاز. */
        fun todayEpochDay(): Long {
            val calendar = Calendar.getInstance()
            return daysFromCivil(
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH) + 1,
                calendar.get(Calendar.DAY_OF_MONTH)
            )
        }

        /**
         * ⚠️ لازم تفضل مطابقة حرفيًا لـ `VersesRepository.indexForDay` في
         * lib/data/verses_repository.dart، وإلا التطبيق والويدجت هيعرضوا
         * آيتين مختلفتين في نفس اليوم.
         */
        fun indexForDay(epochDay: Long, count: Int): Int {
            val hashed = (epochDay * 2654435761L) and 0x7FFFFFFFL
            return (hashed % count).toInt()
        }

        /**
         * خوارزمية days_from_civil المعروفة. بنستخدمها بدل java.time.LocalDate
         * لأن java.time محتاجة API 26 والـ minSdk هنا 24.
         */
        fun daysFromCivil(year: Int, month: Int, day: Int): Long {
            var y = year.toLong()
            if (month <= 2) y -= 1
            val era = (if (y >= 0) y else y - 399) / 400
            val yoe = y - era * 400
            val doy = (153 * (month + (if (month > 2) -3 else 9)) + 2) / 5 + day - 1
            val doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
            return era * 146097 + doe - 719468
        }
    }
}
