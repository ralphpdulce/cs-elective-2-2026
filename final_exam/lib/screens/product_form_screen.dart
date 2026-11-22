import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final int? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageController;
  late final TextEditingController _descController;
  late final TextEditingController _ratingController;
  late final TextEditingController _badgeController;

  int? _selectedCategoryId;
  bool _isSaving = false;
  Product? _existingProduct;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController(text: '10');
    _imageController = TextEditingController(text: 'https://enka.network/ui/UI_AvatarIcon_Zhongli_Card.png');
    _descController = TextEditingController();
    _ratingController = TextEditingController(text: '4.8');
    _badgeController = TextEditingController();

    if (widget.productId != null && widget.productId! > 0) {
      final products = ref.read(productProvider).products;
      _existingProduct = products.where((p) => p.id == widget.productId).firstOrNull;

      if (_existingProduct != null) {
        _nameController.text = _existingProduct!.name;
        _priceController.text = _existingProduct!.price.toStringAsFixed(2);
        _stockController.text = _existingProduct!.stock.toString();
        _imageController.text = _existingProduct!.imageUrl ?? '';
        _descController.text = _existingProduct!.description;
        _ratingController.text = _existingProduct!.rating.toString();
        _badgeController.text = _existingProduct!.badge ?? '';
        _selectedCategoryId = _existingProduct!.categoryId;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _descController.dispose();
    _ratingController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final theme = Theme.of(context);

    try {
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());
      final imageUrl = _imageController.text.trim().isEmpty ? null : _imageController.text.trim();
      final desc = _descController.text.trim();
      final rating = double.tryParse(_ratingController.text.trim()) ?? 4.8;
      final badge = _badgeController.text.trim().isEmpty ? null : _badgeController.text.trim();

      if (widget.productId != null && widget.productId! > 0) {
        // Edit existing product
        final updated = Product(
          id: widget.productId!,
          name: name,
          price: price,
          stock: stock,
          categoryId: _selectedCategoryId,
          imageUrl: imageUrl,
          description: desc.isEmpty ? 'Item available in Paimon\'s Bargains.' : desc,
          rating: rating,
          badge: badge,
        );
        await ref.read(productProvider.notifier).updateProduct(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Updated "${updated.name}" successfully!')),
          );
          context.pop();
        }
      } else {
        // Add new product
        final newProduct = Product(
          id: 0,
          name: name,
          price: price,
          stock: stock,
          categoryId: _selectedCategoryId ?? 1,
          imageUrl: imageUrl,
          description: desc.isEmpty ? 'Item available in Paimon\'s Bargains.' : desc,
          rating: rating,
          badge: badge,
        );
        await ref.read(productProvider.notifier).addProduct(newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added "${newProduct.name}" to inventory!')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: theme.colorScheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isEditing = widget.productId != null && widget.productId! > 0;
    final theme = Theme.of(context);

    // Security check: non-admin cannot access this screen
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(child: Text('Only administrators can access product management.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isEditing ? Icons.edit_note : Icons.add_circle_outline,
                            color: Colors.deepOrange,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? 'Modify Product Specifications' : 'Add Product to Supabase Catalog',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 28),

                      // Product Name (Required)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name *',
                          hintText: 'e.g. Zhongli, Mistsplitter Reforged',
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'A product name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Price & Stock
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Price (\$) *',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter price';
                                final num = double.tryParse(val.trim());
                                if (num == null || num < 0) {
                                  return 'Price must be 0 or more.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Stock Quantity *',
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter stock';
                                final num = int.tryParse(val.trim());
                                if (num == null || num < 0) {
                                  return 'Stock must be whole number >= 0.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      categoriesAsync.when(
                        data: (cats) {
                          if (_selectedCategoryId == null && cats.isNotEmpty) {
                            _selectedCategoryId = cats.first.id;
                          }
                          return DropdownButtonFormField<int>(
                            initialValue: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Category *',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: cats.map((Category c) {
                              return DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(c.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategoryId = val);
                            },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, _) => const Text('Failed to load categories.'),
                      ),
                      const SizedBox(height: 16),

                      // Image URL
                      TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          labelText: 'Image Asset or CDN URL',
                          hintText: 'https://enka.network/...',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating & Badge
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ratingController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Rating (0.0 - 5.0)',
                                prefixIcon: Icon(Icons.star_outline),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return null;
                                final num = double.tryParse(val.trim());
                                if (num == null || num < 0 || num > 5) {
                                  return 'Must be 0.0 to 5.0';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _badgeController,
                              decoration: const InputDecoration(
                                labelText: 'Badge (Optional)',
                                hintText: 'e.g. 5★ ARCHON',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter product lore and background description...',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isSaving ? null : _saveProduct,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            isEditing ? 'Save Changes' : 'Create Product',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
