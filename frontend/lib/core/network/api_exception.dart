import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Koneksi timeout. Periksa jaringan Anda.');
      case DioExceptionType.connectionError:
        return ApiException(message: 'Tidak dapat terhubung ke server.');
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return ApiException(message: 'Request dibatalkan.');
      default:
        return ApiException(message: 'Terjadi kesalahan. Coba lagi.');
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final data = response?.data;
    final statusCode = response?.statusCode;

    if (data is Map<String, dynamic>) {
      return ApiException(
        message: data['message'] ?? 'Terjadi kesalahan.',
        statusCode: statusCode,
        errors: data['errors'] != null
            ? Map<String, dynamic>.from(data['errors'])
            : null,
      );
    }

    switch (statusCode) {
      case 400:
        return ApiException(message: 'Permintaan tidak valid.', statusCode: 400);
      case 401:
        return ApiException(message: 'Sesi telah berakhir. Silakan login kembali.', statusCode: 401);
      case 403:
        return ApiException(message: 'Anda tidak memiliki akses.', statusCode: 403);
      case 404:
        return ApiException(message: 'Data tidak ditemukan.', statusCode: 404);
      case 422:
        return ApiException(message: 'Data tidak valid.', statusCode: 422);
      case 429:
        return ApiException(message: 'Terlalu banyak permintaan. Coba lagi nanti.', statusCode: 429);
      case 500:
        return ApiException(message: 'Terjadi kesalahan pada server.', statusCode: 500);
      default:
        return ApiException(message: 'Terjadi kesalahan.', statusCode: statusCode);
    }
  }

  String get firstError {
    if (errors != null && errors!.isNotEmpty) {
      final first = errors!.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return message;
  }

  @override
  String toString() => message;
}
