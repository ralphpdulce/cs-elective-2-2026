import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBrandColor = Color(0xFF00CEC9);
  static const Color secondaryBrandColor = Color.fromARGB(255, 64, 136, 224);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBrandColor,
      secondary: secondaryBrandColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Color applied globally to all page backgrounds
      scaffoldBackgroundColor: colorScheme.surface,
      
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      
      // Prominent Purple AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
      ),
      
      // Gray cards
      cardTheme: CardThemeData(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        elevation: 2,
      ),
      
      // High-Contrast Teal Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBrandColor,
      secondary: secondaryBrandColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerHigh,
        foregroundColor: colorScheme.primary,
        centerTitle: true,
      ),
      
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }
}