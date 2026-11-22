import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'supabase_provider.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getCategories();
});
