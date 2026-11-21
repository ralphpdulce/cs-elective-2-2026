import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectPath;

  const LoginScreen({super.key, this.redirectPath});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Sign In controllers
  final _signInFormKey = GlobalKey<FormState>();
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Sign Up controllers
  final _signUpFormKey = GlobalKey<FormState>();
  final _signUpFirstNameController = TextEditingController();
  final _signUpLastNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  bool _obscureSignInPassword = true;
  bool _obscureSignUpPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpFirstNameController.dispose();
    _signUpLastNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  void _onAuthSuccess() {
    if (widget.redirectPath != null && widget.redirectPath!.isNotEmpty && widget.redirectPath != '/login') {
      context.go(widget.redirectPath!);
    } else {
      context.go('/');
    }
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).signInWithEmail(
          email: _signInEmailController.text.trim(),
          password: _signInPasswordController.text,
        );
    if (success && mounted) {
      _onAuthSuccess();
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).signUp(
          email: _signUpEmailController.text.trim(),
          password: _signUpPasswordController.text,
          firstname: _signUpFirstNameController.text.trim(),
          lastname: _signUpLastNameController.text.trim(),
        );
    if (success && mounted) {
      _onAuthSuccess();
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await ref.read(authProvider.notifier).signInWithGoogle();
    if (success && mounted) {
      _onAuthSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Store Logo & Header
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Paimon's Bargains",
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CS Elective 2 • Final Exam E-Commerce App',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error message banner
                      if (auth.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.errorMessage!,
                                  style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Tab selector: Sign In / Create Account
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: isDark ? Colors.grey[300] : Colors.grey[700],
                          tabs: const [
                            Tab(text: 'Sign In'),
                            Tab(text: 'Create Account'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tab Views
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // 1. SIGN IN TAB
                            Form(
                              key: _signInFormKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _signInEmailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email Address',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Enter email';
                                      if (!val.contains('@')) return 'Enter a valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _signInPasswordController,
                                    obscureText: _obscureSignInPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscureSignInPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onPressed: () => setState(() =>
                                            _obscureSignInPassword = !_obscureSignInPassword),
                                      ),
                                    ),
                                    validator: (val) => (val == null || val.length < 6)
                                        ? 'Password must be at least 6 characters'
                                        : null,
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: FilledButton(
                                      onPressed: auth.isLoading ? null : _handleSignIn,
                                      child: auth.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Text('Sign In',
                                              style: TextStyle(
                                                  fontSize: 15, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 2. CREATE ACCOUNT TAB
                            Form(
                              key: _signUpFormKey,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _signUpFirstNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'First Name',
                                              prefixIcon: Icon(Icons.person_outline),
                                            ),
                                            validator: (val) => (val == null || val.trim().isEmpty)
                                                ? 'Required'
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _signUpLastNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Last Name',
                                            ),
                                            validator: (val) => (val == null || val.trim().isEmpty)
                                                ? 'Required'
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _signUpEmailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        labelText: 'Email Address',
                                        prefixIcon: Icon(Icons.email_outlined),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Enter email';
                                        if (!val.contains('@')) return 'Enter a valid email';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _signUpPasswordController,
                                      obscureText: _obscureSignUpPassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureSignUpPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                          onPressed: () => setState(() =>
                                              _obscureSignUpPassword = !_obscureSignUpPassword),
                                        ),
                                      ),
                                      validator: (val) => (val == null || val.length < 6)
                                          ? 'At least 6 characters'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: FilledButton(
                                        onPressed: auth.isLoading ? null : _handleSignUp,
                                        child: auth.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Text('Create Account',
                                              style: TextStyle(
                                                  fontSize: 15, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider "OR"
                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.dividerColor.withValues(alpha: 0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: theme.dividerColor.withValues(alpha: 0.3))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Sign-In button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Text(
                            'G',
                            style: TextStyle(
                              color: Color(0xFF4285F4),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          label: const Text('Continue with Google'),
                          onPressed: auth.isLoading ? null : _handleGoogleSignIn,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quick Evaluation Shortcuts (Customer & Admin)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Quick Evaluation Role Switcher:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                    ),
                                    icon: const Icon(Icons.person, size: 14),
                                    label: const Text('Customer', style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      ref.read(authProvider.notifier).setDemoCustomer();
                                      _onAuthSuccess();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                    ),
                                    icon: const Icon(Icons.admin_panel_settings, size: 14),
                                    label: const Text('Admin', style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      ref.read(authProvider.notifier).setDemoAdmin();
                                      _onAuthSuccess();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
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
