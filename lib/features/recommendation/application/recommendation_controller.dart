import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/recommendation/recommendation_models.dart';
import '../../../core/recommendation/recommendation_providers.dart';
import '../../../core/recommendation/recommendation_surface.dart';

final recommendationPrimaryProvider = FutureProvider.autoDispose
    .family<RecommendationCardModel?, RecommendationSurface>((
      ref,
      surface,
    ) async {
      final api = ref.watch(recommendationApiProvider);
      return api.getPrimary(surface);
    });

final recommendationFeedProvider = FutureProvider.autoDispose
    .family<RecommendationFeed?, RecommendationSurface>((ref, surface) async {
      final api = ref.watch(recommendationApiProvider);
      return api.getFeed(surface);
    });
