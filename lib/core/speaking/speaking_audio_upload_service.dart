import 'dart:io';

import 'package:dio/dio.dart';

import 'speaking_api.dart';

class SpeakingAudioUploadService {
  const SpeakingAudioUploadService(this._api);

  final SpeakingApi _api;

  Future<String?> uploadIfAvailable(String? filePath) async {
    final normalizedPath = filePath?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) {
      return null;
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      return null;
    }

    final fileName = file.uri.pathSegments.isEmpty
        ? 'speaking-answer.m4a'
        : file.uri.pathSegments.last;
    final formData = FormData.fromMap(<String, Object>{
      'file': await MultipartFile.fromFile(normalizedPath, filename: fileName),
    });
    final audioUrl = (await _api.uploadAudio(formData)).trim();
    return audioUrl.isEmpty ? null : audioUrl;
  }
}
