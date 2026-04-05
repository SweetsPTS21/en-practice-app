import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import '../network/api_config.dart';
import '../speaking/ai_voice_playback_service.dart';
import '../storage/shared_preferences_provider.dart';
import 'custom_conversation_snapshot_store.dart';
import 'custom_speaking_api.dart';
import 'custom_speaking_ws_client.dart';

final customSpeakingApiProvider = Provider<CustomSpeakingApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return CustomSpeakingApi(client);
});

final customConversationSnapshotStoreProvider =
    Provider<CustomConversationSnapshotStore>((ref) {
      final preferences = ref.watch(sharedPreferencesProvider);
      return CustomConversationSnapshotStore(preferences);
    });

final customSpeakingWsClientProvider =
    Provider.autoDispose<CustomSpeakingWsClient>((ref) {
      final client = CustomSpeakingWsClient(url: _buildCustomSpeakingWsUrl());
      ref.onDispose(() {
        unawaited(client.dispose());
      });
      return client;
    });

final aiVoicePlaybackServiceProvider =
    Provider.autoDispose<AiVoicePlaybackService>((ref) {
      final service = AiVoicePlaybackService();
      ref.onDispose(() {
        unawaited(service.dispose());
      });
      return service;
    });

String _buildCustomSpeakingWsUrl() {
  final apiUri = Uri.parse(ApiConfig.baseUrl);
  final scheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
  return Uri(
    scheme: scheme,
    host: apiUri.host,
    port: apiUri.hasPort ? apiUri.port : null,
    path: '/ws/realtime-chat',
  ).toString();
}
