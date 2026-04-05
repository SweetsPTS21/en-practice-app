import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../../speaking/application/speaking_controllers.dart';
import '../../speaking/presentation/widgets/speaking_answer_composer_card.dart';
import '../application/speaking_conversation_controller.dart';

class SpeakingConversationPage extends ConsumerStatefulWidget {
  const SpeakingConversationPage({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<SpeakingConversationPage> createState() =>
      _SpeakingConversationPageState();
}

class _SpeakingConversationPageState
    extends ConsumerState<SpeakingConversationPage> {
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
    final topic = ref.watch(speakingTopicDetailProvider(widget.topicId));
    final provider = speakingConversationControllerProvider(widget.topicId);
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
      title: 'Guided conversation',
      subtitle:
          'Record each answer, keep the transcript in sync, and move through the interview turn by turn.',
      paletteKey: AppPagePaletteKey.speaking,
      children: [
        switch (topic) {
          AsyncData(:final value) => AppCard(
            strong: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.question,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('${value.part} • ${value.difficulty}'),
              ],
            ),
          ),
          _ => const SizedBox.shrink(),
        },
        if (state.isLoading)
          const AppLoadingCard(
            height: 220,
            message: 'Starting guided conversation...',
          )
        else if (state.loadErrorMessage != null)
          AppErrorCard(
            title: 'Conversation could not start',
            message: state.loadErrorMessage!,
            onRetry: controller.retry,
          )
        else ...[
          AppCard(
            strong: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.step?.aiQuestion ?? 'Preparing the next question...',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Turn ${state.step?.turnNumber ?? 0}${state.step?.lastTurn == true ? ' • Final question' : ''}',
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Conversation history',
                  icon: Icons.history_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.go('/speaking/conversation/history'),
                ),
              ],
            ),
          ),
          SpeakingAnswerComposerCard(
            title: 'Record this answer',
            subtitle:
                'Start recording, answer the prompt naturally, then send the reviewed transcript to continue.',
            transcriptController: _transcriptController,
            onTranscriptChanged: controller.updateTranscript,
            onStartRecording: () =>
                _runAction(context, controller.startRecording),
            onStopRecording: () =>
                _runAction(context, controller.stopRecording),
            onClearTranscript: () => _runAction(context, controller.clearDraft),
            onSubmit: () => _runAction(context, controller.submitTurn),
            isBusy: state.isSubmitting,
            isRecording: state.isRecording,
            sttSupported: state.sttSupported,
            canSubmit: state.canSend,
            timer: state.timer,
            submitLabel: state.isSubmitting ? 'Sending...' : 'Send answer',
            helperMessage: state.helperMessage,
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turns so far',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (state.turns.isEmpty)
                  const Text(
                    'Your submitted turns will appear here as the conversation progresses.',
                  )
                else
                  ...state.turns.map(
                    (turn) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI: ${turn.aiQuestion}'),
                          const SizedBox(height: 6),
                          Text('You: ${turn.transcript}'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
