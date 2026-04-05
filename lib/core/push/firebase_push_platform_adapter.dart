import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_bootstrap.dart';
import 'push_message_models.dart';
import 'push_platform_adapter.dart';

class FirebasePushPlatformAdapter extends PushPlatformAdapter {
  FirebasePushPlatformAdapter({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  bool get isSupported => supportsMobileFirebaseMessaging;

  @override
  Future<PushPermissionStatus> getCurrentPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return _mapAuthorizationStatus(settings.authorizationStatus);
  }

  @override
  Future<PushMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _mapRemoteMessage(message);
  }

  @override
  Stream<PushMessage> get onForegroundMessage =>
      FirebaseMessaging.onMessage.map(_mapRemoteMessage);

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_mapRemoteMessage);

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<PushPermissionStatus> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return _mapAuthorizationStatus(settings.authorizationStatus);
  }

  @override
  Future<void> openNotificationSettings() {
    return AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  @override
  Future<String?> getToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _waitForApnsToken();
    }
    return _messaging.getToken();
  }

  PushPermissionStatus _mapAuthorizationStatus(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized ||
      AuthorizationStatus.provisional => PushPermissionStatus.granted,
      AuthorizationStatus.denied => PushPermissionStatus.denied,
      AuthorizationStatus.notDetermined => PushPermissionStatus.unknown,
    };
  }

  PushMessage _mapRemoteMessage(RemoteMessage message) {
    final payload = <String, dynamic>{
      'messageId': message.messageId,
      'title': message.notification?.title ?? message.data['title'],
      'body': message.notification?.body ?? message.data['body'],
      'type': message.data['type'],
      'actionUrl':
          message.data['actionUrl'] ?? message.data['fallbackActionUrl'],
      'referenceType': message.data['referenceType'],
      'referenceId': message.data['referenceId'],
      'data': {
        ...message.data,
        if (message.sentTime != null)
          'sentTime': message.sentTime!.toIso8601String(),
      },
    };
    return PushMessage.fromJson(payload);
  }

  Future<void> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }
}
