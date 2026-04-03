import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/learning_journey/result_action_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class CompletionActionCard extends StatelessWidget {
  const CompletionActionCard({
    super.key,
    required this.title,
    required this.action,
    required this.onPressed,
    this.outline = false,
  });

  final String title;
  final ResultNextAction action;
  final VoidCallback onPressed;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            action.reason?.replaceAll('_', ' ') ?? action.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.text.secondary,
                ),
          ),
          if (action.estimatedMinutes != null) ...[
            const SizedBox(height: 10),
            Text(
              '${action.estimatedMinutes} min',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: tokens.primary,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          AppButton(
            label: action.label,
            icon: outline ? Icons.open_in_new_rounded : Icons.arrow_forward_rounded,
            variant: outline ? AppButtonVariant.outline : AppButtonVariant.filled,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
