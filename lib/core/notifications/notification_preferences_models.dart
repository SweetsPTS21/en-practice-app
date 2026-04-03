class NotificationPreferences {
  const NotificationPreferences({
    required this.allowPush,
    required this.allowEmail,
    required this.allowVocabularyReminder,
    required this.allowGradingResult,
    required this.allowAdminBroadcast,
  });

  final bool allowPush;
  final bool allowEmail;
  final bool allowVocabularyReminder;
  final bool allowGradingResult;
  final bool allowAdminBroadcast;

  NotificationPreferences copyWith({
    bool? allowPush,
    bool? allowEmail,
    bool? allowVocabularyReminder,
    bool? allowGradingResult,
    bool? allowAdminBroadcast,
  }) {
    return NotificationPreferences(
      allowPush: allowPush ?? this.allowPush,
      allowEmail: allowEmail ?? this.allowEmail,
      allowVocabularyReminder:
          allowVocabularyReminder ?? this.allowVocabularyReminder,
      allowGradingResult: allowGradingResult ?? this.allowGradingResult,
      allowAdminBroadcast: allowAdminBroadcast ?? this.allowAdminBroadcast,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowPush': allowPush,
      'allowEmail': allowEmail,
      'allowVocabularyReminder': allowVocabularyReminder,
      'allowGradingResult': allowGradingResult,
      'allowAdminBroadcast': allowAdminBroadcast,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      allowPush: json['allowPush'] != false,
      allowEmail: json['allowEmail'] == true,
      allowVocabularyReminder: json['allowVocabularyReminder'] != false,
      allowGradingResult: json['allowGradingResult'] != false,
      allowAdminBroadcast: json['allowAdminBroadcast'] != false,
    );
  }
}
