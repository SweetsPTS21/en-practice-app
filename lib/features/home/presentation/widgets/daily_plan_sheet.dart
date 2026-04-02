import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../data/home_launchpad_models.dart';

class DailyPlanSheet extends StatelessWidget {
  const DailyPlanSheet({
    super.key,
    required this.plan,
    required this.completedTaskIds,
    required this.onTaskPressed,
  });

  final DailyLearningPlan plan;
  final Set<String> completedTaskIds;
  final ValueChanged<DailyLearningPlanItem> onTaskPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final completedCount = plan.items
        .where((item) => completedTaskIds.contains(item.id))
        .length;
    final goalMinutes = plan.goalMinutes ??
        plan.items.fold<int>(
          0,
          (sum, item) => sum + (item.estimatedMinutes ?? 0),
        );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.border.subtle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('home.dailyPlan.sheetTitle'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('home.dailyPlan.sheetSubtitle'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.text.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: tokens.background.panelStrong,
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    border: Border.all(color: tokens.border.subtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$completedCount/${plan.items.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '$goalMinutes ${context.tr('home.common.minutes')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.text.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: plan.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = plan.items[index];
                  final isCompleted = completedTaskIds.contains(item.id);

                  return AppCard(
                    strong: isCompleted,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? tokens.success.withValues(alpha: 0.14)
                                : tokens.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(tokens.radius.lg),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.play_arrow_rounded,
                            color: isCompleted ? tokens.success : tokens.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: tokens.text.secondary,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _InfoChip(
                                    label: item.type.replaceAll('_', ' '),
                                    color: tokens.primary,
                                  ),
                                  if (item.estimatedMinutes != null)
                                    _InfoChip(
                                      label:
                                          '${item.estimatedMinutes} ${context.tr('home.common.minutes')}',
                                      color: tokens.secondary,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AppButton(
                          label: isCompleted
                              ? context.tr('home.dailyPlan.completed')
                              : item.ctaLabel,
                          icon: isCompleted
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          variant: isCompleted
                              ? AppButtonVariant.outline
                              : AppButtonVariant.filled,
                          onPressed: isCompleted ? null : () => onTaskPressed(item),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
