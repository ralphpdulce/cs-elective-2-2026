import 'package:flutter/material.dart';
import '../models/product.dart';

class AdminProductDialog extends StatefulWidget {
  final Product? product; // Null if creating new

  const AdminProductDialog({super.key, this.product});

  static Future<Product?> show(BuildContext context, {Product? product}) {
    return showDialog<Product>(
      context: context,
      builder: (context) => AdminProductDialog(product: product),
    );
  }

  @override
  State<AdminProductDialog> createState() => _AdminProductDialogState();
}

class _AdminProductDialogState extends State<AdminProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _ratingController;
  late final TextEditingController _badgeController;
  late final TextEditingController _descController;

  String _selectedCategory = 'Pyro';
  final List<String> _categories = [
    'Pyro',
    'Hydro',
    'Anemo',
    'Electro',
    'Dendro',
    'Cryo',
    'Geo',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _imageController = TextEditingController(text: p?.imageUrl ?? 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/zhongli/card.png');
    _ratingController = TextEditingController(text: p != null ? p.rating.toString() : '4.5');
    _badgeController = TextEditingController(text: p?.badge ?? '');
    _descController = TextEditingController(text: p?.description ?? '');

    if (p != null && _categories.contains(p.category)) {
      _selectedCategory = p.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _ratingController.dispose();
    _badgeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final rating = double.tryParse(_ratingController.text.trim()) ?? 4.5;
    final badgeText = _badgeController.text.trim();

    final result = Product(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      price: price,
      category: _selectedCategory,
      imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
      rating: rating,
      badge: badgeText.isEmpty ? null : badgeText,
      description: _descController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid price greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image Asset or URL',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 12),
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
                        final parsed = double.tryParse(val ?? '');
                        if (parsed == null || parsed < 0 || parsed > 5) {
                          return 'Between 0 and 5';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _badgeController,
                      decoration: const InputDecoration(
                        labelText: 'Badge (Optional)',
                        hintText: 'e.g. SALE 15%',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save Changes' : 'Create Product'),
        ),
      ],
    );
  }
}
