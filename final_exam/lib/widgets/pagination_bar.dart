import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';

class PaginationBar extends ConsumerWidget {
  const PaginationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productProvider);
    final theme = Theme.of(context);

    if (state.totalCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items Per Page
          Row(
            children: [
              const Text('Items:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              DropdownButton<int>(
                value: state.pageSize,
                isDense: true,
                underline: const SizedBox(),
                items: [6, 8, 10, 12, 20].map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text('$size', style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(productProvider.notifier).setPageSize(val);
                  }
                },
              ),
            ],
          ),

          // Total counts
          Text(
            '${state.totalCount} items (Page ${state.currentPage} of ${state.totalPages})',
            style: const TextStyle(fontSize: 12),
          ),

          // Navigation buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                visualDensity: VisualDensity.compact,
                onPressed: state.hasPreviousPage
                    ? () => ref.read(productProvider.notifier).previousPage()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                visualDensity: VisualDensity.compact,
                onPressed: state.hasNextPage
                    ? () => ref.read(productProvider.notifier).nextPage()
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
