import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/recommendation/recommendation_surface.dart';
import '../../core/theme/page_palettes.dart';
import '../../core/theme/theme_extensions.dart';
import '../recommendation/presentation/widgets/recommendation_feed_section.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final tokens = context.tokens;

    return AppPageScaffold(
      title: context.tr('pages.profile.hero.title'),
      subtitle: context.tr('pages.profile.hero.subtitle'),
      paletteKey: AppPagePaletteKey.profile,
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('pages.profile.account.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(context.tr('pages.profile.account.subtitle')),
              SizedBox(height: tokens.density.regularGap),
              _ProfileRow(
                label: context.tr('pages.profile.account.name'),
                value: user?.displayName ?? '-',
              ),
              _ProfileRow(
                label: context.tr('pages.profile.account.email'),
                value: user?.email ?? '-',
              ),
              _ProfileRow(
                label: context.tr('pages.profile.account.status'),
                value: context.tr('pages.profile.account.statusActive'),
              ),
              SizedBox(height: tokens.density.regularGap),
              AppButton(
                label: context.tr('pages.profile.account.logout'),
                icon: Icons.logout_rounded,
                variant: AppButtonVariant.outline,
                onPressed: auth.isSubmitting
                    ? null
                    : () => ref.read(authControllerProvider).logout(),
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('featureHub.sections.scope'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(context.tr('featureHub.copy.scope')),
              SizedBox(height: tokens.density.regularGap),
              _Pill(label: context.tr('pages.profile.focus.identity')),
              SizedBox(height: tokens.density.compactGap),
              _Pill(label: context.tr('pages.profile.focus.progress')),
              SizedBox(height: tokens.density.compactGap),
              _Pill(label: context.tr('pages.profile.focus.preferences')),
            ],
          ),
        ),
        const RecommendationFeedSection(
          surface: RecommendationSurface.profile,
          source: 'PROFILE_RECOMMENDATION',
          title: 'Recommended next',
          subtitle: 'Profile keeps a short feed of what to practice next.',
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.density.compactGap),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Text(label),
    );
  }
}
