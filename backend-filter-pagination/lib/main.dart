import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'router/app_router.dart';
import 'services/supabase_service.dart';
import 'state/product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseService = SupabaseService();
  final productProvider = ProductProvider(service: supabaseService);

  // Initialize service & load initial paginated products
  await productProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: productProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  late final _router = createRouter(onToggleTheme: _toggleTheme);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Paimon's Bargains - Supabase Store",
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
    );
  }
}
