import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<UserModel> login(String email, String password) async {
    try {
      final res = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      return UserModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.register, data: data);
      return UserModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final res = await _dio.get(ApiConstants.profile);
      return UserModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final res = await _dio.post(ApiConstants.updateProfile, data: formData);
      return UserModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      final res = await _dio.post(ApiConstants.forgotPassword, data: {'email': email});
      return res.data['message'] ?? 'OTP terkirim';
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> verifyOtp(String email, String otp) async {
    try {
      final res = await _dio.post(ApiConstants.verifyOtp, data: {
        'email': email,
        'otp': otp,
      });
      return res.data['data']?['reset_token'] ?? '';
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> resetPassword(String token, String password, String confirmation) async {
    try {
      await _dio.post(ApiConstants.resetPassword, data: {
        'reset_token': token,
        'password': password,
        'password_confirmation': confirmation,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
