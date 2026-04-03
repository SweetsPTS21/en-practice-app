import '../../../core/network/json_helpers.dart';

class ContinueLearningItem {
  const ContinueLearningItem({
    required this.source,
    required this.title,
    required this.description,
    required this.resumeUrl,
    required this.reason,
    this.estimatedMinutes,
    this.priority,
    this.referenceType,
    this.referenceId,
    this.metadata = const <String, dynamic>{},
  });

  final String source;
  final String title;
  final String description;
  final String resumeUrl;
  final int? estimatedMinutes;
  final String reason;
  final int? priority;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic> metadata;

  factory ContinueLearningItem.fromJson(Map<String, dynamic> json) {
    return ContinueLearningItem(
      source: json['source']?.toString() ?? 'GET_STARTED',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      resumeUrl: json['resumeUrl']?.toString() ?? '/dictionary/review',
      estimatedMinutes: _readInt(json['estimatedMinutes']),
      reason: json['reason']?.toString() ?? 'GET_STARTED',
      priority: _readInt(json['priority']),
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString(),
      metadata: json['metadata'] is Map
          ? jsonMap(json['metadata'])
          : const <String, dynamic>{},
    );
  }
}

class DailyLearningPlan {
  const DailyLearningPlan({
    required this.date,
    required this.items,
    this.goalMinutes,
  });

  final String date;
  final int? goalMinutes;
  final List<DailyLearningPlanItem> items;

  factory DailyLearningPlan.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return DailyLearningPlan(
      date:
          json['date']?.toString() ??
          DateTime.now().toIso8601String().split('T').first,
      goalMinutes: _readInt(json['goalMinutes']),
      items: rawItems is List
          ? rawItems
                .whereType<Object?>()
                .map((item) => DailyLearningPlanItem.fromJson(jsonMap(item)))
                .toList(growable: false)
          : const <DailyLearningPlanItem>[],
    );
  }
}

class DailyLearningPlanItem {
  const DailyLearningPlanItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.actionUrl,
    required this.reason,
    this.estimatedMinutes,
    this.priority,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final String ctaLabel;
  final String actionUrl;
  final int? estimatedMinutes;
  final int? priority;
  final String reason;
  final Map<String, dynamic> metadata;

  factory DailyLearningPlanItem.fromJson(Map<String, dynamic> json) {
    return DailyLearningPlanItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'DAILY_PLAN_ITEM',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ctaLabel: json['ctaLabel']?.toString() ?? 'Start',
      actionUrl: json['actionUrl']?.toString() ?? '/home',
      estimatedMinutes: _readInt(json['estimatedMinutes']),
      priority: _readInt(json['priority']),
      reason: json['reason']?.toString() ?? 'GET_STARTED',
      metadata: json['metadata'] is Map
          ? jsonMap(json['metadata'])
          : const <String, dynamic>{},
    );
  }
}

class QuickPracticeItem {
  const QuickPracticeItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actionUrl,
    required this.reason,
    this.estimatedMinutes,
    this.priority,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final String actionUrl;
  final int? estimatedMinutes;
  final int? priority;
  final String reason;
  final Map<String, dynamic> metadata;

  factory QuickPracticeItem.fromJson(Map<String, dynamic> json) {
    return QuickPracticeItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'QUICK_PRACTICE',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      actionUrl: json['actionUrl']?.toString() ?? '/home',
      estimatedMinutes: _readInt(json['estimatedMinutes']),
      priority: _readInt(json['priority']),
      reason: json['reason']?.toString() ?? 'QUICK_START',
      metadata: json['metadata'] is Map
          ? jsonMap(json['metadata'])
          : const <String, dynamic>{},
    );
  }
}

class ProgressSnapshot {
  const ProgressSnapshot({
    this.targetMinutes,
    this.studiedMinutes,
    this.todayProgressPercent,
    this.currentStreak,
    this.weeklyXp,
    this.latestImprovementText,
  });

  final int? targetMinutes;
  final int? studiedMinutes;
  final int? todayProgressPercent;
  final int? currentStreak;
  final int? weeklyXp;
  final String? latestImprovementText;

  factory ProgressSnapshot.fromJson(Map<String, dynamic> json) {
    return ProgressSnapshot(
      targetMinutes: _readInt(json['targetMinutes']),
      studiedMinutes: _readInt(json['studiedMinutes']),
      todayProgressPercent: _readInt(json['todayProgressPercent']),
      currentStreak: _readInt(json['currentStreak']),
      weeklyXp: _readInt(json['weeklyXp']),
      latestImprovementText: json['latestImprovementText']?.toString(),
    );
  }
}

class ReminderBanner {
  const ReminderBanner({
    required this.type,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.actionUrl,
    required this.reason,
    this.priority,
    this.estimatedMinutes,
    this.referenceType,
    this.referenceId,
    this.metadata = const <String, dynamic>{},
  });

  final String type;
  final String title;
  final String description;
  final String ctaLabel;
  final String actionUrl;
  final String reason;
  final int? priority;
  final int? estimatedMinutes;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic> metadata;

  factory ReminderBanner.fromJson(Map<String, dynamic> json) {
    return ReminderBanner(
      type: json['type']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ctaLabel: json['ctaLabel']?.toString() ?? 'Open',
      actionUrl: json['actionUrl']?.toString() ?? '/home',
      reason: json['reason']?.toString() ?? 'REENGAGEMENT',
      priority: _readInt(json['priority']),
      estimatedMinutes: _readInt(json['estimatedMinutes']),
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString(),
      metadata: json['metadata'] is Map
          ? jsonMap(json['metadata'])
          : const <String, dynamic>{},
    );
  }
}

int? _readInt(Object? value) {
  return switch (value) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value),
    _ => null,
  };
}
