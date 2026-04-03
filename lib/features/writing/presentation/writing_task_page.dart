import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/writing/writing_models.dart';
import '../../../core/writing/writing_providers.dart';
import '../application/writing_controllers.dart';

class WritingTaskPage extends ConsumerStatefulWidget {
  const WritingTaskPage({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<WritingTaskPage> createState() => _WritingTaskPageState();
}

class _WritingTaskPageState extends ConsumerState<WritingTaskPage> {
  late final TextEditingController _essayController;
  bool _isSubmitting = false;
  final DateTime _openedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _essayController = TextEditingController();
  }

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(writingTaskDetailProvider(widget.taskId));
    final draft = ref.watch(writingDraftControllerProvider(widget.taskId));
    final draftController = ref.read(
      writingDraftControllerProvider(widget.taskId).notifier,
    );

    if (_essayController.text != draft.essay) {
      _essayController.value = TextEditingValue(
        text: draft.essay,
        selection: TextSelection.collapsed(offset: draft.essay.length),
      );
    }

    final wordCount = _countWords(_essayController.text);

    return AppPageScaffold(
      title: 'Writing session',
      subtitle:
          'Draft locally, keep your place, and submit once the answer is ready for grading.',
      paletteKey: AppPagePaletteKey.writing,
      children: [
        switch (detail) {
          AsyncData(:final value) => AppCard(
            strong: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('${value.taskType} • ${value.difficulty}'),
                const SizedBox(height: 10),
                Text(value.content.isEmpty ? value.instruction : value.content),
                if (value.instruction.isNotEmpty &&
                    value.content.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(value.instruction),
                ],
              ],
            ),
          ),
          AsyncError() => AppErrorCard(
            title: 'Writing session is unavailable',
            message: 'We could not load the selected task.',
            onRetry: () =>
                ref.invalidate(writingTaskDetailProvider(widget.taskId)),
          ),
          _ => const AppLoadingCard(
            height: 220,
            message: 'Preparing writing session...',
          ),
        },
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Draft', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Word count: $wordCount${draft.lastSavedAt == null ? '' : ' • Saved ${_timeAgo(draft.lastSavedAt!)}'}',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _essayController,
                maxLines: 16,
                minLines: 12,
                decoration: const InputDecoration(
                  hintText: 'Write your answer here...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                onChanged: draftController.updateEssay,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  AppButton(
                    label: _isSubmitting
                        ? 'Submitting...'
                        : 'Submit for grading',
                    icon: Icons.send_rounded,
                    onPressed: _isSubmitting || detail.valueOrNull == null
                        ? null
                        : () => _submit(
                            context: context,
                            detail: detail.valueOrNull!,
                            draftController: draftController,
                          ),
                  ),
                  AppButton(
                    label: 'Task detail',
                    variant: AppButtonVariant.outline,
                    onPressed: () =>
                        context.go('/writing/task/${widget.taskId}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submit({
    required BuildContext context,
    required WritingTaskDetail detail,
    required WritingDraftController draftController,
  }) async {
    final essay = _essayController.text.trim();
    final wordCount = _countWords(essay);
    if (essay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before submitting.')),
      );
      return;
    }
    if (detail.minWords > 0 && wordCount < detail.minWords) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This task expects at least ${detail.minWords} words.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final timeSpentSeconds = DateTime.now().difference(_openedAt).inSeconds;
      final submission = await ref
          .read(writingApiProvider)
          .submitEssay(
            widget.taskId,
            SubmitWritingPayload(
              essayContent: essay,
              timeSpentSeconds: timeSpentSeconds <= 0 ? 1 : timeSpentSeconds,
            ),
          );
      await draftController.clear();

      if (!context.mounted) {
        return;
      }
      context.go('/writing/submission/${submission.id}');
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

  int _countWords(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    return trimmed.split(RegExp(r'\s+')).length;
  }

  String _timeAgo(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) {
      return 'just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    }
    return '${diff.inHours}h ago';
  }
}
