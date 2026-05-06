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

  Future<String> downloadReport(String url, String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$filename';
      await _dio.download(url, path);
      return path;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> membersPdf() => downloadReport(ApiConstants.reportMembersPdf, 'members.pdf');
  Future<String> membersExcel() => downloadReport(ApiConstants.reportMembersExcel, 'members.xlsx');
  Future<String> savingsPdf() => downloadReport(ApiConstants.reportSavingsPdf, 'savings.pdf');
  Future<String> savingsExcel() => downloadReport(ApiConstants.reportSavingsExcel, 'savings.xlsx');
  Future<String> financingsPdf() => downloadReport(ApiConstants.reportFinancingsPdf, 'financings.pdf');
  Future<String> financingsExcel() => downloadReport(ApiConstants.reportFinancingsExcel, 'financings.xlsx');
  Future<String> socialFundsPdf() => downloadReport(ApiConstants.reportSocialFundsPdf, 'social-funds.pdf');
  Future<String> socialFundsExcel() => downloadReport(ApiConstants.reportSocialFundsExcel, 'social-funds.xlsx');
}
