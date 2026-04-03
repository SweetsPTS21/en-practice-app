class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    this.body,
    this.actionUrl,
    this.referenceType,
    this.referenceId,
    this.metadata,
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String? body;
  final String priority;
  final bool isRead;
  final String? actionUrl;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? readAt;

  String? get reason => metadata?['reason']?.toString();
  String? get ctaLabel => metadata?['ctaLabel']?.toString();
  String? get triggerType => metadata?['triggerType']?.toString();
  int? get estimatedMinutes => _readInt(metadata?['estimatedMinutes']);

  NotificationItem copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: body,
      priority: priority,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl,
      referenceType: referenceType,
      referenceId: referenceId,
      metadata: metadata,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString(),
      priority: json['priority']?.toString() ?? 'NORMAL',
      isRead: json['isRead'] == true,
      actionUrl: json['actionUrl']?.toString(),
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString(),
      metadata: json['metadata'] is Map
          ? (json['metadata'] as Map<Object?, Object?>).map(
              (key, value) => MapEntry(key.toString(), value),
            )
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      readAt: DateTime.tryParse(json['readAt']?.toString() ?? ''),
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
