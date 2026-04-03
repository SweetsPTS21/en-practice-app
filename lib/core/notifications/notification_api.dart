import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'notification_models.dart';
import 'notification_preferences_models.dart';

class NotificationApi {
  NotificationApi(this._client);

  final Dio _client;

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await _client.get<Object?>('/notifications');
      final body = response.data;
      if (body == null) {
        return const <NotificationItem>[];
      }

      if (body is List) {
        return body
            .whereType<Object?>()
            .map((item) => NotificationItem.fromJson(jsonMap(item)))
            .toList(growable: false);
      }

      final data = jsonMap(body);
      final items = data['items'];
      if (items is! List) {
        return const <NotificationItem>[];
      }

      return items
          .whereType<Object?>()
          .map((item) => NotificationItem.fromJson(jsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get<Object?>('/notifications/unread-count');
      final data = jsonMap(response.data);
      return switch (data['count']) {
        int value => value,
        num value => value.toInt(),
        String value => int.tryParse(value) ?? 0,
        _ => 0,
      };
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client.patch<Object?>('/notifications/$notificationId/read');
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _client.patch<Object?>('/notifications/read-all');
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _client.delete<Object?>('/notifications/$notificationId');
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<NotificationPreferences> getPreferences() async {
    try {
      final response = await _client.get<Object?>('/notification-preferences');
      return NotificationPreferences.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final response = await _client.put<Object?>(
        '/notification-preferences',
        data: preferences.toJson(),
      );
      return NotificationPreferences.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
