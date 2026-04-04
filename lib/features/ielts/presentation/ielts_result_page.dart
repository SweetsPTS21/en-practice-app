import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/learning_journey/result_action_models.dart';
import '../../../core/navigation/learning_action_resolver.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../results/presentation/widgets/completion_snapshot_section.dart';
import '../../../core/learning_journey/learning_journey_providers.dart';
import '../application/ielts_controllers.dart';
import 'widgets/ielts_practice_widgets.dart';

class IeltsResultPage extends ConsumerWidget {
  const IeltsResultPage({super.key, required this.attemptId});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(ieltsResultBundleProvider(attemptId));
    return AppPageScaffold(
      title: 'IELTS result',
      subtitle: 'Review the score, inspect answers, and reopen the next best step.',
      paletteKey: AppPagePaletteKey.ielts,
      onRefresh: () async {
        ref.invalidate(ieltsResultBundleProvider(attemptId));
      },
      children: [
        switch (result) {
          AsyncData(:final value) => _LoadedResult(
              bundle: value,
              onActionPressed: (action) => _handleAction(context, ref, action),
            ),
          AsyncError() => AppErrorCard(
              title: 'Result unavailable',
              message: 'This IELTS result could not be loaded right now.',
              onRetry: () => ref.invalidate(ieltsResultBundleProvider(attemptId)),
            ),
          _ => const AppLoadingCard(height: 280, message: 'Loading result...'),
        },
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    ResultNextAction action,
  ) async {
    final outcome = await ref
        .read(learningJourneyActionServiceProvider)
        .prepareResultAction(
          source: 'IELTS_RESULT_PAGE',
          module: 'IELTS',
          resultReferenceType: 'IELTS_ATTEMPT',
          resultReferenceId: attemptId,
          action: action,
        );

    if (!context.mounted) {
      return;
    }

    if (outcome.target.kind == LearningActionKind.external) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('External destinations are not supported here.')),
      );
      return;
    }

    context.go(outcome.target.href);
  }
}

class _LoadedResult extends StatelessWidget {
  const _LoadedResult({
    required this.bundle,
    required this.onActionPressed,
  });

  final IeltsResultBundle bundle;
  final ValueChanged<ResultNextAction> onActionPressed;

  @override
  Widget build(BuildContext context) {
    final attempt = bundle.attempt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(attempt.testTitle, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: attempt.primaryScoreLabel,
                      value: attempt.primaryScoreDisplay,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricTile(
                      label: 'Correct',
                      value: '${attempt.correctCount}/${attempt.questionCount}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricTile(
                      label: 'Mode',
                      value: attempt.attemptMode.label,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (attempt.completionSnapshot != null) ...[
          const SizedBox(height: 12),
          CompletionSnapshotSection(
            snapshot: attempt.completionSnapshot!,
            onActionPressed: onActionPressed,
          ),
        ],
        if (attempt.metrics.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score summary', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (var index = 0; index < attempt.metrics.length; index++) ...[
                  Row(
                    children: [
                      Expanded(child: Text(attempt.metrics[index].label)),
                      const SizedBox(width: 12),
                      Text(
                        attempt.metrics[index].displayValue,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: context.tokens.primary,
                        ),
                      ),
                    ],
                  ),
                  if (index != attempt.metrics.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
        if (bundle.transcript?.hasContent == true) ...[
          const SizedBox(height: 12),
          IeltsTranscriptReviewCard(transcript: bundle.transcript!),
        ],
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Answer review', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (var index = 0; index < attempt.questions.length; index++) ...[
                IeltsAnswerReviewCard(question: attempt.questions[index]),
                if (index != attempt.questions.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(context.tokens.radius.xl),
        border: Border.all(color: context.tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.tokens.text.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
