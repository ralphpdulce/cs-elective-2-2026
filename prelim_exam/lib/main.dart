import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'router/app_router.dart';

void main() {
  runApp(const MyApp());
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
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  late final _router = createRouter(onToggleTheme: _toggleTheme);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Paimon\'s Bargains - Store',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
    );
  }
}