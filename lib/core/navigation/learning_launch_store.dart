import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LearningLaunchContext {
  const LearningLaunchContext({
    required this.source,
    required this.route,
    required this.started,
    required this.launchedAt,
    this.module,
    this.referenceType,
    this.referenceId,
    this.taskId,
    this.taskTitle,
    this.reason,
    this.estimatedMinutes,
    this.priority,
    this.metadata,
    this.startedAt,
  });

  final String source;
  final String route;
  final String? module;
  final String? referenceType;
  final String? referenceId;
  final String? taskId;
  final String? taskTitle;
  final String? reason;
  final int? estimatedMinutes;
  final int? priority;
  final Map<String, dynamic>? metadata;
  final bool started;
  final DateTime launchedAt;
  final DateTime? startedAt;

  LearningLaunchContext copyWith({
    bool? started,
    DateTime? startedAt,
  }) {
    return LearningLaunchContext(
      source: source,
      module: module,
      route: route,
      referenceType: referenceType,
      referenceId: referenceId,
      taskId: taskId,
      taskTitle: taskTitle,
      reason: reason,
      estimatedMinutes: estimatedMinutes,
      priority: priority,
      metadata: metadata,
      started: started ?? this.started,
      launchedAt: launchedAt,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'module': module,
      'route': route,
      'referenceType': referenceType,
      'referenceId': referenceId,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'reason': reason,
      'estimatedMinutes': estimatedMinutes,
      'priority': priority,
      'metadata': metadata,
      'started': started,
      'launchedAt': launchedAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
    };
  }

  factory LearningLaunchContext.fromJson(Map<String, dynamic> json) {
    return LearningLaunchContext(
      source: json['source']?.toString() ?? 'UNKNOWN',
      module: json['module']?.toString(),
      route: json['route']?.toString() ?? '/home',
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString(),
      taskId: json['taskId']?.toString(),
      taskTitle: json['taskTitle']?.toString(),
      reason: json['reason']?.toString(),
      estimatedMinutes: switch (json['estimatedMinutes']) {
        int value => value,
        num value => value.toInt(),
        _ => null,
      },
      priority: switch (json['priority']) {
        int value => value,
        num value => value.toInt(),
        _ => null,
      },
      metadata: json['metadata'] is Map
          ? (json['metadata'] as Map<Object?, Object?>).map(
              (key, value) => MapEntry(key.toString(), value),
            )
          : null,
      started: json['started'] == true,
      launchedAt: DateTime.tryParse(json['launchedAt']?.toString() ?? '') ??
          DateTime.now(),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
    );
  }
}

class RecentLearningFeedback {
  const RecentLearningFeedback({
    required this.timestamp,
    this.taskTitle,
    this.taskId,
    this.source,
    this.module,
    this.route,
    this.xpEarned,
    this.metadata,
  });

  final DateTime timestamp;
  final String? taskTitle;
  final String? taskId;
  final String? source;
  final String? module;
  final String? route;
  final int? xpEarned;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'taskTitle': taskTitle,
      'taskId': taskId,
      'source': source,
      'module': module,
      'route': route,
      'xpEarned': xpEarned,
      'metadata': metadata,
    };
  }

  factory RecentLearningFeedback.fromJson(Map<String, dynamic> json) {
    return RecentLearningFeedback(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      taskTitle: json['taskTitle']?.toString(),
      taskId: json['taskId']?.toString(),
      source: json['source']?.toString(),
      module: json['module']?.toString(),
      route: json['route']?.toString(),
      xpEarned: switch (json['xpEarned']) {
        int value => value,
        num value => value.toInt(),
        _ => null,
      },
      metadata: json['metadata'] is Map
          ? (json['metadata'] as Map<Object?, Object?>).map(
              (key, value) => MapEntry(key.toString(), value),
            )
          : null,
    );
  }
}

class LearningLaunchStore {
  LearningLaunchStore(this._preferences);

  final SharedPreferences _preferences;

