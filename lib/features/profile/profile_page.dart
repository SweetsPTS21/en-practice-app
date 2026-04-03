import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/theme/page_palettes.dart';
import '../../core/theme/theme_extensions.dart';
import '../leaderboard/presentation/widgets/profile_leaderboard_snapshot.dart';
import '../recommendation/presentation/widgets/recommendation_feed_section.dart';
import '../../core/recommendation/recommendation_surface.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final tokens = context.tokens;

    return AppPageScaffold(
      title: 'Profile',
      subtitle: 'Identity, competitive context and recommendation carry-over now share the same profile surface.',
      paletteKey: AppPagePaletteKey.profile,
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Basic account state stays simple here while deeper profile surfaces arrive later.'),
              SizedBox(height: tokens.density.regularGap),
              _ProfileRow(
                label: 'Name',
                value: user?.displayName ?? '-',
              ),
              _ProfileRow(
                label: 'Email',
                value: user?.email ?? '-',
              ),
              const _ProfileRow(
                label: 'Status',
                value: 'Active',
              ),
              SizedBox(height: tokens.density.regularGap),
              AppButton(
                label: 'Log out',
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
                'Profile scope',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('This surface now connects identity, progress visibility and downstream motivation loops.'),
              SizedBox(height: tokens.density.regularGap),
              const _Pill(label: 'Identity'),
              SizedBox(height: tokens.density.compactGap),
              const _Pill(label: 'Progress'),
              SizedBox(height: tokens.density.compactGap),
              const _Pill(label: 'Preferences'),
            ],
          ),
        ),
        const ProfileLeaderboardSnapshot(),
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
