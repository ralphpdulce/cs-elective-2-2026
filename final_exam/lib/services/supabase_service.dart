import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/profile.dart';

class SupabaseService {
  final bool forceLocal;

  // In-memory fallback simulation dataset for offline & test environments
  final List<Product> _localProducts = List.from(sampleFinalExamProducts);
  final List<Category> _localCategories = [
    const Category(id: 1, name: 'Characters'),
    const Category(id: 2, name: 'Weapons'),
    const Category(id: 3, name: 'Materials'),
    const Category(id: 4, name: 'Pyro'),
    const Category(id: 5, name: 'Hydro'),
    const Category(id: 6, name: 'Anemo'),
    const Category(id: 7, name: 'Electro'),
    const Category(id: 8, name: 'Dendro'),
    const Category(id: 9, name: 'Cryo'),
    const Category(id: 10, name: 'Geo'),
  ];
  final List<Order> _localOrders = [];
  Profile? _localProfile;

  final SupabaseClient? _injectedClient;

  SupabaseService({SupabaseClient? client, this.forceLocal = false}) : _injectedClient = client;

  SupabaseClient? get _client {
    if (!forceLocal && SupabaseConfig.isConfigured) {
      try {
        return Supabase.instance.client;
      } catch (_) {}
    }
    return _injectedClient;
  }

  bool get isConnected {
    if (forceLocal || !SupabaseConfig.isConfigured) return false;
    try {
      final c = _client;
      return c != null && c.rest.url.contains(SupabaseConfig.supabaseUrl);
    } catch (_) {
      return false;
    }
  }

  SupabaseClient? get client => _client;

  /// Initialize Supabase
  Future<void> initialize({bool forceLocal = false}) async {
    if (this.forceLocal || forceLocal || !SupabaseConfig.isConfigured) {
      debugPrint('[SupabaseService] Using local in-memory fallback.');
      return;
    }

    try {
      try {
        final existing = Supabase.instance.client;
        if (!existing.rest.url.contains(SupabaseConfig.supabaseUrl)) {
          await Supabase.instance.dispose();
        }
      } catch (_) {}

      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      debugPrint('[SupabaseService] Successfully connected.');
    } catch (e) {
      debugPrint('[SupabaseService] Supabase init notice: $e.');
    }
  }

  // ===========================================================================
  // AUTHENTICATION
  // ===========================================================================

  User? get currentUser => _client?.auth.currentUser;

  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  /// Sign Up with Email and Password
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    if (isConnected) {
      try {
        final res = await _client!.auth.signUp(
          email: email,
          password: password,
          data: {
            'firstname': firstname,
            'lastname': lastname,
            'name': '$firstname $lastname'.trim(),
          },
        );
        return res;
      } catch (e) {
        debugPrint('[SupabaseService] Remote signUp error: $e');
        rethrow;
      }
    }

    if (forceLocal) {
      // Local simulation for unit tests
      _localProfile = Profile(
        id: 'local-user-1',
        email: email,
        firstname: firstname,
        lastname: lastname,
        roleId: 1,
        roleName: 'customer',
      );
      return null;
    }

