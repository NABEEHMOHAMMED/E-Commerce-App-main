import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/web_storage.dart';

class ProductProvider extends ChangeNotifier {
  // ─── Loading & Error State ──────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ─── Connection Status ──────────────────────────────────────────────
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // ─── Products List (fetched from Firestore in real-time) ────────────
  List<Product> _allProducts = [];
  List<Product> get allProducts => _allProducts;

  // ─── Categories ─────────────────────────────────────────────────────
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  // ─── Firestore subscription ─────────────────────────────────────────
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  // ─── Category icon mapping ─────────────────────────────────────────
  static const Map<String, String> _categoryIcons = {
    'electronics': '🔌',
    "men's clothing": '👕',
    "women's clothing": '👗',
    'jewelery': '💍',
    'smartphones': '📱',
    'watches': '⌚',
    'shoes': '👟',
    'furniture': '🪑',
    'beauty': '💄',
    'toys': '🧸',
    'sports': '⚽',
    'groceries': '🛒',
    'accessories': '🕶️',
    'gaming': '🎮',
  };

  // ─── Constructor ─────────────────────────────────────────────────────
  ProductProvider() {
    Future.microtask(() => _initializeData());
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    // Don't notify yet to avoid empty screen flicker

    try {
      // 1. Load disk cache immediately as fallback so screen isn't empty
      await _loadFromDisk();
      _addMockProductsNoNotify();
      _buildCategoriesFromProducts();
      notifyListeners();

      // 2. Determine connection status
      await _initConnectivity();

      // 3. Connect real-time stream listener to Cloud Firestore
      _initFirestoreStream();
    } catch (e) {
      debugPrint('Error in ProductProvider init: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Initialize Cloud Firestore Real-Time Listener ───────────────────
  void _initFirestoreStream() {
    _firestoreSubscription?.cancel();

    _firestoreSubscription = FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isNotEmpty) {
              _allProducts = snapshot.docs
                  .map((doc) => Product.fromDoc(doc))
                  .toList();
              _buildCategoriesFromProducts();
              _isLoading = false;
              _errorMessage = null;
              notifyListeners();

              // Backup to local disk cache for instant startup next time
              _saveToDisk();

              // Automatically correct/update the m1 image URL directly in Firebase Firestore if it still has the old URL
              try {
                final m1Doc = snapshot.docs.firstWhere((doc) => doc.id == 'm1');
                final m1Data = m1Doc.data() as Map<String, dynamic>? ?? {};
                final currentUrl = m1Data['imageUrl'] as String? ?? '';
                if (currentUrl.contains('da61225697cc')) {
                  FirebaseFirestore.instance.collection('products').doc('m1').update({
                    'imageUrl': 'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MGFQ4_AV2?wid=2000&hei=2000&fmt=jpeg&qlt=90&.v=WlBWbGdIeUx1NGF1d0FHRnE2VjFSaVRkTXNZOFJZTitTVFE0NHl0VW5Cb0YwVmtIbGRkS25RMVpBRlo0bk5DUUEvRCtJbFJ4anJIU2grclk0TFVlOUE'
                  }).then((_) {
                    debugPrint('Automatically corrected m1 image URL in Firebase Firestore!');
                  });
                }
              } catch (_) {}
            } else {
              // If Firestore starts out empty, seed it automatically with mock products!
              _seedMockProductsToFirestore();
            }
          },
          onError: (error) {
            debugPrint('Firestore Listener Error: $error');
            // If Firestore connection fails, we retain local cached data and notify user
            _errorMessage = 'Cloud database offline. Showing offline cache.';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // ─── Auto-seed Mock Products to Cloud Firestore ──────────────────────
  Future<void> _seedMockProductsToFirestore() async {
    debugPrint(
      ' Firestore products collection is empty. Auto-seeding mock products...',
    );
    final collection = FirebaseFirestore.instance.collection('products');

    try {
      final mockData = _getMockProductsList();
      for (var product in mockData) {
        await collection.doc(product.id).set(product.toMap());
      }
      debugPrint(' Mock products seeded successfully to Firestore!');
    } catch (e) {
      debugPrint('Error seeding mock products: $e');
    }
  }

  // ─── Add Mock Products (Local fallback when offline & cache empty) ───
  void _addMockProductsNoNotify() {
    final mockData = _getMockProductsList();
    for (var product in mockData) {
      if (!_allProducts.any((p) => p.id == product.id)) {
        _allProducts.add(product);
      }
    }
  }

  // ─── Initialize Connectivity Listener ───────────────────────────────
  Future<void> _initConnectivity() async {
    try {
      final dynamic result = await Connectivity().checkConnectivity();
      List<ConnectivityResult> results = [];
      if (result is List) {
        results = result.map((e) => e as ConnectivityResult).toList();
      } else if (result is ConnectivityResult) {
        results = [result];
      }
      _isConnected = !results.contains(ConnectivityResult.none);
    } catch (e) {
      _isConnected = true; // Assume connected if check fails
    }
  }

  // ─── Pull-to-refresh: Sync External API products into Firestore ──────
  Future<void> fetchProducts({bool showOfflineMessage = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _initConnectivity();

      if (_isConnected) {
        final collection = FirebaseFirestore.instance.collection('products');

        // 1. Sync all mock products (m1 to m10) to Firestore to ensure full upload
        final mockData = _getMockProductsList();
        for (var product in mockData) {
          await collection.doc(product.id).set(product.toMap());
        }

        // 2. Online: Fetch latest products from API and save them to Cloud Firestore
        final fetchedProducts = await ApiService.fetchProducts();
        if (fetchedProducts.isNotEmpty) {
          for (var product in fetchedProducts) {
            await collection.doc(product.id).set(product.toMap());
          }
        }
        debugPrint(
          'Successfully synced both Mock and API products to Cloud Firestore!',
        );
      } else {
        if (showOfflineMessage) {
          _errorMessage = 'Offline mode: Showing cached data';
        }
      }
    } catch (e) {
      debugPrint(' Error refreshing Cloud Database: $e');
      if (showOfflineMessage) {
        _errorMessage = 'Could not sync with Cloud. Showing cached data.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Save Products to Local File (Caching) ───────────────────────────
  Future<void> _saveToDisk() async {
    try {
      if (kIsWeb) {
        final String jsonString = json.encode(
          _allProducts.map((p) => p.toJson()).toList(),
        );
        saveToWebStorage('products_cache', jsonString);
        debugPrint('Products cached successfully to localStorage');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/products_cache.json');

        final String jsonString = json.encode(
          _allProducts.map((p) => p.toJson()).toList(),
        );

        await file.writeAsString(jsonString);
        debugPrint('Products cached successfully to: ${file.path}');
      }
    } catch (e) {
      debugPrint('Error caching products: $e');
    }
  }

  // ─── Load Products from Local File (Offline Fallback) ─────────────────
  Future<void> _loadFromDisk() async {
    try {
      if (kIsWeb) {
        final String? jsonString = loadFromWebStorage('products_cache');
        if (jsonString != null) {
          final List<dynamic> jsonList = json.decode(jsonString);

          _allProducts = jsonList
              .map((item) => Product.fromJson(item))
              .toList();
          debugPrint(
            'Products loaded from cache. Count: ${_allProducts.length}',
          );
        } else {
          debugPrint('No cached data available in localStorage.');
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/products_cache.json');

        if (await file.exists()) {
          final String jsonString = await file.readAsString();
          final List<dynamic> jsonList = json.decode(jsonString);

          _allProducts = jsonList
              .map((item) => Product.fromJson(item))
              .toList();
          debugPrint(
            'Products loaded from cache. Count: ${_allProducts.length}',
          );
        }
      }

      // Always ensure default mock products are loaded if list empty
      _addMockProductsNoNotify();
      _buildCategoriesFromProducts();
    } catch (e) {
      debugPrint('Error loading products from cache: $e');
      _addMockProductsNoNotify();
      _buildCategoriesFromProducts();
    }
  }

  // ─── Build Categories Dynamically ────────────────────────────────────
  void _buildCategoriesFromProducts() {
    final Map<String, int> categoryCounts = {};
    for (final product in _allProducts) {
      categoryCounts[product.categoryId] =
          (categoryCounts[product.categoryId] ?? 0) + 1;
    }

    _categories = categoryCounts.entries.map((entry) {
      return Category(
        id: entry.key,
        name: _formatCategoryName(entry.key),
        icon: _categoryIcons[entry.key] ?? '📦',
        imageUrl: '',
        productCount: entry.value,
      );
    }).toList();

    // Add extra default categories for a complete looking catalog
    final extraCategories = [
      'smartphones',
      'watches',
      'shoes',
      'furniture',
      'beauty',
      'toys',
      'sports',
      'groceries',
      'accessories',
      'gaming',
    ];
    for (var catId in extraCategories) {
      if (!_categories.any((c) => c.id == catId)) {
        _categories.add(
          Category(
            id: catId,
            name: _formatCategoryName(catId),
            icon: _categoryIcons[catId] ?? '📦',
            imageUrl: '',
            productCount: 0,
          ),
        );
      }
    }
  }

  /// Formats raw category ID into a display-friendly name.
  String _formatCategoryName(String categoryId) {
    return categoryId
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  // ─── Helper Methods ──────────────────────────────────────────────────
  List<Product> getProductsByCategory(String categoryId) {
    return _allProducts
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  void toggleFavorite(Product product) {
    product.isFavorite = !product.isFavorite;
    notifyListeners();
  }

  // ─── Static Mock Products Data List ──────────────────────────────────
  List<Product> _getMockProductsList() {
    return [
      Product(
        id: 'm1',
        name: 'iPhone 17 Pro Max',
        categoryId: 'smartphones',
        price: 1199.99,
        oldPrice: 1299.99,
        discountPercentage: 8,
        imageUrl:
            'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MGFQ4_AV2?wid=2000&hei=2000&fmt=jpeg&qlt=90&.v=WlBWbGdIeUx1NGF1d0FHRnE2VjFSaVRkTXNZOFJZTitTVFE0NHl0VW5Cb0YwVmtIbGRkS25RMVpBRlo0bk5DUUEvRCtJbFJ4anJIU2grclk0TFVlOUE',
        description: 'Latest Apple iPhone with Titanium design.',
        rating: 4.9,
      ),
      Product(
        id: 'm2',
        name: 'Samsung Galaxy S24 Ultra',
        categoryId: 'smartphones',
        price: 1099.99,
        imageUrl:
            'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=500',
        description: 'Advanced AI smartphone with S-Pen.',
        rating: 4.8,
      ),
      Product(
        id: 'm3',
        name: 'Rolex Submariner',
        categoryId: 'watches',
        price: 8500.00,
        imageUrl:
            'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=500',
        description: 'Classic luxury diver watch.',
        rating: 5.0,
      ),
      Product(
        id: 'm4',
        name: 'Apple Watch Ultra 2',
        categoryId: 'watches',
        price: 799.00,
        imageUrl:
            'https://images.unsplash.com/photo-1434494878577-86c23bcb06b9?w=500',
        description: 'The most rugged and capable Apple Watch.',
        rating: 4.7,
      ),
      Product(
        id: 'm5',
        name: 'Air Jordan 1 Retro',
        categoryId: 'shoes',
        price: 180.00,
        oldPrice: 220.00,
        discountPercentage: 18,
        imageUrl:
            'https://images.unsplash.com/photo-1584735175315-9d5df23860e6?w=500',
        description: 'Iconic basketball sneakers.',
        rating: 4.9,
      ),
      Product(
        id: 'm6',
        name: 'Nike Air Max 270',
        categoryId: 'shoes',
        price: 150.00,
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
        description: 'Comfortable lifestyle sneakers.',
        rating: 4.6,
      ),
      Product(
        id: 'm7',
        name: 'Modern Velvet Sofa',
        categoryId: 'furniture',
        price: 899.00,
        imageUrl:
            'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500',
        description: 'Luxury velvet sofa for your living room.',
        rating: 4.5,
      ),
      Product(
        id: 'm8',
        name: 'Ergonomic Office Chair',
        categoryId: 'furniture',
        price: 299.00,
        imageUrl:
            'https://images.unsplash.com/photo-1505797149-43b0069ec26b?w=500',
        description: 'Work in comfort with this ergonomic chair.',
        rating: 4.7,
      ),
      Product(
        id: 'm9',
        name: 'Sony PlayStation 5',
        categoryId: 'gaming',
        price: 499.00,
        imageUrl:
            'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=500',
        description: 'Next-gen gaming console.',
        rating: 4.9,
      ),
      Product(
        id: 'm10',
        name: 'Gaming Mechanical Keyboard',
        categoryId: 'gaming',
        price: 120.00,
        imageUrl:
            'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=500',
        description: 'RGB Backlit mechanical keyboard.',
        rating: 4.5,
      ),
    ];
  }
}
