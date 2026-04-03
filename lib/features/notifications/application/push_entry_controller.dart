import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/push/push_permission_service.dart';
import '../../../core/push/push_providers.dart';
import '../../auth/auth_providers.dart';

class PushEntryController {
  const PushEntryController({
    required this.isAuthenticated,
    required this.permissionSnapshot,
    required this.permissionService,
  });

  final bool isAuthenticated;
  final PushPermissionSnapshot? permissionSnapshot;
  final PushPermissionService permissionService;

  bool shouldShowHomePrompt({required int weeklyXp}) {
    return permissionService.shouldShowContextualPrompt(
      permissionSnapshot,
      isAuthenticated: isAuthenticated,
      weeklyXp: weeklyXp,
    );
  }
}

final pushEntryControllerProvider = Provider<PushEntryController>((ref) {
  final auth = ref.watch(authControllerProvider);
  final push = ref.watch(pushLifecycleControllerProvider);
  return PushEntryController(
    isAuthenticated: auth.isAuthenticated,
    permissionSnapshot: push.permissionSnapshot,
    permissionService: ref.watch(pushPermissionServiceProvider),
  );
});
