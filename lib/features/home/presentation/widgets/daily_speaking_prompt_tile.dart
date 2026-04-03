import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/retention/flagship_retention_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class DailySpeakingPromptTile extends StatelessWidget {
  const DailySpeakingPromptTile({
    super.key,
    required this.prompt,
    required this.onPressed,
  });

  final DailySpeakingPrompt prompt;
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
                  color: tokens.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(Icons.mic_rounded, color: tokens.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily speaking prompt',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: tokens.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prompt.topic,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prompt.prompt,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: prompt.persona),
              if (prompt.estimatedMinutes != null)
                _Chip(label: '${prompt.estimatedMinutes} min'),
              if (prompt.difficulty.isNotEmpty) _Chip(label: prompt.difficulty),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: prompt.resumeState == 'RESUME'
                ? 'Resume speaking'
                : 'Start speaking',
            icon: Icons.play_arrow_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
