import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// Service class responsible for making HTTP requests to the FakeStore API.
/// Handles GET requests and JSON parsing.
class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  /// Fetches all products from the API.
  /// Sends an HTTP GET request to /products endpoint,
  /// then parses the JSON response into a `List<Product>`.
  ///
  /// Throws an [Exception] if the request fails.
  static Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('$_baseUrl/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load products (Status: ${response.statusCode})',
      );
    }
  }

  /// Fetches a single product by its ID.
  /// Sends an HTTP GET request to /products/{id} endpoint.
  ///
  /// Throws an [Exception] if the request fails.
  static Future<Product> fetchProductById(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return Product.fromJson(jsonData);
    } else {
      throw Exception(
        'Failed to load product $id (Status: ${response.statusCode})',
      );
    }
  }

  /// Fetches all available categories from the API.
  /// Returns a list of category name strings.
  static Future<List<String>> fetchCategories() async {
    final url = Uri.parse('$_baseUrl/products/categories');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.cast<String>();
    } else {
      throw Exception(
        'Failed to load categories (Status: ${response.statusCode})',
      );
    }
  }

  /// Fetches products filtered by category.
  /// Sends an HTTP GET request to /products/category/{categoryName} endpoint.
  static Future<List<Product>> fetchProductsByCategory(String category) async {
    final url = Uri.parse('$_baseUrl/products/category/$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products for category: $category');
    }
  }
}
