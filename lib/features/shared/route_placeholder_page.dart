import 'package:flutter/material.dart';

import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/theme/page_palettes.dart';

class RoutePlaceholderPage extends StatelessWidget {
  const RoutePlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.paletteKey,
    required this.highlights,
  });

  final String title;
  final String subtitle;
  final AppPagePaletteKey paletteKey;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: title,
      subtitle: subtitle,
      paletteKey: paletteKey,
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: highlights
                .map(
                  (highlight) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.check_circle_outline_rounded, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(highlight)),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}
