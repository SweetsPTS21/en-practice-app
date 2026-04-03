import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/design/widgets/app_card.dart';
import '../../../../core/design/widgets/app_state_widgets.dart';
import '../../../../core/notifications/notification_preferences_models.dart';
import '../../../../core/push/push_providers.dart';
import '../../application/notification_settings_controller.dart';
import 'push_permission_sheet.dart';

class NotificationSettingsCard extends ConsumerWidget {
  const NotificationSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notificationSettingsControllerProvider);
    final pushLifecycle = ref.watch(pushLifecycleControllerProvider);

    if (controller.isLoading) {
      return const AppLoadingCard(
        height: 120,
        message: 'Loading notification settings...',
      );
    }

    final preferences = controller.preferences;
    if (preferences == null) {
      return const AppErrorCard(
        title: 'Settings are unavailable',
        message: 'Notification preferences could not be loaded right now.',
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Notification settings',
            subtitle: 'Choose which updates you want to receive, then review device permission below.',
          ),
          const SizedBox(height: 16),
          _ToggleTile(
            label: 'Push notifications',
            value: preferences.allowPush,
            onChanged: (value) => _save(
              ref,
              preferences.copyWith(allowPush: value),
            ),
          ),
          _ToggleTile(
            label: 'Email updates',
            value: preferences.allowEmail,
            onChanged: (value) => _save(
              ref,
              preferences.copyWith(allowEmail: value),
            ),
          ),
          _ToggleTile(
            label: 'Vocabulary reminders',
            value: preferences.allowVocabularyReminder,
            onChanged: (value) => _save(
              ref,
              preferences.copyWith(allowVocabularyReminder: value),
            ),
          ),
          _ToggleTile(
            label: 'Grading results',
            value: preferences.allowGradingResult,
            onChanged: (value) => _save(
              ref,
              preferences.copyWith(allowGradingResult: value),
            ),
          ),
          _ToggleTile(
            label: 'Admin broadcast',
            value: preferences.allowAdminBroadcast,
            onChanged: (value) => _save(
              ref,
              preferences.copyWith(allowAdminBroadcast: value),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Device push permission', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(pushLifecycle.permissionSnapshot?.label ?? 'Checking...'),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Manage push permission',
                  icon: Icons.notifications_active_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: () => PushPermissionSheet.show(context),
                ),
              ],
            ),
          ),
          if (controller.isSaving) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  void _save(
    WidgetRef ref,
    NotificationPreferences next,
  ) {
    ref.read(notificationSettingsControllerProvider).update(next);
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
