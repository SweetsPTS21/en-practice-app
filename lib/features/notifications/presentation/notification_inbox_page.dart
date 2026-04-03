import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/navigation/learning_action_resolver.dart';
import '../../../core/notifications/notification_models.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/notification_center_controller.dart';
import 'widgets/notification_list.dart';
import 'widgets/notification_settings_card.dart';

class NotificationInboxPage extends ConsumerWidget {
  const NotificationInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notificationCenterControllerProvider);

    return AppPageScaffold(
      title: 'Notification Center',
      subtitle:
          'Review alerts, clear unread items and jump back to the right task.',
      paletteKey: AppPagePaletteKey.profile,
      onRefresh: controller.load,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'Inbox overview',
                subtitle:
                    'Keep only the notifications that still need your attention.',
              ),
              const SizedBox(height: 16),
              Text(
                '${controller.items.where((item) => !item.isRead).length} unread',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: 'Mark all read',
                    icon: Icons.done_all_rounded,
                    variant: AppButtonVariant.outline,
                    onPressed: controller.isSubmitting
                        ? null
                        : controller.markAllAsRead,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (controller.isLoading)
          const AppLoadingCard(height: 220, message: 'Loading notifications...')
        else if (controller.errorMessage != null)
          AppErrorCard(
            title: 'Notifications are unavailable',
            message: controller.errorMessage ?? 'Please try again in a moment.',
            onRetry: controller.load,
          )
        else
          NotificationList(
            items: controller.items,
            onOpen: (item) =>
                _handleOpenNotification(context, controller, item),
            onDelete: controller.deleteNotification,
          ),
        const NotificationSettingsCard(),
      ],
    );
  }

  Future<void> _handleOpenNotification(
    BuildContext context,
    NotificationCenterController controller,
    NotificationItem item,
  ) async {
    final outcome = await controller.openNotification(item);
    if (!context.mounted) {
      return;
    }

    if (outcome.target.kind == LearningActionKind.external) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'External notification routes are not enabled on mobile yet.',
          ),
        ),
      );
      return;
    }

    context.go(outcome.target.href);
  }
}
