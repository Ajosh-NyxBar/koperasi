import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/saving_model.dart';
import '../models/api_response.dart';

final savingServiceProvider = Provider<SavingService>((ref) {
  return SavingService(ref.read(dioProvider));
});

class SavingService {
  final Dio _dio;
  SavingService(this._dio);

  Future<Map<String, dynamic>> getMemberBalance(int memberId) async {
    try {
      final res = await _dio.get('${ApiConstants.savings}/$memberId/balance');
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PaginatedData<SavingTransaction>> getTransactions(
    int memberId, {
    int page = 1,
    String? type,
  }) async {
    try {
      final res = await _dio.get('${ApiConstants.savings}/$memberId/transactions', queryParameters: {
        'page': page,
        if (type != null) 'type': type,
      });
      return PaginatedData.fromJson(res.data['data'], SavingTransaction.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deposit(Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiConstants.savingsDeposit, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> withdraw(Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiConstants.savingsWithdraw, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<MandatorySaving>> getMandatorySavings(int memberId) async {
    try {
      final res = await _dio.get('${ApiConstants.mandatorySavings}/$memberId');
      return (res.data['data'] as List)
          .map((e) => MandatorySaving.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> payMandatory(Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiConstants.payMandatory, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PrincipalSaving?> getPrincipalSaving(int memberId) async {
    try {
      final res = await _dio.get('${ApiConstants.principalSaving}/$memberId');
      if (res.data['data'] != null) {
        return PrincipalSaving.fromJson(res.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
