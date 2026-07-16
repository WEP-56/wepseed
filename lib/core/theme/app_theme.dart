import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography: Inter for product UI + reading chrome.
/// CJK falls back to system fonts (PingFang / Noto / YaHei) so Latin stays sharp.
abstract final class AppTheme {
  static const _cjkFallback = <String>[
    'PingFang SC',
    'Hiragino Sans GB',
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'Microsoft YaHei',
    'sans-serif',
  ];

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        surface: AppColors.canvas,
        onSurface: AppColors.textPrimaryLight,
        primary: AppColors.accent,
        onPrimary: AppColors.white,
        secondary: AppColors.textSecondaryLight,
        outline: AppColors.borderLight,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.black.withValues(alpha: 0.04),
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, dark: false),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: _inter(
          17,
          FontWeight.w600,
          color: AppColors.textPrimaryLight,
          letterSpacing: -0.3,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 0.5,
        space: 0.5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.wash,
        selectedColor: AppColors.black,
        labelStyle: _inter(13, FontWeight.w500),
        secondaryLabelStyle: _inter(13, FontWeight.w500, color: AppColors.white),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.wash,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        hintStyle: _inter(14, FontWeight.w400, color: AppColors.textTertiaryLight),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.ink,
        onSurface: AppColors.textPrimaryDark,
        primary: AppColors.accentOnDark,
        onPrimary: AppColors.black,
        secondary: AppColors.textSecondaryDark,
        outline: AppColors.borderDark,
      ),
      scaffoldBackgroundColor: AppColors.ink,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.white.withValues(alpha: 0.06),
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, dark: true),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: _inter(
          17,
          FontWeight.w600,
          color: AppColors.textPrimaryDark,
          letterSpacing: -0.3,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 0.5,
        space: 0.5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.inkCard,
        selectedColor: AppColors.white,
        labelStyle: _inter(13, FontWeight.w500, color: AppColors.textPrimaryDark),
        secondaryLabelStyle: _inter(13, FontWeight.w500, color: AppColors.black),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        hintStyle: _inter(14, FontWeight.w400, color: AppColors.textTertiaryDark),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, {required bool dark}) {
    final primary = dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return base.copyWith(
      // Page titles — X/Ins weight, not ultra-black poster type
      displayLarge: _inter(32, FontWeight.w700, color: primary, letterSpacing: -1.0, height: 1.12),
      displayMedium: _inter(26, FontWeight.w700, color: primary, letterSpacing: -0.7, height: 1.15),
      headlineLarge: _inter(22, FontWeight.w600, color: primary, letterSpacing: -0.4, height: 1.22),
      headlineMedium: _inter(18, FontWeight.w600, color: primary, letterSpacing: -0.3, height: 1.28),
      titleLarge: _inter(17, FontWeight.w600, color: primary, letterSpacing: -0.25),
      titleMedium: _inter(15, FontWeight.w600, color: primary, letterSpacing: -0.15),
      titleSmall: _inter(13, FontWeight.w600, color: primary, letterSpacing: -0.1),
      // Reading body — open leading, regular weight
      bodyLarge: _inter(16, FontWeight.w400, color: primary, height: 1.65, letterSpacing: 0.05),
      bodyMedium: _inter(14, FontWeight.w400, color: secondary, height: 1.5),
      bodySmall: _inter(12, FontWeight.w400, color: secondary, height: 1.4),
      labelLarge: _inter(13, FontWeight.w600, color: primary, letterSpacing: -0.05),
      labelMedium: _inter(12, FontWeight.w500, color: secondary),
      labelSmall: _inter(11, FontWeight.w500, color: secondary, letterSpacing: 0.1),
    );
  }

  static TextStyle _inter(
    double size,
    FontWeight weight, {
    Color? color,
    double height = 1.3,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: _cjkFallback);
  }
}
