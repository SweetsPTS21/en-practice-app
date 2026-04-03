import 'result_action_models.dart';

class TodayGoalProgress {
  const TodayGoalProgress({
    this.completedMinutes,
    this.targetMinutes,
    this.progressPercent,
    this.label,
  });

  final int? completedMinutes;
  final int? targetMinutes;
  final int? progressPercent;
  final String? label;

  factory TodayGoalProgress.fromJson(Map<String, dynamic> json) {
    return TodayGoalProgress(
      completedMinutes: _readInt(json['completedMinutes']),
      targetMinutes: _readInt(json['targetMinutes']),
      progressPercent: _readInt(json['progressPercent']),
      label: json['label']?.toString(),
    );
  }
}

class CompletionScoreSummary {
  const CompletionScoreSummary({
    required this.label,
    this.value,
    this.displayValue,
    this.description,
  });

  final String label;
  final double? value;
  final String? displayValue;
  final String? description;

  factory CompletionScoreSummary.fromJson(Map<String, dynamic> json) {
    return CompletionScoreSummary(
      label: json['label']?.toString() ?? '',
      value: _readDouble(json['value']),
      displayValue: json['displayValue']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class CompletionDelta {
  const CompletionDelta({
    required this.label,
    this.value,
    this.displayValue,
    this.positive,
  });

  final String label;
  final double? value;
  final String? displayValue;
  final bool? positive;

  factory CompletionDelta.fromJson(Map<String, dynamic> json) {
    return CompletionDelta(
      label: json['label']?.toString() ?? '',
      value: _readDouble(json['value']),
      displayValue: json['displayValue']?.toString(),
      positive: json['positive'] is bool ? json['positive'] as bool : null,
    );
  }
}

class ImprovementItem {
  const ImprovementItem({
    required this.title,
    this.description,
    this.highlight,
  });

  final String title;
  final String? description;
  final String? highlight;

  factory ImprovementItem.fromJson(Map<String, dynamic> json) {
    return ImprovementItem(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      highlight: json['highlight']?.toString(),
    );
  }
}

class CompletionSnapshot {
  const CompletionSnapshot({
    required this.module,
    required this.referenceType,
    required this.referenceId,
    required this.completionTitle,
    required this.scoreSummary,
    required this.deltas,
    required this.improvements,
    required this.metadata,
    this.primaryScoreLabel,
    this.primaryScore,
    this.primaryScoreDisplay,
    this.xpEarned,
    this.streakKept,
    this.todayGoalProgress,
    this.nextAction,
    this.secondaryAction,
  });

  final String module;
  final String referenceType;
  final String referenceId;
  final String completionTitle;
  final String? primaryScoreLabel;
  final double? primaryScore;
  final String? primaryScoreDisplay;
  final int? xpEarned;
  final bool? streakKept;
  final TodayGoalProgress? todayGoalProgress;
  final List<CompletionScoreSummary> scoreSummary;
  final List<CompletionDelta> deltas;
  final List<ImprovementItem> improvements;
  final ResultNextAction? nextAction;
  final ResultNextAction? secondaryAction;
  final Map<String, dynamic> metadata;

  factory CompletionSnapshot.fromJson(Map<String, dynamic> json) {
    List<T> readList<T>(
      Object? value,
      T Function(Map<String, dynamic> json) factory,
    ) {
      if (value is! List) {
        return <T>[];
      }

      return value
          .whereType<Object?>()
          .map(
            (item) => factory(
              item is Map
                  ? item.map((key, value) => MapEntry(key.toString(), value))
                  : const <String, dynamic>{},
            ),
          )
          .toList(growable: false);
    }

    return CompletionSnapshot(
      module: json['module']?.toString() ?? 'UNKNOWN',
      referenceType: json['referenceType']?.toString() ?? 'UNKNOWN',
      referenceId: json['referenceId']?.toString() ?? '',
      completionTitle: json['completionTitle']?.toString() ?? 'Session complete',
      primaryScoreLabel: json['primaryScoreLabel']?.toString(),
      primaryScore: _readDouble(json['primaryScore']),
      primaryScoreDisplay: json['primaryScoreDisplay']?.toString(),
      xpEarned: _readInt(json['xpEarned']),
      streakKept: json['streakKept'] is bool ? json['streakKept'] as bool : null,
      todayGoalProgress: json['todayGoalProgress'] is Map
          ? TodayGoalProgress.fromJson(
              (json['todayGoalProgress'] as Map<Object?, Object?>).map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
          : null,
      scoreSummary: readList(
        json['scoreSummary'],
        CompletionScoreSummary.fromJson,
      ),
      deltas: readList(json['deltas'], CompletionDelta.fromJson),
      improvements: readList(
        json['improvements'],
        ImprovementItem.fromJson,
      ),
      nextAction: json['nextAction'] is Map
          ? ResultNextAction.fromJson(
              (json['nextAction'] as Map<Object?, Object?>).map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
          : null,
      secondaryAction: json['secondaryAction'] is Map
          ? ResultNextAction.fromJson(
              (json['secondaryAction'] as Map<Object?, Object?>).map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
          : null,
      metadata: json['metadata'] is Map
          ? (json['metadata'] as Map<Object?, Object?>).map(
              (key, value) => MapEntry(key.toString(), value),
            )
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

double? _readDouble(Object? value) {
  return switch (value) {
    double value => value,
    num value => value.toDouble(),
    String value => double.tryParse(value),
    _ => null,
  };
}
