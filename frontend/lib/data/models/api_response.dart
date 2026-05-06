class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromData,
  }) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : json['data'] as T?,
      errors: json['errors'] != null
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }
}

class PaginatedData<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  PaginatedData({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final dataList = (json['data'] as List?)
            ?.map((e) => fromItem(e as Map<String, dynamic>))
            .toList() ??
        [];
    return PaginatedData(
      items: dataList,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}
