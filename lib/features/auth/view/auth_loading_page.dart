import 'package:flutter/material.dart';

import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';

class AuthLoadingPage extends StatefulWidget {
  const AuthLoadingPage({super.key});

  @override
  State<AuthLoadingPage> createState() => _AuthLoadingPageState();
}

class _AuthLoadingPageState extends State<AuthLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(AppPagePaletteKey.dashboard);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              tokens.background.body,
              tokens.background.canvas,
              tokens.background.body,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.heroTop, palette.heroBottom],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: palette.accent.withValues(alpha: 0.18),
                        blurRadius: tokens.motion.blurStrong + 14,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 22),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final phase = (_controller.value - (index * 0.18))
                            .clamp(0.0, 1.0);
                        final opacity = 0.28 + (phase * 0.72);
                        final scale = 0.84 + (phase * 0.28);

                        return Padding(
                          padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: palette.accent.withValues(
                                  alpha: opacity,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
