import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/recommendation/recommendation_surface.dart';
import '../../application/recommendation_controller.dart';
import 'recommendation_card.dart';

class RecommendationSurfaceSlot extends ConsumerWidget {
  const RecommendationSurfaceSlot({
    super.key,
    required this.surface,
    required this.source,
    this.hero = false,
    this.showFeedbackActions = false,
  });

  final RecommendationSurface surface;
  final String source;
  final bool hero;
  final bool showFeedbackActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendation = ref.watch(recommendationPrimaryProvider(surface));

    return switch (recommendation) {
      AsyncData(:final value) when value != null => RecommendationCard(
          recommendation: value,
          surface: surface,
          source: source,
          hero: hero,
          showFeedbackActions: showFeedbackActions,
        ),
      AsyncLoading() => const AppCard(
          child: SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
