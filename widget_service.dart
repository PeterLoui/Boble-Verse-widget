import 'package:home_widget/home_widget.dart';
import '../models/verse.dart';

/// هذه القيم لازم تتطابق بالظبط مع اللي هنستخدمه في كود الأندرويد
/// (VerseWidgetProvider.kt) عشان الويدجت يقدر يقرأ البيانات.
class WidgetService {
  static const String appGroupId = 'group.com.example.bible_verse_widget';
  static const String androidWidgetName = 'VerseWidgetProvider';

  static const String keyVerseText = 'verse_text';
  static const String keyVerseReference = 'verse_reference';
  static const String keyLastUpdate = 'last_update';

  static Future<void> updateWidget(Verse verse) async {
    await HomeWidget.setAppGroupId(appGroupId);

    await HomeWidget.saveWidgetData<String>(keyVerseText, verse.text);
    await HomeWidget.saveWidgetData<String>(
        keyVerseReference, verse.reference);
    await HomeWidget.saveWidgetData<String>(
        keyLastUpdate, DateTime.now().toIso8601String());

    // يطلب من أندرويد يعيد رسم الويدجت فوراً بالبيانات الجديدة
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      androidName: androidWidgetName,
    );
  }
}
