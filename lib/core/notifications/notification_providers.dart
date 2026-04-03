import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'notification_api.dart';
import 'notification_realtime_client.dart';

final notificationApiProvider = Provider<NotificationApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationApi(client);
});

final notificationRealtimeClientProvider =
    ChangeNotifierProvider<NotificationRealtimeClient>((ref) {
      final api = ref.watch(notificationApiProvider);
      final auth = ref.watch(authControllerProvider);
      return NotificationRealtimeClient(
        api: api,
        isAuthenticated: auth.isAuthenticated,
      );
    });
