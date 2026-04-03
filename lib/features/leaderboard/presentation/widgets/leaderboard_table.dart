import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/leaderboard/leaderboard_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class LeaderboardTable extends StatelessWidget {
  const LeaderboardTable({
    super.key,
    required this.entries,
    this.currentUserId,
  });

  final List<LeaderboardEntry> entries;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const AppCard(
        child: Text('No leaderboard entries yet. Keep practicing to populate the board.'),
      );
    }

    final tokens = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ranking', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: entry.userId == currentUserId
                      ? tokens.primary.withValues(alpha: 0.08)
                      : tokens.background.panelStrong,
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                  border: Border.all(
                    color: entry.userId == currentUserId
                        ? tokens.primary.withValues(alpha: 0.32)
                        : tokens.border.subtle,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Text(
                        '#${entry.rank}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.displayName, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.xp} XP · ${entry.currentStreak} day streak',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: tokens.text.secondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ChangeBadge(entry: entry),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({
    required this.entry,
  });

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = entry.isRising
        ? tokens.success
        : entry.isFalling
            ? tokens.danger
            : tokens.text.secondary;
    final icon = entry.isRising
        ? Icons.north_rounded
        : entry.isFalling
            ? Icons.south_rounded
            : Icons.remove_rounded;
    final label = entry.rankChange == 0 ? '0' : entry.rankChange.abs().toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
        ],
      ),
    );
  }
}
