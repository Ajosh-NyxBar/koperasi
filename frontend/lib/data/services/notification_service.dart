import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationApiService>((ref) {
  return NotificationApiService(ref.read(dioProvider));
});

class NotificationApiService {
  final Dio _dio;
  NotificationApiService(this._dio);

  /// GET /notifications -> { unread_count, items: { data: [...], meta } }
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await _dio.get(ApiConstants.notifications);
      final items = res.data['data']?['items']?['data'] as List? ?? [];
      return items
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.post('${ApiConstants.notifications}/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.post(ApiConstants.notificationsReadAll);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
