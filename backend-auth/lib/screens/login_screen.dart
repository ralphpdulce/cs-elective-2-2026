import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final String? redirectPath;

  const LoginScreen({super.key, this.redirectPath});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _onSuccess() {
    if (widget.redirectPath != null && widget.redirectPath!.isNotEmpty) {
      context.go(widget.redirectPath!);
    } else {
      context.go('/');
    }
  }

  void _handleProviderSignIn({
    required String providerName,
    required Future<bool> Function() liveCall,
    required VoidCallback demoCall,
  }) async {
    final auth = context.read<AppAuthProvider>();
    final isEnabled = await auth.isProviderEnabled(providerName);

    if (!mounted) return;

    if (!isEnabled) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.vpn_key_off_outlined, color: Colors.orange[800]),
              const SizedBox(width: 8),
              Expanded(
                child: Text('$providerName Not Enabled', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$providerName OAuth has not been toggled ON in your Supabase project dashboard (dfwoygvyymtdwepsjgtz).',
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'To enable live $providerName OAuth, add your Client ID & Secret in Supabase Dashboard -> Authentication -> Providers.',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Would you like to sign in with the instant Demo account instead?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.bolt, size: 16),
              label: Text('Sign in as Demo ($providerName)'),
              onPressed: () {
                Navigator.of(ctx).pop();
                demoCall();
              },
            ),
          ],
        ),
      );
      return;
    }

    final success = await liveCall();
    if (success && mounted) _onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // If already authenticated, redirect
    if (auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onSuccess());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Icon & Header
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_person_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Paimon's Bargains",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in with your preferred third-party account to manage inventory, save favorites, and place orders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Helpful Hint Callout
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: Live OAuth requires the provider toggled ON in your Supabase Dashboard. Use the Instant Demo buttons below to log in immediately without configuration!',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.3,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error Message Banner
                    if (auth.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Theme.of(context).colorScheme.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Loading Indicator
                    if (auth.isLoading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text(
                        'Redirecting to provider authentication...',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      // 1. GitHub Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24292E),
                            foregroundColor: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const _GitHubIcon(),
                          label: const Text(
                            'Continue with GitHub',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _handleProviderSignIn(
                            providerName: 'GitHub',
                            liveCall: () => auth.signInWithGitHub(),
                            demoCall: () {
                              auth.signInDemo(
                                provider: 'GitHub',
                                name: 'Aether (Traveler)',
                                email: 'aether@github.com',
                              );
                              _onSuccess();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. Google Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            foregroundColor: isDark ? Colors.white : Colors.black87,
                            side: BorderSide(
                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const _GoogleIcon(),
                          label: const Text(
                            'Continue with Google',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _handleProviderSignIn(
                            providerName: 'Google',
                            liveCall: () => auth.signInWithGoogle(),
                            demoCall: () {
                              auth.signInDemo(
                                provider: 'Google',
                                name: 'Lumine (Traveler)',
                                email: 'lumine@gmail.com',
                              );
                              _onSuccess();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR FOR TESTING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Instant Demo Login (GitHub)
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton.tonalIcon(
                          icon: const Icon(Icons.bolt, size: 18),
                          label: const Text('Instant Demo Sign In (GitHub)'),
                          onPressed: () {
                            auth.signInDemo(
                              provider: 'GitHub',
                              name: 'Aether (Traveler)',
                              email: 'aether@github.com',
                            );
                            _onSuccess();
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Instant Demo Login (Google)
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton.tonalIcon(
                          icon: const Icon(Icons.bolt, size: 18),
                          label: const Text('Instant Demo Sign In (Google)'),
                          onPressed: () {
                            auth.signInDemo(
                              provider: 'Google',
                              name: 'Lumine (Traveler)',
                              email: 'lumine@gmail.com',
                            );
                            _onSuccess();
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Continue as Guest'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GitHubIcon extends StatelessWidget {
  const _GitHubIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      child: const Icon(Icons.code, color: Colors.white, size: 20),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
      ),
    );
  }
}

