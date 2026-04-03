import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/theme/theme_extensions.dart';

class CompletionMetricCard extends StatelessWidget {
  const CompletionMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.accentColor,
  });

  final String label;
  final String value;
  final String? caption;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final effectiveAccent = accentColor ?? tokens.primary;
    final captionText = caption;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.text.secondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: effectiveAccent,
                ),
          ),
          if ((captionText ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              captionText ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
