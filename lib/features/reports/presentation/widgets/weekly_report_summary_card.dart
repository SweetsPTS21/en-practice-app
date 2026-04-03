import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/retention/weekly_report_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class WeeklyReportSummaryCard extends StatelessWidget {
  const WeeklyReportSummaryCard({
    super.key,
    required this.report,
  });

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week at a glance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(label: 'Study minutes', value: '${report.studyMinutes}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(label: 'Vocabulary', value: '${report.vocabularyLearned}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(label: 'Tests', value: '${report.testsCompleted}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'Band improvement',
                  value: report.bandImprovement == null
                      ? 'Stable'
                      : '+${report.bandImprovement!.toStringAsFixed(1)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.text.secondary,
                ),
          ),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
