import 'api_error.dart';

Map<String, dynamic> jsonMap(
  Object? value, {
  String fallbackMessage = 'Invalid server response.',
}) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, data) => MapEntry(key.toString(), data));
  }

  throw ApiError(
    message: fallbackMessage,
    status: 500,
    data: value,
  );
}
