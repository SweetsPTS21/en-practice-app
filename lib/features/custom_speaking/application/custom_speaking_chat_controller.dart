import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/custom_speaking/custom_speaking_models.dart';
import '../../../core/custom_speaking/custom_speaking_providers.dart';
import '../../../core/learning_journey/learning_journey_providers.dart';
import '../../../core/network/api_error.dart';
import '../../../core/speaking/speech_analytics_models.dart';
import '../../../core/speaking/speaking_providers.dart';
import '../../../core/speaking/speaking_recorder_client.dart';
import '../../../core/speaking/speaking_stt_client.dart';
import '../../auth/auth_providers.dart';

enum CustomSpeakingConnectionState {
  connecting,
  connected,
  fallback,
  disconnected,
}

class CustomSpeakingChatArgs {
  const CustomSpeakingChatArgs({required this.conversationId, this.bootstrap});

  final String conversationId;
  final CustomSpeakingChatBootstrap? bootstrap;

  @override
  bool operator ==(Object other) {
    return other is CustomSpeakingChatArgs &&
        other.conversationId == conversationId &&
        other.bootstrap?.conversationId == bootstrap?.conversationId &&
        other.bootstrap?.latestAiMessage == bootstrap?.latestAiMessage &&
        other.bootstrap?.status == bootstrap?.status &&
        other.bootstrap?.userTurnCount == bootstrap?.userTurnCount &&
        other.bootstrap?.maxUserTurns == bootstrap?.maxUserTurns;
  }

  @override
  int get hashCode => Object.hash(
    conversationId,
    bootstrap?.conversationId,
    bootstrap?.latestAiMessage,
    bootstrap?.status,
    bootstrap?.userTurnCount,
    bootstrap?.maxUserTurns,
  );
}

class CustomSpeakingChatState {
  const CustomSpeakingChatState({
    required this.conversationId,
    required this.connectionState,
    required this.isInitialLoading,
    required this.isRefreshing,
    required this.isSubmitting,
    required this.isWaitingForReply,
    required this.isFinishing,
    required this.recording,
    required this.sttSupported,
    required this.transcriptDraft,
    required this.turnTimer,
    required this.messages,
    this.audioFilePath,
    this.summary,
    this.latestSpeechAnalytics,
    this.loadErrorMessage,
    this.helperMessage,
    this.pendingResultRoute,
    this.latestPromptText,
    this.latestPromptAudioBase64,
  });

  final String conversationId;
  final CustomSpeakingConnectionState connectionState;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isSubmitting;
  final bool isWaitingForReply;
  final bool isFinishing;
  final bool recording;
  final bool sttSupported;
  final String transcriptDraft;
  final Duration turnTimer;
  final List<ConversationMessageItem> messages;
  final String? audioFilePath;
  final CustomSpeakingConversationSummary? summary;
  final SpeechAnalytics? latestSpeechAnalytics;
  final String? loadErrorMessage;
  final String? helperMessage;
  final String? pendingResultRoute;
  final String? latestPromptText;
  final String? latestPromptAudioBase64;

  bool get isLocked => summary?.isLocked ?? false;

  bool get isBusy =>
      isInitialLoading ||
      isRefreshing ||
      isSubmitting ||
      isWaitingForReply ||
      isFinishing;

  bool get canSend => transcriptDraft.trim().isNotEmpty && !isBusy && !isLocked;

  bool get canFinish => !isBusy && !isLocked;

  bool get hasRenderableConversation =>
      summary != null || messages.isNotEmpty || latestPromptText != null;

  String? get effectiveLatestPrompt {
    final trimmedPrompt = latestPromptText?.trim();
    if (trimmedPrompt != null && trimmedPrompt.isNotEmpty) {
      return trimmedPrompt;
    }
    for (final message in messages.reversed) {
      if (message.role == ConversationMessageRole.ai &&
          message.text.trim().isNotEmpty) {
        return message.text.trim();
      }
    }
    return null;
  }

