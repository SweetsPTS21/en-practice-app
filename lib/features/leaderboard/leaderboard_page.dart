import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_header_icon_action.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/design/widgets/app_state_widgets.dart';
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
      subtitle:
          'See where you stand, who is ahead and how much XP it takes to climb.',
      paletteKey: AppPagePaletteKey.leaderboard,
      onRefresh: () =>
          ref.read(leaderboardControllerProvider.notifier).refresh(),
      trailing: AppHeaderIconAction(
        tooltip: 'XP history',
        icon: Icons.timeline_rounded,
        onPressed: () => context.go('/xp-history'),
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'Filter the board',
                subtitle:
                    'Change the time range or scope without leaving this screen.',
              ),
              const SizedBox(height: 16),
              Text('Period', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: LeaderboardPeriod.values
                    .map(
                      (period) => ChoiceChip(
                        label: Text(period.label),
                        selected:
                            leaderboard.valueOrNull?.query.period == period,
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
              subtitle: 'Your current position stays visible at the top.',
            ),
            TopThreePodium(
              entries: state.response.topUsers.take(3).toList(growable: false),
              subtitle: 'Top performers for the selected board.',
            ),
            if (state.response.topUsers.isEmpty)
              const AppCard(
                child: AppEmptyState(
                  icon: Icons.emoji_events_outlined,
                  title: 'No ranking data yet',
                  subtitle:
                      'Complete a few activities and the board will start filling up.',
                ),
              )
            else
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
                        : () => ref
                              .read(leaderboardControllerProvider.notifier)
                              .loadMore(),
                  ),
                ),
              ),
          ],
          loading: () => const [
            AppLoadingCard(height: 240, message: 'Loading leaderboard...'),
          ],
          error: (_, _) => [
            AppErrorCard(
              title: 'Leaderboard is unavailable',
              message:
                  'We could not load the current ranking. Please try again.',
              onRetry: () =>
                  ref.read(leaderboardControllerProvider.notifier).refresh(),
            ),
          ],
        ),
      ],
    );
  }
}
