import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
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
      subtitle: 'Track the current challenge and see which achievements are already unlocked.',
      paletteKey: AppPagePaletteKey.leaderboard,
      trailing: AppButton(
        label: 'Weekly report',
        icon: Icons.assessment_rounded,
        variant: AppButtonVariant.outline,
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
                    child: Text('No active weekly challenge right now.'),
                  ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text('Unlocked achievements stay first, then recent unlocks, then the rest.'),
                      const SizedBox(height: 16),
                      AchievementGrid(achievements: value.achievements),
                    ],
                  ),
                ),
              ],
            ),
          AsyncError() => _ChallengeErrorState(
              onRetry: () => ref.invalidate(weeklyChallengeScreenControllerProvider),
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
    return const AppCard(
      child: SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ChallengeErrorState extends StatelessWidget {
  const _ChallengeErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 40),
          const SizedBox(height: 12),
          Text('Challenge data is unavailable', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'The challenge screen is wired, but the current challenge or achievement payload could not be loaded.',
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
