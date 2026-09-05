import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../data/verses_repository.dart';
import '../models/verse.dart';

/// هذه القيم لازم تتطابق بالظبط مع اللي بنستخدمه في كود الأندرويد
/// (VerseWidgetProvider.kt) عشان الويدجت يقدر يقرأ البيانات.
class WidgetService {
  const WidgetService._();

  static const String appGroupId = 'group.com.example.bibleVerseWidget';

  /// لازم يطابق اسم الكلاس في android/app/src/main/kotlin/.../VerseWidgetProvider.kt
  static const String androidWidgetName = 'VerseWidgetProvider';
  static const String qualifiedAndroidName =
      'com.example.bible_verse_widget.VerseWidgetProvider';

  static const String keyVerseText = 'verse_text';
  static const String keyVerseReference = 'verse_reference';

  /// رقم اليوم اللي الآية المخزنة بتاعته. الويدجت بيستخدمه عشان يعرف
  /// إذا كانت الآية دي لسه بتاعة النهاردة ولا بقت قديمة.
  static const String keyVerseDay = 'verse_day';

  /// كل الآيات كـ JSON. دي اللي بتخلي الويدجت يقدر يجيب آية اليوم بنفسه
  /// من غير ما فلاتر تشتغل أصلاً.
  static const String keyVerses = 'verses_json';

  static const String keyLastUpdate = 'last_update';

  /// الـ plugin موجود على أندرويد و iOS بس. على أي منصة تانية (ويب/ديسكتوب)
  /// أي نداء هيرمي MissingPluginException، فبنتخطاه بدل ما التطبيق يقع.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// بيخزّن الآية المعروضة + القائمة الكاملة، ويطلب من أندرويد يعيد رسم الويدجت.
  ///
  /// تخزين القائمة هو سبب إن الويدجت بقى يجدّد نفسه: من غيرها الويدجت
  /// مكانش بيعرف غير الآية اللي فلاتر بعتتها آخر مرة، يعني كان بيفضل واقف
  /// على نفس الآية لحد ما المستخدم يفتح التطبيق تاني.
  ///
  /// أي فشل هنا (مثلاً الويدجت مش متضاف على الشاشة الرئيسية) مالهوش لازمة
  /// يوقّع التطبيق، فبنسجّله بس.
  static Future<void> updateWidget(Verse verse) async {
    if (!isSupported) return;

    try {
      await HomeWidget.setAppGroupId(appGroupId);

      await HomeWidget.saveWidgetData<String>(keyVerseText, verse.text);
      await HomeWidget.saveWidgetData<String>(
        keyVerseReference,
        verse.reference,
      );
      // بنخزّنه String مش int: الـ plugin بيعمل putInt للأرقام، وبعدين
      // getString من Kotlin هترمي ClassCastException.
      await HomeWidget.saveWidgetData<String>(
        keyVerseDay,
        VersesRepository.epochDay().toString(),
      );
      await HomeWidget.saveWidgetData<String>(
        keyVerses,
        await VersesRepository.encodedVerses(),
      );
      await HomeWidget.saveWidgetData<String>(
        keyLastUpdate,
        DateTime.now().toIso8601String(),
      );

      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        qualifiedAndroidName: qualifiedAndroidName,
      );
    } catch (error, stackTrace) {
      debugPrint('WidgetService.updateWidget failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
