import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/login_screen.dart';
import '../state/auth_provider.dart';
import '../state/cart_state.dart';

GoRouter createRouter({
  required void Function() onToggleTheme,
  required AppAuthProvider authProvider,
}) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(onToggleTheme: onToggleTheme),
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
          final productId = state.pathParameters['id'] ?? '1';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutConfirmationScreen(),
        redirect: (context, state) {
          if (cartState.items.isEmpty) {
            return '/cart';
          }
          if (!authProvider.isAuthenticated) {
            return '/login?redirect=/checkout';
          }
          return null;
        },
      ),
    ],
  );
}
