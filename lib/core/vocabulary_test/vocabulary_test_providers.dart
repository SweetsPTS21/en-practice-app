import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'vocabulary_test_api.dart';

final vocabularyTestApiProvider = Provider<VocabularyTestApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return VocabularyTestApi(client);
});
