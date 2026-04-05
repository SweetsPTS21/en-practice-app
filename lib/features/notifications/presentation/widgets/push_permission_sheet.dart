import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/widgets/app_button.dart';
import '../../../../core/push/push_platform_adapter.dart';
import '../../../../core/push/push_providers.dart';

class PushPermissionSheet extends ConsumerWidget {
  const PushPermissionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const PushPermissionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(pushLifecycleControllerProvider);
    final status =
        controller.permissionSnapshot?.status ?? PushPermissionStatus.unknown;
    final theme = Theme.of(context).textTheme;
    final primaryLabel = switch (status) {
      PushPermissionStatus.granted => 'Open system settings',
      PushPermissionStatus.denied => 'Open system settings',
      PushPermissionStatus.unsupported => 'Close',
      PushPermissionStatus.unknown => 'Enable push',
    };
    final primaryIcon = switch (status) {
      PushPermissionStatus.granted ||
      PushPermissionStatus.denied => Icons.open_in_new_rounded,
      PushPermissionStatus.unsupported => null,
      PushPermissionStatus.unknown => Icons.notifications_active_rounded,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enable push notifications', style: theme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              'Enable push so reminders and results can bring you back to the right task.',
              style: theme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _StatusRow(
              label: 'Device permission',
              value: controller.permissionSnapshot?.label ?? 'Checking...',
            ),
            const SizedBox(height: 10),
            if (status == PushPermissionStatus.unsupported)
              Text(
                'Push is not available on this build yet.',
                style: theme.bodyMedium,
              )
            else if (status == PushPermissionStatus.granted)
              Text(
                'Push permission is enabled. You can change it any time in your device notification settings.',
                style: theme.bodyMedium,
              )
            else if (status == PushPermissionStatus.denied)
              Text(
                'Push permission is currently denied. Open your device notification settings to turn it back on.',
                style: theme.bodyMedium,
              )
            else
              Text(
                'Turn on push when you want reminders, grading updates and quick re-entry into lessons.',
                style: theme.bodyMedium,
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Close',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: primaryLabel,
                    icon: primaryIcon,
                    onPressed:
                        controller.isRequestingPermission ||
                            controller.isSyncingToken
                        ? null
                        : () async {
                            final lifecycle = ref.read(
                              pushLifecycleControllerProvider,
                            );
                            if (status == PushPermissionStatus.unsupported) {
                              Navigator.of(context).pop();
                              return;
                            }
                            if (status == PushPermissionStatus.unknown) {
                              await lifecycle.requestPermission();
                              return;
                            }
                            Navigator.of(context).pop();
                            await lifecycle.openSystemNotificationSettings();
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
