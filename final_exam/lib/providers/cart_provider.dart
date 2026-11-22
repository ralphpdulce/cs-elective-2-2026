import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'auth_provider.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get grandTotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int quantityFor(int productId) {
    final match = items.where((i) => i.product.id == productId).firstOrNull;
    return match?.quantity ?? 0;
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Add a product to cart with strict stock validation
  void addToCart(Product product, {int quantity = 1}) {
    if (product.stock <= 0) {
      throw Exception('"${product.name}" is out of stock.');
    }

    final index = state.items.indexWhere((i) => i.product.id == product.id);
    final currentQty = (index >= 0) ? state.items[index].quantity : 0;
    final targetQty = currentQty + quantity;

    if (targetQty > product.stock) {
      throw Exception('Cannot add more than available stock (${product.stock}) for "${product.name}".');
    }

    final updated = List<CartItem>.from(state.items);
    if (index >= 0) {
      updated[index] = updated[index].copyWith(quantity: targetQty);
    } else {
      updated.add(CartItem(product: product, quantity: quantity));
    }

    state = CartState(items: updated);
  }

  /// Update item quantity by delta (+1 or -1) with stock boundary checks
  void updateQuantity(int productId, int delta) {
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;

    final item = state.items[index];
    final newQty = item.quantity + delta;

    final updated = List<CartItem>.from(state.items);
    if (newQty <= 0) {
      updated.removeAt(index);
    } else {
      if (newQty > item.product.stock) {
        throw Exception('Cannot exceed available stock of ${item.product.stock}.');
      }
      updated[index] = item.copyWith(quantity: newQty);
    }

    state = CartState(items: updated);
  }

  /// Remove item entirely from cart
  void removeItem(int productId) {
    final updated = state.items.where((i) => i.product.id != productId).toList();
    state = CartState(items: updated);
  }

  /// Clear cart (called after successful order & on logout)
  void clearCart() {
    state = const CartState(items: []);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final notifier = CartNotifier();

  // Empty cart automatically on logout
  ref.listen<AuthState>(authProvider, (previous, current) {
    if (previous?.isAuthenticated == true && !current.isAuthenticated) {
      notifier.clearCart();
    }
  });

  return notifier;
});
