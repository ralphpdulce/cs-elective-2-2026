import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Set<String> _wishlistIds = {}; // Track saved wishlist item IDs

  List<CartItem> get items => List.unmodifiable(_items);
  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get grandTotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  // Wishlist methods
  bool isWishlisted(String productId) => _wishlistIds.contains(productId);

  void toggleWishlist(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  // Cart methods
  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int delta) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

final cartState = CartState();