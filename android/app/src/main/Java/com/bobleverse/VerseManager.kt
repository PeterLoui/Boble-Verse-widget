package com.bobleverse
import android.content.Context
import org.json.JSONArray
import java.util.Calendar

object VerseManager {
    fun getVerseOfDay(context: Context): String {
        val jsonString = context.assets.open("verses.json").bufferedReader().use { it.readText() }
        val verses = JSONArray(jsonString)
        val dayOfYear = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
        val index = dayOfYear % verses.length()
        val obj = verses.getJSONObject(index)
        return "${obj.getString("text")} - ${obj.getString("ref")}"
    }
    
    fun getSynaxarium(context: Context): String {
        val copticDate = CopticCalendar.getCopticDate() // مثال: 10 بؤونة
        val parts = copticDate.split(" ")
        val key = "${parts[0]} ${parts[1]}"
        val jsonString = context.assets.open("synaxarium.json").bufferedReader().use { it.readText() }
        val synax = org.json.JSONObject(jsonString)
        return if(synax.has(key)) synax.getString(key) else "لا يوجد تذكار مميز اليوم"
    }
}