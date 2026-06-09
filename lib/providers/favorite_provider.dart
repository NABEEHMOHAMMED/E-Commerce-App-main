import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Product> _favorites = [];
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;
  StreamSubscription<User?>? _authSubscription;

  List<Product> get favorites => _favorites;

  FavoriteProvider() {
    // ─── Listen to User Authentication Status ───────────────────────
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // User logged in: Subscribe to their Firestore favorites subcollection
        _subscribeToFavorites(user.uid);
      } else {
        // User logged out: Cancel subscription and clear list
        _unsubscribeFromFavorites();
      }
    });
  }

  /// Checks if a product is in the favorites list
  bool isFavorite(Product product) {
    return _favorites.any((item) => item.id == product.id);
  }

  /// Toggles favorite state (set/delete in Firestore)
  Future<void> toggleFavorite(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot toggle favorite: No authenticated user.');
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(product.id);

    try {
      if (isFavorite(product)) {
        // ─── Delete document from Firestore ─────────────────────────
        await docRef.delete();
        debugPrint('Removed product ${product.id} from Firestore Favorites.');
      } else {
        // ─── Add/Set document in Firestore ──────────────────────────
        // Set all properties via product.toMap()
        await docRef.set(product.toMap());
        debugPrint('Added product ${product.id} to Firestore Favorites.');
      }
    } catch (e) {
      debugPrint('Error toggling favorite in Firestore: $e');
    }
  }

  /// Removes a product from favorites by ID
  Future<void> removeFromFavorites(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(productId)
          .delete();
      debugPrint('Deleted $productId from Firestore Favorites.');
    } catch (e) {
      debugPrint('Error removing favorite from Firestore: $e');
    }
  }

  // ─── Firestore Subscriptions ────────────────────────────────────────

  /// Subscribe to user's real-time favorites stream
  void _subscribeToFavorites(String userId) {
    _unsubscribeFromFavorites(); // Cancel any existing stream first

    debugPrint('Subscribing to Firestore favorites stream for user: $userId');
    _favoritesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .listen(
          (snapshot) {
            _favorites = snapshot.docs.map((doc) {
              // Map each document back to a Product instance
              final product = Product.fromDoc(doc);
              product.isFavorite = true; // Mark as favorite
              return product;
            }).toList();

            notifyListeners();
            debugPrint(
              'Firestore Favorites updated dynamically. Count: ${_favorites.length}',
            );
          },
          onError: (error) {
            debugPrint('Error listening to favorites stream: $error');
          },
        );
  }

  /// Unsubscribe and clean up resources
  void _unsubscribeFromFavorites() {
    _favoritesSubscription?.cancel();
    _favoritesSubscription = null;
    _favorites = [];
    notifyListeners();
    debugPrint('Unsubscribed from favorites stream.');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}
