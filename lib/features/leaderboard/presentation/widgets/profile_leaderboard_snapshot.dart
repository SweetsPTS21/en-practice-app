import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/leaderboard/leaderboard_providers.dart';
import 'my_rank_card.dart';

class ProfileLeaderboardSnapshot extends ConsumerWidget {
  const ProfileLeaderboardSnapshot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(leaderboardSummaryProvider);

    return summary.when(
      data: (data) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Competitive snapshot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Profile keeps your rank and podium context visible without leaving the page.',
            ),
            const SizedBox(height: 16),
            MyRankCard(rank: data.myRank, title: 'Your standing'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: data.topThree
                  .map(
                    (entry) => Chip(
                      label: Text(
                        '#${entry.rank} ${entry.displayName} · ${entry.xp} XP',
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'View leaderboard',
              icon: Icons.emoji_events_outlined,
              onPressed: () => context.go('/leaderboard'),
            ),
          ],
        ),
      ),
      loading: () => const AppCard(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Competitive snapshot could not be loaded.'),
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
