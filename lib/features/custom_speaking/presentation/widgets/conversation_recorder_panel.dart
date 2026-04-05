import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../application/custom_speaking_chat_controller.dart';

class ConversationRecorderPanel extends StatelessWidget {
  const ConversationRecorderPanel({
    super.key,
    required this.state,
    required this.transcriptController,
    required this.onTranscriptChanged,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onClearTranscript,
    required this.onSendAnswer,
  });

  final CustomSpeakingChatState state;
  final TextEditingController transcriptController;
  final ValueChanged<String> onTranscriptChanged;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onClearTranscript;
  final VoidCallback onSendAnswer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final timerLabel = _formatDuration(state.turnTimer);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your response', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            state.sttSupported
                ? 'Speak naturally. The transcript updates while you record, and you can review it before sending.'
                : 'Record your answer first, then review the transcript before sending it.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TimerChip(
                icon: state.recording
                    ? Icons.mic_rounded
                    : Icons.timer_outlined,
                label: timerLabel,
              ),
              const SizedBox(width: 8),
              _TimerChip(
                icon: state.sttSupported
                    ? Icons.hearing_rounded
                    : Icons.keyboard_alt_rounded,
                label: state.sttSupported
                    ? 'Live transcript'
                    : 'Transcript mode',
              ),
            ],
          ),
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
                  'Record your answer first. You can adjust the transcript before sending it to the AI.',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(
                label: state.recording ? 'Stop recording' : 'Start recording',
                icon: state.recording ? Icons.stop_rounded : Icons.mic_rounded,
                variant: AppButtonVariant.outline,
                onPressed: state.isBusy
                    ? null
                    : (state.recording ? onStopRecording : onStartRecording),
              ),
              AppButton(
                label: 'Clear',
                icon: Icons.close_rounded,
                variant: AppButtonVariant.outline,
                onPressed: state.isBusy ? null : onClearTranscript,
              ),
              AppButton(
                label: state.isSubmitting ? 'Sending...' : 'Send answer',
                icon: Icons.send_rounded,
                onPressed: state.canSend ? onSendAnswer : null,
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

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.icon, required this.label});

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
