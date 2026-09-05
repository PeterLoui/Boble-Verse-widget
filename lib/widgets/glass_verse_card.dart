import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../models/verse.dart';

/// كارت بتصميم "Liquid Glass": شفاف، حواف مضبّبة (Blur) بـ [BackdropFilter]،
/// حدود لامعة خفيفة وتدرج لوني بسيط بيدي إحساس الزجاج السائل.
class GlassVerseCard extends StatelessWidget {
  const GlassVerseCard({
    super.key,
    required this.verse,
    this.onRefresh,
    this.busy = false,
  });

  final Verse verse;
  final VoidCallback? onRefresh;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(28));

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 260),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.1, 1],
              colors: [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
              width: 1.4,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(height: 16),
                Text(
                  verse.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                    shadows: [
                      Shadow(color: Colors.black26, blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  verse.reference,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (onRefresh != null || busy) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: busy
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : IconButton(
                            onPressed: onRefresh,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                            ),
                            tooltip: 'آية جديدة',
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
