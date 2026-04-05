import 'package:flutter/material.dart';

import '../../../../core/custom_speaking/custom_speaking_models.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/design/widgets/app_state_widgets.dart';
import '../../../../core/theme/theme_extensions.dart';

class ConversationMessageList extends StatefulWidget {
  const ConversationMessageList({
    super.key,
    required this.messages,
    required this.isWaitingForReply,
  });

  final List<ConversationMessageItem> messages;
  final bool isWaitingForReply;

  @override
  State<ConversationMessageList> createState() => _ConversationMessageListState();
}

class _ConversationMessageListState extends State<ConversationMessageList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant ConversationMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final didChangeLength =
        oldWidget.messages.length != widget.messages.length ||
        oldWidget.isWaitingForReply != widget.isWaitingForReply;
    if (didChangeLength) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty && !widget.isWaitingForReply) {
      return const AppEmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Conversation ready',
        subtitle: 'The first prompt will appear here when the session is ready.',
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 280, maxHeight: 420),
            child: ListView.separated(
              controller: _scrollController,
              itemCount:
                  widget.messages.length + (widget.isWaitingForReply ? 1 : 0),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= widget.messages.length) {
                  return const _TypingBubble();
                }
                return _MessageBubble(item: widget.messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.item});

  final ConversationMessageItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isAi = item.role == ConversationMessageRole.ai;
    final isUser = item.role == ConversationMessageRole.user;

    final alignment = switch (item.role) {
      ConversationMessageRole.ai => Alignment.centerLeft,
      ConversationMessageRole.user => Alignment.centerRight,
      ConversationMessageRole.system => Alignment.center,
    };

    final bubbleColor = switch (item.role) {
      ConversationMessageRole.ai => tokens.background.panelStrong,
      ConversationMessageRole.user => tokens.primary,
      ConversationMessageRole.system => tokens.background.frosted,
    };

    final textColor = isUser ? tokens.text.inverse : tokens.text.primary;
    final captionColor = isUser
        ? tokens.text.inverse.withValues(alpha: 0.82)
        : tokens.text.secondary;

    final captionParts = <String>[
      if ((item.turnType ?? '').trim().isNotEmpty) item.turnType!.trim(),
      if ((item.timeSpentSeconds ?? 0) > 0) '${item.timeSpentSeconds}s',
      if ((item.speechAnalytics?.wordCount ?? 0) > 0)
        '${item.speechAnalytics!.wordCount} words',
      if (item.isPendingSync) 'Sending',
    ];

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(tokens.radius.xl),
            border: Border.all(color: tokens.border.subtle),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAi)
                  _MessageLabel(
                    label: 'AI',
                    color: captionColor,
                  ),
                if (isUser)
                  _MessageLabel(
                    label: 'You',
                    color: captionColor,
                  ),
                if (item.role == ConversationMessageRole.system)
                  _MessageLabel(
                    label: 'Update',
                    color: captionColor,
                  ),
                Text(
                  item.text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: textColor),
                ),
                if (captionParts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    captionParts.join(' • '),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: captionColor),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageLabel extends StatelessWidget {
  const _MessageLabel({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.background.panelStrong,
          borderRadius: BorderRadius.circular(tokens.radius.xl),
          border: Border.all(color: tokens.border.subtle),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TypingDot(delay: 0),
              SizedBox(width: 6),
              _TypingDot(delay: 120),
              SizedBox(width: 6),
              _TypingDot(delay: 240),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});

  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = ((_controller.value * 1000) + widget.delay) % 1000 / 1000;
        final opacity = 0.35 + (phase < 0.5 ? phase : 1 - phase) * 1.3;
        return Opacity(
          opacity: opacity.clamp(0.35, 1.0),
          child: child,
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: tokens.text.secondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