  CustomSpeakingChatState copyWith({
    String? conversationId,
    CustomSpeakingConnectionState? connectionState,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isSubmitting,
    bool? isWaitingForReply,
    bool? isFinishing,
    bool? recording,
    bool? sttSupported,
    String? transcriptDraft,
    Duration? turnTimer,
    List<ConversationMessageItem>? messages,
    String? audioFilePath,
    bool clearAudioFilePath = false,
    CustomSpeakingConversationSummary? summary,
    SpeechAnalytics? latestSpeechAnalytics,
    bool clearLatestSpeechAnalytics = false,
    String? loadErrorMessage,
    bool clearLoadErrorMessage = false,
    String? helperMessage,
    bool clearHelperMessage = false,
    String? pendingResultRoute,
    bool clearPendingResultRoute = false,
    String? latestPromptText,
    bool clearLatestPromptText = false,
    String? latestPromptAudioBase64,
    bool clearLatestPromptAudioBase64 = false,
  }) {
    return CustomSpeakingChatState(
      conversationId: conversationId ?? this.conversationId,
      connectionState: connectionState ?? this.connectionState,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isWaitingForReply: isWaitingForReply ?? this.isWaitingForReply,
      isFinishing: isFinishing ?? this.isFinishing,
      recording: recording ?? this.recording,
      sttSupported: sttSupported ?? this.sttSupported,
      transcriptDraft: transcriptDraft ?? this.transcriptDraft,
      turnTimer: turnTimer ?? this.turnTimer,
      messages: messages ?? this.messages,
      audioFilePath: clearAudioFilePath
          ? null
          : (audioFilePath ?? this.audioFilePath),
      summary: summary ?? this.summary,
      latestSpeechAnalytics: clearLatestSpeechAnalytics
          ? null
          : (latestSpeechAnalytics ?? this.latestSpeechAnalytics),
      loadErrorMessage: clearLoadErrorMessage
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
      helperMessage: clearHelperMessage
          ? null
          : (helperMessage ?? this.helperMessage),
      pendingResultRoute: clearPendingResultRoute
          ? null
          : (pendingResultRoute ?? this.pendingResultRoute),
      latestPromptText: clearLatestPromptText
          ? null
          : (latestPromptText ?? this.latestPromptText),
      latestPromptAudioBase64: clearLatestPromptAudioBase64
          ? null
          : (latestPromptAudioBase64 ?? this.latestPromptAudioBase64),
    );
  }
}

