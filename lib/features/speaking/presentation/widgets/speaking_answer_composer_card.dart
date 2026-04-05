import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/theme/theme_extensions.dart';

class SpeakingAnswerComposerCard extends StatelessWidget {
  const SpeakingAnswerComposerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.transcriptController,
    required this.onTranscriptChanged,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onClearTranscript,
    required this.onSubmit,
    required this.isBusy,
    required this.isRecording,
    required this.sttSupported,
    required this.canSubmit,
    required this.timer,
    required this.submitLabel,
    this.helperMessage,
  });

  final String title;
  final String subtitle;
  final TextEditingController transcriptController;
  final ValueChanged<String> onTranscriptChanged;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onClearTranscript;
  final VoidCallback onSubmit;
  final bool isBusy;
  final bool isRecording;
  final bool sttSupported;
  final bool canSubmit;
  final Duration timer;
  final String submitLabel;
  final String? helperMessage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: isRecording ? Icons.mic_rounded : Icons.timer_outlined,
                label: _formatDuration(timer),
              ),
              _InfoChip(
                icon: sttSupported
                    ? Icons.hearing_rounded
                    : Icons.subtitles_outlined,
                label: sttSupported ? 'Live transcript' : 'Transcript review',
              ),
            ],
          ),
          if ((helperMessage ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.background.frosted,
                borderRadius: BorderRadius.circular(tokens.radius.lg),
                border: Border.all(color: tokens.border.subtle),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Text(
                  helperMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: transcriptController,
            onChanged: onTranscriptChanged,
            minLines: 4,
            maxLines: 7,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Transcript review',
              hintText:
                  'Record your answer first. You can adjust the transcript here before sending it.',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(
                label: isRecording ? 'Stop recording' : 'Start recording',
                icon: isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                variant: AppButtonVariant.outline,
                onPressed: isBusy
                    ? null
                    : (isRecording ? onStopRecording : onStartRecording),
              ),
              AppButton(
                label: 'Clear',
                icon: Icons.close_rounded,
                variant: AppButtonVariant.outline,
                onPressed: isBusy ? null : onClearTranscript,
              ),
              AppButton(
                label: submitLabel,
                icon: Icons.send_rounded,
                onPressed: canSubmit ? onSubmit : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.background.frosted,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: tokens.text.secondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: tokens.text.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
