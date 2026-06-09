import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/member_model.dart';
import '../models/api_response.dart';

final memberServiceProvider = Provider<MemberService>((ref) {
  return MemberService(ref.read(dioProvider));
});

class MemberService {
  final Dio _dio;
  MemberService(this._dio);

  Future<PaginatedData<MemberModel>> getMembers({int page = 1, String? search}) async {
    try {
      final res = await _dio.get(ApiConstants.members, queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      // Backend membungkus: data: { items: { data:[...], meta } }
      return PaginatedData.fromJson(res.data['data']['items'], MemberModel.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MemberModel> getMember(int id) async {
    try {
      final res = await _dio.get('${ApiConstants.members}/$id');
      return MemberModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MemberModel> createMember(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.members, data: data);
      return MemberModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MemberModel> updateMember(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('${ApiConstants.members}/$id', data: data);
      return MemberModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteMember(int id) async {
    try {
      await _dio.delete('${ApiConstants.members}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
