import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'custom_speaking_api.dart';

final customSpeakingApiProvider = Provider<CustomSpeakingApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return CustomSpeakingApi(client);
});
