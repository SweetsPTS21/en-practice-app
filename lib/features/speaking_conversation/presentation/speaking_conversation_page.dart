import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/speaking_conversation/speaking_conversation_models.dart';
import '../../../core/speaking_conversation/speaking_conversation_providers.dart';
import '../../../core/theme/page_palettes.dart';
import '../../speaking/application/speaking_controllers.dart';

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
  SpeakingConversationNextStep? _step;
  final List<_TurnLog> _turns = <_TurnLog>[];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  DateTime _turnOpenedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startConversation());
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topic = ref.watch(speakingTopicDetailProvider(widget.topicId));

    return AppPageScaffold(
      title: 'Guided conversation',
      subtitle:
          'This loop starts from a speaking topic, tracks each turn, and opens a dedicated conversation result page once grading is ready.',
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
        if (_isLoading)
          const AppLoadingCard(
            height: 220,
            message: 'Starting guided conversation...',
          )
        else if (_error != null)
          AppErrorCard(
            title: 'Conversation could not start',
            message: _error!,
            onRetry: _startConversation,
          )
        else ...[
          AppCard(
            strong: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _step?.aiQuestion ?? 'Preparing the next question...',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Turn ${_step?.turnNumber ?? 0}${_step?.lastTurn == true ? ' • Final question' : ''}',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _transcriptController,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Type the answer you spoke...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AppButton(
                      label: _isSubmitting ? 'Submitting...' : 'Send answer',
                      icon: Icons.send_rounded,
                      onPressed: _isSubmitting ? null : _submitTurn,
                    ),
                    AppButton(
                      label: 'Conversation history',
                      variant: AppButtonVariant.outline,
                      onPressed: () =>
                          context.go('/speaking/conversation/history'),
                    ),
                  ],
                ),
              ],
            ),
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
                if (_turns.isEmpty)
                  const Text(
                    'Your submitted turns will appear here as the conversation progresses.',
                  )
                else
                  ..._turns.map(
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

  Future<void> _startConversation() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _step = null;
      _turns.clear();
    });

    try {
      final step = await ref
          .read(speakingConversationApiProvider)
          .startConversation(widget.topicId);
      if (!mounted) {
        return;
      }
      setState(() {
        _step = step;
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

  Future<void> _submitTurn() async {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty || _step == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final nextStep = await ref
          .read(speakingConversationApiProvider)
          .submitTurn(
            _step!.conversationId,
            SubmitSpeakingConversationTurnPayload(
              transcript: transcript,
              timeSpentSeconds: _elapsedSeconds(_turnOpenedAt),
            ),
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _turns.add(
          _TurnLog(aiQuestion: _step!.aiQuestion ?? '', transcript: transcript),
        );
        _transcriptController.clear();
        _step = nextStep;
        _turnOpenedAt = DateTime.now();
      });

      if (nextStep.conversationComplete && context.mounted) {
        context.go('/speaking/conversation/result/${nextStep.conversationId}');
      }
    } catch (error) {
      if (!mounted) {
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

class _TurnLog {
  const _TurnLog({required this.aiQuestion, required this.transcript});

  final String aiQuestion;
  final String transcript;
}
