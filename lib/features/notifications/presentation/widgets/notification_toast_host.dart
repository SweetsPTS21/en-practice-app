import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/learning_analytics_service.dart';
import '../../../../core/learning_journey/learning_journey_action_service.dart';
import '../../../../core/learning_journey/learning_journey_providers.dart';
import '../../../../core/navigation/learning_action_resolver.dart';
import '../../../../core/notifications/notification_models.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/theme/theme_extensions.dart';

class NotificationToastHost extends ConsumerStatefulWidget {
  const NotificationToastHost({super.key});

  @override
  ConsumerState<NotificationToastHost> createState() =>
      _NotificationToastHostState();
}

class _NotificationToastHostState extends ConsumerState<NotificationToastHost> {
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final realtime = ref.watch(notificationRealtimeClientProvider);
    final item = realtime.foregroundNotification;

    if (item == null) {
      return const SizedBox.shrink();
    }

    _dismissTimer?.cancel();
    _dismissTimer = Timer(
      const Duration(seconds: 6),
      () => ref
          .read(notificationRealtimeClientProvider)
          .consumeForegroundNotification(),
    );

    final tokens = context.tokens;
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openNotification(context, item),
            borderRadius: BorderRadius.circular(tokens.radius.hero),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.background.mobileDrawer,
                borderRadius: BorderRadius.circular(tokens.radius.hero),
                border: Border.all(color: tokens.border.subtle),
                boxShadow: [
                  BoxShadow(
                    color: tokens.shadow.shell,
                    blurRadius: tokens.motion.blurStrong + 6,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: tokens.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(tokens.radius.lg),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: tokens.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if ((item.body ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.body ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.text.secondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(notificationRealtimeClientProvider)
                        .consumeForegroundNotification(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openNotification(
    BuildContext context,
    NotificationItem item,
  ) async {
    ref
        .read(notificationRealtimeClientProvider)
        .consumeForegroundNotification();

    if (!item.isRead) {
      try {
        await ref.read(notificationApiProvider).markAsRead(item.id);
      } catch (_) {
        // Ignore read sync failure for foreground click.
      }
    }

    await ref.read(notificationRealtimeClientProvider).syncUnreadCount();

    final outcome = await ref
        .read(learningJourneyActionServiceProvider)
        .prepareAction(
          JourneyActionRequest(
            source: 'NOTIFICATION_TOAST',
            analyticsEvents: const [
              LearningEventName.notificationOpened,
              LearningEventName.notificationClicked,
            ],
            module: item.metadata?['module']?.toString() ?? item.type,
            actionUrl: item.actionUrl,
            referenceType: item.referenceType ?? 'USER_NOTIFICATION',
            referenceId: item.referenceId ?? item.id,
            reason: item.reason,
            estimatedMinutes: item.estimatedMinutes,
            metadata: {
              ...?item.metadata,
              'entryPoint': 'notification',
              'notificationId': item.id,
              'triggerType': item.triggerType,
            },
          ),
        );

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
