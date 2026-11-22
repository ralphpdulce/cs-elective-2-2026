import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';
import 'product_provider.dart';
import 'supabase_provider.dart';

// =============================================================================
// CUSTOMER ORDERS PROVIDER
// =============================================================================

class CustomerOrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final SupabaseService _service;

  CustomerOrdersNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _service.getCustomerOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final customerOrdersProvider =
    StateNotifierProvider<CustomerOrdersNotifier, AsyncValue<List<Order>>>((ref) {
  ref.watch(authProvider);
  final service = ref.watch(supabaseServiceProvider);
  return CustomerOrdersNotifier(service);
});

// =============================================================================
// ADMIN ORDERS PROVIDER
// =============================================================================

class AdminOrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final SupabaseService _service;

  AdminOrdersNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _service.getAllOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(int orderId, String newStatus) async {
    try {
      await _service.updateOrderStatus(orderId, newStatus);
      await fetchAllOrders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final adminOrdersProvider =
    StateNotifierProvider<AdminOrdersNotifier, AsyncValue<List<Order>>>((ref) {
  ref.watch(authProvider);
  final service = ref.watch(supabaseServiceProvider);
  return AdminOrdersNotifier(service);
});

// =============================================================================
// CHECKOUT ACTION / CONTROLLER
// =============================================================================

class CheckoutState {
  final bool isProcessing;
  final String? errorMessage;
  final ({int orderId, double total, String status})? lastOrderResult;

  const CheckoutState({
    this.isProcessing = false,
    this.errorMessage,
    this.lastOrderResult,
  });
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;

  CheckoutNotifier(this._ref) : super(const CheckoutState());

  Future<({int orderId, double total, String status})> checkout() async {
    final cart = _ref.read(cartProvider);
    if (cart.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    state = const CheckoutState(isProcessing: true);
    final service = _ref.read(supabaseServiceProvider);

    try {
      final items = cart.items
          .map((i) => (productId: i.product.id, quantity: i.quantity))
          .toList();

      final result = await service.placeOrder(items);

      // 1. Clear cart
      _ref.read(cartProvider.notifier).clearCart();

      // 2. Reload products to reflect deducted stock
      await _ref.read(productProvider.notifier).loadProducts();

      // 3. Refresh customer order history
      await _ref.read(customerOrdersProvider.notifier).fetchOrders();

      state = CheckoutState(
        isProcessing: false,
        lastOrderResult: result,
      );

      return result;
    } catch (e) {
      state = CheckoutState(isProcessing: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
