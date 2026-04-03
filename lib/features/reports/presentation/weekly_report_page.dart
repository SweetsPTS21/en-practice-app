import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/recommendation/recommendation_surface.dart';
import '../../../core/theme/page_palettes.dart';
import '../../recommendation/presentation/widgets/recommendation_card.dart';
import '../application/weekly_report_controller.dart';
import 'widgets/weekly_report_insight_card.dart';
import 'widgets/weekly_report_summary_card.dart';

class WeeklyReportPage extends ConsumerWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(weeklyReportControllerProvider);

    return AppPageScaffold(
      title: 'Weekly Report',
      subtitle: 'Review the week, spot the pattern, then follow the next recommendation.',
      paletteKey: AppPagePaletteKey.dashboard,
      trailing: AppButton(
        label: 'Challenges',
        icon: Icons.emoji_events_rounded,
        variant: AppButtonVariant.outline,
        onPressed: () => context.go('/challenges'),
      ),
      children: [
        switch (report) {
          AsyncData(:final value) when value != null => Column(
              children: [
                WeeklyReportSummaryCard(report: value),
                const SizedBox(height: 16),
                WeeklyReportInsightCard(
                  title: 'Strongest win',
                  value: value.strongestWin,
                ),
                const SizedBox(height: 16),
                WeeklyReportInsightCard(
                  title: 'Repeated weakness',
                  value: value.repeatedWeakness,
                ),
                const SizedBox(height: 16),
                WeeklyReportInsightCard(
                  title: 'Next step',
                  value: value.nextStep,
                ),
                if (value.challengeSummary != null) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value.challengeSummary!.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${value.challengeSummary!.currentValue}/${value.challengeSummary!.targetValue} · +${value.challengeSummary!.rewardXp} XP',
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: value.challengeSummary!.progressPercent),
                        const SizedBox(height: 16),
                        AppButton(
                          label: value.challengeSummary!.completed
                              ? 'Review challenge'
                              : 'Continue challenge',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => context.go('/challenges'),
                        ),
                      ],
                    ),
                  ),
                ],
                if (value.recommendation != null) ...[
                  const SizedBox(height: 16),
                  RecommendationCard(
                    recommendation: value.recommendation!,
                    surface: RecommendationSurface.weeklyReport,
                    source: 'WEEKLY_REPORT_RECOMMENDATION',
                    showFeedbackActions: true,
                  ),
                ],
              ],
            ),
          AsyncData() => const _WeeklyReportEmptyState(),
          AsyncError() => _WeeklyReportErrorState(
              onRetry: () => ref.invalidate(weeklyReportControllerProvider),
            ),
          _ => const _WeeklyReportLoadingState(),
        },
      ],
    );
  }
}

class _WeeklyReportLoadingState extends StatelessWidget {
  const _WeeklyReportLoadingState();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _WeeklyReportEmptyState extends StatelessWidget {
  const _WeeklyReportEmptyState();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No weekly report yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Complete a few learning sessions this week and the report will appear here.'),
          const SizedBox(height: 16),
          AppButton(
            label: 'Back to Home',
            icon: Icons.home_rounded,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

class _WeeklyReportErrorState extends StatelessWidget {
  const _WeeklyReportErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 40),
          const SizedBox(height: 12),
          Text('Weekly report is unavailable', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'The route is ready, but the latest weekly report could not be loaded from the backend.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Retry',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
