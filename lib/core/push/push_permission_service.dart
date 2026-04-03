import 'package:shared_preferences/shared_preferences.dart';

import 'push_platform_adapter.dart';

class PushPermissionSnapshot {
  const PushPermissionSnapshot({
    required this.status,
    this.lastPromptedAt,
    this.lastContextualDismissedAt,
  });

  final PushPermissionStatus status;
  final DateTime? lastPromptedAt;
  final DateTime? lastContextualDismissedAt;

  String get label {
    return switch (status) {
      PushPermissionStatus.granted => 'Enabled',
      PushPermissionStatus.denied => 'Denied',
      PushPermissionStatus.unsupported => 'Unavailable in this build',
      PushPermissionStatus.unknown => 'Not requested yet',
    };
  }
}

class PushPermissionService {
  PushPermissionService({
    required SharedPreferences preferences,
    required PushPlatformAdapter adapter,
  }) : _preferences = preferences,
       _adapter = adapter;

  final SharedPreferences _preferences;
  final PushPlatformAdapter _adapter;

  static const _statusKey = 'push.permission.status';
  static const _lastPromptedAtKey = 'push.permission.promptedAt';
  static const _lastDismissedAtKey = 'push.permission.contextualDismissedAt';

  Future<PushPermissionSnapshot> refresh() async {
    final adapterStatus = await _adapter.getCurrentPermissionStatus();
    final effectiveStatus = adapterStatus == PushPermissionStatus.unknown
        ? _readStoredStatus()
        : adapterStatus;
    await _preferences.setString(_statusKey, effectiveStatus.name);
    return _buildSnapshot(effectiveStatus);
  }

  Future<PushPermissionSnapshot> requestPermission() async {
    final status = await _adapter.requestPermission();
    final now = DateTime.now();
    await _preferences.setString(_statusKey, status.name);
    await _preferences.setString(_lastPromptedAtKey, now.toIso8601String());
    return _buildSnapshot(status, promptedAt: now);
  }

  Future<void> dismissContextualPrompt() async {
    await _preferences.setString(
      _lastDismissedAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  bool shouldShowContextualPrompt(
    PushPermissionSnapshot? snapshot, {
    required bool isAuthenticated,
    required int weeklyXp,
  }) {
    if (!isAuthenticated || weeklyXp <= 0 || snapshot == null) {
      return false;
    }

    if (snapshot.status == PushPermissionStatus.granted ||
        snapshot.status == PushPermissionStatus.unsupported) {
      return false;
    }

    final dismissedAt = snapshot.lastContextualDismissedAt;
    if (dismissedAt != null &&
        DateTime.now().difference(dismissedAt) < const Duration(days: 3)) {
      return false;
    }

    return true;
  }

  PushPermissionSnapshot _buildSnapshot(
    PushPermissionStatus status, {
    DateTime? promptedAt,
  }) {
    return PushPermissionSnapshot(
      status: status,
      lastPromptedAt: promptedAt ?? _readDate(_lastPromptedAtKey),
      lastContextualDismissedAt: _readDate(_lastDismissedAtKey),
    );
  }

  PushPermissionStatus _readStoredStatus() {
    final raw = _preferences.getString(_statusKey);
    return PushPermissionStatus.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => PushPermissionStatus.unknown,
    );
  }

  DateTime? _readDate(String key) {
    final raw = _preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
