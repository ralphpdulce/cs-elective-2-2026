import 'package:flutter_test/flutter_test.dart';
import 'package:backend_filter_pagination/models/product.dart';
import 'package:backend_filter_pagination/services/supabase_service.dart';
import 'package:backend_filter_pagination/state/product_provider.dart';
import 'package:flutter/material.dart';

void main() {
  group('ProductProvider Filter & Pagination Tests', () {
    late SupabaseService service;
    late ProductProvider provider;

    setUp(() async {
      service = SupabaseService();
      provider = ProductProvider(service: service);
      await provider.initialize();
    });

    test('Initial state loads first page with max 6 products', () {
      expect(provider.pageSize, equals(6));
      expect(provider.currentPage, equals(1));
      expect(provider.products.length, lessThanOrEqualTo(6));
      expect(provider.totalCount, greaterThan(6));
      expect(provider.totalPages, greaterThan(1));
      expect(provider.hasPreviousPage, isFalse);
      expect(provider.hasNextPage, isTrue);
    });

    test('Page navigation works as expected', () async {
      final firstPageProduct = provider.products.first;
      await provider.nextPage();
      expect(provider.currentPage, equals(2));
      expect(provider.hasPreviousPage, isTrue);
      expect(provider.products.first.id, isNot(equals(firstPageProduct.id)));

      await provider.previousPage();
      expect(provider.currentPage, equals(1));
      expect(provider.products.first.id, equals(firstPageProduct.id));
    });

    test('Switching page size between 6 and 8 updates total pages', () async {
      await provider.setPageSize(8);
      expect(provider.pageSize, equals(8));
      expect(provider.products.length, lessThanOrEqualTo(8));

      await provider.setPageSize(6);
      expect(provider.pageSize, equals(6));
      expect(provider.products.length, lessThanOrEqualTo(6));
    });

    test('Price slider filter filters products correctly', () async {
      // Set a restrictive price range: $50 to $200
      provider.updatePriceRange(const RangeValues(50.0, 200.0));
      // Wait for debounce timer to fire
      await Future.delayed(const Duration(milliseconds: 400));

      for (final p in provider.products) {
        expect(p.price, greaterThanOrEqualTo(50.0));
        expect(p.price, lessThanOrEqualTo(200.0));
      }
    });

    test('Category filter filters products by category', () async {
      await provider.setCategory('Weapons');
      expect(provider.products, isNotEmpty);
      for (final p in provider.products) {
        expect(p.category, equals('Weapons'));
      }
    });

    test('CRUD: Add, Update, and Delete product', () async {
      final initialCount = provider.totalCount;

      // 1. Create
      const newProduct = Product(
        id: 'test-item-999',
        name: 'Prototype Starglitter',
        price: 349.99,
        category: 'Weapons',
        rating: 4.6,
        description: 'A polearm forged in the Blackcliff Forge.',
      );
      await provider.addProduct(newProduct);
      expect(provider.totalCount, equals(initialCount + 1));

      // 2. Update
      final updatedProduct = newProduct.copyWith(name: 'Refined Starglitter');
      await provider.updateProduct(updatedProduct);

      // 3. Delete
      await provider.deleteProduct('test-item-999');
      expect(provider.totalCount, equals(initialCount));
    });
  });
}
