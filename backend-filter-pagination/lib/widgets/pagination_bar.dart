import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/product_provider.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalPages = provider.totalPages;
    final currentPage = provider.currentPage;

    if (provider.totalCount == 0 && !provider.isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Items info & page size toggle (6 vs 8)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${provider.products.isEmpty ? 0 : (currentPage - 1) * provider.pageSize + 1}-'
                '${((currentPage - 1) * provider.pageSize + provider.products.length)} '
                'of ${provider.totalCount} products',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  const Text('Per page: ', style: TextStyle(fontSize: 12)),
                  ChoiceChip(
                    label: const Text('6', style: TextStyle(fontSize: 11)),
                    selected: provider.pageSize == 6,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => provider.setPageSize(6),
                  ),
                  const SizedBox(width: 4),
                  ChoiceChip(
                    label: const Text('8', style: TextStyle(fontSize: 11)),
                    selected: provider.pageSize == 8,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => provider.setPageSize(8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: provider.hasPreviousPage
                    ? () => provider.previousPage()
                    : null,
                tooltip: 'Previous Page',
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 12),
              // Page indicator pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(totalPages, (index) {
                    final pageNum = index + 1;
                    final isSelected = pageNum == currentPage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => provider.setPage(pageNum),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$pageNum',
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed:
                    provider.hasNextPage ? () => provider.nextPage() : null,
                tooltip: 'Next Page',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
