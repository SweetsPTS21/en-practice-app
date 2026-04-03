import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'recommendation_api.dart';

final recommendationApiProvider = Provider<RecommendationApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return RecommendationApi(client);
});
