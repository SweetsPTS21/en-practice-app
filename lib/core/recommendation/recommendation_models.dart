import '../network/json_helpers.dart';

class RecommendationExplanation {
  const RecommendationExplanation({
    this.message,
    this.reasonCode,
  });

  final String? message;
  final String? reasonCode;

  factory RecommendationExplanation.fromJson(Map<String, dynamic> json) {
    return RecommendationExplanation(
      message: json['message']?.toString(),
      reasonCode: json['reasonCode']?.toString(),
    );
  }
}

class RecommendationCardModel {
  const RecommendationCardModel({
    required this.recommendationKey,
    required this.type,
    required this.title,
    required this.description,
    required this.actionUrl,
    this.difficulty,
    this.estimatedMinutes,
    this.urgencyScore,
    this.confidenceGainScore,
    this.priority,
    this.freshUntil,
    this.explanation,
    this.referenceType,
    this.referenceId,
    this.metadata = const <String, dynamic>{},
  });

  final String recommendationKey;
  final String type;
  final String title;
  final String description;
  final String actionUrl;
  final String? difficulty;
  final int? estimatedMinutes;
  final int? urgencyScore;
  final int? confidenceGainScore;
  final int? priority;
  final DateTime? freshUntil;
  final RecommendationExplanation? explanation;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic> metadata;

  factory RecommendationCardModel.fromJson(Map<String, dynamic> json) {
    return RecommendationCardModel(
      recommendationKey: json['recommendationKey']?.toString() ?? '',
      type: json['type']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      actionUrl: json['actionUrl']?.toString() ?? '/home',
      difficulty: json['difficulty']?.toString(),
      estimatedMinutes: _readInt(json['estimatedMinutes']),
      urgencyScore: _readInt(json['urgencyScore']),
      confidenceGainScore: _readInt(json['confidenceGainScore']),
      priority: _readInt(json['priority']),
      freshUntil: DateTime.tryParse(json['freshUntil']?.toString() ?? ''),
      explanation: json['explanation'] is Map
          ? RecommendationExplanation.fromJson(jsonMap(json['explanation']))
          : null,
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString(),
      metadata: json['metadata'] is Map
          ? jsonMap(json['metadata'])
          : const <String, dynamic>{},
    );
  }
}

class RecommendationFeed {
  const RecommendationFeed({
    required this.generatedAt,
    required this.items,
    this.primary,
  });

  final DateTime generatedAt;
  final RecommendationCardModel? primary;
  final List<RecommendationCardModel> items;

  factory RecommendationFeed.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return RecommendationFeed(
      generatedAt:
          DateTime.tryParse(json['generatedAt']?.toString() ?? '') ?? DateTime.now(),
      primary: json['primary'] is Map
          ? RecommendationCardModel.fromJson(jsonMap(json['primary']))
          : null,
      items: rawItems is List
          ? rawItems
              .whereType<Object?>()
              .map((item) => RecommendationCardModel.fromJson(jsonMap(item)))
              .toList(growable: false)
          : const <RecommendationCardModel>[],
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
