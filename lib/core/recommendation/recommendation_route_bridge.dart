import '../navigation/app_route_contract.dart';
import 'recommendation_models.dart';

Map<String, dynamic> buildRecommendationLaunchMetadata(
  RecommendationCardModel recommendation,
  String targetRoute,
) {
  final normalizedRoute = normalizeInternalRoute(targetRoute)?.href ?? '';
  final normalizedType = recommendation.type.toUpperCase();

  final metadata = <String, dynamic>{};

  if (normalizedType.contains('SPEAK') &&
      normalizedRoute.startsWith('/speaking')) {
    metadata['specialEvent'] = 'SPEAKING_PROMPT';
    metadata['resumeState'] = recommendation.metadata['resumeState'];
  }

  if (normalizedType.contains('VOCAB') &&
      normalizedRoute.startsWith('/dictionary/review')) {
    metadata['specialEvent'] = 'VOCAB_MICRO_SESSION';
    metadata['targetWordCount'] =
        recommendation.metadata['targetWordCount'] ??
        recommendation.metadata['dueWordCount'];
  }

  return metadata;
}
