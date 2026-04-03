const Object _speakingUnset = Object();

class SpeakingTopicQueryParams {
  const SpeakingTopicQueryParams({
    this.part,
    this.difficulty,
    this.page = 0,
    this.size = 20,
  });

  final String? part;
  final String? difficulty;
  final int page;
  final int size;

  SpeakingTopicQueryParams copyWith({
    Object? part = _speakingUnset,
    Object? difficulty = _speakingUnset,
    int? page,
    int? size,
  }) {
    return SpeakingTopicQueryParams(
      part: identical(part, _speakingUnset) ? this.part : part as String?,
      difficulty: identical(difficulty, _speakingUnset)
          ? this.difficulty
          : difficulty as String?,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if ((part ?? '').isNotEmpty) 'part': part,
      if ((difficulty ?? '').isNotEmpty) 'difficulty': difficulty,
      'page': page,
      'size': size,
    };
  }
}
