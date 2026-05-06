import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.read(dioProvider));
});

class DashboardService {
  final Dio _dio;
  DashboardService(this._dio);

  Future<AdminDashboard> getAdminDashboard() async {
    try {
      final res = await _dio.get(ApiConstants.dashboardAdmin);
      return AdminDashboard.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MemberDashboard> getMemberDashboard() async {
    try {
      final res = await _dio.get(ApiConstants.dashboardMember);
      return MemberDashboard.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
