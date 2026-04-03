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
    final status = controller.permissionSnapshot?.status ?? PushPermissionStatus.unknown;
    final theme = Theme.of(context).textTheme;

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
            _StatusRow(
              label: 'Token sync',
              value: controller.isSyncingToken ? 'Syncing…' : 'Idle',
            ),
            const SizedBox(height: 18),
            if (status == PushPermissionStatus.unsupported)
              Text(
                'Push is not available on this build yet.',
                style: theme.bodyMedium,
              )
            else if (status == PushPermissionStatus.granted)
              Text(
                'Push permission is enabled. We will keep your device token up to date.',
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
                    label: status == PushPermissionStatus.granted ? 'Close' : 'Not now',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: status == PushPermissionStatus.granted ? 'Sync token' : 'Enable push',
                    icon: status == PushPermissionStatus.granted
                        ? Icons.sync_rounded
                        : Icons.notifications_active_rounded,
                    onPressed: controller.isRequestingPermission || controller.isSyncingToken
                        ? null
                        : () async {
                            if (status == PushPermissionStatus.granted) {
                              await ref.read(pushLifecycleControllerProvider).syncToken(force: true);
                              return;
                            }
                            await ref.read(pushLifecycleControllerProvider).requestPermission();
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
  const _StatusRow({
    required this.label,
    required this.value,
  });

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
