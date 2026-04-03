class Achievement {
  const Achievement({
    required this.definitionId,
    required this.code,
    required this.title,
    required this.description,
    required this.unlocked,
    this.icon,
    this.unlockedAt,
  });

  final String definitionId;
  final String code;
  final String title;
  final String description;
  final String? icon;
  final bool unlocked;
  final DateTime? unlockedAt;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      definitionId: json['definitionId']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString(),
      unlocked: json['unlocked'] == true,
      unlockedAt: DateTime.tryParse(json['unlockedAt']?.toString() ?? ''),
    );
  }
}

List<Achievement> sortAchievements(Iterable<Achievement> items) {
  final sorted = items.toList(growable: false);
  sorted.sort((left, right) {
    if (left.unlocked != right.unlocked) {
      return right.unlocked ? 1 : -1;
    }

    if (left.unlocked && right.unlocked) {
      final rightAt = right.unlockedAt?.millisecondsSinceEpoch ?? 0;
      final leftAt = left.unlockedAt?.millisecondsSinceEpoch ?? 0;
      final compareUnlockedAt = rightAt.compareTo(leftAt);
      if (compareUnlockedAt != 0) {
        return compareUnlockedAt;
      }
    }

    final leftLabel = (left.title.isNotEmpty ? left.title : left.code).toLowerCase();
    final rightLabel = (right.title.isNotEmpty ? right.title : right.code).toLowerCase();
    return leftLabel.compareTo(rightLabel);
  });
  return sorted;
}
