import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/learning_journey/completion_snapshot_models.dart';
import '../../../../core/learning_journey/result_action_models.dart';
import '../../../../core/theme/theme_extensions.dart';
import 'completion_action_card.dart';
import 'completion_metric_card.dart';

class CompletionSnapshotSection extends StatelessWidget {
  const CompletionSnapshotSection({
    super.key,
    required this.snapshot,
    required this.onActionPressed,
  });

  final CompletionSnapshot snapshot;
  final ValueChanged<ResultNextAction> onActionPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final progress = snapshot.todayGoalProgress?.progressPercent?.clamp(0, 100) ?? 0;
    final primaryScoreDisplay = snapshot.primaryScoreDisplay;
    final nextAction = snapshot.nextAction;
    final secondaryAction = snapshot.secondaryAction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.completionTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if ((primaryScoreDisplay ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  snapshot.primaryScoreLabel ?? 'Score',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.text.secondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  primaryScoreDisplay ?? '',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: tokens.primary,
                      ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (snapshot.xpEarned != null)
                    _BadgeChip(
                      label: '+${snapshot.xpEarned} XP',
                      color: tokens.secondary,
                    ),
                  if (snapshot.streakKept == true)
                    _BadgeChip(
                      label: 'Streak kept',
                      color: tokens.warning,
                    ),
                  _BadgeChip(
                    label: snapshot.module,
                    color: tokens.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (snapshot.scoreSummary.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ScoreSummaryList(items: snapshot.scoreSummary),
        ],
        if (snapshot.deltas.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What moved', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 14),
                ...snapshot.deltas.map(
                  (delta) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(delta.label)),
                        const SizedBox(width: 12),
                        Text(
                          delta.displayValue ?? delta.value?.toString() ?? '-',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: delta.positive == false
                                    ? tokens.danger
                                    : tokens.success,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (snapshot.improvements.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keep improving', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 14),
                ...snapshot.improvements.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tokens.background.panelStrong,
                        borderRadius: BorderRadius.circular(tokens.radius.xl),
                        border: Border.all(color: tokens.border.subtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: Theme.of(context).textTheme.titleSmall),
                          if ((item.description ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(item.description ?? ''),
                          ],
                          if ((item.highlight ?? '').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              item.highlight ?? '',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: tokens.primary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (snapshot.todayGoalProgress != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today goal', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text(
                  snapshot.todayGoalProgress?.label ??
                      '${snapshot.todayGoalProgress?.completedMinutes ?? 0}/${snapshot.todayGoalProgress?.targetMinutes ?? 0} min',
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (nextAction != null) ...[
          const SizedBox(height: 12),
          CompletionActionCard(
            title: 'Next action',
            action: nextAction,
            onPressed: () => onActionPressed(nextAction),
          ),
        ],
        if (secondaryAction != null) ...[
          const SizedBox(height: 12),
          CompletionActionCard(
            title: 'Open again',
            action: secondaryAction,
            outline: true,
            onPressed: () => onActionPressed(secondaryAction),
          ),
        ],
      ],
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
            ),
      ),
    );
  }
}

class _ScoreSummaryList extends StatelessWidget {
  const _ScoreSummaryList({
    required this.items,
  });

  final List<CompletionScoreSummary> items;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useTwoColumns = screenWidth > 560;
    final children = <Widget>[];

    for (var index = 0; index < items.length; index += useTwoColumns ? 2 : 1) {
      final first = items[index];
      final second =
          useTwoColumns && index + 1 < items.length ? items[index + 1] : null;

      children.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CompletionMetricCard(
                label: first.label,
                value: first.displayValue ?? first.value?.toString() ?? '-',
                caption: first.description,
              ),
            ),
            if (useTwoColumns) ...[
              const SizedBox(width: 12),
              Expanded(
                child: second == null
                    ? const SizedBox.shrink()
                    : CompletionMetricCard(
                        label: second.label,
                        value: second.displayValue ?? second.value?.toString() ?? '-',
                        caption: second.description,
                      ),
              ),
            ],
          ],
        ),
      );

      if (index + (useTwoColumns ? 2 : 1) < items.length) {
        children.add(const SizedBox(height: 12));
      }
    }

    return Column(
      children: children,
    );
  }
}
