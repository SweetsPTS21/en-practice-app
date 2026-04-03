import 'package:flutter/material.dart';

import '../../core/theme/page_palettes.dart';

class AppDestination {
  const AppDestination({
    required this.route,
    required this.labelKey,
    required this.icon,
    required this.paletteKey,
  });

  final String route;
  final String labelKey;
  final IconData icon;
  final AppPagePaletteKey paletteKey;
}

const dashboardDestination = AppDestination(
  route: '/home',
  labelKey: 'app.nav.home',
  icon: Icons.space_dashboard_rounded,
  paletteKey: AppPagePaletteKey.dashboard,
);

const dictionaryDestination = AppDestination(
  route: '/dictionary',
  labelKey: 'app.nav.dictionary',
  icon: Icons.menu_book_rounded,
  paletteKey: AppPagePaletteKey.dictionary,
);

const ieltsDestination = AppDestination(
  route: '/ielts',
  labelKey: 'app.nav.ielts',
  icon: Icons.school_rounded,
  paletteKey: AppPagePaletteKey.ielts,
);

const writingDestination = AppDestination(
  route: '/writing',
  labelKey: 'app.nav.writing',
  icon: Icons.edit_note_rounded,
  paletteKey: AppPagePaletteKey.writing,
);

const speakingDestination = AppDestination(
  route: '/speaking',
  labelKey: 'app.nav.speaking',
  icon: Icons.mic_rounded,
  paletteKey: AppPagePaletteKey.speaking,
);

const profileDestination = AppDestination(
  route: '/profile',
  labelKey: 'app.nav.profile',
  icon: Icons.account_circle_rounded,
  paletteKey: AppPagePaletteKey.profile,
);

const leaderboardDestination = AppDestination(
  route: '/leaderboard',
  labelKey: 'app.nav.leaderboard',
  icon: Icons.emoji_events_rounded,
  paletteKey: AppPagePaletteKey.leaderboard,
);

const previewDestination = AppDestination(
  route: '/preview',
  labelKey: 'app.nav.preview',
  icon: Icons.palette_rounded,
  paletteKey: AppPagePaletteKey.writing,
);

const settingsDestination = AppDestination(
  route: '/settings',
  labelKey: 'app.nav.settings',
  icon: Icons.tune_rounded,
  paletteKey: AppPagePaletteKey.profile,
);

const appPrimaryDestinations = <AppDestination>[
  dashboardDestination,
  dictionaryDestination,
  ieltsDestination,
  writingDestination,
  speakingDestination,
  leaderboardDestination,
];

const appSecondaryDestinations = <AppDestination>[
  profileDestination,
  previewDestination,
  settingsDestination,
];

AppDestination resolveDestination(String location) {
  for (final destination in [...appPrimaryDestinations, ...appSecondaryDestinations]) {
    if (destination.route == '/') {
      if (location == '/') {
        return destination;
      }
      continue;
    }

    if (location == destination.route || location.startsWith('${destination.route}/')) {
      return destination;
    }
  }

  return dashboardDestination;
}
