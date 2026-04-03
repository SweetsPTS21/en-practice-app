import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/leaderboard/leaderboard_models.dart';
import '../../core/theme/page_palettes.dart';
import '../auth/auth_providers.dart';
import 'application/leaderboard_controller.dart';
import 'presentation/widgets/leaderboard_table.dart';
import 'presentation/widgets/my_rank_card.dart';
import 'presentation/widgets/top_three_podium.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardControllerProvider);
    final auth = ref.watch(authControllerProvider);

    return AppPageScaffold(
      title: 'Leaderboard',
      subtitle: 'Social proof, rank movement and the current XP race now live as a full mobile surface.',
      paletteKey: AppPagePaletteKey.leaderboard,
      trailing: AppButton(
        label: 'XP history',
        icon: Icons.timeline_rounded,
        variant: AppButtonVariant.tonal,
        onPressed: () => context.go('/xp-history'),
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Period', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: LeaderboardPeriod.values
                    .map(
                      (period) => ChoiceChip(
                        label: Text(period.label),
                        selected: leaderboard.valueOrNull?.query.period == period,
                        onSelected: (_) => ref
                            .read(leaderboardControllerProvider.notifier)
                            .updatePeriod(period),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 16),
              Text('Scope', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: LeaderboardScope.values
                    .map(
                      (scope) => ChoiceChip(
                        label: Text(scope.label),
                        selected: leaderboard.valueOrNull?.query.scope == scope,
                        onSelected: (_) => ref
                            .read(leaderboardControllerProvider.notifier)
                            .updateScope(scope),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
        ...leaderboard.when(
          data: (state) => [
            MyRankCard(
              rank: state.response.myRank,
              subtitle: 'Your own rank needs to stay visible above the public list.',
            ),
            TopThreePodium(
              entries: state.response.topUsers.take(3).toList(growable: false),
              subtitle: 'The podium mirrors the web surface while keeping the list below scroll-friendly.',
            ),
            LeaderboardTable(
              entries: state.response.topUsers,
              currentUserId: auth.user?.id,
            ),
            if (state.hasMore)
              AppCard(
                child: Center(
                  child: AppButton(
                    label: state.isLoadingMore ? 'Loading...' : 'Load more',
                    icon: Icons.expand_more_rounded,
                    onPressed: state.isLoadingMore
                        ? null
                        : () => ref.read(leaderboardControllerProvider.notifier).loadMore(),
                  ),
                ),
              ),
          ],
          loading: () => const [
            AppCard(
              child: SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
          error: (error, stackTrace) => [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Leaderboard could not be loaded.'),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Retry',
                    icon: Icons.refresh_rounded,
                    onPressed: () => ref.read(leaderboardControllerProvider.notifier).refresh(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
