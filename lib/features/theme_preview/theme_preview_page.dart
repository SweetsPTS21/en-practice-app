import 'package:flutter/material.dart';

import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/page_palettes.dart';
import '../../core/theme/theme_extensions.dart';

class ThemePreviewPage extends StatelessWidget {
  const ThemePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPageScaffold(
      title: context.tr('themePreview.hero.title'),
      subtitle: context.tr('themePreview.hero.subtitle'),
      paletteKey: AppPagePaletteKey.writing,
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('themePreview.sections.colors'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.density.regularGap),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ColorTile(
                    label: context.tr('themePreview.labels.primary'),
                    color: tokens.primary,
                  ),
                  _ColorTile(
                    label: context.tr('themePreview.labels.accent'),
                    color: tokens.accent,
                  ),
                  _ColorTile(
                    label: context.tr('themePreview.labels.secondary'),
                    color: tokens.secondary,
                  ),
                  _ColorTile(
                    label: context.tr('themePreview.labels.success'),
                    color: tokens.success,
                  ),
                  _ColorTile(
                    label: context.tr('themePreview.labels.warning'),
                    color: tokens.warning,
                  ),
                  _ColorTile(
                    label: context.tr('themePreview.labels.danger'),
                    color: tokens.danger,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('themePreview.sections.buttons'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.density.regularGap),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: context.tr('common.openPreview'),
                    icon: Icons.visibility_rounded,
                  ),
                  AppButton(
                    label: context.tr('common.openSettings'),
                    variant: AppButtonVariant.tonal,
                    icon: Icons.tune_rounded,
                  ),
                  AppButton(
                    label: context.tr('common.current'),
                    variant: AppButtonVariant.outline,
                  ),
                ],
              ),
              SizedBox(height: tokens.density.regularGap),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Chip(label: Text(context.tr('common.mode'))),
                  Chip(label: Text(context.tr('common.profile'))),
                  Chip(label: Text(context.tr('common.background'))),
                ],
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('themePreview.sections.typography'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.density.regularGap),
              Text(
                'Aa',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${context.tr('themePreview.labels.fast')}: ${tokens.motion.fast.inMilliseconds}ms',
              ),
              Text(
                '${context.tr('themePreview.labels.normal')}: ${tokens.motion.normal.inMilliseconds}ms',
              ),
              Text(
                '${context.tr('themePreview.labels.slow')}: ${tokens.motion.slow.inMilliseconds}ms',
              ),
              Text(
                '${context.tr('themePreview.labels.blurSoft')}: ${tokens.motion.blurSoft.toStringAsFixed(0)}',
              ),
              Text(
                '${context.tr('themePreview.labels.blurStrong')}: ${tokens.motion.blurStrong.toStringAsFixed(0)}',
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('themePreview.sections.density'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.density.regularGap),
              _MetricRow(
                label: context.tr('themePreview.labels.controlHeight'),
                value: tokens.density.controlHeight,
              ),
              _MetricRow(
                label: context.tr('themePreview.labels.controlHeightSmall'),
                value: tokens.density.controlHeightSmall,
              ),
              _MetricRow(
                label: context.tr('themePreview.labels.controlHeightLarge'),
                value: tokens.density.controlHeightLarge,
              ),
              _MetricRow(
                label: context.tr('themePreview.labels.compactGap'),
                value: tokens.density.compactGap,
              ),
              _MetricRow(
                label: context.tr('themePreview.labels.regularGap'),
                value: tokens.density.regularGap,
              ),
              _MetricRow(
                label: context.tr('themePreview.labels.panelPadding'),
                value: tokens.density.panelPadding,
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('themePreview.sections.palettes'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.density.regularGap),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppPagePaletteKey.values.map((key) {
                  final palette = context.pagePalette(key);
                  return Container(
                    width: 148,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [palette.heroTop, palette.heroBottom],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(tokens.radius.lg),
                    ),
                    child: Text(
                      context.tr('app.pagePalettes.${key.name}'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(tokens.radius.md),
            ),
          ),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value.toStringAsFixed(0)),
        ],
      ),
    );
  }
}
