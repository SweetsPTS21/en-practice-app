import 'package:flutter/material.dart';

import '../../theme/page_palettes.dart';
import '../../theme/theme_extensions.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.paletteKey,
    required this.children,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final AppPagePaletteKey paletteKey;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(paletteKey);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(tokens.density.panelPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [palette.heroTop, palette.heroBottom],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(tokens.radius.hero),
                boxShadow: [
                  BoxShadow(
                    color: palette.accent.withValues(alpha: 0.24),
                    blurRadius: tokens.motion.blurStrong + 16,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trailing != null)
                    Align(
                      alignment: Alignment.topRight,
                      child: trailing!,
                    ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList.separated(
            itemBuilder: (context, index) => children[index],
            separatorBuilder: (context, index) => SizedBox(
              height: tokens.density.regularGap,
            ),
            itemCount: children.length,
          ),
        ),
      ],
    );
  }
}
