import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/verse.dart';

/// كارت بتصميم "Liquid Glass": شفاف، حواف مضبّبة (Blur)، حدود لامعة خفيفة
/// وتدرج لوني بسيط بيدي إحساس الزجاج السائل.
class GlassVerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback? onRefresh;

  const GlassVerseCard({
    super.key,
    required this.verse,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 260,
      borderRadius: 28,
      blur: 18, // درجة الضبابية
      alignment: Alignment.center,
      border: 1.4,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.25),
          Colors.white.withOpacity(0.08),
        ],
        stops: const [0.1, 1],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories_rounded,
                color: Colors.white, size: 30),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  verse.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              verse.reference,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 12),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'آية جديدة',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
