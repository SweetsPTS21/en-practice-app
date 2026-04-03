import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'speaking_conversation_api.dart';

final speakingConversationApiProvider = Provider<SpeakingConversationApi>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  return SpeakingConversationApi(client);
});
