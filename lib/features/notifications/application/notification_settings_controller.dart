import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_preferences_models.dart';
import '../../../core/notifications/notification_providers.dart';

class NotificationSettingsController extends ChangeNotifier {
  NotificationSettingsController({
    required this.ref,
  }) {
    load();
  }

  final Ref ref;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;
  NotificationPreferences? preferences;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      preferences = await ref.read(notificationApiProvider).getPreferences();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(NotificationPreferences next) async {
    preferences = next;
    isSaving = true;
    notifyListeners();

    try {
      preferences = await ref.read(notificationApiProvider).updatePreferences(next);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}

final notificationSettingsControllerProvider =
    ChangeNotifierProvider.autoDispose<NotificationSettingsController>((ref) {
  return NotificationSettingsController(ref: ref);
});
