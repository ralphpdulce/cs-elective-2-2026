import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/product.dart';
import 'genshin_api_service.dart';

class SupabaseService {
  final GenshinApiService _apiService;
  SupabaseClient? _client;
  bool _isInitialized = false;

  // In-memory fallback dataset initialized with rich Genshin character catalog
  final List<Product> _localProducts = List.from(sampleProducts);

  SupabaseService({GenshinApiService? apiService})
      : _apiService = apiService ?? GenshinApiService();

  bool get isConnected => _isInitialized && SupabaseConfig.isConfigured;

  /// Initialize Supabase if credentials are provided
  Future<void> initialize({bool forceLocal = false}) async {
    if (forceLocal || !SupabaseConfig.isConfigured) {
      debugPrint('[SupabaseService] Using in-memory fallback.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('[SupabaseService] Successfully connected to Supabase.');

      // Check if table has products; if empty or very few, sync characters
      await _autoSeedIfEmpty();
    } catch (e) {
      debugPrint('[SupabaseService] Initialization failed: $e. Using local fallback.');
      _isInitialized = false;
    }
  }

  /// Auto-seed characters to Supabase if products table is currently empty
  Future<void> _autoSeedIfEmpty() async {
    if (!isConnected || _client == null) return;
    try {
      final res = await _client!.from('products').select('id').limit(5);
      if (res.isEmpty) {
        debugPrint('[SupabaseService] Remote products table empty. Auto-seeding characters...');
        await syncCharactersFromApi(force: true);
      }
    } catch (e) {
      debugPrint('[SupabaseService] Auto-seed check notice: $e');
    }
  }

  /// Syncs characters fetched from the Genshin Impact API into Supabase (and local cache).
  Future<int> syncCharactersFromApi({bool force = false}) async {
    debugPrint('[SupabaseService] Fetching characters from Genshin Impact API...');
    final characters = await _apiService.fetchCharacters(fallbackProducts: sampleProducts);

    if (characters.isNotEmpty) {
      _localProducts.clear();
      _localProducts.addAll(characters);

      if (isConnected && _client != null) {
        try {
          debugPrint('[SupabaseService] Upserting ${characters.length} characters into Supabase products table...');
          // Upsert in batches of 25 to respect payload sizes
          for (int i = 0; i < characters.length; i += 25) {
            final int end = (i + 25 < characters.length) ? i + 25 : characters.length;
            final batch = characters.sublist(i, end).map((p) => p.toMap()).toList();
            await _client!.from('products').upsert(batch);
          }
          debugPrint('[SupabaseService] Successfully synced ${characters.length} characters into Supabase!');
        } catch (e) {
          debugPrint('[SupabaseService] Remote Supabase upsert error: $e');
        }
      }
    }

    return _localProducts.length;
  }

  /// Fetch products with price range filtering and pagination via Supabase query
  Future<({List<Product> products, int totalCount})> getProducts({
    double? minPrice,
    double? maxPrice,
    String? category,
    String? searchQuery,
    int page = 1,
    int pageSize = 6,
  }) async {
    if (isConnected && _client != null) {
      try {
        var query = _client!.from('products').select();

        // 1. Price Filtering via Supabase gte/lte
        if (minPrice != null) {
          query = query.gte('price', minPrice);
        }
        if (maxPrice != null) {
          query = query.lte('price', maxPrice);
        }

        // 2. Category (Vision) filter
        if (category != null && category != 'All') {
          query = query.eq('category', category);
        }

        // 3. Search query filter
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          query = query.ilike('name', '%${searchQuery.trim()}%');
        }

        // 4. Supabase Pagination range: zero-indexed [from, to]
        final int from = (page - 1) * pageSize;
        final int to = from + pageSize - 1;

        final response = await query
            .order('price', ascending: true)
            .range(from, to)
            .count(CountOption.exact);

        final List data = response.data as List;
        final products = data
            .map((item) => Product.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        final count = response.count;

        return (products: products, totalCount: count);
      } catch (e) {
        debugPrint('[SupabaseService] Query failed ($e), falling back to local simulation.');
      }
    }

    // --- Fallback in-memory query simulation ---
    Iterable<Product> filtered = _localProducts;

    if (minPrice != null) {
      filtered = filtered.where((p) => p.price >= minPrice);
    }
    if (maxPrice != null) {
      filtered = filtered.where((p) => p.price <= maxPrice);
    }
    if (category != null && category != 'All') {
      filtered = filtered.where((p) => p.category == category);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((p) => p.name.toLowerCase().contains(q));
    }

    final sorted = filtered.toList()..sort((a, b) => a.price.compareTo(b.price));
    final totalCount = sorted.length;

    final int from = (page - 1) * pageSize;
    if (from >= totalCount) {
      return (products: <Product>[], totalCount: totalCount);
    }
    final int to = (from + pageSize).clamp(0, totalCount);
    final paginated = sorted.sublist(from, to);

    return (products: paginated, totalCount: totalCount);
  }

  /// Create a new product (Insert)
  Future<void> createProduct(Product product) async {
    if (isConnected && _client != null) {
      try {
        await _client!.from('products').insert(product.toMap());
        return;
      } catch (e) {
        debugPrint('[SupabaseService] Insert error: $e');
      }
    }
    _localProducts.insert(0, product);
  }

  /// Update an existing product (Update)
  Future<void> updateProduct(Product product) async {
    if (isConnected && _client != null) {
      try {
        await _client!
            .from('products')
            .update(product.toMap())
            .eq('id', product.id);
        return;
      } catch (e) {
        debugPrint('[SupabaseService] Update error: $e');
      }
    }
    final index = _localProducts.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _localProducts[index] = product;
    }
  }

  /// Delete a product (Delete)
  Future<void> deleteProduct(String id) async {
    if (isConnected && _client != null) {
      try {
        await _client!.from('products').delete().eq('id', id);
        return;
      } catch (e) {
        debugPrint('[SupabaseService] Delete error: $e');
      }
    }
    _localProducts.removeWhere((p) => p.id == id);
  }

  /// Get absolute min and max prices across all products
  Future<({double min, double max})> getPriceBounds() async {
    if (isConnected && _client != null) {
      try {
        final minRes = await _client!
            .from('products')
            .select('price')
            .order('price', ascending: true)
            .limit(1);
        final maxRes = await _client!
            .from('products')
            .select('price')
            .order('price', ascending: false)
            .limit(1);

        if (minRes.isNotEmpty && maxRes.isNotEmpty) {
          final double min = (minRes.first['price'] as num).toDouble();
          final double max = (maxRes.first['price'] as num).toDouble();
          return (min: min, max: max);
        }
      } catch (e) {
        debugPrint('[SupabaseService] getPriceBounds error: $e');
      }
    }

    if (_localProducts.isEmpty) {
      return (min: 0.0, max: 2000.0);
    }
    final prices = _localProducts.map((p) => p.price).toList();
    prices.sort();
    return (min: prices.first, max: prices.last);
  }
}
