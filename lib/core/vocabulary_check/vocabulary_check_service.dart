import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'vocabulary_check_models.dart';

class VocabularyCheckService {
  VocabularyCheckService({
    required Dio client,
  })  : _client = client,
        _translateClient = Dio();

  final Dio _client;
  final Dio _translateClient;

  Future<VocabularyWordValidation> validateEnglishWord(String word) async {
    final trimmed = word.trim().toLowerCase();
    if (trimmed.isEmpty || !RegExp(r'^[a-zA-Z\s-]+$').hasMatch(trimmed)) {
      return const VocabularyWordValidation(valid: false, translation: '');
    }

    final payload = await _translateWord(trimmed);
    return VocabularyWordValidation(
      valid: payload.translation.trim().isNotEmpty,
      translation: payload.translation,
    );
  }

  Future<VocabularyMeaningCheckResult> checkMeaning({
    required String englishWord,
    required String vietnameseMeaning,
  }) async {
    final payload = await _translateWord(englishWord.trim());
    final normalizedUser = _normalizeMeaning(vietnameseMeaning);
    final normalizedCorrect = _normalizeMeaning(payload.translation);
    final alternatives = payload.alternatives;
    final isCorrect = normalizedUser.isNotEmpty &&
        (normalizedUser == normalizedCorrect ||
            alternatives.any((value) => _normalizeMeaning(value) == normalizedUser) ||
            normalizedCorrect.contains(normalizedUser) ||
            normalizedUser.contains(normalizedCorrect) ||
            alternatives.any((value) {
              final normalized = _normalizeMeaning(value);
              return normalized.contains(normalizedUser) || normalizedUser.contains(normalized);
            }));

    return VocabularyMeaningCheckResult(
      isCorrect: isCorrect,
      translation: payload.translation,
      alternatives: payload.alternatives,
      synonyms: payload.synonyms,
    );
  }

  Future<VocabularyWordExplanation> explainWord(String word) async {
    try {
      final response = await _client.get<Object?>(
        '/open-claw/explain',
        queryParameters: {'word': word.trim()},
      );
      final data = jsonMap(response.data);
      return VocabularyWordExplanation(
        word: data['word']?.toString() ?? word.trim(),
        meaning: data['meaning']?.toString() ?? data['definition']?.toString() ?? '',
        ipa: data['ipa']?.toString(),
        wordType: data['wordType']?.toString(),
        sourceType: data['sourceType']?.toString() ?? 'OPEN_CLAW',
        examples: _stringList(data['examples']),
        synonyms: _stringList(data['synonyms']),
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<_TranslatePayload> _translateWord(String word) async {
    final url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=vi&hl=vi&dt=t&dt=ss&dt=at&dt=md&q=${Uri.encodeQueryComponent(word)}';
    final response = await _translateClient.getUri<Object?>(Uri.parse(url));
    final data = response.data;
    if (data is! List) {
      throw ApiError(message: 'Translation API request failed.', status: 500);
    }

    final translation = _readPrimaryTranslation(data);
    final alternatives = _readAlternatives(data, translation);
    final synonyms = _readSynonyms(data);
    return _TranslatePayload(
      translation: translation,
      alternatives: alternatives,
      synonyms: synonyms,
    );
  }

  String _readPrimaryTranslation(List<dynamic> payload) {
    if (payload.isEmpty) {
      return '';
    }
    final section = payload.first;
    if (section is List && section.isNotEmpty && section.first is List) {
      final first = section.first as List;
      return first.isNotEmpty ? first.first?.toString() ?? '' : '';
    }
    return '';
  }

  List<String> _readAlternatives(List<dynamic> payload, String translation) {
    if (payload.length <= 5 || payload[5] is! List) {
      return const <String>[];
    }
    final values = <String>{};
    for (final group in payload[5] as List) {
      if (group is! List || group.length <= 2 || group[2] is! List) {
        continue;
      }
      for (final alt in group[2] as List) {
        if (alt is List && alt.isNotEmpty) {
          final value = alt.first?.toString() ?? '';
          if (value.isNotEmpty && value != translation) {
            values.add(value);
          }
        }
      }
    }
    return values.toList(growable: false);
  }

  List<String> _readSynonyms(List<dynamic> payload) {
    if (payload.length <= 11 || payload[11] is! List) {
      return const <String>[];
    }
    final values = <String>{};
    for (final group in payload[11] as List) {
      if (group is! List || group.length <= 1 || group[1] is! List) {
        continue;
      }
      for (final synonymGroup in group[1] as List) {
        if (synonymGroup is! List || synonymGroup.isEmpty || synonymGroup.first is! List) {
          continue;
        }
        for (final synonym in synonymGroup.first as List) {
          final value = synonym?.toString() ?? '';
          if (value.isNotEmpty) {
            values.add(value);
          }
        }
      }
    }
    return values.take(8).toList(growable: false);
  }

  String _normalizeMeaning(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _TranslatePayload {
  const _TranslatePayload({
    required this.translation,
    required this.alternatives,
    required this.synonyms,
  });

  final String translation;
  final List<String> alternatives;
  final List<String> synonyms;
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .whereType<Object?>()
      .map((item) => item?.toString() ?? '')
      .where((item) => item.trim().isNotEmpty)
      .toList(growable: false);
}
