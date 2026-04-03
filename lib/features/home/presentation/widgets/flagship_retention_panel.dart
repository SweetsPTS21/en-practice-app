import 'package:flutter/material.dart';

import '../../../../core/retention/flagship_retention_models.dart';
import '../../../../core/theme/theme_extensions.dart';
import 'daily_speaking_prompt_tile.dart';
import 'vocab_micro_learning_tile.dart';
import 'weekly_challenge_tile.dart';

class FlagshipRetentionPanel extends StatelessWidget {
  const FlagshipRetentionPanel({
    super.key,
    required this.flagship,
    this.onOpenSpeakingPrompt,
    this.onOpenVocabMicroLearning,
    this.onOpenChallenge,
  });

  final FlagshipRetention flagship;
  final VoidCallback? onOpenSpeakingPrompt;
  final VoidCallback? onOpenVocabMicroLearning;
  final VoidCallback? onOpenChallenge;

  @override
  Widget build(BuildContext context) {
    if (!flagship.hasAnyBlock) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flagship retention',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Daily speaking, vocab micro-learning and weekly challenge stay on one shared loop.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.tokens.text.secondary,
          ),
        ),
        const SizedBox(height: 16),
        if (flagship.dailySpeakingPrompt != null) ...[
          DailySpeakingPromptTile(
            prompt: flagship.dailySpeakingPrompt!,
            onPressed: onOpenSpeakingPrompt ?? () {},
          ),
          const SizedBox(height: 12),
        ],
        if (flagship.vocabMicroLearning != null) ...[
          VocabMicroLearningTile(
            item: flagship.vocabMicroLearning!,
            onPressed: onOpenVocabMicroLearning ?? () {},
          ),
          const SizedBox(height: 12),
        ],
        if (flagship.weeklyChallenge != null)
          WeeklyChallengeTile(
            challenge: flagship.weeklyChallenge!,
            onPressed: onOpenChallenge ?? () {},
          ),
      ],
    );
  }
}
