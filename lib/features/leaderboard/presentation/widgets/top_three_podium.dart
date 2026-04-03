import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/leaderboard/leaderboard_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class TopThreePodium extends StatelessWidget {
  const TopThreePodium({
    super.key,
    required this.entries,
    this.title = 'Top learners',
    this.subtitle,
  });

  final List<LeaderboardEntry> entries;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final first = entries.isNotEmpty ? entries.first : null;
    final second = entries.length > 1 ? entries[1] : null;
    final third = entries.length > 2 ? entries[2] : null;
    final tokens = context.tokens;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if ((subtitle ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.text.secondary,
                  ),
            ),
          ],
          const SizedBox(height: 18),
          if (entries.isEmpty)
            Text(
              'Leaderboard data is not available yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else ...[
            if (first != null) _PodiumHero(entry: first),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.hasBoundedWidth &&
                        constraints.maxWidth.isFinite &&
                        constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : MediaQuery.sizeOf(context).width - 40;
                final compact = availableWidth < 360;
                final itemWidth = compact
                    ? availableWidth
                    : (availableWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _PodiumSide(position: 2, entry: second),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _PodiumSide(position: 3, entry: third),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _PodiumHero extends StatelessWidget {
  const _PodiumHero({
    required this.entry,
  });

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E8A5),
        borderRadius: BorderRadius.circular(tokens.radius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(tokens.radius.lg),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF8F6500)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#1', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(entry.displayName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('${entry.xp} XP · ${entry.currentStreak} day streak'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumSide extends StatelessWidget {
  const _PodiumSide({
    required this.position,
    required this.entry,
  });

  final int position;
  final LeaderboardEntry? entry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: entry == null
          ? Text('No #$position learner yet')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('#$position', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(entry!.displayName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${entry!.xp} XP'),
              ],
            ),
    );
  }
}
