import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/speaking/speech_analytics_models.dart';
import '../../../core/speaking/speaking_models.dart';
import '../../../core/speaking/speaking_providers.dart';
import '../../../core/speaking/speaking_recorder_client.dart';
import '../../../core/speaking/speaking_stt_client.dart';

class SpeakingAttemptState {
  const SpeakingAttemptState({
    required this.topicId,
    required this.isSubmitting,
    required this.isRecording,
    required this.sttSupported,
    required this.transcriptDraft,
    required this.timer,
    this.audioFilePath,
    this.latestSpeechAnalytics,
    this.helperMessage,
    this.pendingResultRoute,
  });

  final String topicId;
  final bool isSubmitting;
  final bool isRecording;
  final bool sttSupported;
  final String transcriptDraft;
  final Duration timer;
  final String? audioFilePath;
  final SpeechAnalytics? latestSpeechAnalytics;
  final String? helperMessage;
  final String? pendingResultRoute;

  bool get canSubmit => !isSubmitting && transcriptDraft.trim().isNotEmpty;

  SpeakingAttemptState copyWith({
    String? topicId,
    bool? isSubmitting,
    bool? isRecording,
    bool? sttSupported,
    String? transcriptDraft,
    Duration? timer,
    String? audioFilePath,
    bool clearAudioFilePath = false,
    SpeechAnalytics? latestSpeechAnalytics,
    bool clearLatestSpeechAnalytics = false,
    String? helperMessage,
    bool clearHelperMessage = false,
    String? pendingResultRoute,
    bool clearPendingResultRoute = false,
  }) {
    return SpeakingAttemptState(
      topicId: topicId ?? this.topicId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isRecording: isRecording ?? this.isRecording,
      sttSupported: sttSupported ?? this.sttSupported,
      transcriptDraft: transcriptDraft ?? this.transcriptDraft,
      timer: timer ?? this.timer,
      audioFilePath: clearAudioFilePath
          ? null
          : (audioFilePath ?? this.audioFilePath),
      latestSpeechAnalytics: clearLatestSpeechAnalytics
          ? null
          : (latestSpeechAnalytics ?? this.latestSpeechAnalytics),
      helperMessage: clearHelperMessage
          ? null
          : (helperMessage ?? this.helperMessage),
      pendingResultRoute: clearPendingResultRoute
          ? null
          : (pendingResultRoute ?? this.pendingResultRoute),
    );
  }
}

