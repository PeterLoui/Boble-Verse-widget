import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/verse.dart';

class VersesRepository {
  static List<Verse>? _cache;

  static Future<List<Verse>> _loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('lib/data/verses.json');
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    _cache = jsonList
        .map((e) => Verse.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  /// يرجع آية عشوائية. لو تم تمرير [seed] (مثلاً رقم اليوم) هترجع
  /// نفس الآية لنفس اليوم بدل ما تتغير كل مرة يفتح فيها المستخدم التطبيق.
  static Future<Verse> getRandomVerse({int? seed}) async {
    final verses = await _loadAll();
    final random = seed != null ? Random(seed) : Random();
    return verses[random.nextInt(verses.length)];
  }

  /// رقم يمثل اليوم الحالي، يُستخدم كـ seed عشان "آية اليوم" تفضل ثابتة
  /// طول اليوم لكل المستخدمين اللي بيفتحوا التطبيق.
  static int todaySeed() {
    final now = DateTime.now();
    return int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
    );
  }
}
