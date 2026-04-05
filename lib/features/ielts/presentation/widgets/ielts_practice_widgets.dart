import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/ielts/ielts_models.dart';
import '../../../../core/theme/theme_extensions.dart';
import 'ielts_markdown_block.dart';

class IeltsSessionTimer extends StatelessWidget {
  const IeltsSessionTimer({
    super.key,
    required this.label,
    required this.seconds,
  });

  final String label;
  final int? seconds;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final safeSeconds = seconds ?? 0;
    final minutes = safeSeconds ~/ 60;
    final remainSeconds = safeSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.text.secondary),
          ),
          const SizedBox(height: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${remainSeconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class IeltsQuestionNavigator extends StatelessWidget {
  const IeltsQuestionNavigator({
    super.key,
    required this.questions,
    required this.focusedQuestionId,
    required this.answers,
    required this.onQuestionPressed,
  });

  final List<IeltsQuestion> questions;
  final String focusedQuestionId;
  final Map<String, List<String>> answers;
  final ValueChanged<IeltsQuestion> onQuestionPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question navigator', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: questions.map((question) {
              final values = answers[question.questionId] ?? const <String>[];
              final answered = values.any((value) => value.trim().isNotEmpty);
              final focused = question.questionId == focusedQuestionId;
              final color = focused
                  ? tokens.primary
                  : answered
                  ? tokens.success
                  : tokens.text.secondary;
              return InkWell(
                onTap: () => onQuestionPressed(question),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: focused ? 0.16 : 0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: color.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    question.navigatorLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class IeltsQuestionRenderer extends StatelessWidget {
  const IeltsQuestionRenderer({
    super.key,
    required this.question,
    required this.answers,
    required this.onSingleAnswerSelected,
    required this.onMultipleAnswerToggled,
    required this.onSlotAnswerChanged,
    this.showContextText = true,
    this.showPassageTitle = true,
  });

  final IeltsQuestion question;
  final List<String> answers;
  final ValueChanged<String> onSingleAnswerSelected;
  final ValueChanged<String> onMultipleAnswerToggled;
  final void Function(int slotIndex, String answer) onSlotAnswerChanged;
  final bool showContextText;
  final bool showPassageTitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final choiceOptions = question.options.isNotEmpty
        ? question.options
        : _fallbackOptions(question.type);

    return AppCard(
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPassageTitle && (question.passageTitle ?? '').isNotEmpty) ...[
            Text(
              question.passageTitle!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: tokens.primary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (showContextText && (question.contextText ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.background.panel,
                borderRadius: BorderRadius.circular(tokens.radius.xl),
                border: Border.all(color: tokens.border.subtle),
              ),
              child: Text(question.contextText!),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if ((question.instruction ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              question.instruction!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
            ),
          ],
          const SizedBox(height: 16),
          if (question.type.isSingleSelection)
            _SingleSelectionGroup(
              options: choiceOptions,
              selectedValue: answers.isEmpty ? null : answers.first,
              onSelected: onSingleAnswerSelected,
            )
          else if (question.type.isMultiSelection)
            _MultiSelectionGroup(
              options: choiceOptions,
              selectedValues: answers,
              onToggled: onMultipleAnswerToggled,
            )
          else if (question.type.usesSlotSelection)
            _SlotSelectionGroup(
              slots: question.answerSlots,
              answers: answers,
              onChanged: onSlotAnswerChanged,
            )
          else
            _TextSlotGroup(
              slots: question.answerSlots.isEmpty
                  ? const [
                      IeltsAnswerSlot(
                        id: 'slot_0',
                        label: 'Answer',
                        placeholder: 'Your answer',
                        options: <IeltsAnswerOption>[],
                      ),
                    ]
                  : question.answerSlots,
              answers: answers,
              onChanged: onSlotAnswerChanged,
            ),
        ],
      ),
    );
  }
}

class IeltsAnswerReviewCard extends StatelessWidget {
  const IeltsAnswerReviewCard({
    super.key,
    required this.displayIndex,
    required this.question,
  });

  final int displayIndex;
  final IeltsQuestion question;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final submitted = question.submittedAnswers.where((item) => item.isNotEmpty).toList();
    final correct = question.correctAnswers.where((item) => item.isNotEmpty).toList();
    final matched = submitted.isNotEmpty &&
        correct.isNotEmpty &&
        submitted.length == correct.length &&
        submitted.every((value) => correct.contains(value));
    final statusColor = matched ? tokens.success : tokens.danger;
    final statusIcon = matched
        ? Icons.check_circle_rounded
        : Icons.close_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: tokens.background.panelStrong,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.border.subtle),
              ),
              alignment: Alignment.center,
              child: Text(
                '$displayIndex',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          question.prompt,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  statusIcon,
                  size: 18,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InlineReviewRow(
                    label: 'Your answer',
                    value: submitted.isEmpty ? 'No answer' : submitted.join(', '),
                  ),
                  const SizedBox(height: 6),
                  _InlineReviewRow(
                    label: 'Correct answer',
                    value: correct.isEmpty ? 'Unavailable' : correct.join(', '),
                  ),
                  if ((question.explanation ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ReviewRow(label: 'Why', value: question.explanation!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class IeltsTranscriptReviewCard extends StatelessWidget {
  const IeltsTranscriptReviewCard({
    super.key,
    required this.transcript,
  });

  final IeltsTranscript transcript;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Listening transcript', style: Theme.of(context).textTheme.titleLarge),
          if ((transcript.summary ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            IeltsMarkdownBlock(data: transcript.summary!),
          ],
          const SizedBox(height: 14),
          for (var index = 0; index < transcript.segments.length; index++) ...[
            _TranscriptSegmentTile(segment: transcript.segments[index]),
            if (index != transcript.segments.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SingleSelectionGroup extends StatelessWidget {
  const _SingleSelectionGroup({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<IeltsAnswerOption> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: options.map((option) {
        final selected = selectedValue == option.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onSelected(option.value),
            borderRadius: BorderRadius.circular(tokens.radius.xl),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (selected ? tokens.primary : tokens.background.panelStrong)
                    .withValues(alpha: selected ? 0.12 : 1),
                borderRadius: BorderRadius.circular(tokens.radius.xl),
                border: Border.all(
                  color: (selected ? tokens.primary : tokens.border.subtle)
                      .withValues(alpha: selected ? 0.24 : 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected ? tokens.primary : tokens.text.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(option.label)),
                ],
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _MultiSelectionGroup extends StatelessWidget {
  const _MultiSelectionGroup({
    required this.options,
    required this.selectedValues,
    required this.onToggled,
  });

  final List<IeltsAnswerOption> options;
  final List<String> selectedValues;
  final ValueChanged<String> onToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map(
            (option) => CheckboxListTile(
              value: selectedValues.contains(option.value),
              onChanged: (_) => onToggled(option.value),
              title: Text(option.label),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SlotSelectionGroup extends StatelessWidget {
  const _SlotSelectionGroup({
    required this.slots,
    required this.answers,
    required this.onChanged,
  });

  final List<IeltsAnswerSlot> slots;
  final List<String> answers;
  final void Function(int slotIndex, String answer) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: slots.asMap().entries.map((entry) {
        final index = entry.key;
        final slot = entry.value;
        final current = index < answers.length ? answers[index] : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            initialValue: current?.isEmpty == true ? null : current,
            items: slot.options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(option.label),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) => onChanged(index, value ?? ''),
            decoration: InputDecoration(
              labelText: slot.label,
              hintText: slot.placeholder,
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _TextSlotGroup extends StatelessWidget {
  const _TextSlotGroup({
    required this.slots,
    required this.answers,
    required this.onChanged,
  });

  final List<IeltsAnswerSlot> slots;
  final List<String> answers;
  final void Function(int slotIndex, String answer) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: slots.asMap().entries.map((entry) {
        final index = entry.key;
        final slot = entry.value;
        final current = index < answers.length ? answers[index] : '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TextSlotField(
            key: ValueKey(slot.id),
            slot: slot,
            value: current,
            onChanged: (value) => onChanged(index, value),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _TextSlotField extends StatefulWidget {
  const _TextSlotField({
    super.key,
    required this.slot,
    required this.value,
    required this.onChanged,
  });

  final IeltsAnswerSlot slot;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_TextSlotField> createState() => _TextSlotFieldState();
}

class _TextSlotFieldState extends State<_TextSlotField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _TextSlotField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text == widget.value) {
      return;
    }
    final selection = _controller.selection;
    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset.clamp(0, widget.value.length),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      minLines: 1,
      maxLines: widget.slot.placeholder.length > 24 ? 2 : 1,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.slot.label,
        hintText: widget.slot.placeholder,
      ),
    );
  }
}

class _InlineReviewRow extends StatelessWidget {
  const _InlineReviewRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              color: tokens.text.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: tokens.text.secondary),
        ),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}

class _TranscriptSegmentTile extends StatelessWidget {
  const _TranscriptSegmentTile({required this.segment});

  final IeltsTranscriptSegment segment;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final timestamp = segment.startSeconds == null
        ? null
        : '${(segment.startSeconds! ~/ 60).toString().padLeft(2, '0')}:${(segment.startSeconds! % 60).toString().padLeft(2, '0')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timestamp == null ? segment.speaker : '${segment.speaker} · $timestamp',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: tokens.primary,
            ),
          ),
          const SizedBox(height: 6),
          IeltsMarkdownBlock(data: segment.text),
        ],
      ),
    );
  }
}

List<IeltsAnswerOption> _fallbackOptions(IeltsQuestionType type) {
  switch (type) {
    case IeltsQuestionType.trueFalseNotGiven:
      return const [
        IeltsAnswerOption(value: 'TRUE', label: 'True'),
        IeltsAnswerOption(value: 'FALSE', label: 'False'),
        IeltsAnswerOption(value: 'NOT_GIVEN', label: 'Not given'),
      ];
    case IeltsQuestionType.yesNoNotGiven:
      return const [
        IeltsAnswerOption(value: 'YES', label: 'Yes'),
        IeltsAnswerOption(value: 'NO', label: 'No'),
        IeltsAnswerOption(value: 'NOT_GIVEN', label: 'Not given'),
      ];
    default:
      return const <IeltsAnswerOption>[];
  }
}
