enum ResultActionIntent { nextStep, review, reviewAgain }

class ResultNextAction {
  const ResultNextAction({
    required this.label,
    required this.actionUrl,
    this.intent = ResultActionIntent.nextStep,
    this.referenceType,
    this.referenceId,
    this.reason,
    this.estimatedMinutes,
    this.priority,
    this.metadata = const <String, dynamic>{},
  });

  final String label;
  final String actionUrl;
  final ResultActionIntent intent;
  final String? referenceType;
  final String? referenceId;
  final String? reason;
  final int? estimatedMinutes;
  final int? priority;
  final Map<String, dynamic> metadata;

  factory ResultNextAction.fromJson(Map<String, dynamic> json) {
    return ResultNextAction(
      label: json['label']?.toString() ?? 'Continue',
      actionUrl: json['actionUrl']?.toString() ?? '/home',
      intent: _readIntent(
        json['intent']?.toString(),
        label: json['label']?.toString(),
        actionUrl: json['actionUrl']?.toString(),
      ),
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString(),
      reason: json['reason']?.toString(),
      estimatedMinutes: _readInt(json['estimatedMinutes']),
      priority: _readInt(json['priority']),
      metadata: json['metadata'] is Map
          ? (json['metadata'] as Map<Object?, Object?>).map(
              (key, value) => MapEntry(key.toString(), value),
            )
          : const <String, dynamic>{},
    );
  }
}

ResultActionIntent _readIntent(
  String? raw, {
  String? label,
  String? actionUrl,
}) {
  switch (raw?.trim().toUpperCase()) {
    case 'REVIEW':
    case 'OPEN_REVIEW':
    case 'ERROR_REVIEW':
      return ResultActionIntent.review;
    case 'REVIEW_AGAIN':
    case 'RETAKE':
    case 'TRY_AGAIN':
      return ResultActionIntent.reviewAgain;
  }

  final normalizedLabel = label?.trim().toLowerCase() ?? '';
  final normalizedAction = actionUrl?.trim().toLowerCase() ?? '';
  if (normalizedAction.contains('/result/') ||
      normalizedAction.contains('/submission/')) {
    return ResultActionIntent.review;
  }

  if (normalizedLabel.contains('again') ||
      normalizedLabel.contains('retry') ||
      normalizedLabel.contains('retake')) {
    return ResultActionIntent.reviewAgain;
  }

  return ResultActionIntent.nextStep;
}

int? _readInt(Object? value) {
  return switch (value) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value),
    _ => null,
  };
}
