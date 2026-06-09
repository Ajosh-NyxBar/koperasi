import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/social_fund_model.dart';
import '../models/api_response.dart';

final socialFundServiceProvider = Provider<SocialFundService>((ref) {
  return SocialFundService(ref.read(dioProvider));
});

class SocialFundService {
  final Dio _dio;
  SocialFundService(this._dio);

  Future<PaginatedData<SocialFundModel>> getTransactions({int page = 1, int? memberId}) async {
    try {
      final res = await _dio.get(ApiConstants.socialFunds, queryParameters: {
        'page': page,
        if (memberId != null) 'member_id': memberId,
      });
      // Backend membungkus: data: { funds: { data:[...], meta }, total_in, total_out, balance }
      return PaginatedData.fromJson(res.data['data']['funds'], SocialFundModel.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> recordTransaction(Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiConstants.socialFunds, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PaginatedData<SocialFundApplication>> getApplications({
    int page = 1,
    String? status,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.socialFundApplications, queryParameters: {
        'page': page,
        if (status != null) 'status': status,
      });
      return PaginatedData.fromJson(res.data['data'], SocialFundApplication.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SocialFundApplication> applyForAid(FormData data) async {
    try {
      final res = await _dio.post(ApiConstants.socialFundApplications, data: data);
      return SocialFundApplication.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> decideApplication(int id, Map<String, dynamic> data) async {
    try {
      await _dio.post('${ApiConstants.socialFundApplications}/$id/decide', data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
