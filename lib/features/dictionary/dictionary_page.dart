import 'package:flutter/material.dart';

import '../../core/design/widgets/feature_landing_page.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/page_palettes.dart';

class DictionaryPage extends StatelessWidget {
  const DictionaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureLandingPage(
      title: context.tr('pages.dictionary.hero.title'),
      subtitle: context.tr('pages.dictionary.hero.subtitle'),
      paletteKey: AppPagePaletteKey.dictionary,
      icon: Icons.menu_book_rounded,
      highlights: [
        context.tr('pages.dictionary.focus.lookup'),
        context.tr('pages.dictionary.focus.savedWords'),
        context.tr('pages.dictionary.focus.review'),
      ],
    );
  }
}
