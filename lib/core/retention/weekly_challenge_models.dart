class WeeklyChallenge {
  const WeeklyChallenge({
    required this.definitionId,
    required this.code,
    required this.title,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.rewardXp,
    required this.completed,
    required this.weekStart,
    required this.weekEnd,
  });

  final String definitionId;
  final String code;
  final String title;
  final String description;
  final int currentValue;
  final int targetValue;
  final int rewardXp;
  final bool completed;
  final DateTime weekStart;
  final DateTime weekEnd;

  double get progressPercent {
    if (targetValue <= 0) {
      return 0;
    }
    return (currentValue / targetValue).clamp(0, 1).toDouble();
  }

  factory WeeklyChallenge.fromJson(Map<String, dynamic> json) {
    return WeeklyChallenge(
      definitionId: json['definitionId']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      currentValue: _readInt(json['currentValue']) ?? 0,
      targetValue: _readInt(json['targetValue']) ?? 0,
      rewardXp: _readInt(json['rewardXp']) ?? 0,
      completed: json['completed'] == true,
      weekStart:
          DateTime.tryParse(json['weekStart']?.toString() ?? '') ??
          DateTime.now(),
      weekEnd:
          DateTime.tryParse(json['weekEnd']?.toString() ?? '') ??
          DateTime.now(),
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
