# ---------------------------------------------------------------------------
# Room / WorkManager
#
# home_widget بيجرّ معاه androidx.work، وde بيستخدم Room. و Room بيلاقي الكلاس
# المولّد بتاعه (WorkDatabase_Impl) عن طريق Class.forName، يعني R8 في الـ full
# mode بيشيله أو بيغيّر اسمه، فالتطبيق بيقع أول ما يفتح في الـ release:
#   Failed to create an instance of androidx.work.impl.WorkDatabase
# ---------------------------------------------------------------------------
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep @androidx.room.Database class * { *; }
-dontwarn androidx.room.paging.**

# ---------------------------------------------------------------------------
# ويدجت الشاشة الرئيسية
#
# home_widget بيعمل Class.forName على اسم الـ AppWidgetProvider اللي بنبعته من
# Dart (qualifiedAndroidName)، فلازم الاسم يفضل زي ما هو من غير obfuscation.
# ---------------------------------------------------------------------------
-keep class * extends android.appwidget.AppWidgetProvider { *; }
-keep class es.antonborri.home_widget.** { *; }
