import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/leaderboard/leaderboard_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class MyRankCard extends StatelessWidget {
  const MyRankCard({
    super.key,
    required this.rank,
    this.title = 'Your rank',
    this.subtitle,
  });

  final MyRankSummary? rank;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppCard(
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if ((subtitle ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
            ),
          ],
          const SizedBox(height: 16),
          if (rank == null)
            Text(
              'You are not ranked yet. Finish a few activities to appear on the board.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MetricBlock(
                    label: 'Current rank',
                    value: '#${rank!.rank}',
                  ),
                ),
                const SizedBox(width: 12),
                _MetricDivider(color: tokens.border.subtle),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricBlock(label: 'XP', value: '${rank!.xp}'),
                ),
                const SizedBox(width: 12),
                _MetricDivider(color: tokens.border.subtle),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricBlock(
                    label: 'To next rank',
                    value: '${rank!.xpToNextRank}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: tokens.background.panelStrong,
                borderRadius: BorderRadius.circular(tokens.radius.lg),
                border: Border.all(color: tokens.border.subtle),
              ),
              child: Row(
                children: [
                  Icon(
                    rank!.isRising
                        ? Icons.trending_up_rounded
                        : rank!.isFalling
                        ? Icons.trending_down_rounded
                        : Icons.remove_rounded,
                    color: rank!.isRising
                        ? tokens.success
                        : rank!.isFalling
                        ? tokens.danger
                        : tokens.text.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rank!.rankChange == 0
                          ? 'Stable compared with the previous leaderboard update.'
                          : '${rank!.rankChange.abs()} place change across ${rank!.totalParticipants} learners.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.text.secondary),
        ),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: color,
    );
  }
}
