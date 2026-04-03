import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_header_icon_action.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/weekly_challenge_controller.dart';
import 'widgets/achievement_grid.dart';
import 'widgets/challenge_progress_card.dart';

class WeeklyChallengePage extends ConsumerWidget {
  const WeeklyChallengePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weeklyChallengeScreenControllerProvider);

    return AppPageScaffold(
      title: 'Weekly Challenge',
      subtitle:
          'Track the current challenge and see which achievements are already unlocked.',
      paletteKey: AppPagePaletteKey.leaderboard,
      onRefresh: () =>
          ref.refresh(weeklyChallengeScreenControllerProvider.future),
      trailing: AppHeaderIconAction(
        tooltip: 'Weekly report',
        icon: Icons.assessment_rounded,
        onPressed: () => context.go('/weekly-report'),
      ),
      children: [
        switch (state) {
          AsyncData(:final value) => Column(
            children: [
              if (value.challenge != null)
                ChallengeProgressCard(
                  challenge: value.challenge!,
                  nextStep: value.report?.nextStep,
                  onOpenReport: () => context.go('/weekly-report'),
                )
              else
                const AppCard(
                  child: AppEmptyState(
                    icon: Icons.emoji_events_outlined,
                    title: 'No active challenge right now',
                    subtitle: 'Check back soon for the next weekly goal.',
                  ),
                ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(
                      title: 'Achievements',
                      subtitle:
                          'Unlocked badges stay easy to scan while the rest remain available below.',
                    ),
                    const SizedBox(height: 16),
                    AchievementGrid(achievements: value.achievements),
                  ],
                ),
              ),
            ],
          ),
          AsyncError() => _ChallengeErrorState(
            onRetry: () =>
                ref.invalidate(weeklyChallengeScreenControllerProvider),
          ),
          _ => const _ChallengeLoadingState(),
        },
      ],
    );
  }
}

class _ChallengeLoadingState extends StatelessWidget {
  const _ChallengeLoadingState();

  @override
  Widget build(BuildContext context) {
    return const AppLoadingCard(
      height: 240,
      message: 'Loading challenge progress...',
    );
  }
}

class _ChallengeErrorState extends StatelessWidget {
  const _ChallengeErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorCard(
      title: 'Challenge data is unavailable',
      message: 'We could not load the current challenge or achievement list.',
      onRetry: onRetry,
    );
  }
}
