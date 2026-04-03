import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/retention/weekly_challenge_models.dart';

class ChallengeProgressCard extends StatelessWidget {
  const ChallengeProgressCard({
    super.key,
    required this.challenge,
    this.nextStep,
    required this.onOpenReport,
  });

  final WeeklyChallenge challenge;
  final String? nextStep;
  final VoidCallback onOpenReport;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: challenge.completed
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(challenge.completed ? 'Completed' : 'In progress'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(challenge.description),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: challenge.progressPercent),
          const SizedBox(height: 8),
          Text(
            '${challenge.currentValue}/${challenge.targetValue} · +${challenge.rewardXp} XP',
          ),
          if ((nextStep ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(nextStep!),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: challenge.completed
                ? 'See weekly report'
                : 'Use weekly report',
            icon: Icons.calendar_month_rounded,
            onPressed: onOpenReport,
          ),
        ],
      ),
    );
  }
}
