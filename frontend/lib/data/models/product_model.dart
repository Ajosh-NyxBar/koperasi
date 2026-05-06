class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      productCount: json['products_count'] ?? 0,
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final String? description;
  final int categoryId;
  final String? categoryName;
  final double buyPrice;
  final double marginPercent;
  final double sellingPrice;
  final int stock;
  final String? imageUrl;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.categoryName,
    required this.buyPrice,
    required this.marginPercent,
    required this.sellingPrice,
    required this.stock,
    this.imageUrl,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? json['category']?['name'],
      buyPrice: _d(json['buy_price']),
      marginPercent: _d(json['margin_percent']),
      sellingPrice: _d(json['selling_price']),
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'],
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
