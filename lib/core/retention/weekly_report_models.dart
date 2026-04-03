import '../network/json_helpers.dart';
import '../recommendation/recommendation_models.dart';

class WeeklyChallengeSummary {
  const WeeklyChallengeSummary({
    required this.code,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.rewardXp,
    required this.completed,
  });

  final String code;
  final String title;
  final int currentValue;
  final int targetValue;
  final int rewardXp;
  final bool completed;

  double get progressPercent {
    if (targetValue <= 0) {
      return 0;
    }
    return (currentValue / targetValue).clamp(0, 1).toDouble();
  }

  factory WeeklyChallengeSummary.fromJson(Map<String, dynamic> json) {
    return WeeklyChallengeSummary(
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      currentValue: _readInt(json['currentValue']) ?? 0,
      targetValue: _readInt(json['targetValue']) ?? 0,
      rewardXp: _readInt(json['rewardXp']) ?? 0,
      completed: json['completed'] == true,
    );
  }
}

class WeeklyReport {
  const WeeklyReport({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.studyMinutes,
    required this.vocabularyLearned,
    required this.testsCompleted,
    this.bandImprovement,
    this.strongestWin,
    this.repeatedWeakness,
    this.nextStep,
    this.challengeSummary,
    this.recommendation,
  });

  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int studyMinutes;
  final int vocabularyLearned;
  final int testsCompleted;
  final double? bandImprovement;
  final String? strongestWin;
  final String? repeatedWeakness;
  final String? nextStep;
  final WeeklyChallengeSummary? challengeSummary;
  final RecommendationCardModel? recommendation;

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      id: json['id']?.toString() ?? '',
      weekStart:
          DateTime.tryParse(json['weekStart']?.toString() ?? '') ??
          DateTime.now(),
      weekEnd:
          DateTime.tryParse(json['weekEnd']?.toString() ?? '') ??
          DateTime.now(),
      studyMinutes: _readInt(json['studyMinutes']) ?? 0,
      vocabularyLearned: _readInt(json['vocabularyLearned']) ?? 0,
      testsCompleted: _readInt(json['testsCompleted']) ?? 0,
      bandImprovement: switch (json['bandImprovement']) {
        num value => value.toDouble(),
        String value => double.tryParse(value),
        _ => null,
      },
      strongestWin: json['strongestWin']?.toString(),
      repeatedWeakness: json['repeatedWeakness']?.toString(),
      nextStep: json['nextStep']?.toString(),
      challengeSummary: json['challengeSummary'] is Map
          ? WeeklyChallengeSummary.fromJson(jsonMap(json['challengeSummary']))
          : null,
      recommendation: json['recommendation'] is Map
          ? RecommendationCardModel.fromJson(jsonMap(json['recommendation']))
          : null,
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
