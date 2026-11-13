import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';

class UserProfileDialog extends StatelessWidget {
  const UserProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const UserProfileDialog(),
    );
  }

  Widget _buildAvatar(BuildContext context, AppAuthProvider auth) {
    final avatarUrl = auth.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('assets/')) {
        return CircleAvatar(
          radius: 36,
          backgroundImage: AssetImage(avatarUrl),
        );
      }
      return CircleAvatar(
        radius: 36,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, _) {},
      );
    }
    return CircleAvatar(
      radius: 36,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U',
        style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(context, auth),
          const SizedBox(height: 16),
          Text(
            auth.displayName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (auth.email != null) ...[
            const SizedBox(height: 4),
            Text(
              auth.email!,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  auth.providerName.toLowerCase().contains('git')
                      ? Icons.code
                      : Icons.verified_user,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'Connected via ${auth.providerName}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.tonalIcon(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          icon: const Icon(Icons.logout, size: 16),
          label: const Text('Sign Out'),
          onPressed: () async {
            Navigator.of(context).pop();
            await auth.signOut();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Successfully signed out.')),
              );
            }
          },
        ),
      ],
    );
  }
}
