import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'dictionary_api.dart';
import 'review_api.dart';

final dictionaryApiProvider = Provider<DictionaryApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return DictionaryApi(client);
});

final reviewApiProvider = Provider<ReviewApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReviewApi(client);
});