class SpeakingAttemptController
    extends AutoDisposeFamilyNotifier<SpeakingAttemptState, String> {
  late final SpeakingRecorderClient _recorder;
  late final SpeakingSttClient _sttClient;

  StreamSubscription<Uint8List>? _audioChunkSubscription;
  StreamSubscription<SpeakingSttEvent>? _sttSubscription;
  Timer? _timerTicker;
  DateTime? _recordingStartedAt;
  DateTime? _openedAt;

  @override
  SpeakingAttemptState build(String topicId) {
    _recorder = RecordSpeakingRecorderClient();
    _sttClient = ref.read(speakingSttClientFactoryProvider)();
    _openedAt = DateTime.now();
    _bindAudioChunks();
    _bindStt();

    ref.onDispose(() async {
      _timerTicker?.cancel();
      await _audioChunkSubscription?.cancel();
      await _sttSubscription?.cancel();
      await _sttClient.dispose();
      await _recorder.dispose();
    });

    return SpeakingAttemptState(
      topicId: topicId,
      isSubmitting: false,
      isRecording: false,
      sttSupported: _sttClient.isSupported,
      transcriptDraft: '',
      timer: Duration.zero,
    );
  }

  void updateTranscript(String value) {
    state = state.copyWith(transcriptDraft: value, clearHelperMessage: true);
  }

  Future<void> startRecording() async {
    if (state.isSubmitting || state.isRecording) {
      return;
    }

    try {
      await _sttClient.start();
      await _recorder.start();
      _recordingStartedAt = DateTime.now();
      _startTimerTicker();
      state = state.copyWith(
        isRecording: true,
        sttSupported: _sttClient.isSupported,
        clearHelperMessage: true,
        clearAudioFilePath: true,
        clearLatestSpeechAnalytics: true,
      );
    } catch (error) {
      await _sttClient.cancel();
      state = state.copyWith(
        helperMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> stopRecording() async {
    if (!state.isRecording) {
      return;
    }

    SpeakingRecordedClip? clip;
    try {
      clip = await _recorder.stop();
    } finally {
      await _sttClient.stop();
    }
    _timerTicker?.cancel();
    final timer = _recordingStartedAt == null
        ? state.timer
        : DateTime.now().difference(_recordingStartedAt!);
    _recordingStartedAt = null;
    state = state.copyWith(
      isRecording: false,
      timer: timer,
      audioFilePath: clip?.filePath,
      sttSupported: _sttClient.isSupported,
    );
  }

  Future<void> clearDraft() async {
    if (state.isRecording) {
      try {
        await _recorder.cancel();
      } finally {
        await _sttClient.cancel();
      }
    }
    _timerTicker?.cancel();
    _recordingStartedAt = null;
    state = state.copyWith(
      isRecording: false,
      transcriptDraft: '',
      timer: Duration.zero,
      clearAudioFilePath: true,
      clearLatestSpeechAnalytics: true,
      clearHelperMessage: true,
    );
  }

  Future<void> submitAttempt() async {
    if (state.isSubmitting) {
      return;
    }

    if (state.isRecording) {
      await stopRecording();
    }

    final transcript = state.transcriptDraft.trim();
    if (transcript.isEmpty) {
      state = state.copyWith(
        helperMessage:
            'Record your answer first, or review the transcript before sending.',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearHelperMessage: true,
      clearPendingResultRoute: true,
    );

    try {
      final timeSpentSeconds = _resolveTimeSpentSeconds();
      final audioUrl = await ref
          .read(speakingAudioUploadServiceProvider)
          .uploadIfAvailable(state.audioFilePath);
      final analytics =
          state.latestSpeechAnalytics ??
          _buildTranscriptAnalytics(transcript, timeSpentSeconds);
      final attempt = await ref
          .read(speakingApiProvider)
          .submitAttempt(
            state.topicId,
            SubmitSpeakingPayload(
              transcript: transcript,
              timeSpentSeconds: timeSpentSeconds,
              audioUrl: audioUrl,
              speechAnalytics: analytics,
            ),
          );
      state = state.copyWith(
        isSubmitting: false,
        pendingResultRoute: '/speaking/result/${attempt.id}',
        helperMessage: 'Your answer has been submitted for grading.',
      );
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        helperMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  void consumePendingResultRoute() {
    state = state.copyWith(clearPendingResultRoute: true);
  }

  void _bindAudioChunks() {
    _audioChunkSubscription = _recorder.audioChunks.listen((chunk) {
      unawaited(_sttClient.addAudioChunk(chunk));
    });
  }

  void _bindStt() {
    _sttSubscription = _sttClient.events.listen((event) {
      switch (event.type) {
        case SpeakingSttEventType.transcript:
          final text = event.text?.trim() ?? '';
          if (text.isEmpty) {
            return;
          }
          state = state.copyWith(transcriptDraft: text);
          break;
        case SpeakingSttEventType.speechSummary:
          state = state.copyWith(latestSpeechAnalytics: event.summary);
          break;
        case SpeakingSttEventType.error:
          state = state.copyWith(
            helperMessage: event.errorMessage,
            sttSupported: _sttClient.isSupported,
          );
          break;
      }
    });
  }

  void _startTimerTicker() {
    _timerTicker?.cancel();
    _timerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final startedAt = _recordingStartedAt;
      if (startedAt == null || !state.isRecording) {
        return;
      }
      state = state.copyWith(timer: DateTime.now().difference(startedAt));
    });
  }

  int _resolveTimeSpentSeconds() {
    final recordingSeconds = state.timer.inSeconds;
    if (recordingSeconds > 0) {
      return recordingSeconds;
    }
    final openedAt = _openedAt;
    if (openedAt == null) {
      return 1;
    }
    final seconds = DateTime.now().difference(openedAt).inSeconds;
    return seconds <= 0 ? 1 : seconds;
  }

  SpeechAnalytics _buildTranscriptAnalytics(String transcript, int seconds) {
    final words = RegExp(r"[A-Za-z']+")
        .allMatches(transcript.toLowerCase())
        .map((match) => match.group(0)!)
        .toList(growable: false);
    const fillerVocabulary = <String>{
      'um',
      'uh',
      'erm',
      'hmm',
      'like',
      'actually',
      'basically',
    };
    final fillerWords = words
        .where((word) => fillerVocabulary.contains(word))
        .toSet()
        .toList(growable: false);
    final fillerCount = words.where(fillerVocabulary.contains).length;
    final safeSeconds = seconds <= 0 ? 1 : seconds;
    final wordsPerMinute = words.isEmpty
        ? 0.0
        : (words.length * 60) / safeSeconds;

    return SpeechAnalytics(
      wordCount: words.length,
      wordsPerMinute: wordsPerMinute,
      pauseCount: 0,
      avgPauseDurationMs: 0,
      longPauseCount: 0,
      fillerWordCount: fillerCount,
      fillerWords: fillerWords,
      lowConfidenceWords: const <String>[],
      wordDetails: const <SpeechWordDetail>[],
    );
  }
}

final speakingAttemptControllerProvider =
    AutoDisposeNotifierProviderFamily<
      SpeakingAttemptController,
      SpeakingAttemptState,
      String
    >(SpeakingAttemptController.new);
