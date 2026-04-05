import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SpeakingRecordedClip {
  const SpeakingRecordedClip({required this.filePath, required this.fileName});

  final String filePath;
  final String fileName;
}

abstract class SpeakingRecorderClient {
  bool get isSupported;

  Stream<Uint8List> get audioChunks;

  Future<bool> ensurePermission();

  Future<void> start();

  Future<SpeakingRecordedClip?> stop();

  Future<void> cancel();

  Future<void> dispose();
}

class RecordSpeakingRecorderClient implements SpeakingRecorderClient {
  RecordSpeakingRecorderClient({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  static const int _sampleRateHz = 16000;
  static const int _channelCount = 1;
  static const int _bitsPerSample = 16;
  static const RecordConfig _recordConfig = RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: _sampleRateHz,
    numChannels: _channelCount,
    echoCancel: true,
    noiseSuppress: true,
    androidConfig: AndroidRecordConfig(
      audioSource: AndroidAudioSource.voiceRecognition,
    ),
    streamBufferSize: 4096,
  );

  final AudioRecorder _recorder;
  final StreamController<Uint8List> _audioChunkController =
      StreamController<Uint8List>.broadcast();

  StreamSubscription<Uint8List>? _recordingSubscription;
  Completer<void>? _streamDoneCompleter;
  BytesBuilder _pcmBuffer = BytesBuilder(copy: false);

  @override
  bool get isSupported => true;

  @override
  Stream<Uint8List> get audioChunks => _audioChunkController.stream;

  @override
  Future<bool> ensurePermission() {
    return _recorder.hasPermission();
  }

  @override
  Future<void> start() async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) {
      throw Exception(
        'Microphone access is required before you can record a speaking answer.',
      );
    }

    await cancel();

    _pcmBuffer = BytesBuilder(copy: false);
    _streamDoneCompleter = Completer<void>();

    final stream = await _recorder.startStream(_recordConfig);
    _recordingSubscription = stream.listen(
      _handleAudioChunk,
      onError: (Object error, StackTrace stackTrace) => _completeStreamDone(),
      onDone: _completeStreamDone,
      cancelOnError: false,
    );
  }

  @override
  Future<SpeakingRecordedClip?> stop() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    await _waitForStreamDrain();
    await _cleanupSubscription();

    final pcmBytes = _takeBufferedAudio();
    if (pcmBytes.isEmpty) {
      return null;
    }

    final directory = await getTemporaryDirectory();
    final fileName = 'speaking-${DateTime.now().microsecondsSinceEpoch}.wav';
    final filePath = '${directory.path}${Platform.pathSeparator}$fileName';
    final file = File(filePath);
    await file.writeAsBytes(_buildWaveFile(pcmBytes), flush: true);

    return SpeakingRecordedClip(filePath: filePath, fileName: fileName);
  }

  @override
  Future<void> cancel() async {
    if (await _recorder.isRecording()) {
      await _recorder.cancel();
    }
    await _waitForStreamDrain();
    await _cleanupSubscription();
    _pcmBuffer = BytesBuilder(copy: false);
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
    await _audioChunkController.close();
  }

  void _handleAudioChunk(Uint8List chunk) {
    if (chunk.isEmpty) {
      return;
    }

    _pcmBuffer.add(chunk);
    if (!_audioChunkController.isClosed) {
      _audioChunkController.add(Uint8List.fromList(chunk));
    }
  }

  void _completeStreamDone() {
    final completer = _streamDoneCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Future<void> _waitForStreamDrain() async {
    final completer = _streamDoneCompleter;
    if (completer == null) {
      return;
    }

    try {
      await completer.future.timeout(const Duration(seconds: 1));
    } on TimeoutException {
      return;
    }
  }

  Future<void> _cleanupSubscription() async {
    await _recordingSubscription?.cancel();
    _recordingSubscription = null;
    _streamDoneCompleter = null;
  }

  Uint8List _takeBufferedAudio() {
    final bytes = _pcmBuffer.takeBytes();
    _pcmBuffer = BytesBuilder(copy: false);
    return bytes;
  }

  Uint8List _buildWaveFile(Uint8List pcmBytes) {
    final header = Uint8List(44);
    final byteData = ByteData.sublistView(header);
    final dataLength = pcmBytes.lengthInBytes;
    final bytesPerSample = _bitsPerSample ~/ 8;
    final blockAlign = _channelCount * bytesPerSample;
    final byteRate = _sampleRateHz * blockAlign;

    header.setRange(0, 4, const <int>[0x52, 0x49, 0x46, 0x46]);
    byteData.setUint32(4, 36 + dataLength, Endian.little);
    header.setRange(8, 12, const <int>[0x57, 0x41, 0x56, 0x45]);
    header.setRange(12, 16, const <int>[0x66, 0x6d, 0x74, 0x20]);
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little);
    byteData.setUint16(22, _channelCount, Endian.little);
    byteData.setUint32(24, _sampleRateHz, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, _bitsPerSample, Endian.little);
    header.setRange(36, 40, const <int>[0x64, 0x61, 0x74, 0x61]);
    byteData.setUint32(40, dataLength, Endian.little);

    return Uint8List.fromList(<int>[...header, ...pcmBytes]);
  }
}
