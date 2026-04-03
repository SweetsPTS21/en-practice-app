import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/speaking/speaking_models.dart';
import '../../../core/speaking/speaking_providers.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/speaking_controllers.dart';

class SpeakingPracticePage extends ConsumerStatefulWidget {
  const SpeakingPracticePage({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<SpeakingPracticePage> createState() =>
      _SpeakingPracticePageState();
}

class _SpeakingPracticePageState extends ConsumerState<SpeakingPracticePage> {
  late final TextEditingController _transcriptController;
  bool _isSubmitting = false;
  final DateTime _openedAt = DateTime.now();

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

    return AppPageScaffold(
      title: 'Speaking attempt',
      subtitle:
          'Use transcript-first submission as the safe fallback for mobile, then rely on async grading and result re-entry for the score.',
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
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transcript', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'Transcript fallback is enabled by default. Audio upload can be added later without blocking the phase-7 productive loop.',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _transcriptController,
                maxLines: 12,
                minLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Paste or type what you said here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  AppButton(
                    label: _isSubmitting ? 'Submitting...' : 'Submit attempt',
                    icon: Icons.send_rounded,
                    onPressed: _isSubmitting ? null : () => _submit(context),
                  ),
                  AppButton(
                    label: 'Guided conversation',
                    variant: AppButtonVariant.outline,
                    onPressed: () =>
                        context.go('/speaking/conversation/${widget.topicId}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcript is required for submission.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final timeSpentSeconds = DateTime.now().difference(_openedAt).inSeconds;
      final result = await ref
          .read(speakingApiProvider)
          .submitAttempt(
            widget.topicId,
            SubmitSpeakingPayload(
              transcript: transcript,
              timeSpentSeconds: timeSpentSeconds <= 0 ? 1 : timeSpentSeconds,
            ),
          );
      if (!context.mounted) {
        return;
      }
      context.go('/speaking/result/${result.id}');
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
}
