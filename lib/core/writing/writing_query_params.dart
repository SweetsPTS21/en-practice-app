const Object _writingUnset = Object();

class WritingTaskQueryParams {
  const WritingTaskQueryParams({
    this.taskType,
    this.difficulty,
    this.page = 0,
    this.size = 10,
  });

  final String? taskType;
  final String? difficulty;
  final int page;
  final int size;

  WritingTaskQueryParams copyWith({
    Object? taskType = _writingUnset,
    Object? difficulty = _writingUnset,
    int? page,
    int? size,
  }) {
    return WritingTaskQueryParams(
      taskType: identical(taskType, _writingUnset)
          ? this.taskType
          : taskType as String?,
      difficulty: identical(difficulty, _writingUnset)
          ? this.difficulty
          : difficulty as String?,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if ((taskType ?? '').isNotEmpty) 'taskType': taskType,
      if ((difficulty ?? '').isNotEmpty) 'difficulty': difficulty,
      'page': page,
      'size': size,
    };
  }
}
