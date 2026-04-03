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
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final AppPagePaletteKey paletteKey;
  final List<Widget> children;
  final Widget? trailing;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(paletteKey);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width >= 1200
            ? 32.0
            : width >= 720
            ? 24.0
            : 20.0;
        final contentWidth = width > 960 ? 960.0 : width;

        Widget wrapContent(Widget child) {
          return Center(
            child: SizedBox(width: contentWidth, child: child),
          );
        }

        Widget buildHeroCard() {
          return Container(
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 16), trailing!],
              ],
            ),
          );
        }

        final listView = ListView.separated(
          physics: onRefresh == null
              ? const BouncingScrollPhysics()
              : const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            32,
          ),
          itemCount: children.length + 1,
          separatorBuilder: (context, index) =>
              SizedBox(height: index == 0 ? 12 : tokens.density.regularGap),
          itemBuilder: (context, index) {
            if (index == 0) {
              return wrapContent(buildHeroCard());
            }

            return wrapContent(children[index - 1]);
          },
        );

        if (onRefresh == null) {
          return listView;
        }

        return RefreshIndicator(onRefresh: onRefresh!, child: listView);
      },
    );
  }
}
