import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'fruits.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FruitListPage(),
      routes: [
        GoRoute(
          path: 'fruit/:slug',
          builder: (context, state) {
            final slug = state.pathParameters['slug'] ?? '';
            return FruitDetailPage(fruitSlug: slug);
          },
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const FruitRouterApp());
}

class FruitRouterApp extends StatelessWidget {
  const FruitRouterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fruits, Fruits, Fruits!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}