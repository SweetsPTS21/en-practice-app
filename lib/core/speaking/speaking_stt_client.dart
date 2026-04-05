import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'speech_analytics_models.dart';

typedef SpeakingAccessTokenLoader = Future<String?> Function();

enum SpeakingSttEventType { transcript, speechSummary, error }

class SpeakingSttEvent {
  const SpeakingSttEvent._({
    required this.type,
    this.text,
    this.isFinal = false,
    this.summary,
    this.errorMessage,
  });

  final SpeakingSttEventType type;
  final String? text;
  final bool isFinal;
  final SpeechAnalytics? summary;
  final String? errorMessage;

  factory SpeakingSttEvent.transcript(String text, {required bool isFinal}) {
    return SpeakingSttEvent._(
      type: SpeakingSttEventType.transcript,
      text: text,
      isFinal: isFinal,
    );
  }

  factory SpeakingSttEvent.summary(SpeechAnalytics summary) {
    return SpeakingSttEvent._(
      type: SpeakingSttEventType.speechSummary,
      summary: summary,
    );
  }

  factory SpeakingSttEvent.error(String message) {
    return SpeakingSttEvent._(
      type: SpeakingSttEventType.error,
      errorMessage: message,
    );
  }
}

abstract class SpeakingSttClient {
  bool get isSupported;

  Stream<SpeakingSttEvent> get events;

  Future<void> start();

  Future<void> addAudioChunk(Uint8List chunk);

  Future<void> stop();

  Future<void> cancel();

  Future<void> dispose();
}

class ServerSpeakingSttClient implements SpeakingSttClient {
  ServerSpeakingSttClient({
    required String websocketUrl,
    required SpeakingAccessTokenLoader accessTokenLoader,
    Duration finishTimeout = const Duration(seconds: 3),
  }) : _websocketUrl = websocketUrl,
       _accessTokenLoader = accessTokenLoader,
       _finishTimeout = finishTimeout;

  final String _websocketUrl;
  final SpeakingAccessTokenLoader _accessTokenLoader;
  final Duration _finishTimeout;

  final StreamController<SpeakingSttEvent> _controller =
      StreamController<SpeakingSttEvent>.broadcast();

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Completer<void>? _finishCompleter;
  Timer? _finishDrainTimer;

  String _committedTranscript = '';
  String _partialTranscript = '';

  @override
  bool get isSupported => !kIsWeb;

  @override
  Stream<SpeakingSttEvent> get events => _controller.stream;

  @override
  Future<void> start() async {
    await cancel();
    if (!isSupported) {
      _emitError(
        'Live transcript is not available on this device right now. You can still review and edit the transcript manually.',
      );
      return;
    }

    final token = (await _accessTokenLoader())?.trim();
    if (token == null || token.isEmpty) {
      _emitError(
        'Live transcript is unavailable because your session needs to reconnect. You can still send the recorded answer after reviewing it.',
      );
      return;
    }

    try {
      final socket = await WebSocket.connect(_buildSocketUri(token).toString());
      _socket = socket;
      _socketSubscription = socket.listen(
        _handleSocketMessage,
        onError: _handleSocketError,
        onDone: _handleSocketDone,
        cancelOnError: false,
      );
    } catch (_) {
      _emitError(
        'We could not connect live transcript right now. You can still review the transcript manually before sending.',
      );
      await _closeSocket();
    }
  }

  @override
  Future<void> addAudioChunk(Uint8List chunk) async {
    final socket = _socket;
    if (socket == null || chunk.isEmpty) {
      return;
    }

    try {
      socket.add(chunk);
    } catch (_) {
      _emitError(
        'Live transcript disconnected while recording. You can still review and send the answer manually.',
      );
      _completeFinish();
      await _closeSocket();
    }
  }

  @override
  Future<void> stop() async {
    final socket = _socket;
    if (socket == null) {
      return;
    }

    _finishCompleter?.complete();
    _finishCompleter = Completer<void>();
    _scheduleFinishTimeout();

    try {
      socket.add(jsonEncode(const <String, String>{'type': 'finish'}));
    } catch (_) {
      _completeFinish();
    }

    try {
      await _finishCompleter!.future.timeout(_finishTimeout);
    } on TimeoutException {
      _completeFinish();
    }

    await _closeSocket();
  }

  @override
  Future<void> cancel() async {
    _committedTranscript = '';
    _partialTranscript = '';
    _finishDrainTimer?.cancel();
    _finishDrainTimer = null;
    _completeFinish();
    await _closeSocket();
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _controller.close();
  }

  Uri _buildSocketUri(String token) {
    final baseUri = Uri.parse(_websocketUrl);
    final queryParameters = <String, String>{
      ...baseUri.queryParameters,
      'token': token,
    };
    return baseUri.replace(queryParameters: queryParameters);
  }

