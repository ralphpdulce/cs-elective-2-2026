import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';
import 'supabase_provider.dart';

class ProductState {
  final bool isLoading;
  final String? errorMessage;
  final List<Product> products;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final String searchQuery;
  final String selectedCategory;
  final int? selectedCategoryId;
  final RangeValues currentPriceRange;
  final double minPriceBound;
  final double maxPriceBound;

  const ProductState({
    this.isLoading = false,
    this.errorMessage,
    this.products = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.pageSize = 10,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.selectedCategoryId,
    this.currentPriceRange = const RangeValues(100.0, 1600.0),
    this.minPriceBound = 50.0,
    this.maxPriceBound = 1600.0,
  });

  int get totalPages => (totalCount <= 0) ? 1 : ((totalCount + pageSize - 1) ~/ pageSize);
  bool get hasPreviousPage => currentPage > 1;
  bool get hasNextPage => currentPage < totalPages;

  ProductState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Product>? products,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    String? searchQuery,
    String? selectedCategory,
    int? selectedCategoryId,
    RangeValues? currentPriceRange,
    double? minPriceBound,
    double? maxPriceBound,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      currentPriceRange: currentPriceRange ?? this.currentPriceRange,
      minPriceBound: minPriceBound ?? this.minPriceBound,
      maxPriceBound: maxPriceBound ?? this.maxPriceBound,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final SupabaseService _service;
  Timer? _debounceTimer;

  ProductNotifier(this._service)
      : super(ProductState(
          products: sampleFinalExamProducts.take(10).toList(),
          totalCount: sampleFinalExamProducts.length,
        )) {
    if (_service.isConnected) {
      initialize();
    }
  }

  Future<void> initialize({bool forceLocal = false}) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.initialize(forceLocal: forceLocal);
      if (!mounted) return;
      final bounds = await _service.getPriceBounds();
      if (!mounted) return;
      final minBound = (bounds.min.floorToDouble() / 10).floor() * 10.0;
      var maxBound = (bounds.max.ceilToDouble() / 50).ceil() * 50.0;
      if (maxBound <= minBound) {
        maxBound = minBound + 1000.0;
      }
      state = state.copyWith(
        minPriceBound: minBound,
        maxPriceBound: maxBound,
        currentPriceRange: RangeValues(minBound, maxBound),
      );
      if (!mounted) return;
      await loadProducts(resetPage: true);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadProducts({bool resetPage = false}) async {
    if (!mounted) return;
    final pageToLoad = resetPage ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, clearError: true, currentPage: pageToLoad);

    try {
      final result = await _service.getProducts(
        minPrice: state.currentPriceRange.start,
        maxPrice: state.currentPriceRange.end,
        category: state.selectedCategory,
        categoryId: state.selectedCategoryId,
        searchQuery: state.searchQuery,
        page: pageToLoad,
        pageSize: state.pageSize,
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        products: result.products,
        totalCount: result.totalCount,
        currentPage: pageToLoad,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      loadProducts(resetPage: true);
    });
  }

  void setCategory(String category, {int? categoryId}) {
    if (state.selectedCategory == category && state.selectedCategoryId == categoryId) return;
    state = state.copyWith(
      selectedCategory: category,
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    );
    loadProducts(resetPage: true);
  }

  void updatePriceRange(RangeValues values) {
    state = state.copyWith(currentPriceRange: values);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      loadProducts(resetPage: true);
    });
  }

  Future<void> setPriceRange(RangeValues values) async {
    state = state.copyWith(currentPriceRange: values);
    await loadProducts(resetPage: true);
  }

  Future<void> setPage(int page) async {
    if (page < 1 || page > state.totalPages || page == state.currentPage) return;
    state = state.copyWith(currentPage: page);
    await loadProducts();
  }

  Future<void> nextPage() async {
    if (state.hasNextPage) {
      await setPage(state.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (state.hasPreviousPage) {
      await setPage(state.currentPage - 1);
    }
  }

  Future<void> setPageSize(int size) async {
    if (state.pageSize == size) return;
    state = state.copyWith(pageSize: size);
    await loadProducts(resetPage: true);
  }

  Future<void> resetFilters() async {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: 'All',
      clearCategory: true,
      currentPriceRange: RangeValues(state.minPriceBound, state.maxPriceBound),
    );
    await loadProducts(resetPage: true);
  }

  // Admin Actions
  Future<void> addProduct(Product product) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      await _service.createProduct(product);
      if (!mounted) return;
      await loadProducts(resetPage: true);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to add product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateProduct(product);
      if (!mounted) return;
      await loadProducts();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to update product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      await _service.deleteProduct(productId);
      if (!mounted) return;
      await loadProducts();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to delete product: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  ref.watch(authProvider);
  return ProductNotifier(service);
});
