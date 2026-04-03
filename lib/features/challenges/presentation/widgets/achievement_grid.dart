import 'package:flutter/material.dart';

import '../../../../core/retention/achievement_models.dart';
import 'achievement_card.dart';

class AchievementGrid extends StatelessWidget {
  const AchievementGrid({
    super.key,
    required this.achievements,
  });

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const Text('No achievements unlocked yet.');
    }

    return Column(
      children: [
        for (var index = 0; index < achievements.length; index += 1) ...[
          AchievementCard(achievement: achievements[index]),
          if (index != achievements.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
