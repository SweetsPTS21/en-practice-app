import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/recommendation/recommendation_models.dart';
import '../../../../core/recommendation/recommendation_surface.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../application/recommendation_controller.dart';
import 'recommendation_card.dart';

class RecommendationFeedSection extends ConsumerWidget {
  const RecommendationFeedSection({
    super.key,
    required this.surface,
    required this.source,
    required this.title,
    required this.subtitle,
    this.maxItems = 4,
  });

  final RecommendationSurface surface;
  final String source;
  final String title;
  final String subtitle;
  final int maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(recommendationFeedProvider(surface));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.tokens.text.secondary,
            ),
          ),
          const SizedBox(height: 16),
          switch (feed) {
            AsyncLoading() => const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            ),
            AsyncData(:final value) => _FeedItems(
              items: _extractItems(value, maxItems),
              surface: surface,
              source: source,
            ),
            _ => const Text('No recommendations right now.'),
          },
        ],
      ),
    );
  }

  List<RecommendationCardModel> _extractItems(
    RecommendationFeed? feed,
    int maxItems,
  ) {
    if (feed == null) {
      return const <RecommendationCardModel>[];
    }

    final items = feed.items.isNotEmpty
        ? feed.items
        : feed.primary == null
        ? const <RecommendationCardModel>[]
        : <RecommendationCardModel>[feed.primary!];

    return items.take(maxItems).toList(growable: false);
  }
}

class _FeedItems extends StatelessWidget {
  const _FeedItems({
    required this.items,
    required this.surface,
    required this.source,
  });

  final List<RecommendationCardModel> items;
  final RecommendationSurface surface;
  final String source;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('No recommendations right now.');
    }

    return Column(
      children: [
        for (var index = 0; index < items.length; index += 1) ...[
          RecommendationCard(
            recommendation: items[index],
            surface: surface,
            source: source,
            position: index,
            showFeedbackActions: index == 0,
          ),
          if (index != items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
