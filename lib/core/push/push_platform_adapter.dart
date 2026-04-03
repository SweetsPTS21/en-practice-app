import 'dart:async';

import 'push_message_models.dart';

enum PushPermissionStatus {
  unknown,
  granted,
  denied,
  unsupported,
}

abstract class PushPlatformAdapter {
  const PushPlatformAdapter();

  bool get isSupported;

  Future<PushPermissionStatus> getCurrentPermissionStatus();

  Future<PushPermissionStatus> requestPermission();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Stream<PushMessage> get onForegroundMessage;

  Stream<PushMessage> get onMessageOpenedApp;

  Future<PushMessage?> getInitialMessage();
}

class NoopPushPlatformAdapter extends PushPlatformAdapter {
  const NoopPushPlatformAdapter();

  @override
  bool get isSupported => false;

  @override
  Future<PushPermissionStatus> getCurrentPermissionStatus() async {
    return PushPermissionStatus.unsupported;
  }

  @override
  Future<PushMessage?> getInitialMessage() async {
    return null;
  }

  @override
  Stream<PushMessage> get onForegroundMessage => const Stream<PushMessage>.empty();

  @override
  Stream<PushMessage> get onMessageOpenedApp => const Stream<PushMessage>.empty();

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  Future<PushPermissionStatus> requestPermission() async {
    return PushPermissionStatus.unsupported;
  }

  @override
  Future<String?> getToken() async {
    return null;
  }
}
