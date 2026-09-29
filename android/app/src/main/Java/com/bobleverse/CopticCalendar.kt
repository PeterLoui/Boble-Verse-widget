package com.bobleverse

import java.util.Calendar

object CopticCalendar {
    private val copticMonths = arrayOf(
        "توت", "بابه", "هاتور", "كيهك", "طوبة", "أمشير",
        "برمهات", "برمودة", "بشنس", "بؤونة", "أبيب", "مسرى", "نسيء"
    )

    fun getCopticDate(): String {
        val cal = Calendar.getInstance()
        val gYear = cal.get(Calendar.YEAR)
        val gMonth = cal.get(Calendar.MONTH) + 1
        val gDay = cal.get(Calendar.DAY_OF_MONTH)
        
        // معادلة تحويل مبسطة ودقيقة
        val julianDay = (1461 * (gYear + 4800 + (gMonth - 14)/12))/4 + (367 * (gMonth - 2 - 12 * ((gMonth - 14)/12)))/12 - (3 * ((gYear + 4900 + (gMonth - 14)/12)/100))/4 + gDay - 32075
        val copticDayNumber = julianDay - 1824665 // بداية التقويم القبطي
        var copticYear = copticDayNumber / 365
        var dayOfYear = copticDayNumber % 365
        if (dayOfYear < 0) { copticYear--; dayOfYear += 365 }
        
        val month = dayOfYear / 30
        val day = dayOfYear % 30 + 1
        val year = copticYear + 284 // سنة الشهداء
        
        return "$day ${copticMonths[month]} $year"
    }
}