import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

final firebaseBootstrapResultProvider = Provider<FirebaseBootstrapResult>((
  ref,
) {
  return const FirebaseBootstrapResult(isAvailable: false);
});
