import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/l10n/app_locale_controller.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme_controller.dart';
import '../../core/theme/page_palettes.dart';
import '../../core/theme/theme_backgrounds.dart';
import '../../core/theme/theme_mode_prefs.dart';
import '../../core/theme/theme_profiles.dart';
import '../../core/theme/theme_solid_primary.dart';
import '../../core/theme/theme_extensions.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(appThemeControllerProvider);
    final themeController = ref.read(appThemeControllerProvider.notifier);
    final locale = ref.watch(appLocaleControllerProvider);
    final localeController = ref.read(appLocaleControllerProvider.notifier);
    final tokens = context.tokens;

    return AppPageScaffold(
      title: context.tr('settingsPage.hero.title'),
      subtitle: context.tr('settingsPage.hero.subtitle'),
      paletteKey: AppPagePaletteKey.profile,
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('settingsPage.sections.appearance'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.density.regularGap),
              Text(context.tr('common.mode')),
              SizedBox(height: tokens.density.compactGap),
              SegmentedButton<AppThemePreference>(
                showSelectedIcon: false,
                segments: AppThemePreference.values
                    .map(
                      (value) => ButtonSegment(
                        value: value,
                        label: Text(
                          context.tr('app.theme.modes.${value.name}'),
                        ),
                      ),
                    )
                    .toList(),
                selected: {themeState.themePreference},
                onSelectionChanged: (selection) {
                  themeController.setThemePreference(selection.first);
                },
              ),
              SizedBox(height: tokens.density.regularGap),
              _EnumDropdown<AppThemeProfilePreference>(
                label: context.tr('common.profile'),
                value: themeState.themeProfilePreference,
                items: AppThemeProfilePreference.values,
                itemLabel: (value) =>
                    context.tr('app.theme.profiles.${value.name}'),
                onChanged: (value) {
                  if (value != null) {
                    themeController.setThemeProfilePreference(value);
                  }
                },
              ),
              SizedBox(height: tokens.density.regularGap),
              _EnumDropdown<AppThemeBackgroundPreference>(
                label: context.tr('common.background'),
                value: themeState.themeBackgroundPreference,
                items: AppThemeBackgroundPreference.values,
                itemLabel: (value) =>
                    context.tr('app.theme.backgrounds.${value.name}'),
                onChanged: themeState.themeBackgroundLocked
                    ? null
                    : (value) {
                        if (value != null) {
                          themeController.setThemeBackgroundPreference(value);
                        }
                      },
              ),
              SizedBox(height: tokens.density.regularGap),
              _EnumDropdown<AppThemeSolidPrimaryPreference>(
                label: context.tr('common.solidPrimary'),
                value: themeState.themeSolidPrimaryPreference,
                items: AppThemeSolidPrimaryPreference.values,
                itemLabel: (value) =>
                    context.tr('app.theme.solidPrimary.${value.name}'),
                onChanged: (value) {
                  if (value != null) {
                    themeController.setThemeSolidPrimaryPreference(value);
                  }
                },
              ),
              SizedBox(height: tokens.density.compactGap),
              Text(
                context.tr('settingsPage.hints.solidPrimary'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('settingsPage.sections.language'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.density.regularGap),
              SegmentedButton<AppLocale>(
                showSelectedIcon: false,
                segments: AppLocale.values
                    .map(
                      (value) => ButtonSegment(
                        value: value,
                        label: Text(
                          context.tr('app.language.${value.languageCode}'),
                        ),
                      ),
                    )
                    .toList(),
                selected: {locale},
                onSelectionChanged: (selection) {
                  localeController.setLocale(selection.first);
                },
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('settingsPage.sections.locks'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.density.regularGap),
              _LockChip(
                text: themeState.themeModeLocked
                    ? context.tr('settingsPage.locks.mode')
                    : context.tr('settingsPage.locks.open'),
                active: themeState.themeModeLocked,
              ),
              SizedBox(height: tokens.density.compactGap),
              _LockChip(
                text: themeState.themeBackgroundLocked
                    ? context.tr('settingsPage.locks.background')
                    : context.tr('settingsPage.locks.open'),
                active: themeState.themeBackgroundLocked,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final void Function(T? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _LockChip extends StatelessWidget {
  const _LockChip({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active
            ? tokens.primary.withValues(alpha: 0.12)
            : tokens.secondary,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(
          color: active ? tokens.border.accent : tokens.border.subtle,
        ),
      ),
      child: Text(text),
    );
  }
}
