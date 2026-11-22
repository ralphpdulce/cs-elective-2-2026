import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';

class PriceSliderFilter extends ConsumerWidget {
  const PriceSliderFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productProvider);
    final theme = Theme.of(context);

    final minBound = state.minPriceBound;
    final maxBound = state.maxPriceBound;
    final currentRange = RangeValues(
      state.currentPriceRange.start.clamp(minBound, maxBound),
      state.currentPriceRange.end.clamp(minBound, maxBound),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    const Text(
                      'Price Range Filter',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  '\$${currentRange.start.toStringAsFixed(0)} - \$${currentRange.end.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: currentRange,
              min: minBound,
              max: maxBound,
              divisions: 20,
              labels: RangeLabels(
                '\$${currentRange.start.toStringAsFixed(0)}',
                '\$${currentRange.end.toStringAsFixed(0)}',
              ),
              onChanged: (values) {
                ref.read(productProvider.notifier).updatePriceRange(values);
              },
            ),
          ],
        ),
      ),
    );
  }
}
