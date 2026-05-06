import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/financing_model.dart';
import '../models/api_response.dart';

final financingServiceProvider = Provider<FinancingService>((ref) {
  return FinancingService(ref.read(dioProvider));
});

class FinancingService {
  final Dio _dio;
  FinancingService(this._dio);

  Future<PaginatedData<FinancingModel>> getFinancings({
    int page = 1,
    String? status,
    int? memberId,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.financings, queryParameters: {
        'page': page,
        if (status != null) 'status': status,
        if (memberId != null) 'member_id': memberId,
      });
      return PaginatedData.fromJson(res.data['data'], FinancingModel.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<FinancingModel> getFinancing(int id) async {
    try {
      final res = await _dio.get('${ApiConstants.financings}/$id');
      return FinancingModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SimulationResult> simulate(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.financingSimulate, data: data);
      return SimulationResult.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<FinancingModel> apply(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.financings, data: data);
      return FinancingModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<FinancingModel> approve(int id) async {
    try {
      final res = await _dio.post('${ApiConstants.financings}/$id/approve');
      return FinancingModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<FinancingModel> reject(int id, String reason) async {
    try {
      final res = await _dio.post('${ApiConstants.financings}/$id/reject', data: {
        'rejection_reason': reason,
      });
      return FinancingModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<InstallmentModel>> getInstallments(int financingId) async {
    try {
      final res = await _dio.get('${ApiConstants.financings}/$financingId/installments');
      return (res.data['data'] as List)
          .map((e) => InstallmentModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> payInstallment(int financingId, Map<String, dynamic> data) async {
    try {
      await _dio.post('${ApiConstants.financings}/$financingId/pay', data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
