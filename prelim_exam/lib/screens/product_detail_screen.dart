import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/cart_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    cartState.addListener(_rebuild);
  }

  @override
  void dispose() {
    cartState.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _toggleWishlist(Product product) {
    cartState.toggleWishlist(product.id);
    final isWishlisted = cartState.isWishlisted(product.id);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isWishlisted ? '${product.name} added to Wishlist!' : '${product.name} removed from Wishlist!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = sampleProducts.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => sampleProducts.first,
    );

    final isWishlisted = cartState.isWishlisted(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : null,
            ),
            tooltip: 'Wishlist',
            onPressed: () => _toggleWishlist(product),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic Responsive Image Container
                Container(
                  height: isWideScreen ? 350 : 220,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.asset(
                          product.imageUrl!,
                          fit: isWideScreen ? BoxFit.contain : BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey[600]),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[600]),
                        ),
                ),
                const SizedBox(height: 20),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),

                // Select Quantity Controls
                Row(
                  children: [
                    const Text('Quantity:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                          ),
                          Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => quantity++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Add to Wishlist Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : null,
                    ),
                    label: Text(
                      isWishlisted ? 'Saved to Wishlist' : 'Add to Wishlist',
                      style: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () => _toggleWishlist(product),
                  ),
                ),
                const SizedBox(height: 12),

                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      for (int i = 0; i < quantity; i++) {
                        cartState.addToCart(product);
                      }
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$quantity x ${product.name} added to cart!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}