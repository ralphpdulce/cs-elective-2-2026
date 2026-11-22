import 'dart:convert';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/supabase_provider.dart';

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

  // Drag and drop & image picker state
  bool _isDragging = false;
  bool _isUploadingImage = false;
  Uint8List? _imageBytes;
  String? _imageFileName;
  bool _showManualUrl = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController(text: '10');
    _imageController = TextEditingController();
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

  Future<void> _processImageBytes(Uint8List bytes, String fileName) async {
    setState(() {
      _imageBytes = bytes;
      _imageFileName = fileName;
      _isUploadingImage = true;
    });

    try {
      final service = ref.read(supabaseServiceProvider);
      final url = await service.uploadProductImage(
        bytes: bytes,
        fileName: fileName,
      );
      if (url != null && mounted) {
        setState(() {
          _imageController.text = url;
        });
      }
    } catch (e) {
      debugPrint('[ProductFormScreen] Upload error: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _pickImageFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        await _processImageBytes(bytes, file.name);
      }
    } catch (e) {
      debugPrint('[ProductFormScreen] FilePicker error: $e');
    }
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

  Widget _buildPreviewImage() {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }
    final url = _imageController.text.trim();
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final base64Str = commaIdx >= 0 ? url.substring(commaIdx + 1) : url;
        final bytes = base64Decode(base64Str);
        return Image.memory(bytes, fit: BoxFit.contain);
      } catch (_) {}
    }
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.contain);
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
      );
    }
    return const Center(child: Icon(Icons.image, size: 48, color: Colors.grey));
  }

  Widget _buildImageDropZone(ThemeData theme) {
    final hasImage = _imageBytes != null || _imageController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_library_outlined, size: 18, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Text(
              'Product Image',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              onPressed: () => setState(() => _showManualUrl = !_showManualUrl),
              icon: Icon(_showManualUrl ? Icons.keyboard_arrow_up : Icons.link, size: 16),
              label: Text(_showManualUrl ? 'Hide manual URL' : 'Or paste URL',
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        DropTarget(
          onDragEntered: (_) => setState(() => _isDragging = true),
          onDragExited: (_) => setState(() => _isDragging = false),
          onDragDone: (detail) async {
            setState(() => _isDragging = false);
            if (detail.files.isNotEmpty) {
              final file = detail.files.first;
              final bytes = await file.readAsBytes();
              await _processImageBytes(bytes, file.name);
            }
          },
          child: hasImage
              ? Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isDragging ? Colors.deepOrange : theme.dividerColor,
                      width: _isDragging ? 2.5 : 1.5,
                    ),
                    color: _isDragging
                        ? Colors.deepOrange.withValues(alpha: 0.08)
                        : (theme.brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.grey.shade50),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildPreviewImage(),
                        ),
                      ),
                      if (_isUploadingImage)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 10),
                                Text(
                                  'Uploading to Supabase Storage...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 15),
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 220),
                                child: Text(
                                  _imageFileName ??
                                      (_imageController.text.startsWith('http')
                                          ? 'Online Image Attached'
                                          : 'Image Ready'),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.white.withValues(alpha: 0.9),
                                foregroundColor: Colors.black87,
                              ),
                              onPressed: _pickImageFile,
                              icon: const Icon(Icons.swap_horiz, size: 16),
                              label: const Text('Change'),
                            ),
                            const SizedBox(width: 6),
                            IconButton.filled(
                              style: IconButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.red.withValues(alpha: 0.85),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _imageBytes = null;
                                  _imageFileName = null;
                                  _imageController.clear();
                                });
                              },
                              icon: const Icon(Icons.close, size: 16),
                              tooltip: 'Remove Image',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : InkWell(
                  onTap: _pickImageFile,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isDragging
                          ? Colors.deepOrange.withValues(alpha: 0.12)
                          : (theme.brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.02)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isDragging
                            ? Colors.deepOrange
                            : theme.colorScheme.outline.withValues(alpha: 0.4),
                        width: _isDragging ? 2.5 : 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: _isDragging ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isDragging ? Icons.file_download : Icons.cloud_upload_outlined,
                            size: 46,
                            color: _isDragging ? Colors.deepOrange : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isDragging
                              ? 'Release to upload image!'
                              : 'Drag & Drop product image here',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isDragging ? Colors.deepOrange : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'or click to browse from device (PNG, JPG, WEBP)',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        if (_showManualUrl) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _imageController,
            decoration: const InputDecoration(
              labelText: 'Manual Image URL (Optional)',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.link),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ],
    );
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
                            items: cats.map<DropdownMenuItem<int>>((Category c) {
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
                      const SizedBox(height: 20),

                      // Drag and Drop Image Zone
                      _buildImageDropZone(theme),
                      const SizedBox(height: 20),

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
