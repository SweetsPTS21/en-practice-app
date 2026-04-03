import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'writing_api.dart';

final writingApiProvider = Provider<WritingApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return WritingApi(client);
});
