import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear Cart',
              onPressed: () {
                cartState.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart cleared'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
      body: cartState.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      final product = item.product;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                ? Image.asset(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Icon(Icons.broken_image_outlined, size: 24, color: Colors.grey[600]),
                                    ),
                                  )
                                : Center(
                                    child: Icon(Icons.inventory_2_outlined, size: 24, color: Colors.grey[600]),
                                  ),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () => cartState.updateQuantity(product.id, -1),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => cartState.updateQuantity(product.id, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Summary Footer
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${cartState.grandTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => context.push('/checkout'),
                          child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}