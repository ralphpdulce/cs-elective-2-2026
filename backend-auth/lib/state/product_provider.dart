import 'dart:async';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/supabase_service.dart';

class ProductProvider extends ChangeNotifier {
  final SupabaseService _service;

  // ignore: prefer_initializing_formals
  ProductProvider({required SupabaseService service}) : _service = service;

  bool _isLoading = false;
  bool _isSyncing = false;
  String? _errorMessage;
  List<Product> _products = [];
  int _totalCount = 0;

  // Pagination parameters
  int _currentPage = 1;
  int _pageSize = 10; // Default 10 products per page

  // Filtering parameters
  String _selectedCategory = 'All';
  String _searchQuery = '';
  RangeValues _currentPriceRange = const RangeValues(200.0, 1600.0);
  double _minPriceBound = 200.0;
  double _maxPriceBound = 1600.0;

  Timer? _debounceTimer;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  List<Product> get products => List.unmodifiable(_products);
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => (_totalCount <= 0) ? 1 : ((_totalCount + _pageSize - 1) ~/ _pageSize);
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < totalPages;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  RangeValues get currentPriceRange => _currentPriceRange;
  double get minPriceBound => _minPriceBound;
  double get maxPriceBound => _maxPriceBound;
  bool get isConnectedToSupabase => _service.isConnected;

  /// Initialize service, fetch price range, and load first page
  Future<void> initialize({bool forceLocal = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.initialize(forceLocal: forceLocal);
      final bounds = await _service.getPriceBounds();
      _minPriceBound = (bounds.min.floorToDouble() / 10).floor() * 10;
      _maxPriceBound = (bounds.max.ceilToDouble() / 50).ceil() * 50;
      if (_maxPriceBound <= _minPriceBound) {
        _maxPriceBound = _minPriceBound + 1000;
      }
      _currentPriceRange = RangeValues(_minPriceBound, _maxPriceBound);

      await loadProducts(resetPage: true);
    } catch (e) {
      _errorMessage = 'Failed to load initial data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync live characters from Genshin Impact API into Supabase & local cache
  Future<int> syncFromGenshinApi({bool force = true}) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final count = await _service.syncCharactersFromApi(force: force);
      final bounds = await _service.getPriceBounds();
      _minPriceBound = (bounds.min.floorToDouble() / 10).floor() * 10;
      _maxPriceBound = (bounds.max.ceilToDouble() / 50).ceil() * 50;
      if (_maxPriceBound <= _minPriceBound) {
        _maxPriceBound = _minPriceBound + 1000;
      }
      _currentPriceRange = RangeValues(_minPriceBound, _maxPriceBound);
      await loadProducts(resetPage: true);
      return count;
    } catch (e) {
      _errorMessage = 'Sync failed: $e';
      return 0;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Core data fetching method querying Supabase with current filter and pagination
  Future<void> loadProducts({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getProducts(
        minPrice: _currentPriceRange.start,
        maxPrice: _currentPriceRange.end,
        category: _selectedCategory,
        searchQuery: _searchQuery,
        page: _currentPage,
        pageSize: _pageSize,
      );

      _products = result.products;
      _totalCount = result.totalCount;

      // Adjust current page if beyond bounds
      if (_currentPage > totalPages && totalPages > 0) {
        _currentPage = totalPages;
        // Re-fetch clamped page
        final adjusted = await _service.getProducts(
          minPrice: _currentPriceRange.start,
          maxPrice: _currentPriceRange.end,
          category: _selectedCategory,
          searchQuery: _searchQuery,
          page: _currentPage,
          pageSize: _pageSize,
        );
        _products = adjusted.products;
        _totalCount = adjusted.totalCount;
      }
    } catch (e) {
      _errorMessage = 'Error loading products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Price Slider change handler: updates slider instantly and debounces Supabase query
  void updatePriceRange(RangeValues values) {
    _currentPriceRange = values;
    notifyListeners();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      loadProducts(resetPage: true);
    });
  }

  /// Explicitly set price range and immediately trigger query without debounce
  Future<void> setPriceRange(RangeValues values) async {
    _debounceTimer?.cancel();
    _currentPriceRange = values;
    await loadProducts(resetPage: true);
  }

  /// Category filter change handler
  Future<void> setCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    await loadProducts(resetPage: true);
  }

  /// Search query filter change handler
  void setSearchQuery(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      loadProducts(resetPage: true);
    });
  }

  /// Jump to a specific page
  Future<void> setPage(int page) async {
    if (page < 1 || page > totalPages || page == _currentPage) return;
    _currentPage = page;
    await loadProducts(resetPage: false);
  }

  /// Navigate to previous page
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      await setPage(_currentPage - 1);
    }
  }

  /// Navigate to next page
  Future<void> nextPage() async {
    if (hasNextPage) {
      await setPage(_currentPage + 1);
    }
  }

  /// Toggle items per page between 6, 8, and 10
  Future<void> setPageSize(int size) async {
    if (size != 6 && size != 8 && size != 10) return;
    if (_pageSize == size) return;
    _pageSize = size;
    await loadProducts(resetPage: true);
  }

  /// Reset all filters to default
  Future<void> resetFilters() async {
    _selectedCategory = 'All';
    _searchQuery = '';
    _currentPriceRange = RangeValues(_minPriceBound, _maxPriceBound);
    await loadProducts(resetPage: true);
  }

  // ================= CRUD OPERATIONS =================

  /// Add new product to Supabase
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createProduct(product);
      final bounds = await _service.getPriceBounds();
      if (bounds.min < _minPriceBound) _minPriceBound = bounds.min;
      if (bounds.max > _maxPriceBound) _maxPriceBound = bounds.max;
      await loadProducts();
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update existing product in Supabase
  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateProduct(product);
      await loadProducts();
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete product from Supabase
  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
