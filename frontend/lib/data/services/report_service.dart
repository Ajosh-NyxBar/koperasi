import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref.read(dioProvider));
});

class ReportService {
  final Dio _dio;
  ReportService(this._dio);

  Future<String> downloadReport(String url, String filename, {Map<String, dynamic>? queryParams}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$filename';
      await _dio.download(url, path, queryParameters: queryParams);
      return path;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Members
  Future<String> membersPdf({String? status}) => downloadReport(
    ApiConstants.reportMembersPdf, 'members.pdf',
    queryParams: {'format': 'pdf', if (status != null) 'status': status},
  );
  Future<String> membersExcel({String? status}) => downloadReport(
    ApiConstants.reportMembersExcel, 'members.xlsx',
    queryParams: {'format': 'excel', if (status != null) 'status': status},
  );

  // Savings
  Future<String> savingsPdf({String? from, String? to}) => downloadReport(
    ApiConstants.reportSavingsPdf, 'savings.pdf',
    queryParams: {'format': 'pdf', if (from != null) 'from': from, if (to != null) 'to': to},
  );
  Future<String> savingsExcel({String? from, String? to}) => downloadReport(
    ApiConstants.reportSavingsExcel, 'savings.xlsx',
    queryParams: {'format': 'excel', if (from != null) 'from': from, if (to != null) 'to': to},
  );

  // Financings
  Future<String> financingsPdf({String? status, String? from, String? to}) => downloadReport(
    ApiConstants.reportFinancingsPdf, 'financings.pdf',
    queryParams: {'format': 'pdf', if (status != null) 'status': status, if (from != null) 'from': from, if (to != null) 'to': to},
  );
  Future<String> financingsExcel({String? status, String? from, String? to}) => downloadReport(
    ApiConstants.reportFinancingsExcel, 'financings.xlsx',
    queryParams: {'format': 'excel', if (status != null) 'status': status, if (from != null) 'from': from, if (to != null) 'to': to},
  );

  // Social Funds
  Future<String> socialFundsPdf({String? direction, String? from, String? to}) => downloadReport(
    ApiConstants.reportSocialFundsPdf, 'social-funds.pdf',
    queryParams: {'format': 'pdf', if (direction != null) 'direction': direction, if (from != null) 'from': from, if (to != null) 'to': to},
  );
  Future<String> socialFundsExcel({String? direction, String? from, String? to}) => downloadReport(
    ApiConstants.reportSocialFundsExcel, 'social-funds.xlsx',
    queryParams: {'format': 'excel', if (direction != null) 'direction': direction, if (from != null) 'from': from, if (to != null) 'to': to},
  );
}
