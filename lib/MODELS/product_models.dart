class ProductModel {
  final String? id;
  final String name;
  final String brand;
  final String price;
  final String? originalPrice;
  final String category;
  final String image;
  final String desc;
  final double rating;

  ProductModel({
    this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.image,
    required this.desc,
    required this.rating,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      price: map['price']?.toString() ?? '',
      originalPrice: map['originalPrice']?.toString(),
      category: map['category'] ?? '',
      image: map['image'] ?? '',
      desc: map['desc'] ?? '',
     rating: double.tryParse(map['rating']?.toString() ?? '0') ?? 0.0,
    );
  }

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'brand': brand,
    'price': price,
    'originalPrice': originalPrice,
    'category': category,
    'image': image,
    'desc': desc,
    'rating': rating,
  };
}

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? price,
    String? originalPrice,
    String? category,
    String? image,
    String? desc,
    double? rating,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      image: image ?? this.image,
      desc: desc ?? this.desc,
      rating: rating ?? this.rating,
    );
  }
}