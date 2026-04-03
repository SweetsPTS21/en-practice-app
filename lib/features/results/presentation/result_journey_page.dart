import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/recommendation/recommendation_surface.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/learning_journey/result_action_models.dart';
import '../../../core/navigation/learning_action_resolver.dart';
import '../../../core/theme/page_palettes.dart';
import '../../home/home_providers.dart';
import '../../recommendation/presentation/widgets/recommendation_surface_slot.dart';
import '../application/result_journey_controller.dart';
import '../data/result_snapshot_request.dart';
import 'widgets/completion_snapshot_section.dart';

class ResultJourneyPage extends ConsumerWidget {
  const ResultJourneyPage({
    super.key,
    required this.request,
    required this.title,
    required this.subtitle,
    required this.paletteKey,
  });

  final ResultSnapshotRequest request;
  final String title;
  final String subtitle;
  final AppPagePaletteKey paletteKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(resultJourneyControllerProvider(request));

    return AppPageScaffold(
      title: title,
      subtitle: subtitle,
      paletteKey: paletteKey,
      children: [
        switch (snapshot) {
          AsyncData(:final value) => CompletionSnapshotSection(
              snapshot: value,
              onActionPressed: (action) => _handleAction(context, ref, action),
            ),
          AsyncError() => _ResultErrorState(
              onRetry: () => ref.invalidate(resultJourneyControllerProvider(request)),
            ),
          _ => const _ResultLoadingState(),
        },
        const RecommendationSurfaceSlot(
          surface: RecommendationSurface.result,
          source: 'RESULT_RECOMMENDATION',
          showFeedbackActions: true,
        ),
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    ResultNextAction action,
  ) async {
    final outcome = await ref.read(learningJourneyActionServiceProvider).prepareResultAction(
          source: 'RESULT_PAGE',
          module: request.routeModuleName,
          resultReferenceType: request.referenceType,
          resultReferenceId: request.referenceId,
          action: action,
        );

    if (!context.mounted) {
      return;
    }

    if (outcome.target.kind == LearningActionKind.external) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('home.common.externalRouteUnsupported'))),
      );
      return;
    }

    context.go(outcome.target.href);
  }
}

class _ResultLoadingState extends StatelessWidget {
  const _ResultLoadingState();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: SizedBox(
        height: 320,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ResultErrorState extends StatelessWidget {
  const _ResultErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.error_outline_rounded, size: 40),
          const SizedBox(height: 12),
          Text(
            'Result snapshot is unavailable',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'The result route is ready, but the completion snapshot could not be loaded from the backend.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Retry',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
