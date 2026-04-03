import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/navigation/learning_action_resolver.dart';
import '../../../../core/recommendation/recommendation_models.dart';
import '../../../../core/recommendation/recommendation_surface.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../application/recommendation_feedback_controller.dart';

class RecommendationCard extends ConsumerStatefulWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.surface,
    required this.source,
    this.position = 0,
    this.hero = false,
    this.showFeedbackActions = false,
    this.onHide,
  });

  final RecommendationCardModel recommendation;
  final RecommendationSurface surface;
  final String source;
  final int position;
  final bool hero;
  final bool showFeedbackActions;
  final VoidCallback? onHide;

  @override
  ConsumerState<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends ConsumerState<RecommendationCard> {
  bool _hidden = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    if (_hidden) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;
    final recommendation = widget.recommendation;
    final accent = _accentColor(context, recommendation.type);
    final icon = _iconForType(recommendation.type);

    return AppCard(
      strong: widget.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widget.hero ? 52 : 44,
                height: widget.hero ? 52 : 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _typeLabel(recommendation.type),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendation.title,
                      style: widget.hero
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              if (widget.showFeedbackActions)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<_SnoozePreset>(
                      tooltip: 'Snooze recommendation',
                      onSelected: _handleSnooze,
                      itemBuilder: (context) => const [
                        PopupMenuItem<_SnoozePreset>(
                          value: _SnoozePreset.oneHour,
                          child: Text('Snooze 1 hour'),
                        ),
                        PopupMenuItem<_SnoozePreset>(
                          value: _SnoozePreset.tomorrow,
                          child: Text('Snooze until tomorrow'),
                        ),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.bedtime_rounded, size: 18),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dismiss recommendation',
                      onPressed: _submitting ? null : _handleDismiss,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
            ],
          ),
          if (recommendation.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              recommendation.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
            ),
          ],
          if ((recommendation.explanation?.message ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(tokens.radius.xl),
                border: Border.all(color: accent.withValues(alpha: 0.12)),
              ),
              child: Text(
                recommendation.explanation!.message!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.text.secondary),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (recommendation.estimatedMinutes != null)
                _MetaChip(
                  icon: Icons.schedule_rounded,
                  label: '${recommendation.estimatedMinutes} min',
                ),
              if ((recommendation.difficulty ?? '').isNotEmpty)
                _MetaChip(
                  icon: Icons.tune_rounded,
                  label: recommendation.difficulty!,
                ),
              if (recommendation.priority != null)
                _MetaChip(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Priority ${recommendation.priority}',
                ),
              if (recommendation.confidenceGainScore != null)
                _MetaChip(
                  icon: Icons.trending_up_rounded,
                  label: '+${recommendation.confidenceGainScore} confidence',
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: _submitting ? 'Working...' : 'Start now',
            icon: Icons.arrow_forward_rounded,
            onPressed: _submitting ? null : _handleClick,
          ),
        ],
      ),
    );
  }

  Future<void> _handleClick() async {
    setState(() {
      _submitting = true;
    });

    try {
      final currentRoute = GoRouterState.of(context).uri.toString();
      final target = await ref
          .read(recommendationFeedbackControllerProvider)
          .click(
            recommendation: widget.recommendation,
            surface: widget.surface,
            source: widget.source,
            currentRoute: currentRoute,
            position: widget.position,
          );

      if (!mounted) {
        return;
      }

      if (target.kind == LearningActionKind.external) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'External recommendation routes are not enabled on mobile.',
            ),
          ),
        );
        return;
      }

      context.go(target.href);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _handleDismiss() async {
    setState(() {
      _submitting = true;
    });

    try {
      await ref
          .read(recommendationFeedbackControllerProvider)
          .dismiss(
            recommendation: widget.recommendation,
            surface: widget.surface,
            currentRoute: GoRouterState.of(context).uri.toString(),
            source: widget.source,
            position: widget.position,
          );

      if (mounted) {
        setState(() {
          _hidden = true;
        });
      }
      widget.onHide?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _handleSnooze(_SnoozePreset preset) async {
    setState(() {
      _submitting = true;
    });

    final now = DateTime.now();
    final snoozeUntil = switch (preset) {
      _SnoozePreset.oneHour => now.add(const Duration(hours: 1)),
      _SnoozePreset.tomorrow => DateTime(now.year, now.month, now.day + 1, 8),
    };

    try {
      await ref
          .read(recommendationFeedbackControllerProvider)
          .snooze(
            recommendation: widget.recommendation,
            surface: widget.surface,
            currentRoute: GoRouterState.of(context).uri.toString(),
            snoozeUntil: snoozeUntil,
            source: widget.source,
            position: widget.position,
          );

      if (mounted) {
        setState(() {
          _hidden = true;
        });
      }
      widget.onHide?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

enum _SnoozePreset { oneHour, tomorrow }

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tokens.text.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tokens.text.secondary),
          ),
        ],
      ),
    );
  }
}

IconData _iconForType(String type) {
  final normalized = type.toUpperCase();
  if (normalized.contains('SPEAK')) {
    return Icons.mic_rounded;
  }
  if (normalized.contains('WRITE')) {
    return Icons.edit_note_rounded;
  }
  if (normalized.contains('READ') || normalized.contains('IELTS')) {
    return Icons.menu_book_rounded;
  }
  if (normalized.contains('LISTEN')) {
    return Icons.headphones_rounded;
  }
  if (normalized.contains('VOCAB')) {
    return Icons.psychology_rounded;
  }
  return Icons.auto_awesome_rounded;
}

Color _accentColor(BuildContext context, String type) {
  final tokens = context.tokens;
  final normalized = type.toUpperCase();
  if (normalized.contains('SPEAK')) {
    return tokens.warning;
  }
  if (normalized.contains('WRITE')) {
    return tokens.success;
  }
  if (normalized.contains('READ') || normalized.contains('IELTS')) {
    return tokens.secondary;
  }
  if (normalized.contains('VOCAB')) {
    return tokens.primary;
  }
  return tokens.primary;
}

String _typeLabel(String type) {
  return type.replaceAll('_', ' ').trim();
}
