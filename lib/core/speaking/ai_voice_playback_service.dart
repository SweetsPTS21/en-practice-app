// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class AiVoicePlaybackService {
  AiVoicePlaybackService()
    : _audioPlayer = AudioPlayer(),
      _tts = FlutterTts() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.46);
    _tts.awaitSpeakCompletion(true);
  }

  final AudioPlayer _audioPlayer;
  final FlutterTts _tts;

  Future<void> playPrompt({
    required String text,
    String? audioBase64,
    String? voiceName,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      return;
    }

    final encodedAudio = _normalizeAudioBase64(audioBase64);
    if (encodedAudio != null && encodedAudio.isNotEmpty) {
      final bytes = base64Decode(encodedAudio);
      await _playBytes(bytes);
      return;
    }

    await _speakText(normalizedText, voiceName: voiceName);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _tts.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
  }

  Future<void> _playBytes(Uint8List bytes) async {
    await _tts.stop();
    await _audioPlayer.stop();
    await _audioPlayer.setAudioSource(_BytesAudioSource(bytes));
    await _audioPlayer.play();
  }

  Future<void> _speakText(String text, {String? voiceName}) async {
    await _audioPlayer.stop();
    await _tts.stop();
    try {
      if ((voiceName ?? '').trim().isNotEmpty) {
        await _tts.setVoice(<String, String>{
          'name': voiceName!.trim(),
          'locale': 'en-US',
        });
      } else {
        await _tts.setVoice(<String, String>{'locale': 'en-US'});
      }
    } catch (_) {
      await _tts.setVoice(<String, String>{'locale': 'en-US'});
    }
    await _tts.speak(text);
  }

  String? _normalizeAudioBase64(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final markerIndex = raw.indexOf('base64,');
    if (markerIndex >= 0) {
      return raw.substring(markerIndex + 'base64,'.length);
    }
    return raw;
  }
}

class _BytesAudioSource extends StreamAudioSource {
  _BytesAudioSource(this._bytes);

  final Uint8List _bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final resolvedStart = start ?? 0;
    final resolvedEnd = end ?? _bytes.length;
    final sliced = Uint8List.sublistView(_bytes, resolvedStart, resolvedEnd);
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: sliced.length,
      offset: resolvedStart,
      stream: Stream<List<int>>.value(sliced),
      contentType: 'audio/mpeg',
    );
  }
}
