import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/navigation/app_destinations.dart';
import '../auth/auth_providers.dart';
import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/l10n/app_locale_controller.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme_controller.dart';
import '../../core/theme/page_palettes.dart';
import '../../core/theme/theme_backgrounds.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/theme/theme_mode_prefs.dart';
import '../../core/theme/theme_profiles.dart';
import '../../core/theme/theme_solid_primary.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(appThemeControllerProvider);
    final locale = ref.watch(appLocaleControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final tokens = context.tokens;

    return AppPageScaffold(
      title: context.tr('dashboard.hero.title'),
      subtitle: context.tr('dashboard.hero.subtitle'),
      paletteKey: AppPagePaletteKey.dashboard,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(tokens.radius.hero),
        ),
        child: Text(
          context.tr('dashboard.hero.badge'),
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('dashboard.overview.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(context.tr('dashboard.overview.subtitle')),
              SizedBox(height: tokens.density.regularGap),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MetricCard(
                    label: context.tr('dashboard.metrics.streak'),
                    value: '12',
                    caption: context.tr('dashboard.metrics.streakCaption'),
                    color: const Color(0xFFF59E0B),
                    icon: Icons.local_fire_department_rounded,
                  ),
                  _MetricCard(
                    label: context.tr('dashboard.metrics.reviewQueue'),
                    value: '28',
                    caption: context.tr('dashboard.metrics.reviewQueueCaption'),
                    color: const Color(0xFF14B8A6),
                    icon: Icons.refresh_rounded,
                  ),
                  _MetricCard(
                    label: context.tr('dashboard.metrics.mockReadiness'),
                    value: '84%',
                    caption: context.tr(
                      'dashboard.metrics.mockReadinessCaption',
                    ),
                    color: const Color(0xFF8B5CF6),
                    icon: Icons.analytics_rounded,
                  ),
                  _MetricCard(
                    label: context.tr('dashboard.metrics.timeToday'),
                    value: '42m',
                    caption: context.tr('dashboard.metrics.timeTodayCaption'),
                    color: const Color(0xFF2563EB),
                    icon: Icons.schedule_rounded,
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
                context.tr('dashboard.quickAccess.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(context.tr('dashboard.quickAccess.subtitle')),
              SizedBox(height: tokens.density.regularGap),
              ...appPrimaryDestinations
                  .where((destination) => destination.route != '/')
                  .map(
                    (destination) => Padding(
                      padding: EdgeInsets.only(
                        bottom: tokens.density.compactGap,
                      ),
                      child: _DestinationCard(destination: destination),
                    ),
                  ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('dashboard.focus.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(context.tr('dashboard.focus.subtitle')),
              SizedBox(height: tokens.density.regularGap),
              _FocusStrip(
                title: context.tr('dashboard.focus.dictionaryTitle'),
                subtitle: context.tr('dashboard.focus.dictionarySubtitle'),
                value: 0.72,
                color: context.pagePalette(AppPagePaletteKey.dictionary).accent,
              ),
              SizedBox(height: tokens.density.compactGap),
              _FocusStrip(
                title: context.tr('dashboard.focus.writingTitle'),
                subtitle: context.tr('dashboard.focus.writingSubtitle'),
                value: 0.58,
                color: context.pagePalette(AppPagePaletteKey.writing).accent,
              ),
              SizedBox(height: tokens.density.compactGap),
              _FocusStrip(
                title: context.tr('dashboard.focus.speakingTitle'),
                subtitle: context.tr('dashboard.focus.speakingSubtitle'),
                value: 0.41,
                color: context.pagePalette(AppPagePaletteKey.speaking).accent,
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('dashboard.system.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(context.tr('dashboard.system.subtitle')),
              SizedBox(height: tokens.density.regularGap),
              _SummaryRow(
                label: context.tr('dashboard.summary.account'),
                value: auth.user?.displayName ?? 'Guest',
              ),
              _SummaryRow(
                label: context.tr('dashboard.summary.email'),
                value: auth.user?.email ?? '-',
              ),
              _SummaryRow(
                label: context.tr('dashboard.summary.selectedMode'),
                value: _themeModeLabel(context, themeState.themePreference),
              ),
              _SummaryRow(
                label: context.tr('dashboard.summary.effectiveMode'),
                value: _themeModeLabel(
                  context,
                  themeState.effectiveThemePreference,
                ),
              ),
              _SummaryRow(
                label: context.tr('dashboard.summary.profile'),
                value: _profileLabel(
                  context,
                  themeState.themeProfilePreference,
                ),
              ),
              _SummaryRow(
                label: context.tr('dashboard.summary.background'),
                value: _backgroundLabel(
                  context,
                  themeState.effectiveThemeBackgroundPreference,
                ),
              ),
              _SummaryRow(
                label: context.tr('dashboard.summary.solidPrimary'),
                value: _solidPrimaryLabel(
                  context,
                  themeState.themeSolidPrimaryPreference,
                ),
              ),
              _SummaryRow(
                label: context.tr('dashboard.summary.language'),
                value: _localeLabel(context, locale),
              ),
              SizedBox(height: tokens.density.regularGap),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: context.tr('common.openPreview'),
                    icon: Icons.palette_rounded,
                    onPressed: () => context.go('/preview'),
                  ),
                  AppButton(
                    label: context.tr('common.openSettings'),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.background.panel,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(tokens.radius.lg),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination});

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(destination.paletteKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(destination.route),
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                palette.heroTop.withValues(alpha: 0.10),
                palette.heroBottom.withValues(alpha: 0.18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(tokens.radius.xl),
            border: Border.all(color: palette.accent.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(destination.icon, color: palette.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(destination.labelKey),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(
                        'dashboard.moduleCards${_routeSuffix(destination.route)}',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: palette.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusStrip extends StatelessWidget {
  const _FocusStrip({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
  });

  final String title;
  final String subtitle;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text('${(value * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.density.compactGap),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

String _routeSuffix(String route) {
  return switch (route) {
    '/dictionary' => 'Dictionary',
    '/ielts' => 'Ielts',
    '/writing' => 'Writing',
    '/speaking' => 'Speaking',
    '/profile' => 'Profile',
    '/leaderboard' => 'Leaderboard',
    _ => 'Dashboard',
  };
}

String _themeModeLabel(BuildContext context, AppThemePreference value) {
  return context.tr('app.theme.modes.${value.name}');
}

String _backgroundLabel(
  BuildContext context,
  AppThemeBackgroundPreference value,
) {
  return context.tr('app.theme.backgrounds.${value.name}');
}

String _profileLabel(BuildContext context, AppThemeProfilePreference value) {
  return context.tr('app.theme.profiles.${value.name}');
}

String _solidPrimaryLabel(
  BuildContext context,
  AppThemeSolidPrimaryPreference value,
) {
  return context.tr('app.theme.solidPrimary.${value.name}');
}

String _localeLabel(BuildContext context, AppLocale value) {
  return context.tr('app.language.${value.languageCode}');
}