  static const pendingLaunchKey = 'en_practice_learning_pending_launch';
  static const dailyTaskCompletionKey = 'en_practice_daily_task_completion';
  static const recentFeedbackKey = 'en_practice_recent_learning_feedback';

  Future<void> rememberLearningLaunch(LearningLaunchContext context) async {
    final value = context.copyWith(
      started: false,
      startedAt: null,
    );
    await _writeJson(pendingLaunchKey, value.toJson());
  }

  LearningLaunchContext? getPendingLearningLaunch() {
    return _readJson(
      pendingLaunchKey,
      (json) => LearningLaunchContext.fromJson(json),
    );
  }

  Future<void> clearPendingLearningLaunch() async {
    await _preferences.remove(pendingLaunchKey);
  }

  Future<LearningLaunchContext?> consumeLearningStartForRoute(
    String route,
    bool Function(String? routeA, String? routeB) routeMatcher,
  ) async {
    final current = getPendingLearningLaunch();
    if (current == null || current.started || !routeMatcher(current.route, route)) {
      return null;
    }

    final next = current.copyWith(
      started: true,
      startedAt: DateTime.now(),
    );
    await _writeJson(pendingLaunchKey, next.toJson());
    return next;
  }

  List<String> getCompletedDailyTaskIds({String? date}) {
    final completionState = _readJsonMap(dailyTaskCompletionKey);
    final key = date ?? _todayKey();
    final values = completionState[key];

    if (values is! List) {
      return const <String>[];
    }

    return values.map((value) => value.toString()).toList(growable: false);
  }

  Future<void> markDailyTaskCompleted(String? taskId, {String? date}) async {
    if (taskId == null || taskId.isEmpty) {
      return;
    }

    final key = date ?? _todayKey();
    final completionState = _readJsonMap(dailyTaskCompletionKey);
    final currentIds = (completionState[key] is List)
        ? (completionState[key] as List<Object?>)
            .map((value) => value.toString())
            .toList()
        : <String>[];

    if (currentIds.contains(taskId)) {
      return;
    }

    completionState[key] = <String>[...currentIds, taskId];
    await _writeJson(dailyTaskCompletionKey, completionState);
  }

  Future<LearningLaunchContext?> registerLearningCompletion({
    required String route,
    int? xpEarned,
    Map<String, dynamic>? metadata,
  }) async {
    final launchContext = getPendingLearningLaunch();
    if (launchContext == null) {
      return null;
    }

    if (launchContext.taskId != null && launchContext.taskId!.isNotEmpty) {
      await markDailyTaskCompleted(launchContext.taskId);
    }

    final feedback = RecentLearningFeedback(
      timestamp: DateTime.now(),
      taskTitle: launchContext.taskTitle,
      taskId: launchContext.taskId,
      source: launchContext.source,
      module: launchContext.module,
      route: route,
      xpEarned: xpEarned,
      metadata: metadata,
    );
    await _writeJson(recentFeedbackKey, feedback.toJson());
    await clearPendingLearningLaunch();
    return launchContext;
  }

  RecentLearningFeedback? consumeRecentLearningFeedback() {
    final feedback = _readJson(
      recentFeedbackKey,
      (json) => RecentLearningFeedback.fromJson(json),
    );
    _preferences.remove(recentFeedbackKey);
    return feedback;
  }

  T? _readJson<T>(
    String key,
    T Function(Map<String, dynamic> json) factory,
  ) {
    final raw = _preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is! Map) {
        throw const FormatException('Stored JSON value must be an object.');
      }

      return factory(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (_) {
      _preferences.remove(key);
      return null;
    }
  }

  Map<String, dynamic> _readJsonMap(String key) {
    return _readJson(key, (json) => json) ?? <String, dynamic>{};
  }

  Future<void> _writeJson(String key, Map<String, dynamic> value) async {
    await _preferences.setString(key, json.encode(value));
  }

  String _todayKey() => DateTime.now().toIso8601String().split('T').first;
}
