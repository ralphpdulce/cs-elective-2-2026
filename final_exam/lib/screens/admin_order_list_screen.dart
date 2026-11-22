import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class AdminOrderListScreen extends ConsumerWidget {
  const AdminOrderListScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final ordersAsync = ref.watch(adminOrdersProvider);
    final theme = Theme.of(context);

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(child: Text('Only administrators can access this view.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Order Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
            onPressed: () => ref.read(adminOrdersProvider.notifier).fetchAllOrders(),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Fetching customer orders...'),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 12),
                Text('Failed to load orders: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.read(adminOrdersProvider.notifier).fetchAllOrders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No orders placed yet across all users',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: RefreshIndicator(
                onRefresh: () => ref.read(adminOrdersProvider.notifier).fetchAllOrders(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final dateStr = order.createdAt != null
                        ? DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt!.toLocal())
                        : 'Recent';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ExpansionTile(
                        initiallyExpanded: index == 0,
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrange.withValues(alpha: 0.15),
                          child: const Icon(Icons.receipt, color: Colors.deepOrange),
                        ),
                        title: Row(
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${order.customerName ?? order.customerEmail ?? "Customer"})',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const Spacer(),
                            // Status Dropdown to update status
                            DropdownButton<String>(
                              value: ['done', 'processing', 'completed', 'cancelled']
                                      .contains(order.status.toLowerCase())
                                  ? order.status.toLowerCase()
                                  : 'done',
                              underline: const SizedBox(),
                              isDense: true,
                              items: ['done', 'processing', 'completed', 'cancelled'].map((st) {
                                return DropdownMenuItem(
                                  value: st,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(st).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      st.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(st),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newStatus) async {
                                if (newStatus != null && newStatus != order.status) {
                                  try {
                                    await ref
                                        .read(adminOrdersProvider.notifier)
                                        .updateStatus(order.id, newStatus);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Updated Order #${order.id} status to $newStatus'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to update status: $e'),
                                          backgroundColor: theme.colorScheme.error,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '$dateStr • Total: \$${order.total.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Customer ID: ${order.userId}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    Text('Customer Email: ${order.customerEmail ?? "N/A"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Ordered Items (Price & Name Snapshot):',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                ...order.items.map((OrderItem item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text('${item.quantity}x ${item.productName}'),
                                          ),
                                          Text(
                                            '@ \$${item.unitPrice.toStringAsFixed(2)} = \$${item.subtotal.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Revenue:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      '\$${order.total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
