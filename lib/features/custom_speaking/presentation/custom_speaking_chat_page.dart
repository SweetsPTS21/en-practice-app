import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/custom_speaking/custom_speaking_models.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/custom_speaking_chat_controller.dart';
import 'widgets/conversation_message_list.dart';
import 'widgets/conversation_recorder_panel.dart';
import 'widgets/conversation_status_bar.dart';

class CustomSpeakingChatPage extends ConsumerStatefulWidget {
  const CustomSpeakingChatPage({
    super.key,
    required this.conversationId,
    this.bootstrap,
  });

  final String conversationId;
  final CustomSpeakingChatBootstrap? bootstrap;

  @override
  ConsumerState<CustomSpeakingChatPage> createState() =>
      _CustomSpeakingChatPageState();
}

class _CustomSpeakingChatPageState
    extends ConsumerState<CustomSpeakingChatPage> {
  late final TextEditingController _transcriptController;
  late final AutoDisposeNotifierProviderFamily<
    CustomSpeakingChatController,
    CustomSpeakingChatState,
    CustomSpeakingChatArgs
  >
  _providerFactory;
  late final CustomSpeakingChatArgs _args;
  bool _resultNavigationHandled = false;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    _providerFactory = customSpeakingChatControllerProvider;
    _args = CustomSpeakingChatArgs(
      conversationId: widget.conversationId,
      bootstrap: widget.bootstrap,
    );
  }

  @override
  void dispose() {
    unawaited(
      ref.read(_providerFactory(_args).notifier).registerAbandonedIfNeeded(),
    );
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = _providerFactory(_args);
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
      title: 'Custom conversation',
      subtitle:
          'Resume the same speaking thread, record each answer naturally, and hand off to the result page when the conversation finishes.',
      paletteKey: AppPagePaletteKey.speaking,
      onRefresh: controller.refresh,
      children: [
        if (state.isInitialLoading && !state.hasRenderableConversation)
          const AppLoadingCard(
            height: 260,
            message: 'Loading your conversation...',
          )
        else if (state.loadErrorMessage != null &&
            !state.hasRenderableConversation)
          AppErrorCard(
            title: 'Conversation unavailable',
            message: state.loadErrorMessage!,
            onRetry: controller.refresh,
          )
        else ...[
          ConversationStatusBar(
            state: state,
            onReplayPrompt: () =>
                _runAction(context, controller.replayLatestPrompt),
            onFinishConversation: () =>
                _runAction(context, controller.finishConversation),
            onOpenResult: () =>
                context.go('/custom-speaking/result/${widget.conversationId}'),
          ),
          ConversationMessageList(
            messages: state.messages,
            isWaitingForReply: state.isWaitingForReply,
          ),
          if (!state.isLocked)
            ConversationRecorderPanel(
              state: state,
              transcriptController: _transcriptController,
              onTranscriptChanged: controller.updateTranscript,
              onStartRecording: () =>
                  _runAction(context, controller.startRecording),
              onStopRecording: () =>
                  _runAction(context, controller.stopRecording),
              onClearTranscript: () =>
                  _runAction(context, controller.clearDraft),
              onSendAnswer: () => _runAction(context, controller.submitTurn),
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
