import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/price_slider_filter.dart';
import '../widgets/product_card.dart';
import '../widgets/user_profile_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final productState = ref.watch(productProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cart = ref.watch(cartProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PAIMON'S BARGAINS",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          // Role Indicator Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: auth.isAdmin ? Colors.deepOrange.withValues(alpha: 0.2) : theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: auth.isAdmin ? Colors.deepOrange : theme.colorScheme.primary,
              ),
            ),
            child: Text(
              auth.isAdmin ? 'ADMIN' : 'CUSTOMER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: auth.isAdmin ? Colors.deepOrange : theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // User Avatar / Profile
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: auth.isAdmin ? Colors.deepOrange : theme.colorScheme.secondary,
              child: Text(
                auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            tooltip: '${auth.displayName} (${auth.isAdmin ? "Admin" : "Customer"})',
            onPressed: () => UserProfileDialog.show(context),
          ),

          // Admin Orders Shortcut
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'Admin Order Management',
              onPressed: () => context.push('/admin/orders'),
            ),

          // Customer Cart with Badge (Hidden for Admin!)
          if (auth.isCustomer)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  tooltip: 'Shopping Cart',
                  onPressed: () => context.push('/cart'),
                ),
                if (cart.totalItemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: theme.colorScheme.error,
                      child: Text(
                        '${cart.totalItemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          // Theme Toggle
          IconButton(
            icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            tooltip: theme.brightness == Brightness.dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(theme.brightness == Brightness.dark),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Drawer navigation
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: auth.isAdmin ? Colors.deepOrange : theme.colorScheme.primary,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: auth.isAdmin ? Colors.deepOrange : theme.colorScheme.primary,
                  ),
                ),
              ),
              accountName: Text(auth.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text('${auth.email} • ${auth.isAdmin ? "Administrator" : "Customer"}'),
            ),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Product Catalog'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),

            if (auth.isAdmin) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('ADMINISTRATION',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined, color: Colors.deepOrange),
                title: const Text('Add Product Form'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/admin/products/add');
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_outlined, color: Colors.deepOrange),
                title: const Text('Admin Order Management'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/admin/orders');
                },
              ),
            ],

            if (auth.isCustomer) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('CUSTOMER SHOPPING',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart_outlined),
                title: const Text('Shopping Cart'),
                trailing: Text('${cart.totalItemCount}'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/cart');
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Order History'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/orders');
                },
              ),
            ],

            const Divider(),
            ListTile(
              leading: Icon(theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
              title: Text(theme.brightness == Brightness.dark ? 'Light Mode' : 'Dark Mode'),
              trailing: Switch(
                value: theme.brightness == Brightness.dark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(theme.brightness == Brightness.dark),
              ),
              onTap: () => ref.read(themeProvider.notifier).toggleTheme(theme.brightness == Brightness.dark),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),

      // Admin Floating Action Button (redirects to Add Product Form as per PDF requirement!)
      floatingActionButton: auth.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/admin/products/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,

      bottomNavigationBar: const PaginationBar(),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: RefreshIndicator(
            onRefresh: () => ref.read(productProvider.notifier).loadProducts(),
            child: CustomScrollView(
              slivers: [
                // Search Input
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products by name...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(productProvider.notifier).setSearchQuery('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: theme.cardTheme.color,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {});
                        ref.read(productProvider.notifier).setSearchQuery(val);
                      },
                    ),
                  ),
                ),

                // Category Chips Filter
                SliverToBoxAdapter(
                  child: categoriesAsync.when(
                    data: (categories) {
                      final allCats = ['All', ...categories.map((c) => c.name)];
                      return SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: allCats.length,
                          itemBuilder: (context, index) {
                            final cat = allCats[index];
                            final isSelected = productState.selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (_) {
                                  ref.read(productProvider.notifier).setCategory(cat);
                                },
                                selectedColor: theme.colorScheme.primaryContainer,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const SizedBox(
                      height: 48,
                      child: Center(
                        child: Text('Loading categories...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),

                // Price Slider Filter
                const SliverToBoxAdapter(
                  child: PriceSliderFilter(),
                ),

                // Products State: Loading / Error / Empty / Grid
                if (productState.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Loading catalog from Supabase...'),
                        ],
                      ),
                    ),
                  )
                else if (productState.errorMessage != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                            const SizedBox(height: 12),
                            Text(
                              productState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => ref.read(productProvider.notifier).loadProducts(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (productState.products.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'No products match your filters.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(productProvider.notifier).resetFilters();
                            },
                            child: const Text('Reset All Filters'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 240,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = productState.products[index];
                          return ProductCard(product: product);
                        },
                        childCount: productState.products.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
