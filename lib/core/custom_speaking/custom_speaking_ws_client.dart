import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../network/json_helpers.dart';
import 'custom_speaking_models.dart';

class CustomSpeakingWsClient {
  CustomSpeakingWsClient({required String url}) : _url = url;

  final String _url;
  final StreamController<CustomSpeakingRealtimeEvent> _eventController =
      StreamController<CustomSpeakingRealtimeEvent>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  StompClient? _client;
  bool _isConnected = false;
  String? _subscribedUserId;

  Stream<CustomSpeakingRealtimeEvent> get events => _eventController.stream;

  Stream<bool> get connectionStates => _connectionController.stream;

  bool get isConnected => _isConnected;

  void connect({required String accessToken, required String userId}) {
    if (_subscribedUserId == userId && _isConnected) {
      return;
    }

    disconnect();
    _subscribedUserId = userId;

    late final StompClient client;
    client = StompClient(
      config: StompConfig(
        url: _url,
        reconnectDelay: const Duration(seconds: 5),
        stompConnectHeaders: <String, String>{
          'Authorization': 'Bearer $accessToken',
        },
        webSocketConnectHeaders: <String, String>{
          'Authorization': 'Bearer $accessToken',
        },
        onConnect: (_) {
          _setConnected(true);
          client.subscribe(
            destination: '/topic/custom-speaking-conversation/$userId',
            callback: (frame) {
              final body = frame.body;
              if (body == null || body.trim().isEmpty) {
                return;
              }
              try {
                final decoded = json.decode(body);
                _eventController.add(
                  CustomSpeakingRealtimeEvent.fromJson(jsonMap(decoded)),
                );
              } catch (_) {
                _eventController.add(
                  const CustomSpeakingRealtimeEvent(
                    type: CustomSpeakingRealtimeEventType.error,
                    rawType: 'ERROR',
                    errorMessage:
                        'We could not read the latest conversation update.',
                  ),
                );
              }
            },
          );
        },
        onDisconnect: (_) {
          _setConnected(false);
        },
        onWebSocketError: (_) {
          _setConnected(false);
        },
        onStompError: (frame) {
          _setConnected(false);
          final message = frame.body?.trim();
          if (message != null && message.isNotEmpty) {
            _eventController.add(
              CustomSpeakingRealtimeEvent(
                type: CustomSpeakingRealtimeEventType.error,
                rawType: 'ERROR',
                errorMessage: message,
              ),
            );
          }
        },
      ),
    );

    _client = client;
    client.activate();
  }

  bool publishSubmit(SubmitCustomSpeakingRealtimePayload payload) {
    return _send(payload.toJson());
  }

  bool publishFinish(FinishCustomSpeakingRealtimePayload payload) {
    return _send(payload.toJson());
  }

  void disconnect() {
    _setConnected(false);
    _client?.deactivate();
    _client = null;
  }

  Future<void> dispose() async {
    disconnect();
    await _eventController.close();
    await _connectionController.close();
  }

  bool _send(Map<String, dynamic> payload) {
    final client = _client;
    if (!_isConnected || client == null) {
      return false;
    }

    try {
      client.send(
        destination: '/app/custom-speaking-conversation',
        body: json.encode(payload),
      );
      return true;
    } catch (_) {
      _setConnected(false);
      return false;
    }
  }

  void _setConnected(bool value) {
    if (_isConnected == value) {
      return;
    }
    _isConnected = value;
    if (!_connectionController.isClosed) {
      _connectionController.add(value);
    }
  }
}
