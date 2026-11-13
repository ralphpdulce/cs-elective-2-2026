import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/auth_provider.dart';
import '../state/cart_state.dart';
import '../state/product_provider.dart';
import '../widgets/admin_product_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/price_slider_filter.dart';
import '../widgets/product_card.dart';
import '../widgets/user_profile_dialog.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = [
    'All',
    'Weapons',
    'Talent Books',
    'Gadgets',
    'Gemstones',
  ];

  @override
  void initState() {
    super.initState();
    cartState.addListener(_rebuild);
  }

  @override
  void dispose() {
    _searchController.dispose();
    cartState.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _addNewProduct() async {
    final provider = context.read<ProductProvider>();
    final newProduct = await AdminProductDialog.show(context);
    if (newProduct != null && mounted) {
      await provider.addProduct(newProduct);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${newProduct.name}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final auth = context.watch<AppAuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paimon's Bargains",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          // User Avatar / Login button
          if (auth.isAuthenticated)
            IconButton(
              icon: CircleAvatar(
                radius: 14,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                backgroundImage: auth.avatarUrl != null && auth.avatarUrl!.isNotEmpty
                    ? (auth.avatarUrl!.startsWith('assets/')
                        ? AssetImage(auth.avatarUrl!) as ImageProvider
                        : NetworkImage(auth.avatarUrl!))
                    : null,
                child: auth.avatarUrl == null
                    ? Text(
                        auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              tooltip: '${auth.displayName} (${auth.providerName})',
              onPressed: () => UserProfileDialog.show(context),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.login, size: 16),
              label: const Text('Sign In', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => context.push('/login'),
            ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
                tooltip: 'View Cart',
              ),
              if (cartState.totalItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    child: Text(
                      '${cartState.totalItemCount}',
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
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: auth.avatarUrl != null && auth.avatarUrl!.isNotEmpty
                    ? (auth.avatarUrl!.startsWith('assets/')
                        ? AssetImage(auth.avatarUrl!) as ImageProvider
                        : NetworkImage(auth.avatarUrl!))
                    : null,
                child: auth.avatarUrl == null
                    ? Text(
                        auth.isAuthenticated
                            ? (auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U')
                            : '?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              accountName: Text(
                auth.isAuthenticated ? auth.displayName : 'Guest Explorer',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                auth.isAuthenticated
                    ? '${auth.email ?? "No email"} • ${auth.providerName}'
                    : 'Sign in to access user features',
              ),
            ),
            if (auth.isAuthenticated) ...[
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('My Profile'),
                subtitle: Text('Connected via ${auth.providerName}'),
                onTap: () {
                  Navigator.pop(context);
                  UserProfileDialog.show(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.signOut();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Sign In'),
                subtitle: const Text('Connect via GitHub or Google'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('Cart'),
              trailing: Text('${cartState.totalItemCount} items'),
              onTap: () {
                Navigator.pop(context);
                context.push('/cart');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      bottomNavigationBar: const PaginationBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: RefreshIndicator(
            onRefresh: () => provider.loadProducts(),
            child: CustomScrollView(
              slivers: [
            // Backend status banner
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: provider.isConnectedToSupabase
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.amber.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    Icon(
                      provider.isConnectedToSupabase
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      size: 16,
                      color: provider.isConnectedToSupabase
                          ? Colors.green
                          : Colors.amber[800],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.isConnectedToSupabase
                            ? 'Connected to Supabase Backend • ${auth.isAuthenticated ? "Auth: ${auth.displayName} (${auth.providerName})" : "Guest Mode"}'
                            : 'Running local cache mode • ${auth.isAuthenticated ? "Auth: ${auth.displayName} (${auth.providerName})" : "Guest Mode"}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: provider.isConnectedToSupabase
                              ? Colors.green[800]
                              : Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
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
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).cardTheme.color,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                    provider.setSearchQuery(val);
                  },
                ),
              ),
            ),

            // Category Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = provider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => provider.setCategory(cat),
                        selectedColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Price Slider Filter
            const SliverToBoxAdapter(
              child: PriceSliderFilter(),
            ),

            // Loading / Error / Products Grid
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Querying Supabase...'),
                    ],
                  ),
                ),
              )
            else if (provider.errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 12),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => provider.loadProducts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (provider.products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No products match your filters.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          provider.resetFilters();
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
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = provider.products[index];
                      return ProductCard(product: product);
                    },
                    childCount: provider.products.length,
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