class CustomSpeakingChatController
    extends
        AutoDisposeFamilyNotifier<
          CustomSpeakingChatState,
          CustomSpeakingChatArgs
        > {
  late CustomSpeakingChatArgs _args;
  late final SpeakingRecorderClient _recorder;
  late final SpeakingSttClient _sttClient;
  StreamSubscription<CustomSpeakingRealtimeEvent>? _realtimeSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<Uint8List>? _audioChunkSubscription;
  StreamSubscription<SpeakingSttEvent>? _sttSubscription;
  Timer? _turnTimerTicker;
  DateTime? _turnOpenedAt;
  Completer<CustomSpeakingRealtimeEvent?>? _pendingRealtimeCompleter;
  bool _hasTrackedStart = false;
  bool _hasTrackedCompletion = false;
  String? _lastAutoPlayedPromptKey;

  @override
  CustomSpeakingChatState build(CustomSpeakingChatArgs arg) {
    _args = arg;
    _recorder = RecordSpeakingRecorderClient();
    _sttClient = ref.read(speakingSttClientFactoryProvider)();
    final bootstrap = arg.bootstrap;

    ref.onDispose(() {
      _pendingRealtimeCompleter?.complete(null);
      _pendingRealtimeCompleter = null;
      _turnTimerTicker?.cancel();
      unawaited(_realtimeSubscription?.cancel());
      unawaited(_connectionSubscription?.cancel());
      unawaited(_audioChunkSubscription?.cancel());
      unawaited(_sttSubscription?.cancel());
      unawaited(_sttClient.dispose());
      unawaited(_recorder.dispose());
    });

    _bindRealtime();
    _bindAudioChunks();
    _bindStt(_sttClient);
    _startTurnTicker();

    final initialMessages = _buildBootstrapMessages(bootstrap);
    if (initialMessages.isNotEmpty) {
      _turnOpenedAt = DateTime.now();
    }

    Future<void>.microtask(() => _initialize(arg));

    return CustomSpeakingChatState(
      conversationId: arg.conversationId,
      connectionState: CustomSpeakingConnectionState.connecting,
      isInitialLoading: true,
      isRefreshing: false,
      isSubmitting: false,
      isWaitingForReply: false,
      isFinishing: false,
      recording: false,
      sttSupported: _sttClient.isSupported,
      transcriptDraft: '',
      turnTimer: Duration.zero,
      messages: initialMessages,
      summary: bootstrap?.summary,
      latestPromptText: bootstrap?.latestAiMessage,
    );
  }

  Future<void> refresh() {
    return _loadConversation(initial: false, refreshOnly: true);
  }

  void updateTranscript(String value) {
    state = state.copyWith(
      transcriptDraft: value,
      clearLoadErrorMessage: true,
      clearHelperMessage: true,
    );
  }

  Future<void> startRecording() async {
    if (state.isLocked || state.isBusy || state.recording) {
      return;
    }
    try {
      await _sttClient.start();
      await _recorder.start();
      state = state.copyWith(
        recording: true,
        sttSupported: _sttClient.isSupported,
        helperMessage:
            'Speak naturally. We will keep the transcript in sync while you record.',
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
    if (!state.recording) {
      return;
    }
    SpeakingRecordedClip? clip;
    try {
      clip = await _recorder.stop();
    } finally {
      await _sttClient.stop();
    }
    state = state.copyWith(
      recording: false,
      audioFilePath: clip?.filePath,
      sttSupported: _sttClient.isSupported,
    );
  }

  Future<void> cancelRecording() async {
    if (!state.recording) {
      return;
    }
    try {
      await _recorder.cancel();
    } finally {
      await _sttClient.cancel();
    }
    state = state.copyWith(recording: false, clearAudioFilePath: true);
  }

  Future<void> clearDraft() async {
    if (state.recording) {
      await cancelRecording();
    }
    state = state.copyWith(
      transcriptDraft: '',
      clearAudioFilePath: true,
      clearLatestSpeechAnalytics: true,
      clearHelperMessage: true,
    );
  }

  Future<void> replayLatestPrompt() async {
    final text = state.effectiveLatestPrompt;
    if (text == null || text.isEmpty) {
      return;
    }
    await ref
        .read(aiVoicePlaybackServiceProvider)
        .playPrompt(
          text: text,
          audioBase64: state.latestPromptAudioBase64,
          voiceName: state.summary?.voiceName,
        );
  }

  Future<void> submitTurn() async {
    final transcript = state.transcriptDraft.trim();
    final summary = state.summary;
    if (summary == null ||
        transcript.isEmpty ||
        state.isLocked ||
        state.isBusy) {
      return;
    }

    await stopRecording();
    final elapsedSeconds = _currentTurnSeconds();
    final audioUrl = await ref
        .read(speakingAudioUploadServiceProvider)
        .uploadIfAvailable(state.audioFilePath);
    final analytics =
        state.latestSpeechAnalytics ??
        _buildTranscriptAnalytics(transcript, elapsedSeconds);
    final optimisticMessage = ConversationMessageItem(
      id: 'local-user-${DateTime.now().microsecondsSinceEpoch}',
      role: ConversationMessageRole.user,
      text: transcript,
      speechAnalytics: analytics,
      timeSpentSeconds: elapsedSeconds,
      createdAt: DateTime.now(),
      isPendingSync: true,
    );

    state = state.copyWith(
      isSubmitting: true,
      isWaitingForReply: true,
      transcriptDraft: '',
      latestSpeechAnalytics: analytics,
      messages: <ConversationMessageItem>[...state.messages, optimisticMessage],
      clearAudioFilePath: true,
      clearHelperMessage: true,
      clearLoadErrorMessage: true,
    );

    final api = ref.read(customSpeakingApiProvider);
    final wsClient = ref.read(customSpeakingWsClientProvider);
    final restPayload = SubmitCustomSpeakingTurnPayload(
      transcript: transcript,
      timeSpentSeconds: elapsedSeconds,
      audioUrl: audioUrl,
      speechAnalytics: analytics,
    );
    final realtimePayload = SubmitCustomSpeakingRealtimePayload(
      conversationId: summary.conversationId,
      transcript: transcript,
      timeSpentSeconds: elapsedSeconds,
      audioUrl: audioUrl,
      speechAnalytics: analytics,
    );

    try {
      final published = wsClient.publishSubmit(realtimePayload);
      if (published) {
        state = state.copyWith(
          connectionState: CustomSpeakingConnectionState.connected,
        );
        final event = await _waitForRealtimeEvent();
        if (event != null &&
            event.type != CustomSpeakingRealtimeEventType.error) {
          return;
        }
        state = state.copyWith(
          connectionState: CustomSpeakingConnectionState.fallback,
          helperMessage:
              event?.errorMessage ??
              'The reply is taking longer than expected, so we are finishing this turn through the regular network path.',
        );
      } else {
        state = state.copyWith(
          connectionState: CustomSpeakingConnectionState.fallback,
          helperMessage:
              'Live updates are reconnecting. Your answer is still being sent.',
        );
      }

      final step = await api.submitTurn(summary.conversationId, restPayload);
      await _applyStep(step);
    } catch (error) {
      final message = error is ApiError ? error.message : error.toString();
      state = state.copyWith(
        isSubmitting: false,
        isWaitingForReply: false,
        helperMessage: message,
      );
      rethrow;
    }
  }

  Future<void> finishConversation() async {
    final summary = state.summary;
    if (summary == null || state.isLocked || state.isBusy) {
      return;
    }

    await cancelRecording();
    state = state.copyWith(
      isFinishing: true,
      clearHelperMessage: true,
      clearLoadErrorMessage: true,
    );

    final api = ref.read(customSpeakingApiProvider);
    final wsClient = ref.read(customSpeakingWsClientProvider);

    try {
      final published = wsClient.publishFinish(
        FinishCustomSpeakingRealtimePayload(
          conversationId: summary.conversationId,
        ),
      );
      if (published) {
        state = state.copyWith(
          connectionState: CustomSpeakingConnectionState.connected,
        );
        final event = await _waitForRealtimeEvent();
        if (event != null &&
            event.type ==
                CustomSpeakingRealtimeEventType.conversationComplete) {
          return;
        }
        state = state.copyWith(
          connectionState: CustomSpeakingConnectionState.fallback,
          helperMessage:
              event?.errorMessage ??
              'We are finishing the conversation through the regular network path.',
        );
      } else {
        state = state.copyWith(
          connectionState: CustomSpeakingConnectionState.fallback,
          helperMessage:
              'Live updates are reconnecting. We are still finishing the conversation.',
        );
      }

      final step = await api.finishConversation(summary.conversationId);
      await _applyStep(step);
    } catch (error) {
      final message = error is ApiError ? error.message : error.toString();
      state = state.copyWith(isFinishing: false, helperMessage: message);
      rethrow;
    }
  }

  Future<void> registerAbandonedIfNeeded() {
    if (!_hasTrackedStart || _hasTrackedCompletion) {
      return Future<void>.value();
    }
    return ref
        .read(learningAnalyticsServiceProvider)
        .registerLearningAbandoned(
          route: '/custom-speaking/conversation/${_args.conversationId}',
        );
  }

  void consumePendingResultRoute() {
    state = state.copyWith(clearPendingResultRoute: true);
  }

  Future<void> _initialize(CustomSpeakingChatArgs arg) async {
    await _connectRealtime();
    await _loadConversation(initial: true, refreshOnly: false);
  }

  Future<void> _connectRealtime() async {
    final auth = ref.read(authControllerProvider);
    final userId = auth.user?.id;
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        connectionState: CustomSpeakingConnectionState.disconnected,
      );
      return;
    }

    final token = await ref
        .read(authSessionManagerProvider)
        .ensureValidAccessToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(
        connectionState: CustomSpeakingConnectionState.disconnected,
      );
      return;
    }

    ref
        .read(customSpeakingWsClientProvider)
        .connect(accessToken: token, userId: userId);
  }

  Future<void> _loadConversation({
    required bool initial,
    required bool refreshOnly,
  }) async {
    if (initial) {
      state = state.copyWith(
        isInitialLoading: true,
        clearLoadErrorMessage: true,
      );
    } else {
      state = state.copyWith(
        isRefreshing: true,
        clearHelperMessage: true,
        clearLoadErrorMessage: true,
      );
    }

    final snapshotStore = ref.read(customConversationSnapshotStoreProvider);
    final snapshot = snapshotStore.readSnapshot(_args.conversationId);
    if (snapshot != null && state.summary == null) {
      final messages = _mergeSnapshotPrompt(
        currentMessages: state.messages,
        latestAiMessage: snapshot.latestAiMessage,
      );
      state = state.copyWith(
        summary: CustomSpeakingConversationSummary.fromSnapshot(snapshot),
        messages: messages,
        latestPromptText: snapshot.latestAiMessage,
      );
    }

    try {
      final conversation = await ref
          .read(customSpeakingApiProvider)
          .getConversation(_args.conversationId);
      final effectiveSnapshot =
          snapshot ?? snapshotStore.readSnapshot(_args.conversationId);
      final messages = _buildMessagesFromConversation(
        conversation,
        fallbackPrompt:
            effectiveSnapshot?.latestAiMessage ??
            _args.bootstrap?.latestAiMessage,
      );
      final latestPrompt = _resolveLatestAiMessage(
        messages,
        fallbackPrompt:
            effectiveSnapshot?.latestAiMessage ??
            _args.bootstrap?.latestAiMessage,
      );
      final helperMessage = conversation.isLocked
          ? 'This conversation is no longer active. Open the result to review it.'
          : null;

      state = state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        isSubmitting: false,
        isWaitingForReply: false,
        isFinishing: false,
        summary: conversation.summary,
        messages: messages,
        latestPromptText: latestPrompt,
        latestPromptAudioBase64: null,
        helperMessage: helperMessage,
        clearLoadErrorMessage: true,
      );

      if (!_hasTrackedStart) {
        await ref
            .read(learningAnalyticsServiceProvider)
            .registerLearningStartIfNeeded(
              '/custom-speaking/conversation/${_args.conversationId}',
            );
        _hasTrackedStart = true;
      }

      if (!conversation.isLocked && latestPrompt != null) {
        _turnOpenedAt = DateTime.now();
        state = state.copyWith(turnTimer: Duration.zero);
        await _persistSnapshot(
          conversation.summary,
          latestAiMessage: latestPrompt,
        );
        _maybeAutoplayPrompt(
          latestPrompt,
          audioBase64: null,
          voiceName: conversation.voiceName,
        );
      }
    } catch (error) {
      final message = error is ApiError ? error.message : error.toString();
      if (state.hasRenderableConversation) {
        state = state.copyWith(
          isInitialLoading: false,
          isRefreshing: false,
          loadErrorMessage: message,
          helperMessage: refreshOnly
              ? 'We could not refresh the latest conversation state.'
              : message,
        );
      } else {
        state = state.copyWith(
          isInitialLoading: false,
          isRefreshing: false,
          loadErrorMessage: message,
        );
      }
    }
  }

  Future<void> _applyStep(CustomSpeakingStep step) async {
    final currentSummary = state.summary;
    final updatedSummary =
        (currentSummary ??
                CustomSpeakingConversationSummary(
                  conversationId: step.conversationId,
                  title: step.title,
                  topic: _args.bootstrap?.topic ?? '',
                  gradingEnabled: step.gradingEnabled,
                  status: step.status,
                  userTurnCount: step.userTurnCount,
                  maxUserTurns: step.maxUserTurns,
                  voiceName: step.voiceName,
                ))
            .copyWith(
              title: step.title,
              status: step.status,
              userTurnCount: step.userTurnCount,
              maxUserTurns: step.maxUserTurns,
              voiceName: step.voiceName,
            );

    if (step.conversationComplete || updatedSummary.isLocked) {
      await _completeConversation(
        updatedSummary,
        latestAiMessage: step.aiMessage,
      );
      return;
    }

    final nextMessages = _appendAiMessage(
      _markLatestUserMessageSynced(state.messages),
      text: step.aiMessage,
      turnNumber: step.turnNumber,
      isPendingSync: false,
    );
    state = state.copyWith(
      summary: updatedSummary,
      messages: nextMessages,
      isSubmitting: false,
      isWaitingForReply: false,
      isFinishing: false,
      latestPromptText: step.aiMessage,
      clearLatestPromptAudioBase64: true,
      clearHelperMessage: true,
      turnTimer: Duration.zero,
    );
    _turnOpenedAt = DateTime.now();
    await _persistSnapshot(updatedSummary, latestAiMessage: step.aiMessage);
    if ((step.aiMessage ?? '').trim().isNotEmpty) {
      _maybeAutoplayPrompt(
        step.aiMessage!,
        audioBase64: null,
        voiceName: step.voiceName ?? updatedSummary.voiceName,
      );
    }
  }

  Future<void> _completeConversation(
    CustomSpeakingConversationSummary summary, {
    String? latestAiMessage,
    String? latestPromptAudioBase64,
  }) async {
    await ref
        .read(customConversationSnapshotStoreProvider)
        .clearSnapshot(summary.conversationId);
    if (!_hasTrackedCompletion) {
      await ref
          .read(learningAnalyticsServiceProvider)
          .registerLearningCompletion(
            route: '/custom-speaking/result/${summary.conversationId}',
            metadata: <String, dynamic>{
              'status': summary.status,
              'userTurnCount': summary.userTurnCount,
            },
          );
      _hasTrackedCompletion = true;
    }

    final nextMessages = _appendAiMessage(
      _markLatestUserMessageSynced(state.messages),
      text: latestAiMessage,
      isPendingSync: false,
    );
    state = state.copyWith(
      summary: summary,
      messages: nextMessages,
      isSubmitting: false,
      isWaitingForReply: false,
      isFinishing: false,
      recording: false,
      clearAudioFilePath: true,
      helperMessage: 'Conversation complete. Opening the result next.',
      pendingResultRoute: '/custom-speaking/result/${summary.conversationId}',
      latestPromptText: latestAiMessage,
      latestPromptAudioBase64: latestPromptAudioBase64,
    );
  }

  void _bindRealtime() {
    final wsClient = ref.read(customSpeakingWsClientProvider);
    _realtimeSubscription = wsClient.events.listen(_handleRealtimeEvent);
    _connectionSubscription = wsClient.connectionStates.listen((isConnected) {
      state = state.copyWith(
        connectionState: isConnected
            ? CustomSpeakingConnectionState.connected
            : CustomSpeakingConnectionState.disconnected,
      );
    });
  }

  void _bindStt(SpeakingSttClient sttClient) {
    _sttSubscription = sttClient.events.listen((event) {
      switch (event.type) {
        case SpeakingSttEventType.transcript:
          if ((event.text ?? '').trim().isNotEmpty) {
            state = state.copyWith(transcriptDraft: event.text!.trim());
          }
          break;
        case SpeakingSttEventType.speechSummary:
          state = state.copyWith(latestSpeechAnalytics: event.summary);
          break;
        case SpeakingSttEventType.error:
          state = state.copyWith(helperMessage: event.errorMessage);
          break;
      }
    });
  }

  void _bindAudioChunks() {
    _audioChunkSubscription = _recorder.audioChunks.listen((chunk) {
      unawaited(_sttClient.addAudioChunk(chunk));
    });
  }

  void _handleRealtimeEvent(CustomSpeakingRealtimeEvent event) {
    final isMatchingConversation =
        event.conversationId == null ||
        event.conversationId == _args.conversationId;
    if (!isMatchingConversation) {
      return;
    }

    final completer = _pendingRealtimeCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(event);
    }

    switch (event.type) {
      case CustomSpeakingRealtimeEventType.aiMessage:
        final currentSummary = state.summary;
        if (currentSummary == null) {
          return;
        }
        final updatedSummary = currentSummary.copyWith(
          title: event.title,
          status: event.status,
          userTurnCount: event.userTurnCount,
          maxUserTurns: event.maxUserTurns,
          voiceName: event.voiceName,
        );
        final nextMessages = _appendAiMessage(
          _markLatestUserMessageSynced(state.messages),
          text: event.aiMessage,
          turnNumber: event.turnNumber,
          isPendingSync: false,
        );
        state = state.copyWith(
          summary: updatedSummary,
          messages: nextMessages,
          isSubmitting: false,
          isWaitingForReply: false,
          isFinishing: false,
          latestPromptText: event.aiMessage,
          latestPromptAudioBase64: event.audioBase64,
          clearHelperMessage: true,
          turnTimer: Duration.zero,
        );
        _turnOpenedAt = DateTime.now();
        unawaited(
          _persistSnapshot(updatedSummary, latestAiMessage: event.aiMessage),
        );
        if ((event.aiMessage ?? '').trim().isNotEmpty) {
          _maybeAutoplayPrompt(
            event.aiMessage!,
            audioBase64: event.audioBase64,
            voiceName: event.voiceName ?? updatedSummary.voiceName,
          );
        }
        break;
      case CustomSpeakingRealtimeEventType.conversationComplete:
        final currentSummary = state.summary;
        final updatedSummary =
            (currentSummary ??
                    CustomSpeakingConversationSummary(
                      conversationId: _args.conversationId,
                      title: event.title ?? 'Custom conversation',
                      topic: _args.bootstrap?.topic ?? '',
                      gradingEnabled: true,
                      status: event.status ?? 'COMPLETED',
                      userTurnCount: event.userTurnCount ?? 0,
                      maxUserTurns: event.maxUserTurns ?? 0,
                      voiceName: event.voiceName,
                    ))
                .copyWith(
                  title: event.title,
                  status: event.status ?? 'COMPLETED',
                  userTurnCount: event.userTurnCount,
                  maxUserTurns: event.maxUserTurns,
                  voiceName: event.voiceName,
                );
        unawaited(
          _completeConversation(
            updatedSummary,
            latestAiMessage: event.aiMessage,
            latestPromptAudioBase64: event.audioBase64,
          ),
        );
        break;
      case CustomSpeakingRealtimeEventType.error:
        state = state.copyWith(
          helperMessage:
              event.errorMessage ??
              'We could not receive the latest live update for this conversation.',
        );
        break;
      case CustomSpeakingRealtimeEventType.unknown:
        break;
    }
  }

  Future<CustomSpeakingRealtimeEvent?> _waitForRealtimeEvent() async {
    _pendingRealtimeCompleter?.complete(null);
    final completer = Completer<CustomSpeakingRealtimeEvent?>();
    _pendingRealtimeCompleter = completer;
    try {
      return await completer.future.timeout(const Duration(seconds: 8));
    } on TimeoutException {
      return null;
    } finally {
      if (identical(_pendingRealtimeCompleter, completer)) {
        _pendingRealtimeCompleter = null;
      }
    }
  }

  void _startTurnTicker() {
    _turnTimerTicker?.cancel();
    _turnTimerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final turnOpenedAt = _turnOpenedAt;
      if (turnOpenedAt == null || state.isLocked || state.isWaitingForReply) {
        return;
      }
      state = state.copyWith(
        turnTimer: DateTime.now().difference(turnOpenedAt),
      );
    });
  }

  List<ConversationMessageItem> _buildBootstrapMessages(
    CustomSpeakingChatBootstrap? bootstrap,
  ) {
    final message = bootstrap?.latestAiMessage?.trim();
    if (message == null || message.isEmpty) {
      return const <ConversationMessageItem>[];
    }
    return <ConversationMessageItem>[
      ConversationMessageItem(
        id: 'bootstrap-ai-${bootstrap!.conversationId}',
        role: ConversationMessageRole.ai,
        text: message,
        isPendingSync: true,
      ),
    ];
  }

  List<ConversationMessageItem> _buildMessagesFromConversation(
    CustomSpeakingConversation conversation, {
    String? fallbackPrompt,
  }) {
    final messages = <ConversationMessageItem>[];
    for (final turn in conversation.turns) {
      final aiText = turn.aiMessage.trim();
      if (aiText.isNotEmpty) {
        messages.add(
          ConversationMessageItem(
            id: 'ai-${turn.id}-${turn.turnNumber}',
            role: ConversationMessageRole.ai,
            text: aiText,
            turnNumber: turn.turnNumber,
            createdAt: turn.createdAt,
          ),
        );
      }
      final userText = turn.userTranscript?.trim();
      if (userText != null && userText.isNotEmpty) {
        messages.add(
          ConversationMessageItem(
            id: 'user-${turn.id}-${turn.turnNumber}',
            role: ConversationMessageRole.user,
            text: userText,
            turnNumber: turn.turnNumber,
            speechAnalytics: turn.speechAnalytics,
            timeSpentSeconds: turn.timeSpentSeconds,
            createdAt: turn.createdAt,
          ),
        );
      }
    }
    return _mergeSnapshotPrompt(
      currentMessages: messages,
      latestAiMessage: fallbackPrompt,
    );
  }

  List<ConversationMessageItem> _mergeSnapshotPrompt({
    required List<ConversationMessageItem> currentMessages,
    required String? latestAiMessage,
  }) {
    final prompt = latestAiMessage?.trim();
    if (prompt == null || prompt.isEmpty) {
      return currentMessages;
    }
    for (final message in currentMessages.reversed) {
      if (message.role == ConversationMessageRole.ai &&
          message.text.trim() == prompt) {
        return currentMessages;
      }
    }
    return <ConversationMessageItem>[
      ...currentMessages,
      ConversationMessageItem(
        id: 'snapshot-ai-$prompt',
        role: ConversationMessageRole.ai,
        text: prompt,
        isPendingSync: true,
      ),
    ];
  }

  String? _resolveLatestAiMessage(
    List<ConversationMessageItem> messages, {
    String? fallbackPrompt,
  }) {
    for (final message in messages.reversed) {
      if (message.role == ConversationMessageRole.ai &&
          message.text.trim().isNotEmpty) {
        return message.text.trim();
      }
    }
    final trimmedFallback = fallbackPrompt?.trim();
    return (trimmedFallback == null || trimmedFallback.isEmpty)
        ? null
        : trimmedFallback;
  }

  List<ConversationMessageItem> _appendAiMessage(
    List<ConversationMessageItem> messages, {
    required String? text,
    int? turnNumber,
    required bool isPendingSync,
  }) {
    final aiText = text?.trim();
    if (aiText == null || aiText.isEmpty) {
      return messages;
    }
    for (final message in messages.reversed) {
      if (message.role == ConversationMessageRole.ai &&
          message.text.trim() == aiText) {
        return messages;
      }
    }
    return <ConversationMessageItem>[
      ...messages,
      ConversationMessageItem(
        id: 'ai-${DateTime.now().microsecondsSinceEpoch}',
        role: ConversationMessageRole.ai,
        text: aiText,
        turnNumber: turnNumber,
        createdAt: DateTime.now(),
        isPendingSync: isPendingSync,
      ),
    ];
  }

  List<ConversationMessageItem> _markLatestUserMessageSynced(
    List<ConversationMessageItem> messages,
  ) {
    final copy = List<ConversationMessageItem>.from(messages);
    for (var index = copy.length - 1; index >= 0; index -= 1) {
      final item = copy[index];
      if (item.role == ConversationMessageRole.user && item.isPendingSync) {
        copy[index] = item.copyWith(isPendingSync: false);
        break;
      }
    }
    return copy;
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

  int _currentTurnSeconds() {
    final base = _turnOpenedAt;
    if (base == null) {
      return state.turnTimer.inSeconds <= 0 ? 1 : state.turnTimer.inSeconds;
    }
    final seconds = DateTime.now().difference(base).inSeconds;
    return seconds <= 0 ? 1 : seconds;
  }

  Future<void> _persistSnapshot(
    CustomSpeakingConversationSummary summary, {
    String? latestAiMessage,
  }) {
    return ref
        .read(customConversationSnapshotStoreProvider)
        .saveSnapshot(
          CustomConversationSnapshot(
            conversationId: summary.conversationId,
            title: summary.title,
            topic: summary.topic,
            latestAiMessage: latestAiMessage,
            gradingEnabled: summary.gradingEnabled,
            status: summary.status,
            userTurnCount: summary.userTurnCount,
            maxUserTurns: summary.maxUserTurns,
            voiceName: summary.voiceName,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  void _maybeAutoplayPrompt(
    String text, {
    String? audioBase64,
    String? voiceName,
  }) {
    final promptKey = '${text.trim()}|${audioBase64 ?? ''}';
    if (_lastAutoPlayedPromptKey == promptKey) {
      return;
    }
    _lastAutoPlayedPromptKey = promptKey;
    unawaited(
      ref
          .read(aiVoicePlaybackServiceProvider)
          .playPrompt(
            text: text,
            audioBase64: audioBase64,
            voiceName: voiceName,
          ),
    );
  }
}

final customSpeakingChatControllerProvider =
    AutoDisposeNotifierProviderFamily<
      CustomSpeakingChatController,
      CustomSpeakingChatState,
      CustomSpeakingChatArgs
    >(CustomSpeakingChatController.new);
