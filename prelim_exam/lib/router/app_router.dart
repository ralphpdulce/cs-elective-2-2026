import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../state/cart_state.dart';

GoRouter createRouter({required void Function() onToggleTheme}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(onToggleTheme: onToggleTheme),
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
          // Route guard: Prevent direct entry if cart is empty
          if (cartState.items.isEmpty) {
            return '/cart';
          }
          return null;
        },
      ),
    ],
  );
}