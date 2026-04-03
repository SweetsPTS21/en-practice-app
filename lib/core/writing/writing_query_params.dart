class WritingTaskQueryParams {
  const WritingTaskQueryParams({
    this.taskType,
    this.difficulty,
    this.page = 0,
    this.size = 20,
  });

  final String? taskType;
  final String? difficulty;
  final int page;
  final int size;

  WritingTaskQueryParams copyWith({String? taskType, String? difficulty}) {
    return WritingTaskQueryParams(
      taskType: taskType,
      difficulty: difficulty,
      page: page,
      size: size,
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
