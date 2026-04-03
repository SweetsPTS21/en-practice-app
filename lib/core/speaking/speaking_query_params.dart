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

  SpeakingTopicQueryParams copyWith({String? part, String? difficulty}) {
    return SpeakingTopicQueryParams(
      part: part,
      difficulty: difficulty,
      page: page,
      size: size,
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
