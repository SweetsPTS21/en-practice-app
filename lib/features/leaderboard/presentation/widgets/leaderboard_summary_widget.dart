import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/leaderboard/leaderboard_providers.dart';
import '../../../../core/theme/theme_extensions.dart';
import 'my_rank_card.dart';
import 'top_three_podium.dart';

class LeaderboardSummaryWidget extends ConsumerWidget {
  const LeaderboardSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(leaderboardSummaryProvider);

    return summary.when(
      data: (data) => Column(
        children: [
          TopThreePodium(
            entries: data.topThree,
            title: 'Leaderboard snapshot',
            subtitle: 'See who is leading the current ${data.period.label.toLowerCase()} race.',
          ),
          const SizedBox(height: 12),
          MyRankCard(
            rank: data.myRank,
            subtitle: 'Competition context on Home should stay lightweight and actionable.',
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Open the full leaderboard to compare rank movement and see the entire table.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.tokens.text.secondary,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Open leaderboard',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go('/leaderboard'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => const AppCard(
        child: SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leaderboard is unavailable right now.'),
            const SizedBox(height: 12),
            AppButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              variant: AppButtonVariant.outline,
              onPressed: () => ref.invalidate(leaderboardSummaryProvider),
            ),
          ],
        ),
      ),
    );
  }
}
