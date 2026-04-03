import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'vocabulary_check_service.dart';

final vocabularyCheckServiceProvider = Provider<VocabularyCheckService>((ref) {
  final client = ref.watch(apiClientProvider);
  return VocabularyCheckService(client: client);
});
