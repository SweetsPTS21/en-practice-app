import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/navigation/learning_action_resolver.dart';
import '../../../core/notifications/notification_models.dart';
import '../../../core/recommendation/recommendation_surface.dart';
import '../../../core/theme/page_palettes.dart';
import '../../recommendation/presentation/widgets/recommendation_surface_slot.dart';
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
          'Unread badge, action routing, mark-read flows and in-app re-entry now live in the mobile shell.',
      paletteKey: AppPagePaletteKey.profile,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    onPressed: controller.isSubmitting ? null : controller.markAllAsRead,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (controller.isLoading)
          const AppCard(
            child: SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (controller.errorMessage != null)
          AppCard(
            child: Column(
              children: [
                Text(controller.errorMessage ?? 'Unknown notification error'),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Retry',
                  icon: Icons.refresh_rounded,
                  onPressed: controller.load,
                ),
              ],
            ),
          )
        else
          NotificationList(
            items: controller.items,
            onOpen: (item) => _handleOpenNotification(context, controller, item),
            onDelete: controller.deleteNotification,
          ),
        const RecommendationSurfaceSlot(
          surface: RecommendationSurface.notification,
          source: 'NOTIFICATION_RECOMMENDATION',
          showFeedbackActions: true,
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
        const SnackBar(content: Text('External notification routes are not enabled on mobile yet.')),
      );
      return;
    }

    context.go(outcome.target.href);
  }
}
