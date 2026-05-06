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

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await _dio.get(ApiConstants.notifications);
      return (res.data['data'] as List)
          .map((e) => NotificationModel.fromJson(e))
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
