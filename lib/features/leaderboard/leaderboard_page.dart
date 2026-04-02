import 'package:flutter/material.dart';

import '../../core/design/widgets/feature_landing_page.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/page_palettes.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureLandingPage(
      title: context.tr('pages.leaderboard.hero.title'),
      subtitle: context.tr('pages.leaderboard.hero.subtitle'),
      paletteKey: AppPagePaletteKey.leaderboard,
      icon: Icons.emoji_events_rounded,
      highlights: [
        context.tr('pages.leaderboard.focus.rankings'),
        context.tr('pages.leaderboard.focus.friends'),
        context.tr('pages.leaderboard.focus.rewards'),
      ],
    );
  }
}