    throw const AuthException('Unable to reach Supabase. Check your connection and configuration.');
  }

  /// Sign In with Email and Password
  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (isConnected) {
      try {
        final res = await _client!.auth.signInWithPassword(
          email: email,
          password: password,
        );
        return res;
      } catch (e) {
        debugPrint('[SupabaseService] Remote signIn error: $e');
        rethrow;
      }
    }

    if (forceLocal) {
      // Local simulation for unit tests
      final isAdmin = email.toLowerCase().contains('admin');
      _localProfile = Profile(
        id: isAdmin ? 'local-admin-1' : 'local-user-1',
        email: email,
        firstname: isAdmin ? 'Grand' : 'Lumine',
        lastname: isAdmin ? 'Master' : 'Traveler',
        roleId: isAdmin ? 2 : 1,
        roleName: isAdmin ? 'admin' : 'customer',
      );
      return null;
    }

    throw const AuthException('Unable to reach Supabase. Check your connection and configuration.');
  }

  /// Sign In with Google OAuth
  Future<bool> signInWithGoogle() async {
    if (isConnected) {
      final redirectUrl = kIsWeb ? Uri.base.origin : SupabaseConfig.authRedirectUri;
      return await _client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
    }

    if (forceLocal) {
      _localProfile = const Profile(
        id: 'local-google-user',
        email: 'traveler@gmail.com',
        firstname: 'Lumine',
        lastname: 'Traveler',
        roleId: 1,
        roleName: 'customer',
      );
      return true;
    }

    throw const AuthException('Unable to reach Supabase. Check your connection and configuration.');
  }

  /// Sign Out
  Future<void> signOut() async {
    if (isConnected && currentUser != null) {
      try {
        await _client!.auth.signOut();
      } catch (e) {
        debugPrint('[SupabaseService] Sign out error: $e');
      }
    }
    _localProfile = null;
  }

  /// Fetch user profile joining roles table
  Future<Profile?> getProfile(String userId) async {
    if (isConnected) {
      try {
        final res = await _client!
            .from('profiles')
            .select('id, email, firstname, lastname, role_id, roles(role)')
            .eq('id', userId)
            .maybeSingle();

        if (res != null) {
          return Profile.fromMap(Map<String, dynamic>.from(res));
        }
      } catch (e) {
        debugPrint('[SupabaseService] getProfile notice (table may need setup): $e');
      }

      // If database profile row not found yet (e.g. schema migration in progress),
      // gracefully extract the authenticated user's real Supabase metadata.
      final user = _client?.auth.currentUser;
      if (user != null && user.id == userId) {
        final meta = user.userMetadata ?? {};
        final fullName = (meta['full_name'] ?? meta['name'] ?? '').toString().trim();
        final parts = fullName.isNotEmpty ? fullName.split(' ') : <String>[];
        final first = (meta['firstname'] ?? (parts.isNotEmpty ? parts.first : '')).toString();
        final last = (meta['lastname'] ?? (parts.length > 1 ? parts.sublist(1).join(' ') : '')).toString();
        return Profile(
          id: user.id,
          email: user.email ?? '',
          firstname: first.isNotEmpty ? first : (user.email?.split('@').first ?? 'Traveler'),
          lastname: last,
          roleId: 1,
          roleName: 'customer',
        );
      }
    }

    return _localProfile;
  }

  /// Check whether current user is admin via RPC or profile
  Future<bool> isUserAdmin() async {
    if (isConnected) {
      try {
        final res = await _client!.rpc('is_admin');
        if (res is bool) return res;
      } catch (e) {
        debugPrint('[SupabaseService] is_admin RPC error: $e');
      }
    }
    return _localProfile?.isAdmin ?? false;
  }

  // ===========================================================================
  // CATEGORIES
  // ===========================================================================

  Future<List<Category>> getCategories() async {
    if (isConnected) {
      try {
        final res = await _client!.from('categories').select().order('id');
        final List list = res as List;
        return list.map((c) => Category.fromMap(Map<String, dynamic>.from(c))).toList();
      } catch (e) {
        debugPrint('[SupabaseService] getCategories error: $e');
      }
    }
    return List.unmodifiable(_localCategories);
  }

  // ===========================================================================
  // PRODUCTS (CRUD, FILTERING, PAGINATION)
  // ===========================================================================

  Future<({List<Product> products, int totalCount})> getProducts({
    double? minPrice,
    double? maxPrice,
    String? category,
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (isConnected) {
      try {
        var query = _client!.from('products').select('*, categories(name)');

        // 1. Price Filtering
        if (minPrice != null) {
          query = query.gte('price', minPrice);
        }
        if (maxPrice != null) {
          query = query.lte('price', maxPrice);
        }

        // 2. Category Filter
        if (categoryId != null && categoryId > 0) {
          query = query.eq('category_id', categoryId);
        } else if (category != null && category != 'All') {
          // Find matching category ID from list
          final catObj = _localCategories.where((c) => c.name.toLowerCase() == category.toLowerCase()).firstOrNull;
          if (catObj != null) {
            query = query.eq('category_id', catObj.id);
          }
        }

        // 3. Search Query Filter
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          query = query.ilike('name', '%${searchQuery.trim()}%');
        }

        // 4. Pagination
        final int from = (page - 1) * pageSize;
        final int to = from + pageSize - 1;

        final response = await query
            .order('id', ascending: true)
            .range(from, to)
            .count(CountOption.exact);

        final List data = response.data as List;
        final products = data
            .map((item) => Product.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        final int count = response.count;

        return (products: products, totalCount: count);
      } catch (e) {
        debugPrint('[SupabaseService] getProducts error ($e). Using local fallback.');
      }
    }

    // Local in-memory simulation
    Iterable<Product> filtered = _localProducts;

    if (minPrice != null) {
      filtered = filtered.where((p) => p.price >= minPrice);
    }
    if (maxPrice != null) {
      filtered = filtered.where((p) => p.price <= maxPrice);
    }
    if (categoryId != null && categoryId > 0) {
      filtered = filtered.where((p) => p.categoryId == categoryId);
    } else if (category != null && category != 'All') {
      filtered = filtered.where((p) =>
          p.categoryName?.toLowerCase() == category.toLowerCase() ||
          p.badge?.toLowerCase().contains(category.toLowerCase()) == true);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((p) => p.name.toLowerCase().contains(q));
    }

    final sorted = filtered.toList()..sort((a, b) => a.id.compareTo(b.id));
    final totalCount = sorted.length;

    final int from = (page - 1) * pageSize;
    if (from >= totalCount) {
      return (products: <Product>[], totalCount: totalCount);
    }
    final int to = (from + pageSize).clamp(0, totalCount);
    final paginated = sorted.sublist(from, to);

    return (products: paginated, totalCount: totalCount);
  }

  /// Create a new product (Admin only)
  Future<Product> createProduct(Product product) async {
    if (isConnected) {
      try {
        final res = await _client!
            .from('products')
            .insert(product.toMap(includeId: false))
            .select('*, categories(name)')
            .single();
        final created = Product.fromMap(Map<String, dynamic>.from(res));
        _localProducts.insert(0, created);
        return created;
      } catch (e) {
        debugPrint('[SupabaseService] createProduct error: $e');
        rethrow;
      }
    }

    final newId = (_localProducts.isEmpty) ? 1 : (_localProducts.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1);
    final created = product.copyWith(id: newId);
    _localProducts.insert(0, created);
    return created;
  }

  /// Update an existing product (Admin only)
  Future<Product> updateProduct(Product product) async {
    if (isConnected) {
      try {
        final res = await _client!
            .from('products')
            .update(product.toMap(includeId: false))
            .eq('id', product.id)
            .select('*, categories(name)')
            .single();
        final updated = Product.fromMap(Map<String, dynamic>.from(res));
        final index = _localProducts.indexWhere((p) => p.id == product.id);
        if (index >= 0) _localProducts[index] = updated;
        return updated;
      } catch (e) {
        debugPrint('[SupabaseService] updateProduct error: $e');
        rethrow;
      }
    }

    final index = _localProducts.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _localProducts[index] = product;
    }
    return product;
  }

  /// Delete a product (Admin only)
  Future<void> deleteProduct(int id) async {
    if (isConnected) {
      try {
        await _client!.from('products').delete().eq('id', id);
      } catch (e) {
        debugPrint('[SupabaseService] deleteProduct error: $e');
        rethrow;
      }
    }
    _localProducts.removeWhere((p) => p.id == id);
  }

  /// Get price bounds for the price range slider
  Future<({double min, double max})> getPriceBounds() async {
    if (isConnected) {
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
    final prices = _localProducts.map((p) => p.price).toList()..sort();
    return (min: prices.first, max: prices.last);
  }

  // ===========================================================================
  // ORDERS & CHECKOUT (TRANSACTIONAL RPC)
  // ===========================================================================

  /// Place an order atomically via Supabase RPC 'place_order'
  Future<({int orderId, double total, String status})> placeOrder(
    List<({int productId, int quantity})> items,
  ) async {
    if (items.isEmpty) {
      throw Exception('Cannot checkout an empty cart.');
    }

    if (isConnected) {
      try {
        final payload = items
            .map((i) => {'product_id': i.productId, 'quantity': i.quantity})
            .toList();

        final res = await _client!.rpc('place_order', params: {'items': payload});
        final map = Map<String, dynamic>.from(res as Map);
        final orderId = map['order_id'] is int
            ? map['order_id'] as int
            : int.tryParse(map['order_id']?.toString() ?? '0') ?? 0;
        final total = (map['total'] as num?)?.toDouble() ?? 0.0;
        final status = (map['status'] ?? 'done') as String;

        return (orderId: orderId, total: total, status: status);
      } catch (e) {
        debugPrint('[SupabaseService] placeOrder RPC error: $e');
        rethrow;
      }
    }

    // Local simulation: check stock, deduct stock, create order & order_items
    double calculatedTotal = 0.0;
    final List<OrderItem> orderItems = [];
    final nextOrderId = _localOrders.length + 1001;

    for (final item in items) {
      final index = _localProducts.indexWhere((p) => p.id == item.productId);
      if (index < 0) {
        throw Exception('Product ID ${item.productId} not found.');
      }
      final product = _localProducts[index];
      if (product.stock < item.quantity) {
        throw Exception('Insufficient stock for "${product.name}". Available: ${product.stock}');
      }
      // Deduct stock
      _localProducts[index] = product.copyWith(stock: product.stock - item.quantity);
      calculatedTotal += product.price * item.quantity;

      orderItems.add(
        OrderItem(
          id: orderItems.length + 1,
          orderId: nextOrderId,
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          quantity: item.quantity,
          createdAt: DateTime.now(),
        ),
      );
    }

    final newOrder = Order(
      id: nextOrderId,
      userId: _localProfile?.id ?? 'local-user-1',
      status: 'done',
      total: calculatedTotal,
      createdAt: DateTime.now(),
      items: orderItems,
      customerEmail: _localProfile?.email ?? 'traveler@gmail.com',
      customerName: _localProfile?.fullName ?? 'Traveler',
    );
    _localOrders.insert(0, newOrder);

    return (orderId: nextOrderId, total: calculatedTotal, status: 'done');
  }

  /// Get past orders for currently logged in customer
  Future<List<Order>> getCustomerOrders() async {
    if (isConnected) {
      try {
        final userId = currentUser?.id;
        if (userId == null) return [];

        final res = await _client!
            .from('orders')
            .select('*, order_items(*)')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        final List list = res as List;
        return list.map((o) => Order.fromMap(Map<String, dynamic>.from(o))).toList();
      } catch (e) {
        debugPrint('[SupabaseService] getCustomerOrders error: $e');
      }
    }

    final currentId = _localProfile?.id ?? 'local-user-1';
    return _localOrders.where((o) => o.userId == currentId).toList();
  }

  /// Get all orders for Admin view
  Future<List<Order>> getAllOrders() async {
    if (isConnected) {
      try {
        final res = await _client!
            .from('orders')
            .select('*, order_items(*)')
            .order('created_at', ascending: false);

        final List list = res as List;

        final userIds = list
            .map((o) => o['user_id']?.toString())
            .whereType<String>()
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();

        final Map<String, Map<String, dynamic>> profilesMap = {};
        if (userIds.isNotEmpty) {
          try {
            final profilesRes = await _client!
                .from('profiles')
                .select('id, email, firstname, lastname')
                .filter('id', 'in', userIds);
            for (final p in (profilesRes as List)) {
              if (p is Map && p['id'] != null) {
                profilesMap[p['id'].toString()] = Map<String, dynamic>.from(p);
              }
            }
          } catch (e) {
            debugPrint('[SupabaseService] profiles fetch for orders notice: $e');
          }
        }

        return list.map((o) {
          final map = Map<String, dynamic>.from(o as Map);
          final uid = map['user_id']?.toString();
          if (uid != null && profilesMap.containsKey(uid)) {
            map['profiles'] = profilesMap[uid];
          }
          return Order.fromMap(map);
        }).toList();
      } catch (e) {
        debugPrint('[SupabaseService] getAllOrders error: $e');
      }
    }

    return List.unmodifiable(_localOrders);
  }

  /// Update order status (Admin only)
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    if (isConnected) {
      try {
        await _client!
            .from('orders')
            .update({'status': newStatus})
            .eq('id', orderId);
      } catch (e) {
        debugPrint('[SupabaseService] updateOrderStatus error: $e');
        rethrow;
      }
    }

    final index = _localOrders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final old = _localOrders[index];
      _localOrders[index] = Order(
        id: old.id,
        userId: old.userId,
        status: newStatus,
        total: old.total,
        createdAt: old.createdAt,
        items: old.items,
        customerEmail: old.customerEmail,
        customerName: old.customerName,
      );
    }
  }

  /// Reset local state (useful in test setups)
  @visibleForTesting
  void resetLocalState({Profile? mockProfile}) {
    _localProducts.clear();
    _localProducts.addAll(sampleFinalExamProducts);
    _localOrders.clear();
    _localProfile = mockProfile;
  }
}
