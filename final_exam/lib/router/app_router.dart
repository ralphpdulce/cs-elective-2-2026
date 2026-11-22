import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/admin_order_list_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_form_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AuthState>(ref.read(authProvider));
  ref.listen<AuthState>(authProvider, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. Auth Gate: signed-out users must be redirected to /login
      if (!auth.isAuthenticated) {
        if (isLoggingIn) return null;
        final target = state.matchedLocation;
        return '/login?redirect=${Uri.encodeComponent(target)}';
      }

      // 2. If signed in and on /login, redirect to Home
      if (isLoggingIn) {
        final redirectParam = state.uri.queryParameters['redirect'];
        if (redirectParam != null && redirectParam.isNotEmpty && redirectParam != '/login') {
          return redirectParam;
        }
        return '/';
      }

      // 3. Admin-only Route Guard
      if (state.matchedLocation.startsWith('/admin')) {
        if (!auth.isAdmin) {
          return '/';
        }
      }

      // 4. Customer-only Route Guard (Admin cannot access customer cart / checkout)
      if (auth.isAdmin && (state.matchedLocation == '/cart' || state.matchedLocation == '/orders')) {
        return '/admin/orders';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return LoginScreen(redirectPath: redirect);
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout-confirmation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CheckoutConfirmationScreen(
            orderId: extra?['orderId'] as int? ?? 0,
            total: (extra?['total'] as num?)?.toDouble() ?? 0.0,
          );
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/admin/products/add',
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/admin/products/edit/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return ProductFormScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrderListScreen(),
      ),
    ],
  );
});
