import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/theme/page_palettes.dart';
import 'application/xp_history_controller.dart';
import 'presentation/widgets/xp_history_timeline.dart';

class XpHistoryPage extends ConsumerWidget {
  const XpHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(xpHistoryControllerProvider);

    return AppPageScaffold(
      title: 'XP history',
      subtitle:
          'This screen explains where your rewards came from and keeps the progress loop legible.',
      paletteKey: AppPagePaletteKey.leaderboard,
      onRefresh: () => ref.read(xpHistoryControllerProvider.notifier).refresh(),
      children: [
        ...history.when(
          data: (state) => [
            AppCard(
              strong: true,
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total XP',
                      value: '${state.response.totalXP}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Weekly XP',
                      value: '${state.response.weeklyXP}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Activities',
                      value: '${state.response.history.length}',
                    ),
                  ),
                ],
              ),
            ),
            XpHistoryTimeline(entries: state.response.history),
            if (state.hasMore)
              AppCard(
                child: Center(
                  child: AppButton(
                    label: state.isLoadingMore ? 'Loading...' : 'Load more',
                    icon: Icons.expand_more_rounded,
                    onPressed: state.isLoadingMore
                        ? null
                        : () => ref
                              .read(xpHistoryControllerProvider.notifier)
                              .loadMore(),
                  ),
                ),
              ),
          ],
          loading: () => const [
            AppCard(
              child: SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
          error: (error, stackTrace) => [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('XP history could not be loaded.'),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Retry',
                    icon: Icons.refresh_rounded,
                    onPressed: () => ref
                        .read(xpHistoryControllerProvider.notifier)
                        .refresh(),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
