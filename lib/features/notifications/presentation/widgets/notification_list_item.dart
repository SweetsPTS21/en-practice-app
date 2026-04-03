import 'package:flutter/material.dart';

import '../../../../core/notifications/notification_models.dart';
import '../../../../core/theme/theme_extensions.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.item,
    required this.onOpen,
    required this.onDelete,
  });

  final NotificationItem item;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final priorityColor = switch (item.priority.toUpperCase()) {
      'HIGH' => tokens.danger,
      'LOW' => tokens.text.secondary,
      _ => tokens.primary,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? tokens.background.panelStrong : tokens.background.elevated,
            borderRadius: BorderRadius.circular(tokens.radius.xl),
            border: Border.all(
              color: item.isRead ? tokens.border.subtle : priorityColor.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(
                  item.isRead ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded,
                  color: priorityColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                    if ((item.body ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.body ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.text.secondary,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(label: item.priority),
                        if ((item.reason ?? '').isNotEmpty)
                          _Chip(label: (item.reason ?? '').replaceAll('_', ' ')),
                        if (item.estimatedMinutes != null)
                          _Chip(label: '${item.estimatedMinutes} min'),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, color: tokens.text.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.background.panel,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
