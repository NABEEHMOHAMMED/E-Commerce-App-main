import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final double? oldPrice;        // السعر القديم (مشطوب)
  final int? discountPercentage; // نسبة الخصم مثل 40
  final String? timeLeft;        // الوقت المتبقي مثل "2h 28m left"
  final String imageUrl;
  final String description;
  final double rating;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    this.oldPrice,
    this.discountPercentage,
    this.timeLeft,
    required this.imageUrl,
    this.description = '',
    this.rating = 4.5,
    this.isFavorite = false,
  });

  /// Converts product to JSON for local storage (Exercise 2)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'price': price,
      'image': imageUrl,
      'category': categoryId,
      'oldPrice': oldPrice,
      'discountPercentage': discountPercentage,
      'timeLeft': timeLeft,
      'description': description,
      'rating': rating,
      'isFavorite': isFavorite,
    };
  }

  /// Creates Product from JSON (for loading from cache)
  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    String imageUrl = json['image'] ?? '';
    if (id == 'm1' && imageUrl.contains('da61225697cc')) {
      imageUrl = 'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MGFQ4_AV2?wid=2000&hei=2000&fmt=jpeg&qlt=90&.v=WlBWbGdIeUx1NGF1d0FHRnE2VjFSaVRkTXNZOFJZTitTVFE0NHl0VW5Cb0YwVmtIbGRkS25RMVpBRlo0bk5DUUEvRCtJbFJ4anJIU2grclk0TFVlOUE';
    }
    return Product(
      id: id,
      name: json['title'] ?? json['name'] ?? 'Unknown Product',
      categoryId: json['category'] ?? 'others',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: imageUrl,
      description: json['description'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 
          (json['rating'] is Map ? (json['rating']['rate'] as num?)?.toDouble() : 4.5) ?? 
          4.5,
      oldPrice: json['oldPrice'] != null ? (json['oldPrice'] as num).toDouble() : null,
      discountPercentage: json['discountPercentage'] as int?,
      timeLeft: json['timeLeft'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Converts product to a map for saving to Cloud Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'oldPrice': oldPrice,
      'discountPercentage': discountPercentage,
      'timeLeft': timeLeft,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
    };
  }

  /// Creates Product from a Cloud Firestore DocumentSnapshot
  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    String imageUrl = data['imageUrl'] ?? data['image'] ?? '';
    if (doc.id == 'm1' && imageUrl.contains('da61225697cc')) {
      imageUrl = 'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MGFQ4_AV2?wid=2000&hei=2000&fmt=jpeg&qlt=90&.v=WlBWbGdIeUx1NGF1d0FHRnE2VjFSaVRkTXNZOFJZTitTVFE0NHl0VW5Cb0YwVmtIbGRkS25RMVpBRlo0bk5DUUEvRCtJbFJ4anJIU2grclk0TFVlOUE';
    }
    return Product(
      id: doc.id,
      name: data['name'] ?? data['title'] ?? 'Unknown Product',
      categoryId: data['categoryId'] ?? data['category'] ?? 'others',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: data['oldPrice'] != null ? (data['oldPrice'] as num).toDouble() : null,
      discountPercentage: data['discountPercentage'] as int?,
      timeLeft: data['timeLeft'] as String?,
      imageUrl: imageUrl,
      description: data['description'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
    );
  }
}

