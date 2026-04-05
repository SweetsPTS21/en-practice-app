import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'custom_speaking_models.dart';

class CustomConversationSnapshotStore {
  CustomConversationSnapshotStore(this._preferences);

  final SharedPreferences _preferences;

  static const _keyPrefix = 'en_practice_custom_speaking_snapshot_';

  Future<void> saveSnapshot(CustomConversationSnapshot snapshot) {
    return _preferences.setString(
      _snapshotKey(snapshot.conversationId),
      json.encode(snapshot.toJson()),
    );
  }

  CustomConversationSnapshot? readSnapshot(String conversationId) {
    final raw = _preferences.getString(_snapshotKey(conversationId));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is! Map) {
        throw const FormatException('Snapshot must be a JSON object.');
      }
      return CustomConversationSnapshot.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (_) {
      _preferences.remove(_snapshotKey(conversationId));
      return null;
    }
  }

  Future<void> clearSnapshot(String conversationId) {
    return _preferences.remove(_snapshotKey(conversationId));
  }

  String _snapshotKey(String conversationId) => '$_keyPrefix$conversationId';
}
