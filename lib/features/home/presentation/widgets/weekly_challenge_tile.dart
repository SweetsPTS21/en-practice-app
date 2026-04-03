import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/retention/weekly_challenge_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class WeeklyChallengeTile extends StatelessWidget {
  const WeeklyChallengeTile({
    super.key,
    required this.challenge,
    required this.onPressed,
  });

  final WeeklyChallenge challenge;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tokens.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(Icons.emoji_events_rounded, color: tokens.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weekly challenge',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: tokens.secondary,
                              fontWeight: FontWeight.w700,
                            )),
                    const SizedBox(height: 4),
                    Text(challenge.title, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            challenge.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.text.secondary,
                ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: challenge.progressPercent),
          const SizedBox(height: 8),
          Text(
            '${challenge.currentValue}/${challenge.targetValue} · +${challenge.rewardXp} XP',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.text.secondary,
                ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: challenge.completed ? 'View weekly progress' : 'Open challenge',
            icon: Icons.arrow_forward_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
