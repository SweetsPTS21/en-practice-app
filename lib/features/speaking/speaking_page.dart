import 'package:flutter/material.dart';

import '../../core/design/widgets/feature_landing_page.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/page_palettes.dart';

class SpeakingPage extends StatelessWidget {
  const SpeakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureLandingPage(
      title: context.tr('pages.speaking.hero.title'),
      subtitle: context.tr('pages.speaking.hero.subtitle'),
      paletteKey: AppPagePaletteKey.speaking,
      icon: Icons.mic_rounded,
      highlights: [
        context.tr('pages.speaking.focus.recording'),
        context.tr('pages.speaking.focus.fluency'),
        context.tr('pages.speaking.focus.coaching'),
      ],
    );
  }
}
