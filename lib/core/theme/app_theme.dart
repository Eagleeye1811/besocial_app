import 'package:flutter/material.dart';

import 'theme_constants.dart';

/// Application theme.
///
/// The website (`../besocial/frontend`) ships a **light-only** palette — its
/// `tokens.js` has no dark variants, there is no `darkMode` toggle, no
/// `prefers-color-scheme` handling, and no `data-theme` attribute. To stay
/// faithful to that branding we expose `light` only. A dark theme would have
/// to be designed first on the web side; do not invent one here.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final ColorScheme colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.accent,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.accentSoft,
      onPrimaryContainer: AppColors.accentInk,
      secondary: AppColors.ink2,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.surface2,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.good,
      onTertiary: AppColors.white,
      error: Color(0xFFDC2626),
      onError: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.ink,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surface2,
      surfaceContainerHighest: AppColors.surface2,
      onSurfaceVariant: AppColors.ink2,
      outline: AppColors.line,
      outlineVariant: AppColors.line2,
      shadow: AppColors.ink,
      scrim: AppColors.ink,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.surface,
      inversePrimary: AppColors.accentSoft,
    );

    final TextTheme textTheme = _buildTextTheme(AppColors.ink);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      canvasColor: AppColors.surface,
      dividerColor: AppColors.line,
      fontFamily: AppFonts.ui,
      fontFamilyFallback: AppFonts.uiFallback,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.display,
          fontFamilyFallback: AppFonts.displayFallback,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: AppShadows.ring,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.line,
          disabledForegroundColor: AppColors.ink4,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFonts.ui,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentInk,
          textStyle: const TextStyle(
            fontFamily: AppFonts.ui,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: AppShadows.ring,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFonts.ui,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: TextStyle(color: AppColors.ink3),
        labelStyle: TextStyle(color: AppColors.ink2),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: AppShadows.ring,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: AppShadows.ring,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.ink2, size: 20),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color onSurface) {
    const String display = AppFonts.display;
    const String ui = AppFonts.ui;
    return TextTheme(
      displayLarge: TextStyle(fontFamily: display, fontFamilyFallback: AppFonts.displayFallback, fontSize: 48, fontWeight: FontWeight.w700, color: onSurface, height: 1.1, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: display, fontFamilyFallback: AppFonts.displayFallback, fontSize: 36, fontWeight: FontWeight.w700, color: onSurface, height: 1.15, letterSpacing: -0.4),
      displaySmall: TextStyle(fontFamily: display, fontFamilyFallback: AppFonts.displayFallback, fontSize: 28, fontWeight: FontWeight.w700, color: onSurface, height: 1.2, letterSpacing: -0.3),
      headlineLarge: TextStyle(fontFamily: display, fontFamilyFallback: AppFonts.displayFallback, fontSize: 24, fontWeight: FontWeight.w600, color: onSurface, height: 1.25),
      headlineMedium: TextStyle(fontFamily: display, fontFamilyFallback: AppFonts.displayFallback, fontSize: 20, fontWeight: FontWeight.w600, color: onSurface, height: 1.3),
      headlineSmall: TextStyle(fontFamily: display, fontFamilyFallback: AppFonts.displayFallback, fontSize: 18, fontWeight: FontWeight.w600, color: onSurface, height: 1.35),
      titleLarge: TextStyle(fontFamily: ui, fontFamilyFallback: AppFonts.uiFallback, fontSize: 16, fontWeight: FontWeight.w600, color: onSurface, height: 1.4),
      titleMedium: TextStyle(fontFamily: ui, fontFamilyFallback: AppFonts.uiFallback, fontSize: 15, fontWeight: FontWeight.w600, color: onSurface, height: 1.45),
      titleSmall: TextStyle(fontFamily: ui, fontFamilyFallback: AppFonts.uiFallback, fontSize: 14, fontWeight: FontWeight.w600, color: onSurface, height: 1.45),
      bodyLarge: TextStyle(fontFamily: ui, fontFamilyFallback: AppFonts.uiFallback, fontSize: 16, fontWeight: FontWeight.w400, color: onSurface, height: 1.5),
      bodyMedium: TextStyle(fontFamily: ui, fontFamilyFallback: AppFonts.uiFallback, fontSize: 14, fontWeight: FontWeight.w400, color: onSurface, height: 1.5),
      bodySmall: TextStyle(fontFamily: ui, fontFamilyFallback: AppFonts.uiFallback, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.ink3, height: 1.5),
      labelLarge: TextStyle(fontFamily: ui, fontFamilyFallback: AppFonts.uiFallback, fontSize: 14, fontWeight: FontWeight.w600, color: onSurface, height: 1.4),
      labelMedium: TextStyle(fontFamily: ui, fontFamilyFallback: AppFonts.uiFallback, fontSize: 12, fontWeight: FontWeight.w600, color: onSurface, height: 1.4),
      labelSmall: TextStyle(fontFamily: ui, fontFamilyFallback: AppFonts.uiFallback, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink3, height: 1.4, letterSpacing: 0.4),
    );
  }
}
