import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'speaking_api.dart';

final speakingApiProvider = Provider<SpeakingApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return SpeakingApi(client);
});
