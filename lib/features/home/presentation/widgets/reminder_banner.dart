import 'package:flutter/material.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../data/home_launchpad_models.dart';

class ReminderBannerCard extends StatelessWidget {
  const ReminderBannerCard({
    super.key,
    required this.banner,
    required this.onPressed,
  });

  final ReminderBanner banner;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accent = _accentColor(tokens, banner.type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.16),
            tokens.background.panelStrong,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.hero),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(
                  _iconForType(banner.type),
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  banner.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            banner.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.text.secondary,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (banner.estimatedMinutes != null)
                _MetaChip(
                  icon: Icons.schedule_rounded,
                  label: '${banner.estimatedMinutes} min',
                ),
              _MetaChip(
                icon: Icons.flag_rounded,
                label: banner.reason.replaceAll('_', ' '),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: banner.ctaLabel,
            icon: Icons.arrow_forward_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Color _accentColor(AppThemeTokens tokens, String type) {
    return switch (type.toUpperCase()) {
      'STREAK_RISK' => tokens.warning,
      'GRADING_RESULT_READY' => tokens.secondary,
      'DUE_VOCAB_QUICK_REVIEW' => tokens.primary,
      'REENGAGEMENT_3D' || 'REENGAGEMENT_7D' => tokens.success,
      _ => tokens.primary,
    };
  }

  IconData _iconForType(String type) {
    return switch (type.toUpperCase()) {
      'STREAK_RISK' => Icons.local_fire_department_rounded,
      'GRADING_RESULT_READY' => Icons.task_alt_rounded,
      'DUE_VOCAB_QUICK_REVIEW' => Icons.refresh_rounded,
      'REENGAGEMENT_3D' || 'REENGAGEMENT_7D' => Icons.notifications_active_rounded,
      _ => Icons.bolt_rounded,
    };
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.background.elevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.text.secondary),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
