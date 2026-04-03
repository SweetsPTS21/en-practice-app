import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_state_widgets.dart';
import '../../../../core/notifications/notification_models.dart';
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
      return const AppEmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications yet',
        subtitle: 'New reminders, results and updates will appear here.',
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
