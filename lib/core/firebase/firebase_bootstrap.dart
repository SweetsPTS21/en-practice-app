import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({required this.isAvailable, this.error});

  final bool isAvailable;
  final Object? error;
}

bool get supportsMobileFirebaseMessaging {
  if (kIsWeb) {
    return false;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}

Future<FirebaseBootstrapResult> initializeFirebaseBootstrap() async {
  if (!supportsMobileFirebaseMessaging) {
    return const FirebaseBootstrapResult(isAvailable: false);
  }

  try {
    Firebase.apps.isEmpty
        ? await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          )
        : Firebase.app();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    return const FirebaseBootstrapResult(isAvailable: true);
  } catch (error) {
    return FirebaseBootstrapResult(isAvailable: false, error: error);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {
    // Leave background delivery as a no-op until native Firebase config exists.
  }
}
