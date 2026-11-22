import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class UserProfileDialog extends ConsumerWidget {
  const UserProfileDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const UserProfileDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            auth.isAdmin ? Icons.admin_panel_settings : Icons.account_circle,
            color: auth.isAdmin ? Colors.deepOrange : theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: auth.isAdmin ? Colors.deepOrange : theme.colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text(auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U'),
            ),
            title: Text(auth.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(auth.email),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assigned Role:', style: TextStyle(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: auth.isAdmin ? Colors.deepOrange.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: auth.isAdmin ? Colors.deepOrange : Colors.blue,
                  ),
                ),
                child: Text(
                  auth.isAdmin ? 'ADMINISTRATOR' : 'CUSTOMER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: auth.isAdmin ? Colors.deepOrange : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            auth.isAdmin
                ? '• Full access to manage product catalog (add, edit, delete)\n• Full access to view all orders and update status'
                : '• Browse store catalog\n• Build and manage shopping cart\n• Place orders and view order history',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.tonal(
          style: FilledButton.styleFrom(foregroundColor: theme.colorScheme.error),
          onPressed: () async {
            Navigator.of(context).pop();
            await ref.read(authProvider.notifier).signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}
