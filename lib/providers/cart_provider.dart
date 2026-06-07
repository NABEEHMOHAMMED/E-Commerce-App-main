import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../database/cart_database_helper.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toDbMap(String userId) {
    return {
      'id': product.id,
      'title': product.name,
      'price': product.price,
      'image': product.imageUrl,
      'quantity': quantity,
      'userId': userId,
    };
  }

  factory CartItem.fromDbMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product(
        id: map['id'],
        name: map['title'],
        categoryId: 'others',
        price: map['price'],
        imageUrl: map['image'],
      ),
      quantity: map['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal {
    return _items.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  double get totalPrice => subtotal;

  StreamSubscription<User?>? _authSubscription;
  String _currentUserId = 'guest';

  CartProvider() {
    // Check initial user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
    }
    _loadFromDb();

    // Listen to Authentication changes to isolate cart
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        if (_currentUserId != user.uid) {
           _currentUserId = user.uid;
           _loadFromDb();
        }
      } else {
        if (_currentUserId != 'guest') {
          _currentUserId = 'guest';
          _loadFromDb();
        }
      }
    });
  }

  Future<void> addToCart(Product product) async {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
      notifyListeners();
      await CartDatabaseHelper.instance.update(_items[existingIndex].toDbMap(_currentUserId));
    } else {
      final newItem = CartItem(product: product);
      _items.add(newItem);
      notifyListeners();
      await CartDatabaseHelper.instance.insert(newItem.toDbMap(_currentUserId));
    }
  }

  Future<void> increaseQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
      await CartDatabaseHelper.instance.update(_items[index].toDbMap(_currentUserId));
    }
  }

  Future<void> decreaseQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        notifyListeners();
        await CartDatabaseHelper.instance.update(_items[index].toDbMap(_currentUserId));
      } else {
        _items.removeAt(index);
        notifyListeners();
        await CartDatabaseHelper.instance.delete(productId, _currentUserId);
      }
    }
  }

  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    await CartDatabaseHelper.instance.delete(productId, _currentUserId);
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await CartDatabaseHelper.instance.deleteAll(_currentUserId);
  }

  Future<void> _loadFromDb() async {
    try {
      final data = await CartDatabaseHelper.instance.query('cart_items', _currentUserId);
      _items = data.map((item) => CartItem.fromDbMap(item)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart from db: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
