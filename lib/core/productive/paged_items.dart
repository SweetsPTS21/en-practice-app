class PagedItems<T> {
  const PagedItems({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.items,
  });

  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final List<T> items;

  bool get hasItems => items.isNotEmpty;
  bool get hasNextPage => page + 1 < totalPages;

  factory PagedItems.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) itemBuilder,
  }) {
    final rawItems = json['items'];
    return PagedItems<T>(
      page: readInt(json['page']),
      size: readInt(json['size']),
      totalElements: readInt(json['totalElements']),
      totalPages: readInt(json['totalPages']),
      items: rawItems is List
          ? rawItems
                .whereType<Object?>()
                .map((item) => itemBuilder(readMap(item)))
                .toList(growable: false)
          : <T>[],
    );
  }
}

Map<String, dynamic> readMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, data) => MapEntry(key.toString(), data));
  }
  return const <String, dynamic>{};
}

List<String> readStringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }

  return value
      .whereType<Object?>()
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int readInt(Object? value) {
  return switch (value) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value) ?? 0,
    _ => 0,
  };
}

int? readNullableInt(Object? value) {
  return switch (value) {
    null => null,
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value),
    _ => null,
  };
}

double? readDouble(Object? value) {
  return switch (value) {
    null => null,
    double value => value,
    num value => value.toDouble(),
    String value => double.tryParse(value),
    _ => null,
  };
}

bool readBool(Object? value, {bool fallback = false}) {
  return switch (value) {
    bool value => value,
    String value => value.toLowerCase() == 'true',
    num value => value != 0,
    _ => fallback,
  };
}

DateTime? readDateTime(Object? value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) {
    return null;
  }

  return DateTime.tryParse(raw) ??
      DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}
