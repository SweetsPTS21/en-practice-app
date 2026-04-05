import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/speaking_attempt_controller.dart';
import '../application/speaking_controllers.dart';
import 'widgets/speaking_answer_composer_card.dart';

class SpeakingPracticePage extends ConsumerStatefulWidget {
  const SpeakingPracticePage({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<SpeakingPracticePage> createState() =>
      _SpeakingPracticePageState();
}

class _SpeakingPracticePageState extends ConsumerState<SpeakingPracticePage> {
  late final TextEditingController _transcriptController;
  bool _resultNavigationHandled = false;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(speakingTopicDetailProvider(widget.topicId));
    final provider = speakingAttemptControllerProvider(widget.topicId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    ref.listen<String?>(provider.select((value) => value.transcriptDraft), (
      previous,
      next,
    ) {
      final text = next ?? '';
      if (_transcriptController.text == text) {
        return;
      }
      _transcriptController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });

    ref.listen<String?>(provider.select((value) => value.pendingResultRoute), (
      previous,
      next,
    ) {
      if (_resultNavigationHandled || next == null || next.isEmpty) {
        return;
      }
      _resultNavigationHandled = true;
      controller.consumePendingResultRoute();
      if (!mounted) {
        return;
      }
      context.go(next);
    });

    return AppPageScaffold(
      title: 'Speaking attempt',
      subtitle:
          'Record your answer first, review the transcript, then send the attempt for grading.',
      paletteKey: AppPagePaletteKey.speaking,
      children: [
        switch (detail) {
          AsyncData(:final value) => AppCard(
            strong: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.question,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text('${value.part} • ${value.difficulty}'),
                if (value.cueCard.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Cue card',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(value.cueCard),
                ],
                if (value.followUpQuestions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Follow-up questions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...value.followUpQuestions.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $item'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppButton(
                  label: 'Guided conversation',
                  icon: Icons.forum_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: () =>
                      context.go('/speaking/conversation/${widget.topicId}'),
                ),
              ],
            ),
          ),
          AsyncError() => AppErrorCard(
            title: 'Speaking topic is unavailable',
            message: 'We could not load this speaking topic.',
            onRetry: () =>
                ref.invalidate(speakingTopicDetailProvider(widget.topicId)),
          ),
          _ => const AppLoadingCard(
            height: 220,
            message: 'Loading speaking topic...',
          ),
        },
        if (detail.hasValue)
          SpeakingAnswerComposerCard(
            title: 'Record your answer',
            subtitle:
                'Tap record, answer naturally, then review the transcript before sending the attempt.',
            transcriptController: _transcriptController,
            onTranscriptChanged: controller.updateTranscript,
            onStartRecording: () =>
                _runAction(context, controller.startRecording),
            onStopRecording: () =>
                _runAction(context, controller.stopRecording),
            onClearTranscript: () => _runAction(context, controller.clearDraft),
            onSubmit: () => _runAction(context, controller.submitAttempt),
            isBusy: state.isSubmitting,
            isRecording: state.isRecording,
            sttSupported: state.sttSupported,
            canSubmit: state.canSubmit,
            timer: state.timer,
            submitLabel: state.isSubmitting
                ? 'Submitting...'
                : 'Submit attempt',
            helperMessage: state.helperMessage,
          ),
      ],
    );
  }

  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
