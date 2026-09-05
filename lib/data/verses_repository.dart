import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/verse.dart';

class VersesRepository {
  const VersesRepository._();

  static const String assetPath = 'assets/verses.json';

  static List<Verse>? _cache;

  /// يقرأ كل الآيات من الـ asset مرة واحدة بس ويحتفظ بيها في الذاكرة.
  static Future<List<Verse>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(assetPath);
    final decoded = json.decode(raw);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array in $assetPath');
    }

    final verses = decoded
        .whereType<Map<String, dynamic>>()
        .map(Verse.fromJson)
        .where((verse) => verse.text.isNotEmpty)
        .toList(growable: false);

    if (verses.isEmpty) {
      throw StateError('$assetPath does not contain any usable verses.');
    }

    return _cache = verses;
  }

  /// القائمة اللي بنبعتها للويدجت.
  ///
  /// بنعيد ترميزها من [loadAll] مش من ملف الـ asset الخام عن قصد: كده الترتيب
  /// والعدد اللي بيشوفهم Kotlin هما بالظبط اللي بيشوفهم Dart (بعد استبعاد أي
  /// عنصر ناقص)، وبالتالي نفس الـ index بيدي نفس الآية في الاتنين.
  static Future<String> encodedVerses() async {
    final verses = await loadAll();
    return json.encode(verses.map((verse) => verse.toJson()).toList());
  }

  /// عدد الأيام من 1970-01-01، محسوبة بالتاريخ المحلي للمستخدم.
  static int epochDay([DateTime? now]) {
    final date = now ?? DateTime.now();
    return DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(1970, 1, 1))
        .inDays;
  }

  /// بيحوّل رقم اليوم لـ index ثابت داخل القائمة.
  ///
  /// ⚠️ لازم تفضل مطابقة حرفيًا لـ `indexForDay` في
  /// android/app/src/main/kotlin/.../VerseWidgetProvider.kt — التطبيق والويدجت
  /// بيحسبوا آية اليوم كلٌّ على حدة، ولو الاتنين اختلفوا هيبقى كل واحد بيعرض
  /// آية مختلفة في نفس اليوم.
  ///
  /// مش بنستخدم `Random(seed)` هنا لأن مولّد Dart ومولّد Java بيدّوا نتايج
  /// مختلفة لنفس الـ seed. الضرب دا (Knuth multiplicative hashing) بيتحسب في
  /// 64 بت في اللغتين وبيدي نفس الناتج.
  static int indexForDay(int epochDay, int count) {
    final hashed = (epochDay * 2654435761) & 0x7FFFFFFF;
    return hashed % count;
  }

  /// آية اليوم — ثابتة طول اليوم، ونفسها لكل المستخدمين.
  static Future<Verse> verseOfTheDay([DateTime? now]) async {
    final verses = await loadAll();
    return verses[indexForDay(epochDay(now), verses.length)];
  }

  /// آية عشوائية لزرار "آية جديدة". [exclude] بيمنع تكرار الآية المعروضة.
  static Future<Verse> randomVerse({Verse? exclude, Random? random}) async {
    final verses = await loadAll();
    final rng = random ?? Random();

    if (exclude == null || verses.length < 2) {
      return verses[rng.nextInt(verses.length)];
    }

    final pool =
        verses.where((verse) => verse != exclude).toList(growable: false);
    if (pool.isEmpty) return verses[rng.nextInt(verses.length)];
    return pool[rng.nextInt(pool.length)];
  }

  /// للاختبارات فقط.
  static void resetCacheForTesting() => _cache = null;
}
