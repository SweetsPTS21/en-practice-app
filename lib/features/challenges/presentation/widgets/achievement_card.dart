import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/retention/achievement_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.achievement,
  });

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? tokens.warning.withValues(alpha: 0.12)
                  : tokens.background.panelStrong,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
            ),
            child: Icon(
              achievement.unlocked ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
              color: achievement.unlocked ? tokens.warning : tokens.text.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.text.secondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.unlocked
                      ? _formatDateTime(achievement.unlockedAt)
                      : 'Locked',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: achievement.unlocked ? tokens.warning : tokens.text.secondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return 'Unlocked recently';
  }

  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year} ${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}
