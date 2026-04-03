class DictionaryQueryParams {
  const DictionaryQueryParams({
    this.page = 0,
    this.size = 12,
    this.keyword = '',
    this.wordType,
    this.isFavorite,
  });

  final int page;
  final int size;
  final String keyword;
  final String? wordType;
  final bool? isFavorite;

  DictionaryQueryParams copyWith({
    int? page,
    int? size,
    String? keyword,
    Object? wordType = _sentinel,
    Object? isFavorite = _sentinel,
  }) {
    return DictionaryQueryParams(
      page: page ?? this.page,
      size: size ?? this.size,
      keyword: keyword ?? this.keyword,
      wordType: identical(wordType, _sentinel) ? this.wordType : wordType as String?,
      isFavorite: identical(isFavorite, _sentinel) ? this.isFavorite : isFavorite as bool?,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'size': size,
      if (keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      if (wordType != null && wordType!.trim().isNotEmpty) 'wordType': wordType,
      if (isFavorite != null) 'isFavorite': isFavorite,
    };
  }
}

const _sentinel = Object();
