import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/theme/theme_extensions.dart';

class WeeklyReportInsightCard extends StatelessWidget {
  const WeeklyReportInsightCard({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            (value ?? '').isEmpty ? 'No data yet for this section.' : value!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.tokens.text.secondary,
                ),
          ),
        ],
      ),
    );
  }
}
