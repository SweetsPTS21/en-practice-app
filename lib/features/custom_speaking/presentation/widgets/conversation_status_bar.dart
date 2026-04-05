import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../application/custom_speaking_chat_controller.dart';

class ConversationStatusBar extends StatelessWidget {
  const ConversationStatusBar({
    super.key,
    required this.state,
    required this.onReplayPrompt,
    required this.onFinishConversation,
    required this.onOpenResult,
  });

  final CustomSpeakingChatState state;
  final VoidCallback onReplayPrompt;
  final VoidCallback onFinishConversation;
  final VoidCallback onOpenResult;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final tokens = context.tokens;

    return AppCard(
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary?.title ?? 'Custom speaking conversation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if ((summary?.topic ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              summary!.topic,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: tokens.text.secondary),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: _statusLabel(summary?.status),
                tone: summary?.isLocked == true
                    ? _StatusTone.warning
                    : _StatusTone.neutral,
              ),
              _StatusPill(
                label: _connectionLabel(state.connectionState),
                tone: switch (state.connectionState) {
                  CustomSpeakingConnectionState.connected => _StatusTone.success,
                  CustomSpeakingConnectionState.fallback => _StatusTone.warning,
                  CustomSpeakingConnectionState.disconnected =>
                    _StatusTone.warning,
                  CustomSpeakingConnectionState.connecting => _StatusTone.neutral,
                },
              ),
              if (summary != null)
                _StatusPill(
                  label: 'Turns ${summary.userTurnCount}/${summary.maxUserTurns}',
                  tone: _StatusTone.neutral,
                ),
              _StatusPill(
                label: summary?.gradingEnabled == false
                    ? 'Practice only'
                    : 'Grading on',
                tone: _StatusTone.neutral,
              ),
            ],
          ),
          if ((state.helperMessage ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.background.frosted,
                borderRadius: BorderRadius.circular(tokens.radius.lg),
                border: Border.all(color: tokens.border.subtle),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Text(
                  state.helperMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(
                label: 'Replay prompt',
                icon: Icons.volume_up_rounded,
                variant: AppButtonVariant.outline,
                onPressed: state.effectiveLatestPrompt == null
                    ? null
                    : onReplayPrompt,
              ),
              if (state.isLocked)
                AppButton(
                  label: 'Open result',
                  icon: Icons.assessment_rounded,
                  onPressed: onOpenResult,
                )
              else
                AppButton(
                  label: state.isFinishing ? 'Finishing...' : 'Finish now',
                  icon: Icons.flag_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: state.canFinish ? onFinishConversation : null,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(String? status) {
    return switch ((status ?? 'IN_PROGRESS').toUpperCase()) {
      'COMPLETED' => 'Completed',
      'GRADING' => 'Grading',
      'GRADED' => 'Graded',
      'FAILED' => 'Needs review',
      _ => 'In progress',
    };
  }

  String _connectionLabel(CustomSpeakingConnectionState state) {
    return switch (state) {
      CustomSpeakingConnectionState.connected => 'Live',
      CustomSpeakingConnectionState.fallback => 'Retry mode',
      CustomSpeakingConnectionState.disconnected => 'Reconnecting',
      CustomSpeakingConnectionState.connecting => 'Connecting',
    };
  }
}

enum _StatusTone { neutral, success, warning }

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.tone,
  });

  final String label;
  final _StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final background = switch (tone) {
      _StatusTone.neutral => tokens.background.frosted,
      _StatusTone.success => tokens.success.withValues(alpha: 0.14),
      _StatusTone.warning => tokens.warning.withValues(alpha: 0.14),
    };
    final foreground = switch (tone) {
      _StatusTone.neutral => tokens.text.secondary,
      _StatusTone.success => tokens.success,
      _StatusTone.warning => tokens.warning,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
