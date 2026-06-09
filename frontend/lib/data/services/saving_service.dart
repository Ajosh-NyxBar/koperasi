import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/saving_model.dart';

final savingServiceProvider = Provider<SavingService>((ref) {
  return SavingService(ref.read(dioProvider));
});

class SavingService {
  final Dio _dio;
  SavingService(this._dio);

  Future<Map<String, dynamic>> getMemberBalance() async {
    try {
      final res = await _dio.get('${ApiConstants.savings}/balance');
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // TODO: backend belum punya endpoint riwayat transaksi simpanan (GET /savings/transactions).
  // Method getTransactions dihapus sampai endpoint tersedia.

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

  Future<List<MandatorySaving>> getMandatorySavings() async {
    try {
      final res = await _dio.get(ApiConstants.mandatorySavings);
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

  Future<PrincipalSaving?> getPrincipalSaving() async {
    try {
      final res = await _dio.get(ApiConstants.principalSaving);
      if (res.data['data'] != null) {
        return PrincipalSaving.fromJson(res.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
