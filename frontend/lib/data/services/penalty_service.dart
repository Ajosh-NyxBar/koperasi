import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';

final penaltyServiceProvider = Provider<PenaltyService>((ref) {
  return PenaltyService(ref.read(dioProvider));
});

class PenaltyService {
  final Dio _dio;
  PenaltyService(this._dio);

  Future<Map<String, dynamic>> getOverview() async {
    try {
      final res = await _dio.get(ApiConstants.penaltyOverview);
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<PenaltySettingModel>> getSettings() async {
    try {
      final res = await _dio.get(ApiConstants.penaltySettings);
      return (res.data['data'] as List)
          .map((e) => PenaltySettingModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> createSetting(Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiConstants.penaltySettings, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> updateSetting(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('${ApiConstants.penaltySettings}/$id', data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteSetting(int id) async {
    try {
      await _dio.delete('${ApiConstants.penaltySettings}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> waivePenalty(int installmentId, {required double amount, required String reason}) async {
    try {
      final res = await _dio.post(
        ApiConstants.penaltyWaive(installmentId),
        data: {'waived_amount': amount, 'reason': reason},
      );
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getWaiverHistory({int? financingId}) async {
    try {
      final res = await _dio.get(ApiConstants.penaltyWaivers, queryParameters: {
        if (financingId != null) 'financing_id': financingId,
      });
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

class PenaltySettingModel {
  final int id;
  final String name;
  final double penaltyPerDay;
  final int gracePeriodDays;
  final double maxPenaltyPercentage;
  final bool isDefault;
  final bool isActive;

  PenaltySettingModel({
    required this.id,
    required this.name,
    required this.penaltyPerDay,
    required this.gracePeriodDays,
    required this.maxPenaltyPercentage,
    required this.isDefault,
    required this.isActive,
  });

  factory PenaltySettingModel.fromJson(Map<String, dynamic> json) {
    return PenaltySettingModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      penaltyPerDay: _d(json['penalty_per_day']),
      gracePeriodDays: json['grace_period_days'] ?? 0,
      maxPenaltyPercentage: _d(json['max_penalty_percentage']),
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
