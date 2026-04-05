import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import '../network/api_config.dart';
import 'speaking_api.dart';
import 'speaking_audio_upload_service.dart';
import 'speaking_stt_client.dart';

final speakingApiProvider = Provider<SpeakingApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return SpeakingApi(client);
});

final speakingAudioUploadServiceProvider = Provider<SpeakingAudioUploadService>(
  (ref) {
    return SpeakingAudioUploadService(ref.watch(speakingApiProvider));
  },
);

typedef SpeakingSttClientFactory = SpeakingSttClient Function();

final speakingSttClientFactoryProvider = Provider<SpeakingSttClientFactory>((
  ref,
) {
  final sessionManager = ref.watch(authSessionManagerProvider);
  final wsUrl = buildSpeakingSttWsUrl();
  return () => ServerSpeakingSttClient(
    websocketUrl: wsUrl,
    accessTokenLoader: sessionManager.ensureValidAccessToken,
  );
});

String buildSpeakingSttWsUrl() {
  final apiUri = Uri.parse(ApiConfig.baseUrl);
  final scheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
  return Uri(
    scheme: scheme,
    host: apiUri.host,
    port: apiUri.hasPort ? apiUri.port : null,
    path: '/ws/speaking/stt',
  ).toString();
}
