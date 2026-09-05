import 'dart:convert';
import 'dart:math';

import 'package:bible_verse_widget/data/verses_repository.dart';
import 'package:bible_verse_widget/main.dart';
import 'package:bible_verse_widget/models/verse.dart';
import 'package:bible_verse_widget/widgets/glass_verse_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Verse', () {
    test('parses json and tolerates whitespace', () {
      final verse =
          Verse.fromJson({'text': '  نص  ', 'reference': ' يوحنا 3:16 '});
      expect(verse.text, 'نص');
      expect(verse.reference, 'يوحنا 3:16');
    });

    test('round-trips through json', () {
      const verse = Verse(text: 'نص', reference: 'يوحنا 3:16');
      expect(Verse.fromJson(verse.toJson()), verse);
    });
  });

  group('VersesRepository', () {
    setUp(VersesRepository.resetCacheForTesting);

    test('loads every verse from the bundled asset', () async {
      final verses = await VersesRepository.loadAll();
      expect(verses.length, greaterThanOrEqualTo(80));
      expect(verses.every((v) => v.text.isNotEmpty), isTrue);
      expect(verses.every((v) => v.reference.isNotEmpty), isTrue);
    });

    test('references are unique', () async {
      final verses = await VersesRepository.loadAll();
      final references = verses.map((v) => v.reference).toSet();
      expect(references.length, verses.length);
    });

    test('epochDay counts days from 1970-01-01 in local time', () {
      expect(VersesRepository.epochDay(DateTime(1970, 1, 1)), 0);
      expect(VersesRepository.epochDay(DateTime(1970, 1, 2)), 1);
      expect(VersesRepository.epochDay(DateTime(2026, 9, 5)), 20701);
      // الوقت جوه اليوم مالوش تأثير
      expect(
        VersesRepository.epochDay(DateTime(2026, 9, 5, 23, 59)),
        VersesRepository.epochDay(DateTime(2026, 9, 5, 0, 1)),
      );
    });

    // القيم دي متولّدة من نفس المعادلة، والغرض منها إنها تقفل الخوارزمية:
    // لو حد غيّرها في Dart لازم يغيّرها في VerseWidgetProvider.kt، وإلا
    // التطبيق والويدجت هيعرضوا آيتين مختلفتين في نفس اليوم.
    test('indexForDay matches the Kotlin implementation', () {
      expect(VersesRepository.indexForDay(0, 84), 0);
      expect(VersesRepository.indexForDay(20701, 84), 13);
      expect(VersesRepository.indexForDay(20702, 84), 70);
      expect(VersesRepository.indexForDay(20818, 84), 14);
      expect(VersesRepository.indexForDay(20819, 84), 31);
    });

    test('indexForDay always lands inside the list', () {
      for (var day = 0; day < 5000; day++) {
        final index = VersesRepository.indexForDay(day, 84);
        expect(index, inInclusiveRange(0, 83));
      }
    });

    test('indexForDay spreads across the whole list', () {
      final seen = <int>{};
      for (var day = 20000; day < 20840; day++) {
        seen.add(VersesRepository.indexForDay(day, 84));
      }
      expect(seen.length, 84);
    });

    test('verseOfTheDay is stable within a day and changes the next', () async {
      final today =
          await VersesRepository.verseOfTheDay(DateTime(2026, 9, 5, 3));
      final laterToday =
          await VersesRepository.verseOfTheDay(DateTime(2026, 9, 5, 21));
      final tomorrow =
          await VersesRepository.verseOfTheDay(DateTime(2026, 9, 6));

      expect(today, laterToday);
      expect(today, isNot(tomorrow));
    });

    test('encodedVerses keeps the same order and count as loadAll', () async {
      final verses = await VersesRepository.loadAll();
      final decoded =
          json.decode(await VersesRepository.encodedVerses()) as List;

      // ده اللي بيضمن إن الـ index اللي Kotlin بيحسبه بيدي نفس آية Dart.
      expect(decoded.length, verses.length);
      for (var i = 0; i < verses.length; i++) {
        final entry = decoded[i] as Map<String, dynamic>;
        expect(entry['text'], verses[i].text);
        expect(entry['reference'], verses[i].reference);
      }
    });

    test('randomVerse never returns the excluded verse', () async {
      final verses = await VersesRepository.loadAll();
      final excluded = verses.first;
      for (var i = 0; i < 100; i++) {
        final verse = await VersesRepository.randomVerse(exclude: excluded);
        expect(verse, isNot(excluded));
      }
    });

    test('randomVerse is deterministic when given a seeded Random', () async {
      final first = await VersesRepository.randomVerse(random: Random(7));
      final second = await VersesRepository.randomVerse(random: Random(7));
      expect(first, second);
    });
  });

  testWidgets('shows today\'s verse in a glass card', (tester) async {
    await tester.pumpWidget(const BibleVerseApp());
    await tester.pumpAndSettle();

    expect(find.text('آية اليوم'), findsOneWidget);
    expect(find.byType(GlassVerseCard), findsOneWidget);

    final card = tester.widget<GlassVerseCard>(find.byType(GlassVerseCard));
    expect(card.verse, await VersesRepository.verseOfTheDay());
    expect(find.text(card.verse.text), findsOneWidget);
    expect(find.text(card.verse.reference), findsOneWidget);
  });

  testWidgets('refresh button swaps in a different verse', (tester) async {
    await tester.pumpWidget(const BibleVerseApp());
    await tester.pumpAndSettle();

    final before =
        tester.widget<GlassVerseCard>(find.byType(GlassVerseCard)).verse;

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();

    final after =
        tester.widget<GlassVerseCard>(find.byType(GlassVerseCard)).verse;
    expect(after, isNot(before));
  });
}
