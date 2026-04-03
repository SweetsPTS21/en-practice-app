import 'package:flutter/material.dart';

import '../../../../core/notifications/notification_models.dart';
import '../../../../core/theme/theme_extensions.dart';
import 'notification_list_item.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onDelete,
  });

  final List<NotificationItem> items;
  final ValueChanged<NotificationItem> onOpen;
  final ValueChanged<NotificationItem> onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.tokens.background.panelStrong,
          borderRadius: BorderRadius.circular(context.tokens.radius.hero),
          border: Border.all(color: context.tokens.border.subtle),
        ),
        child: const Text('No notifications yet.'),
      );
    }

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NotificationListItem(
                item: item,
                onOpen: () => onOpen(item),
                onDelete: () => onDelete(item),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
