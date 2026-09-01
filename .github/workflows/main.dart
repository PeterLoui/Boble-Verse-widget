import 'package:flutter/material.dart';
import 'models/verse.dart';
import 'data/verses_repository.dart';
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
        fontFamily: 'Cairo', // ضيف خط عربي جميل لو عايز (اختياري)
        useMaterial3: true,
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayVerse();
  }

  Future<void> _loadTodayVerse() async {
    setState(() => _loading = true);
    final verse =
        await VersesRepository.getRandomVerse(seed: VersesRepository.todaySeed());
    setState(() {
      _verse = verse;
      _loading = false;
    });
    // حدّث ويدجت الشاشة الرئيسية بنفس آية اليوم
    await WidgetService.updateWidget(verse);
  }

  Future<void> _getNewRandomVerse() async {
    setState(() => _loading = true);
    final verse = await VersesRepository.getRandomVerse();
    setState(() {
      _verse = verse;
      _loading = false;
    });
    await WidgetService.updateWidget(verse);
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
                if (_loading || _verse == null)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  GlassVerseCard(
                    verse: _verse!,
                    onRefresh: _getNewRandomVerse,
                  ),
                const SizedBox(height: 24),
                Text(
                  'الويدجت على شاشتك الرئيسية بيتحدّث تلقائيًا',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
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
}
