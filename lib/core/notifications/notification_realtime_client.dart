import 'dart:async';

import 'package:flutter/foundation.dart';

import 'notification_api.dart';
import 'notification_models.dart';

class NotificationRealtimeClient extends ChangeNotifier {
  NotificationRealtimeClient({
    required NotificationApi api,
    required bool isAuthenticated,
  })  : _api = api,
        _isAuthenticated = isAuthenticated {
    if (_isAuthenticated) {
      unawaited(_bootstrap());
    }
  }

  final NotificationApi _api;
  final bool _isAuthenticated;

  Timer? _pollTimer;
  bool _isDisposed = false;
  bool _isPolling = false;
  String? _latestKnownNotificationId;

  int unreadCount = 0;
  bool isReady = false;
  NotificationItem? foregroundNotification;

  Future<void> _bootstrap() async {
    await refreshBaseline();
    if (_isDisposed || !_isAuthenticated) {
      return;
    }

    _pollTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => unawaited(poll()),
    );
  }

  Future<void> refreshBaseline() async {
    if (!_isAuthenticated) {
      unreadCount = 0;
      isReady = true;
      foregroundNotification = null;
      _notifySafely();
      return;
    }

    try {
      final notifications = await _api.getNotifications();
      unreadCount = await _api.getUnreadCount();
      _latestKnownNotificationId = notifications.isEmpty ? null : notifications.first.id;
    } catch (_) {
      unreadCount = 0;
    } finally {
      isReady = true;
      _notifySafely();
    }
  }

  Future<void> poll() async {
    if (_isDisposed || !_isAuthenticated || _isPolling) {
      return;
    }

    _isPolling = true;
    try {
      final notifications = await _api.getNotifications();
      final nextUnreadCount = await _api.getUnreadCount();
      final latestNotification = notifications.isEmpty ? null : notifications.first;

      unreadCount = nextUnreadCount;
      if (latestNotification != null &&
          latestNotification.id != _latestKnownNotificationId) {
        _latestKnownNotificationId = latestNotification.id;
        foregroundNotification = latestNotification;
      }
      _notifySafely();
    } catch (_) {
      // Polling should never break the app shell.
    } finally {
      _isPolling = false;
    }
  }

  Future<void> syncUnreadCount([int? value]) async {
    if (!_isAuthenticated) {
      unreadCount = 0;
      _notifySafely();
      return;
    }

    if (value != null) {
      unreadCount = value;
      _notifySafely();
      return;
    }

    try {
      unreadCount = await _api.getUnreadCount();
      _notifySafely();
    } catch (_) {
      // Ignore sync errors.
    }
  }

  void consumeForegroundNotification() {
    foregroundNotification = null;
    _notifySafely();
  }

  void acknowledgeLatestNotification(String? notificationId) {
    if (notificationId == null || notificationId.isEmpty) {
      return;
    }

    _latestKnownNotificationId = notificationId;
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollTimer?.cancel();
    super.dispose();
  }
}
