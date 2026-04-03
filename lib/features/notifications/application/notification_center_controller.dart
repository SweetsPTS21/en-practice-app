import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/learning_analytics_service.dart';
import '../../../core/learning_journey/learning_journey_action_service.dart';
import '../../../core/learning_journey/learning_journey_providers.dart';
import '../../../core/notifications/notification_models.dart';
import '../../../core/notifications/notification_providers.dart';

class NotificationCenterController extends ChangeNotifier {
  NotificationCenterController({required this.ref}) {
    load();
  }

  final Ref ref;

  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;
  List<NotificationItem> items = const <NotificationItem>[];

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final api = ref.read(notificationApiProvider);
      items = await api.getNotifications();
      ref
          .read(notificationRealtimeClientProvider)
          .acknowledgeLatestNotification(items.isEmpty ? null : items.first.id);
      await ref
          .read(notificationRealtimeClientProvider)
          .syncUnreadCount(items.where((item) => !item.isRead).length);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(NotificationItem item) async {
    if (item.isRead) {
      return;
    }

    _replace(item.copyWith(isRead: true, readAt: DateTime.now()));
    notifyListeners();

    try {
      await ref.read(notificationApiProvider).markAsRead(item.id);
    } finally {
      await ref
          .read(notificationRealtimeClientProvider)
          .syncUnreadCount(items.where((entry) => !entry.isRead).length);
    }
  }

  Future<void> markAllAsRead() async {
    isSubmitting = true;
    notifyListeners();
    try {
      await ref.read(notificationApiProvider).markAllAsRead();
      items = items
          .map((item) => item.copyWith(isRead: true, readAt: DateTime.now()))
          .toList(growable: false);
      await ref.read(notificationRealtimeClientProvider).syncUnreadCount(0);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(NotificationItem item) async {
    final previous = items;
    items = items.where((entry) => entry.id != item.id).toList(growable: false);
    notifyListeners();

    try {
      await ref.read(notificationApiProvider).deleteNotification(item.id);
      await ref
          .read(notificationRealtimeClientProvider)
          .syncUnreadCount(items.where((entry) => !entry.isRead).length);
    } catch (_) {
      items = previous;
      notifyListeners();
    }
  }

  Future<JourneyActionOutcome> openNotification(NotificationItem item) async {
    await markAsRead(item);
    return ref
        .read(learningJourneyActionServiceProvider)
        .prepareAction(
          JourneyActionRequest(
            source: 'NOTIFICATION_CENTER',
            analyticsEvents: const [
              LearningEventName.notificationOpened,
              LearningEventName.notificationClicked,
            ],
            module: _resolveModule(item),
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
  }

  void _replace(NotificationItem next) {
    items = items
        .map((item) => item.id == next.id ? next : item)
        .toList(growable: false);
  }

  String? _resolveModule(NotificationItem item) {
    final rawModule = item.metadata?['module']?.toString();
    if ((rawModule ?? '').isNotEmpty) {
      return rawModule;
    }

    final actionUrl = item.actionUrl?.toLowerCase() ?? '';
    if (actionUrl.contains('/ielts/')) {
      return 'IELTS';
    }
    if (actionUrl.contains('/writing/')) {
      return 'WRITING';
    }
    if (actionUrl.contains('/custom-speaking/')) {
      return 'CUSTOM_SPEAKING';
    }
    if (actionUrl.contains('/speaking/')) {
      return 'SPEAKING';
    }
    if (actionUrl.contains('/dictionary/')) {
      return 'VOCABULARY';
    }
    return item.type;
  }
}

final notificationCenterControllerProvider =
    ChangeNotifierProvider.autoDispose<NotificationCenterController>((ref) {
      return NotificationCenterController(ref: ref);
    });
