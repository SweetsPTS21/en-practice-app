import 'package:flutter/material.dart';

import '../../core/design/widgets/feature_landing_page.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/page_palettes.dart';

class WritingPage extends StatelessWidget {
  const WritingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureLandingPage(
      title: context.tr('pages.writing.hero.title'),
      subtitle: context.tr('pages.writing.hero.subtitle'),
      paletteKey: AppPagePaletteKey.writing,
      icon: Icons.edit_note_rounded,
      highlights: [
        context.tr('pages.writing.focus.prompts'),
        context.tr('pages.writing.focus.feedback'),
        context.tr('pages.writing.focus.history'),
      ],
    );
  }
}
