import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/design/widgets/app_state_widgets.dart';
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
              AppSectionHeader(
                title: 'Coming next',
                subtitle: subtitle,
              ),
              const SizedBox(height: 16),
              const AppEmptyState(
                icon: Icons.schedule_rounded,
                title: 'This area is still being prepared',
                subtitle:
                    'You can already reach this route. The detailed workflow will be added soon.',
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'What to expect',
                subtitle: 'The finished page will stay focused on one clear job.',
              ),
              const SizedBox(height: 16),
              ...highlights.map(
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
              ),
              const SizedBox(height: 6),
              AppButton(
                label: 'Back to home',
                icon: Icons.home_rounded,
                variant: AppButtonVariant.outline,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
