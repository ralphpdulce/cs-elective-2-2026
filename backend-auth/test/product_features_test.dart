import 'package:flutter_test/flutter_test.dart';
import 'package:backend_auth/models/product.dart';
import 'package:backend_auth/services/genshin_api_service.dart';
import 'package:backend_auth/services/supabase_service.dart';
import 'package:backend_auth/state/product_provider.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductProvider Filter & Pagination Tests', () {
    late SupabaseService service;
    late ProductProvider provider;

    setUp(() async {
      service = SupabaseService();
      provider = ProductProvider(service: service);
      await provider.initialize(forceLocal: true);
    });

    test('Initial state loads first page with max 6 characters', () {
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
      // Set price range spanning 4-star characters: $300 to $400
      await provider.setPriceRange(const RangeValues(300.0, 400.0));

      expect(provider.products, isNotEmpty);
      for (final p in provider.products) {
        expect(p.price, greaterThanOrEqualTo(300.0));
        expect(p.price, lessThanOrEqualTo(400.0));
      }
    });

    test('Category filter filters characters by Vision', () async {
      await provider.setCategory('Pyro');
      expect(provider.products, isNotEmpty);
      for (final p in provider.products) {
        expect(p.category, equals('Pyro'));
      }

      await provider.setCategory('Geo');
      expect(provider.products, isNotEmpty);
      for (final p in provider.products) {
        expect(p.category, equals('Geo'));
      }
    });

    test('CRUD: Add, Update, and Delete character', () async {
      final initialCount = provider.totalCount;

      // 1. Create
      const newProduct = Product(
        id: 'test-char-999',
        name: 'Mavuika',
        price: 1499.99,
        category: 'Pyro',
        rating: 5.0,
        badge: '5★ ARCHON',
        description: 'The Pyro Archon of Natlan.',
      );
      await provider.addProduct(newProduct);
      expect(provider.totalCount, equals(initialCount + 1));

      // 2. Update
      final updatedProduct = newProduct.copyWith(name: 'Habakkuk Mavuika');
      await provider.updateProduct(updatedProduct);

      // 3. Delete
      await provider.deleteProduct('test-char-999');
      expect(provider.totalCount, equals(initialCount));
    });
  });

  group('GenshinApiService Tests', () {
    test('mapCharacterToProduct correctly maps raw API map into Product with calculated price', () {
      final rawMap = {
        'key': 'raiden',
        'name': 'Raiden Shogun',
        'title': 'Plane of Euthymia',
        'vision': 'Electro',
        'weapon': 'Polearm',
        'nation': 'Inazuma',
        'rarity': 5,
        'img': {
          'card': 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/raiden/card.png',
        },
      };

      final product = GenshinApiService.mapCharacterToProduct(rawMap);
      expect(product, isNotNull);
      expect(product!.id, equals('raiden'));
      expect(product.name, equals('Raiden Shogun'));
      expect(product.category, equals('Electro'));
      expect(product.badge, equals('5★ ARCHON'));
      expect(product.price, greaterThanOrEqualTo(899.99));
      expect(product.rating, greaterThanOrEqualTo(4.8));
      expect(product.imageUrl, contains('raiden/card.png'));
    });

    test('mapCharacterToProduct handles 4-star character pricing', () {
      final rawMap = {
        'key': 'bennett',
        'name': 'Bennett',
        'title': 'Trial by Fire',
        'vision': 'Pyro',
        'weapon': 'Sword',
        'nation': 'Mondstadt',
        'rarity': 4,
        'img': {
          'card': 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/bennett/card.png',
        },
      };

      final product = GenshinApiService.mapCharacterToProduct(rawMap);
      expect(product, isNotNull);
      expect(product!.badge, equals('4★ FEATURED'));
      expect(product.price, greaterThanOrEqualTo(249.99));
      expect(product.price, lessThanOrEqualTo(599.99));
      expect(product.category, equals('Pyro'));
    });
  });
}