  void _handleSocketMessage(dynamic payload) {
    final decodedMessage = switch (payload) {
      String value => value,
      List<int> value => utf8.decode(value, allowMalformed: true),
      _ => null,
    };
    if (decodedMessage == null || decodedMessage.trim().isEmpty) {
      return;
    }

    Object? decoded;
    try {
      decoded = jsonDecode(decodedMessage);
    } catch (_) {
      return;
    }
    if (decoded is! Map<Object?, Object?>) {
      return;
    }

    final message = decoded.map<String, Object?>(
      (key, value) => MapEntry(key.toString(), value),
    );
    switch (message['type']?.toString()) {
      case 'ready':
        break;
      case 'transcript':
        _handleTranscriptEvent(message);
        break;
      case 'speech_summary':
        final summary = _parseSpeechSummary(message);
        if (summary.hasAnySignal && !_controller.isClosed) {
          _controller.add(SpeakingSttEvent.summary(summary));
        }
        _completeFinish();
        break;
      case 'error':
        _emitError(
          message['message']?.toString().trim().isNotEmpty == true
              ? message['message']!.toString().trim()
              : 'Live transcript could not process this recording.',
        );
        _completeFinish();
        break;
      default:
        break;
    }
  }

  void _handleTranscriptEvent(Map<String, Object?> message) {
    final rawText = message['text']?.toString().trim() ?? '';
    final isFinal = _readBool(message['final']);
    if (rawText.isEmpty && !isFinal) {
      return;
    }

    if (isFinal) {
      final finalText = rawText.isNotEmpty ? rawText : _partialTranscript;
      if (finalText.isNotEmpty) {
        _committedTranscript = _mergeTranscript(
          _committedTranscript,
          finalText,
        );
      }
      _partialTranscript = '';
      final transcript = _committedTranscript.trim();
      if (transcript.isNotEmpty && !_controller.isClosed) {
        _controller.add(SpeakingSttEvent.transcript(transcript, isFinal: true));
      }
      _scheduleFinishDrain();
      return;
    }

    _partialTranscript = rawText;
    final transcript = _composeTranscript();
    if (transcript.isEmpty || _controller.isClosed) {
      return;
    }
    _controller.add(SpeakingSttEvent.transcript(transcript, isFinal: false));
  }

  SpeechAnalytics _parseSpeechSummary(Map<String, Object?> message) {
    final normalized = <String, Object?>{
      ...message,
      if (message['wordsPerMinute'] == null && message['wpm'] != null)
        'wordsPerMinute': message['wpm'],
      if (message['wordDetails'] == null && message['words'] != null)
        'wordDetails': message['words'],
    };
    return SpeechAnalytics.fromJson(normalized);
  }

  bool _readBool(Object? value) {
    return switch (value) {
      bool flag => flag,
      String text => text.trim().toLowerCase() == 'true',
      num number => number != 0,
      _ => false,
    };
  }

  String _composeTranscript() {
    return _mergeTranscript(_committedTranscript, _partialTranscript);
  }

  String _mergeTranscript(String committed, String latest) {
    final base = committed.trim();
    final next = latest.trim();
    if (base.isEmpty) {
      return next;
    }
    if (next.isEmpty) {
      return base;
    }
    if (next == base || next.startsWith(base)) {
      return next;
    }
    if (base.endsWith(next)) {
      return base;
    }
    return '$base $next';
  }

  void _scheduleFinishDrain() {
    final completer = _finishCompleter;
    if (completer == null || completer.isCompleted) {
      return;
    }
    _finishDrainTimer?.cancel();
    _finishDrainTimer = Timer(
      const Duration(milliseconds: 450),
      _completeFinish,
    );
  }

  void _scheduleFinishTimeout() {
    _finishDrainTimer?.cancel();
    _finishDrainTimer = Timer(_finishTimeout, _completeFinish);
  }

  void _handleSocketError(Object error, [StackTrace? _]) {
    _emitError(
      'Live transcript connection was interrupted. You can still review and edit the transcript manually.',
    );
    _completeFinish();
  }

  void _handleSocketDone() {
    _completeFinish();
  }

  void _completeFinish() {
    _finishDrainTimer?.cancel();
    _finishDrainTimer = null;
    final completer = _finishCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _finishCompleter = null;
  }

  Future<void> _closeSocket() async {
    final subscription = _socketSubscription;
    final socket = _socket;
    _socketSubscription = null;
    _socket = null;

    await subscription?.cancel();
    try {
      await socket?.close(WebSocketStatus.normalClosure);
    } catch (_) {}
  }

  void _emitError(String? message) {
    final text = (message ?? '').trim();
    if (text.isEmpty || _controller.isClosed) {
      return;
    }
    _controller.add(SpeakingSttEvent.error(text));
  }
}

class UnsupportedSpeakingSttClient implements SpeakingSttClient {
  UnsupportedSpeakingSttClient();

  final StreamController<SpeakingSttEvent> _controller =
      StreamController<SpeakingSttEvent>.broadcast();

  @override
  bool get isSupported => false;

  @override
  Stream<SpeakingSttEvent> get events => _controller.stream;

  @override
  Future<void> addAudioChunk(Uint8List chunk) async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> start() async {
    if (!_controller.isClosed) {
      _controller.add(
        SpeakingSttEvent.error(
          'Live transcript is not available right now. You can still type your answer.',
        ),
      );
    }
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
