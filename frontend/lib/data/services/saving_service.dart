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

  /// GET /savings/balance -> saldo tabungan + riwayat transaksi (paginated).
  /// Backend mendukung filter query: type (deposit/withdrawal), from, to (YYYY-MM-DD).
  Future<SavingBalance> getBalance({String? type, String? from, String? to}) async {
    try {
      final res = await _dio.get('${ApiConstants.savings}/balance', queryParameters: {
        if (type != null) 'type': type,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      });
      return SavingBalance.fromJson(res.data['data'] as Map<String, dynamic>);
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

  /// GET /savings/mandatory -> { total_paid, items: { data: [...] } }
  Future<List<MandatorySaving>> getMandatorySavings() async {
    try {
      final res = await _dio.get(ApiConstants.mandatorySavings);
      final items = res.data['data']?['items']?['data'] as List? ?? [];
      return items
          .map((e) => MandatorySaving.fromJson(e as Map<String, dynamic>))
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
