import 'package:flutter/material.dart';

import '../../core/design/widgets/feature_landing_page.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/page_palettes.dart';

class IeltsPage extends StatelessWidget {
  const IeltsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureLandingPage(
      title: context.tr('pages.ielts.hero.title'),
      subtitle: context.tr('pages.ielts.hero.subtitle'),
      paletteKey: AppPagePaletteKey.ielts,
      icon: Icons.school_rounded,
      highlights: [
        context.tr('pages.ielts.focus.roadmap'),
        context.tr('pages.ielts.focus.practice'),
        context.tr('pages.ielts.focus.results'),
      ],
    );
  }
}
