import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/custom_speaking/custom_speaking_models.dart';
import '../../../core/custom_speaking/custom_speaking_providers.dart';
import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';

class CustomSpeakingChatPage extends ConsumerStatefulWidget {
  const CustomSpeakingChatPage({
    super.key,
    required this.conversationId,
    this.bootstrap,
  });

  final String conversationId;
  final CustomSpeakingStep? bootstrap;

  @override
  ConsumerState<CustomSpeakingChatPage> createState() =>
      _CustomSpeakingChatPageState();
}

class _CustomSpeakingChatPageState
    extends ConsumerState<CustomSpeakingChatPage> {
  late final TextEditingController _transcriptController;
  bool _isLoading = true;
  bool _isSubmitting = false;
  CustomSpeakingConversation? _conversation;
  String? _error;
  DateTime _turnOpenedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadConversation());
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingPrompt =
        _conversation?.pendingTurn?.aiMessage ?? widget.bootstrap?.aiMessage;

    return AppPageScaffold(
      title: 'Custom conversation',
      subtitle:
          'Freestyle custom speaking stays on REST polling for mobile phase 7, but still supports grading, history, and revisit semantics.',
      paletteKey: AppPagePaletteKey.speaking,
      children: [
        if (_isLoading)
          const AppLoadingCard(
            height: 220,
            message: 'Loading custom conversation...',
          )
        else if (_error != null)
          AppErrorCard(
            title: 'Custom conversation is unavailable',
            message: _error!,
            onRetry: _loadConversation,
          )
        else ...[
          AppCard(
            strong: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _conversation?.title ??
                      widget.bootstrap?.title ??
                      'Conversation',
                ),
                const SizedBox(height: 8),
                Text(_conversation?.topic ?? ''),
                const SizedBox(height: 8),
                Text(
                  'Turns ${_conversation?.userTurnCount ?? widget.bootstrap?.userTurnCount ?? 0}/${_conversation?.maxUserTurns ?? widget.bootstrap?.maxUserTurns ?? 0}',
                ),
                const SizedBox(height: 16),
                Text(
                  pendingPrompt ?? 'The conversation is ready to finish.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _transcriptController,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Write the answer you spoke...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AppButton(
                      label: _isSubmitting ? 'Sending...' : 'Send turn',
                      icon: Icons.send_rounded,
                      onPressed: _isSubmitting
                          ? null
                          : () => _sendTurn(context),
                    ),
                    AppButton(
                      label: 'Finish now',
                      variant: AppButtonVariant.outline,
                      onPressed: _isSubmitting
                          ? null
                          : () => _finishConversation(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if ((_conversation?.turns ?? const <CustomSpeakingTurn>[]).isNotEmpty)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversation turns',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ..._conversation!.turns.map(
                    (turn) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI: ${turn.aiMessage}'),
                          const SizedBox(height: 6),
                          Text(
                            'You: ${turn.userTranscript ?? 'Waiting for answer'}',
                          ),
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

  Future<void> _loadConversation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conversation = await ref
          .read(customSpeakingApiProvider)
          .getConversation(widget.conversationId);
      if (!mounted) {
        return;
      }

      if (conversation.status.toUpperCase() != 'IN_PROGRESS') {
        context.go('/custom-speaking/result/${conversation.id}');
        return;
      }

      setState(() {
        _conversation = conversation;
        _isLoading = false;
        _turnOpenedAt = DateTime.now();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendTurn(BuildContext context) async {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final step = await ref
          .read(customSpeakingApiProvider)
          .submitTurn(
            widget.conversationId,
            SubmitCustomSpeakingTurnPayload(
              transcript: transcript,
              timeSpentSeconds: _elapsedSeconds(_turnOpenedAt),
            ),
          );
      if (!context.mounted) {
        return;
      }

      _transcriptController.clear();
      if (step.conversationComplete) {
        context.go('/custom-speaking/result/${step.conversationId}');
        return;
      }

      await _loadConversation();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _finishConversation(BuildContext context) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final step = await ref
          .read(customSpeakingApiProvider)
          .finishConversation(widget.conversationId);
      if (!context.mounted) {
        return;
      }
      context.go('/custom-speaking/result/${step.conversationId}');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  int _elapsedSeconds(DateTime openedAt) {
    final seconds = DateTime.now().difference(openedAt).inSeconds;
    return seconds <= 0 ? 1 : seconds;
  }
}
