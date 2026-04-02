import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/page_palettes.dart';
import '../../theme/theme_extensions.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'app_page_scaffold.dart';

class FeatureLandingPage extends StatelessWidget {
  const FeatureLandingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.paletteKey,
    required this.icon,
    required this.highlights,
  });

  final String title;
  final String subtitle;
  final AppPagePaletteKey paletteKey;
  final IconData icon;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(paletteKey);

    return AppPageScaffold(
      title: title,
      subtitle: subtitle,
      paletteKey: paletteKey,
      trailing: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(tokens.radius.lg),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('featureHub.sections.focus'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.density.regularGap),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: highlights
                    .map(
                      (item) => Chip(
                        avatar: CircleAvatar(
                          backgroundColor: palette.accent,
                          child: const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        label: Text(item),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('featureHub.sections.scope'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(context.tr('featureHub.copy.scope')),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('featureHub.sections.actions'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(context.tr('featureHub.copy.actions')),
              SizedBox(height: tokens.density.regularGap),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: context.tr('featureHub.actions.backDashboard'),
                    icon: Icons.home_rounded,
                    onPressed: () => context.go('/'),
                  ),
                  AppButton(
                    label: context.tr('featureHub.actions.openSettings'),
                    icon: Icons.tune_rounded,
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
