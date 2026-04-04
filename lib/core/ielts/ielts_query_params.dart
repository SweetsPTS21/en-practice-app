class IeltsTestQueryParams {
  const IeltsTestQueryParams({
    this.page = 0,
    this.size = 10,
    this.skill,
    this.search,
  });

  final int page;
  final int size;
  final String? skill;
  final String? search;

  IeltsTestQueryParams copyWith({
    int? page,
    int? size,
    String? skill,
    bool clearSkill = false,
    String? search,
    bool clearSearch = false,
  }) {
    return IeltsTestQueryParams(
      page: page ?? this.page,
      size: size ?? this.size,
      skill: clearSkill ? null : (skill ?? this.skill),
      search: clearSearch ? null : (search ?? this.search),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'size': size,
      if ((skill ?? '').isNotEmpty) 'skill': skill,
      if ((search ?? '').isNotEmpty) 'search': search,
    };
  }
}
