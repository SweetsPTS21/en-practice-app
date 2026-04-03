import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/leaderboard/xp_history_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class XpHistoryTimeline extends StatelessWidget {
  const XpHistoryTimeline({super.key, required this.entries});

  final List<XpHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('XP timeline', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Text('No XP activity found yet.')
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tokens.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(tokens.radius.lg),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: tokens.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.description,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.source} · ${_formatDate(entry.earnedAt)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.text.secondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '+${entry.xp}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: tokens.success),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} · $hour:$minute';
}
