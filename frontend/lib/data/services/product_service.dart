import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/product_model.dart';
import '../models/api_response.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.read(dioProvider));
});

class ProductService {
  final Dio _dio;
  ProductService(this._dio);

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _dio.get(ApiConstants.categories);
      return (res.data['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.categories, data: data);
      return CategoryModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CategoryModel> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('${ApiConstants.categories}/$id', data: data);
      return CategoryModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _dio.delete('${ApiConstants.categories}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Products
  Future<PaginatedData<ProductModel>> getProducts({
    int page = 1,
    int? categoryId,
    String? search,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.products, queryParameters: {
        'page': page,
        if (categoryId != null) 'category_id': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      return PaginatedData.fromJson(res.data['data'], ProductModel.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ProductModel> createProduct(FormData data) async {
    try {
      final res = await _dio.post(ApiConstants.products, data: data);
      return ProductModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ProductModel> updateProduct(int id, FormData data) async {
    try {
      final res = await _dio.post('${ApiConstants.products}/$id', data: data);
      return ProductModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('${ApiConstants.products}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
