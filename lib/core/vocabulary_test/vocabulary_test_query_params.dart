class VocabularyTestAttemptQueryParams {
  const VocabularyTestAttemptQueryParams({this.page = 0, this.size = 10});

  final int page;
  final int size;

  Map<String, dynamic> toQueryParameters() => {'page': page, 'size': size};
}
