import 'dart:async';

import 'package:flutter/foundation.dart';

import '../learning_journey/learning_journey_action_service.dart';
import 'push_message_models.dart';
import 'push_open_router.dart';
import 'push_permission_service.dart';
import 'push_platform_adapter.dart';
import 'push_token_service.dart';

class PushLifecycleController extends ChangeNotifier {
  PushLifecycleController({
    required PushPlatformAdapter adapter,
    required PushPermissionService permissionService,
    required PushTokenService tokenService,
    required PushOpenRouter openRouter,
    required bool isAuthenticated,
  })  : _adapter = adapter,
        _permissionService = permissionService,
        _tokenService = tokenService,
        _openRouter = openRouter,
        _isAuthenticated = isAuthenticated {
    unawaited(_initialize());
  }

  final PushPlatformAdapter _adapter;
  final PushPermissionService _permissionService;
  final PushTokenService _tokenService;
  final PushOpenRouter _openRouter;
  final bool _isAuthenticated;

  StreamSubscription<PushMessage>? _foregroundSubscription;
  StreamSubscription<PushMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _isDisposed = false;

  PushPermissionSnapshot? permissionSnapshot;
  PushMessage? foregroundMessage;
  String? pendingRoute;
  bool isInitializing = true;
  bool isRequestingPermission = false;
  bool isSyncingToken = false;

  Future<void> _initialize() async {
    permissionSnapshot = await _permissionService.refresh();
    if (_isDisposed) {
      return;
    }

    _foregroundSubscription = _adapter.onForegroundMessage.listen((message) {
      if (_isDisposed) {
        return;
      }
      foregroundMessage = message;
      _safeNotifyListeners();
    });
    _openedSubscription = _adapter.onMessageOpenedApp.listen(_handlePushOpen);
    _tokenRefreshSubscription = _adapter.onTokenRefresh.listen((_) {
      if (_isDisposed || !_isAuthenticated) {
        return;
      }
      unawaited(syncToken(force: true));
    });

    final initialMessage = await _adapter.getInitialMessage();
    if (_isDisposed) {
      return;
    }
    if (initialMessage != null) {
      await _handlePushOpen(initialMessage);
    }

    if (_isAuthenticated) {
      await syncToken();
      if (_isDisposed) {
        return;
      }
    }

    isInitializing = false;
    _safeNotifyListeners();
  }

  Future<void> requestPermission() async {
    isRequestingPermission = true;
    _safeNotifyListeners();
    try {
      permissionSnapshot = await _permissionService.requestPermission();
      if (_isDisposed) {
        return;
      }
      if (_isAuthenticated && permissionSnapshot?.status == PushPermissionStatus.granted) {
        await syncToken(force: true);
      }
    } finally {
      if (!_isDisposed) {
        isRequestingPermission = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> syncToken({bool force = false}) async {
    if (!_isAuthenticated || _isDisposed) {
      return;
    }

    isSyncingToken = true;
    _safeNotifyListeners();
    try {
      await _tokenService.syncTokenIfPossible(force: force);
    } finally {
      if (!_isDisposed) {
        isSyncingToken = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> dismissContextualPrompt() async {
    await _permissionService.dismissContextualPrompt();
    if (_isDisposed) {
      return;
    }
    permissionSnapshot = await _permissionService.refresh();
    if (_isDisposed) {
      return;
    }
    _safeNotifyListeners();
  }

  void dismissForegroundMessage() {
    if (_isDisposed) {
      return;
    }
    foregroundMessage = null;
    _safeNotifyListeners();
  }

  Future<JourneyActionOutcome?> openForegroundMessage() async {
    final message = foregroundMessage;
    if (message == null || _isDisposed) {
      return null;
    }

    foregroundMessage = null;
    _safeNotifyListeners();
    final outcome = await _openRouter.prepareOpen(message);
    return outcome;
  }

  String? consumePendingRoute() {
    if (_isDisposed) {
      return null;
    }
    final route = pendingRoute;
    pendingRoute = null;
    _safeNotifyListeners();
    return route;
  }

  Future<void> _handlePushOpen(PushMessage message) async {
    if (_isDisposed) {
      return;
    }
    final outcome = await _openRouter.prepareOpen(message);
    if (_isDisposed) {
      return;
    }
    if (outcome.target.kind.name != 'external') {
      pendingRoute = outcome.target.href;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    super.dispose();
  }
}
