import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/theme/theme_extensions.dart';

class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realtime = ref.watch(notificationRealtimeClientProvider);
    final tokens = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/notifications'),
        borderRadius: BorderRadius.circular(tokens.radius.hero),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tokens.background.panelStrong,
            borderRadius: BorderRadius.circular(tokens.radius.hero),
            border: Border.all(color: tokens.border.subtle),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Center(
                child: Icon(Icons.notifications_none_rounded),
              ),
              if (realtime.unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.danger,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      realtime.unreadCount > 99 ? '99+' : '${realtime.unreadCount}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
