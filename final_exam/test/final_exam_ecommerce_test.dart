import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_exam/models/product.dart';
import 'package:final_exam/models/profile.dart';
import 'package:final_exam/providers/auth_provider.dart';
import 'package:final_exam/providers/cart_provider.dart';
import 'package:final_exam/providers/order_provider.dart';
import 'package:final_exam/providers/product_provider.dart';
import 'package:final_exam/providers/supabase_provider.dart';
import 'package:final_exam/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SupabaseService mockService;

  setUp(() async {
    mockService = SupabaseService(forceLocal: true);
    mockService.resetLocalState(
      mockProfile: const Profile(
        id: 'test-customer-1',
        email: 'traveler@gmail.com',
        firstname: 'Lumine',
        lastname: 'Traveler',
        roleId: 1,
        roleName: 'customer',
      ),
    );

    container = ProviderContainer(
      overrides: [
        supabaseServiceProvider.overrideWithValue(mockService),
      ],
    );

    // Initialize products in container
    await container.read(productProvider.notifier).initialize(forceLocal: true);
  });

  tearDown(() {
    container.dispose();
  });

  group('Riverpod Auth & Role Separation Tests', () {
    test('Customer role is identified correctly', () {
      container.read(authProvider.notifier).setDemoCustomer();
      final updated = container.read(authProvider);

      expect(updated.isAuthenticated, isTrue);
      expect(updated.isCustomer, isTrue);
      expect(updated.isAdmin, isFalse);
      expect(updated.displayName, equals('Lumine Traveler'));
    });

    test('Admin role is identified correctly', () {
      container.read(authProvider.notifier).setDemoAdmin();
      final updated = container.read(authProvider);

      expect(updated.isAuthenticated, isTrue);
      expect(updated.isAdmin, isTrue);
      expect(updated.isCustomer, isFalse);
      expect(updated.displayName, contains('Jean Gunnhildr'));
    });

    test('Sign out clears user session and role', () async {
      container.read(authProvider.notifier).setDemoCustomer();
      expect(container.read(authProvider).isAuthenticated, isTrue);

      await container.read(authProvider.notifier).signOut();
      expect(container.read(authProvider).isAuthenticated, isFalse);
      expect(container.read(authProvider).profile, isNull);
    });
  });

  group('Riverpod Product Filtering, Pagination & Admin CRUD Tests', () {
    test('Initial catalog pagination loads max 10 products', () {
      final state = container.read(productProvider);
      expect(state.pageSize, equals(10));
      expect(state.currentPage, equals(1));
      expect(state.products.length, lessThanOrEqualTo(10));
      expect(state.totalCount, greaterThan(10));
      expect(state.totalPages, greaterThan(1));
      expect(state.hasPreviousPage, isFalse);
      expect(state.hasNextPage, isTrue);
    });

    test('Pagination navigation operates cleanly', () async {
      final firstProduct = container.read(productProvider).products.first;
      await container.read(productProvider.notifier).nextPage();

      final page2State = container.read(productProvider);
      expect(page2State.currentPage, equals(2));
      expect(page2State.hasPreviousPage, isTrue);
      expect(page2State.products.first.id, isNot(equals(firstProduct.id)));

      await container.read(productProvider.notifier).previousPage();
      expect(container.read(productProvider).currentPage, equals(1));
    });

    test('Price filter filters items within range', () async {
      await container.read(productProvider.notifier).setPriceRange(const RangeValues(300.0, 400.0));
      final products = container.read(productProvider).products;

      expect(products, isNotEmpty);
      for (final p in products) {
        expect(p.price, greaterThanOrEqualTo(300.0));
        expect(p.price, lessThanOrEqualTo(400.0));
      }
    });

    test('Category filter filters by category name', () async {
      container.read(productProvider.notifier).setCategory('Weapons');
      await container.read(productProvider.notifier).loadProducts(resetPage: true);

      final products = container.read(productProvider).products;
      expect(products, isNotEmpty);
      for (final p in products) {
        expect(p.categoryName, equals('Weapons'));
      }
    });

    test('Admin CRUD: create, update, delete product', () async {
      final initialCount = container.read(productProvider).totalCount;

      // 1. Create product
      const newProduct = Product(
        id: 0,
        name: 'Mavuika',
        price: 1499.99,
        stock: 35,
        categoryId: 4,
        categoryName: 'Pyro',
        description: 'The Pyro Archon of Natlan.',
      );
      await container.read(productProvider.notifier).addProduct(newProduct);
      expect(container.read(productProvider).totalCount, equals(initialCount + 1));

      // 2. Update product
      container.read(productProvider.notifier).setSearchQuery('Mavuika');
      await container.read(productProvider.notifier).loadProducts(resetPage: true);

      final created = container.read(productProvider).products.firstWhere((p) => p.name == 'Mavuika');
      final updated = created.copyWith(name: 'Habakkuk Mavuika', stock: 50);
      await container.read(productProvider.notifier).updateProduct(updated);

      container.read(productProvider.notifier).setSearchQuery('Habakkuk');
      await container.read(productProvider.notifier).loadProducts(resetPage: true);

      final found = container.read(productProvider).products.firstWhere((p) => p.id == created.id);
      expect(found.name, equals('Habakkuk Mavuika'));
      expect(found.stock, equals(50));

      // 3. Delete product
      await container.read(productProvider.notifier).deleteProduct(created.id);
      await container.read(productProvider.notifier).resetFilters();
      expect(container.read(productProvider).totalCount, equals(initialCount));
    });
  });

  group('Riverpod Cart & Stock Validation Tests', () {
    test('Adding product to cart updates quantity, total item count, and running total', () {
      final cartNotifier = container.read(cartProvider.notifier);
      final product = container.read(productProvider).products.first;

      cartNotifier.addToCart(product, quantity: 2);
      final state = container.read(cartProvider);

      expect(state.items.length, equals(1));
      expect(state.totalItemCount, equals(2));
      expect(state.grandTotal, equals(product.price * 2));
    });

    test('Cannot add out-of-stock product to cart', () {
      final cartNotifier = container.read(cartProvider.notifier);
      const outOfStockProduct = Product(
        id: 9999,
        name: 'Sold Out Item',
        price: 99.99,
        stock: 0,
      );

      expect(
        () => cartNotifier.addToCart(outOfStockProduct),
        throwsA(isA<Exception>()),
      );
    });

    test('Cannot add quantity exceeding available stock', () {
      final cartNotifier = container.read(cartProvider.notifier);
      const lowStockProduct = Product(
        id: 8888,
        name: 'Rare Item',
        price: 49.99,
        stock: 3,
      );

      cartNotifier.addToCart(lowStockProduct, quantity: 2);

      // Attempting to add 2 more exceeds stock of 3
      expect(
        () => cartNotifier.addToCart(lowStockProduct, quantity: 2),
        throwsA(isA<Exception>()),
      );
    });

    test('Updating quantity and removing item from cart', () {
      final cartNotifier = container.read(cartProvider.notifier);
      final product = container.read(productProvider).products.first;

      cartNotifier.addToCart(product, quantity: 1);
      expect(container.read(cartProvider).totalItemCount, equals(1));

      cartNotifier.updateQuantity(product.id, 1);
      expect(container.read(cartProvider).totalItemCount, equals(2));

      cartNotifier.updateQuantity(product.id, -2);
      expect(container.read(cartProvider).items, isEmpty);
    });

    test('Logging out empties the cart automatically', () async {
      container.read(authProvider.notifier).setDemoCustomer();
      final product = container.read(productProvider).products.first;
      container.read(cartProvider.notifier).addToCart(product, quantity: 1);
      expect(container.read(cartProvider).items, isNotEmpty);

      await container.read(authProvider.notifier).signOut();
      expect(container.read(cartProvider).items, isEmpty);
    });
  });

  group('Riverpod Atomic Checkout & Orders Integrity Tests', () {
    test('Placing an order checks stock, deducts stock, empties cart, and saves snapshot', () async {
      container.read(authProvider.notifier).setDemoCustomer();
      final product = container.read(productProvider).products.first;
      final initialStock = product.stock;

      container.read(cartProvider.notifier).addToCart(product, quantity: 2);
      expect(container.read(cartProvider).totalItemCount, equals(2));

      final checkoutNotifier = container.read(checkoutProvider.notifier);
      final result = await checkoutNotifier.checkout();

      expect(result.orderId, greaterThan(0));
      expect(result.status, equals('done'));
      expect(result.total, equals(product.price * 2));

      // 1. Cart is emptied after successful order
      expect(container.read(cartProvider).items, isEmpty);

      // 2. Stock is reduced in database / state
      final updatedProduct = container.read(productProvider).products.firstWhere((p) => p.id == product.id);
      expect(updatedProduct.stock, equals(initialStock - 2));

      // 3. Customer order history includes new order with product snapshot
      await container.read(customerOrdersProvider.notifier).fetchOrders();
      final customerOrders = container.read(customerOrdersProvider).value!;
      expect(customerOrders, isNotEmpty);
      expect(customerOrders.first.id, equals(result.orderId));
      expect(customerOrders.first.items.first.productName, equals(product.name));
      expect(customerOrders.first.items.first.unitPrice, equals(product.price));

      // 4. Admin order list displays order and allows status update
      await container.read(adminOrdersProvider.notifier).fetchAllOrders();
      final adminOrders = container.read(adminOrdersProvider).value!;
      expect(adminOrders, isNotEmpty);
      expect(adminOrders.first.id, equals(result.orderId));

      await container.read(adminOrdersProvider.notifier).updateStatus(result.orderId, 'completed');
      final updatedAdminOrders = container.read(adminOrdersProvider).value!;
      expect(updatedAdminOrders.first.status, equals('completed'));
    });
  });
}
