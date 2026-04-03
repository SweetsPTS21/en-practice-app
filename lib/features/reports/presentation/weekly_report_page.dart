import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_header_icon_action.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
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
      subtitle:
          'Review the week, spot the pattern, then follow the next recommendation.',
      paletteKey: AppPagePaletteKey.dashboard,
      onRefresh: () => ref.refresh(weeklyReportControllerProvider.future),
      trailing: AppHeaderIconAction(
        tooltip: 'Challenges',
        icon: Icons.emoji_events_rounded,
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
                      LinearProgressIndicator(
                        value: value.challengeSummary!.progressPercent,
                      ),
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
    return const AppLoadingCard(
      height: 240,
      message: 'Preparing your weekly report...',
    );
  }
}

class _WeeklyReportEmptyState extends StatelessWidget {
  const _WeeklyReportEmptyState();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AppEmptyState(
        icon: Icons.insights_outlined,
        title: 'No weekly report yet',
        subtitle:
            'Complete a few learning sessions this week and your summary will appear here.',
        action: AppButton(
          label: 'Back to Home',
          icon: Icons.home_rounded,
          onPressed: () => context.go('/home'),
        ),
      ),
    );
  }
}

class _WeeklyReportErrorState extends StatelessWidget {
  const _WeeklyReportErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorCard(
      title: 'Weekly report is unavailable',
      message: 'We could not load the latest summary for this week.',
      onRetry: onRetry,
    );
  }
}
