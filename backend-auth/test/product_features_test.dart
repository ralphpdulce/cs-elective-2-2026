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

    test('Initial state loads first page with max 10 products', () {
      expect(provider.pageSize, equals(10));
      expect(provider.currentPage, equals(1));
      expect(provider.products.length, lessThanOrEqualTo(10));
      expect(provider.totalCount, greaterThan(10));
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

    test('Switching page size between 6, 8, and 10 updates total pages', () async {
      await provider.setPageSize(6);
      expect(provider.pageSize, equals(6));
      expect(provider.products.length, lessThanOrEqualTo(6));

      await provider.setPageSize(8);
      expect(provider.pageSize, equals(8));
      expect(provider.products.length, lessThanOrEqualTo(8));

      await provider.setPageSize(10);
      expect(provider.pageSize, equals(10));
      expect(provider.products.length, lessThanOrEqualTo(10));
    });

    test('Price slider filter filters products correctly', () async {
      await provider.setPriceRange(const RangeValues(300.0, 400.0));

      expect(provider.products, isNotEmpty);
      for (final p in provider.products) {
        expect(p.price, greaterThanOrEqualTo(300.0));
        expect(p.price, lessThanOrEqualTo(400.0));
      }
    });

    test('Category filter filters by Weapons, Materials, and Visions', () async {
      await provider.setCategory('Weapons');
      expect(provider.products, isNotEmpty);
      for (final p in provider.products) {
        expect(p.category, equals('Weapons'));
      }

      await provider.setCategory('Materials');
      expect(provider.products, isNotEmpty);
      for (final p in provider.products) {
        expect(p.category, equals('Materials'));
      }

      await provider.setCategory('Geo');
      expect(provider.products, isNotEmpty);
      for (final p in provider.products) {
        expect(p.category, equals('Geo'));
      }
    });

    test('CRUD: Add, Update, and Delete product', () async {
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
          'card': 'https://enka.network/ui/UI_AvatarIcon_Shougun_Card.png',
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
          'card': 'https://enka.network/ui/UI_AvatarIcon_Bennett_Card.png',
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
