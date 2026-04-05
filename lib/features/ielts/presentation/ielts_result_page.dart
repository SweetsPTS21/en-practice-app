import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';
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
      subtitle:
          'Review the score, inspect answers, and reopen the next best step.',
      paletteKey: AppPagePaletteKey.ielts,
      onRefresh: () async {
        ref.invalidate(ieltsResultBundleProvider(attemptId));
      },
      children: [
        switch (result) {
          AsyncData(:final value) => _LoadedResult(bundle: value),
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
}

class _LoadedResult extends StatelessWidget {
  const _LoadedResult({required this.bundle});

  final IeltsResultBundle bundle;

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
              Text(
                attempt.testTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ResultMetric(
                      label: attempt.primaryScoreLabel,
                      value: attempt.primaryScoreDisplay,
                    ),
                  ),
                  _MetricDivider(),
                  Expanded(
                    child: _ResultMetric(
                      label: 'Correct',
                      value: '${attempt.correctCount}/${attempt.questionCount}',
                    ),
                  ),
                  _MetricDivider(),
                  Expanded(
                    child: _ResultMetric(
                      label: 'Time',
                      value: _formatAttemptDuration(attempt.timeSpentSeconds),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (bundle.transcript?.hasContent == true) ...[
          const SizedBox(height: 12),
          IeltsTranscriptReviewCard(transcript: bundle.transcript!),
        ],
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Answer review',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (
                var index = 0;
                index < attempt.questions.length;
                index++
              ) ...[
                IeltsAnswerReviewCard(
                  displayIndex: index + 1,
                  question: attempt.questions[index],
                ),
                if (index != attempt.questions.length - 1) ...[
                  const SizedBox(height: 12),
                  Divider(color: context.tokens.border.subtle),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.tokens.text.secondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: context.tokens.primary),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: context.tokens.border.subtle,
    );
  }
}

String _formatAttemptDuration(int? timeSpentSeconds) {
  if (timeSpentSeconds == null || timeSpentSeconds <= 0) {
    return '-';
  }
  final minutes = timeSpentSeconds / 60;
  if (minutes < 10) {
    return '${minutes.toStringAsFixed(1)} min';
  }
  return '${minutes.round()} min';
}
