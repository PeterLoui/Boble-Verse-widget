import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/verses_repository.dart';
import 'models/verse.dart';
import 'services/widget_service.dart';
import 'widgets/glass_verse_card.dart';

void main() {
  runApp(const BibleVerseApp());
}

class BibleVerseApp extends StatelessWidget {
  const BibleVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'آية اليوم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
      ),
      // التطبيق عربي بالكامل، فبنجبر الاتجاه من اليمين للشمال.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Verse? _verse;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVerse();
  }

  /// بيجيب آية ويحدّث الشاشة والويدجت.
  ///
  /// [shuffle] بيبقى true لما المستخدم يضغط "آية جديدة"، ساعتها بنجيب آية
  /// عشوائية غير المعروضة. غير كده بنعرض آية اليوم — وهي نفسها اللي الويدجت
  /// بيحسبها لوحده، فالاتنين دايماً متفقين.
  Future<void> _loadVerse({bool shuffle = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final verse = shuffle
          ? await VersesRepository.randomVerse(exclude: _verse)
          : await VersesRepository.verseOfTheDay();

      // الـ State ممكن يكون اتشال من الشجرة أثناء الـ await.
      if (!mounted) return;
      setState(() {
        _verse = verse;
        _loading = false;
      });

      // حدّث ويدجت الشاشة الرئيسية بنفس الآية المعروضة.
      await WidgetService.updateWidget(verse);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF3EC6E0),
              Color(0xFF8E6FF7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'آية اليوم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _buildContent(),
                const SizedBox(height: 24),
                Text(
                  'الويدجت على شاشتك الرئيسية بيتحدّث تلقائيًا',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return _ErrorCard(
        message: 'حصلت مشكلة في تحميل الآيات',
        onRetry: () => _loadVerse(),
      );
    }

    final verse = _verse;
    if (_loading && verse == null) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (verse == null) {
      return const SizedBox(height: 260);
    }

    return GlassVerseCard(
      verse: verse,
      busy: _loading,
      onRefresh: _loading ? null : () => _loadVerse(shuffle: true),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 40),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('حاول تاني'),
        ),
      ],
    );
  }
}
