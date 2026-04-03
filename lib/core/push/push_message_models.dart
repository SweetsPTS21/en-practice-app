class PushMessage {
  const PushMessage({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.actionUrl,
    this.referenceType,
    this.referenceId,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String type;
  final String title;
  final String? body;
  final String? actionUrl;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic> metadata;

  String? get reason => metadata['reason']?.toString();
  String? get triggerType => metadata['triggerType']?.toString();
  int? get estimatedMinutes => _readInt(metadata['estimatedMinutes']);

  factory PushMessage.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['data'] ?? json['metadata'];
    final metadata = rawMetadata is Map
        ? rawMetadata.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};
    return PushMessage(
      id: json['notificationId']?.toString() ??
          json['id']?.toString() ??
          json['messageId']?.toString() ??
          '',
      type: json['type']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString(),
      actionUrl: json['actionUrl']?.toString() ?? metadata['actionUrl']?.toString(),
      referenceType:
          json['referenceType']?.toString() ?? metadata['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString() ?? metadata['referenceId']?.toString(),
      metadata: metadata,
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
