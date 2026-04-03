import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/design/widgets/app_state_widgets.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/page_palettes.dart';
import '../../core/learning_journey/learning_journey_providers.dart';

class LearningSessionPlaceholderPage extends ConsumerStatefulWidget {
  const LearningSessionPlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.module,
    required this.paletteKey,
  });

  final String title;
  final String subtitle;
  final String route;
  final String module;
  final AppPagePaletteKey paletteKey;

  @override
  ConsumerState<LearningSessionPlaceholderPage> createState() =>
      _LearningSessionPlaceholderPageState();
}
class _LearningSessionPlaceholderPageState
    extends ConsumerState<LearningSessionPlaceholderPage> {
  bool _trackedStart = false;
  bool _completed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_trackedStart) {
      return;
    }

    _trackedStart = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(learningAnalyticsServiceProvider)
          .registerLearningStartIfNeeded(widget.route);
    });
  }

  @override
  void dispose() {
    if (_trackedStart && !_completed) {
      ref.read(learningAnalyticsServiceProvider).registerLearningAbandoned(
            route: widget.route,
          );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      paletteKey: widget.paletteKey,
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(
                title: context.tr('learningSession.title'),
                subtitle: context.tr('learningSession.description'),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: context.tr('learningSession.complete'),
                    icon: Icons.check_circle_rounded,
                    onPressed: _handleCompleteSession,
                  ),
                  AppButton(
                    label: context.tr('learningSession.backHome'),
                    icon: Icons.home_rounded,
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'Before you start',
                subtitle: 'Use this screen to confirm the flow, then continue or return without losing context.',
              ),
              const SizedBox(height: 16),
              AppEmptyState(
                icon: Icons.play_circle_outline_rounded,
                title: '${widget.module} session ready',
                subtitle: 'When you complete this flow, the app will take you to the matching result screen.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleCompleteSession() async {
    _completed = true;
    await ref.read(learningAnalyticsServiceProvider).registerLearningCompletion(
          route: widget.route,
          xpEarned: 15,
        );

    if (mounted) {
      context.go(_resultRouteFor(widget.route));
    }
  }

  String _resultRouteFor(String route) {
    final uri = Uri.tryParse(route);
    final path = uri?.path ?? route;

    final ieltsMatch = RegExp(r'^/ielts/take/([^/?#]+)$').firstMatch(path);
    if (ieltsMatch != null) {
      return '/ielts/result/${ieltsMatch.group(1)}';
    }

    final writingMatch =
        RegExp(r'^/writing/task/([^/?#]+)/take$').firstMatch(path);
    if (writingMatch != null) {
      return '/writing/submission/${writingMatch.group(1)}';
    }

    final speakingMatch =
        RegExp(r'^/speaking/practice/([^/?#]+)$').firstMatch(path);
    if (speakingMatch != null) {
      return '/speaking/result/${speakingMatch.group(1)}';
    }

    final customSpeakingMatch =
        RegExp(r'^/custom-speaking/conversation/([^/?#]+)$').firstMatch(path);
    if (customSpeakingMatch != null) {
      return '/custom-speaking/result/${customSpeakingMatch.group(1)}';
    }

    if (path == '/dictionary/review') {
      final sessionId = DateTime.now().millisecondsSinceEpoch;
      return '/dictionary/review/result/$sessionId';
    }

    return '/home?refresh=${DateTime.now().millisecondsSinceEpoch}';
  }
}
