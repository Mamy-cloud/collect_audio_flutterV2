import 'package:flutter/material.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  static const background  = Color(0xFF000000);
  static const surface     = Color(0xFF111111);
  static const inputFill   = Color(0xFF1C1C1C);
  static const inputBorder = Colors.white;
  static const textPrimary = Colors.white;
  static const textMuted   = Color(0xFF9E9E9E);
  static const buttonBg    = Colors.white;
}

// ── Typographie ───────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static const headline = TextStyle(
    fontSize:      36,
    fontWeight:    FontWeight.w800,
    color:         AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const label = TextStyle(
    fontSize:      13,
    fontWeight:    FontWeight.w500,
    color:         AppColors.textMuted,
    letterSpacing: 0.4,
  );

  static const input = TextStyle(
    fontSize:   15,
    color:      AppColors.textPrimary,
    fontWeight: FontWeight.w400,
  );

  static const button = TextStyle(
    fontSize:      15,
    fontWeight:    FontWeight.w700,
    color:         Color(0xFF000000),
    letterSpacing: 0.3,
  );

  static const guestLink = TextStyle(
    fontSize:        13,
    color:           AppColors.textMuted,
    decoration:      TextDecoration.underline,
    decorationColor: AppColors.textMuted,
  );
}

// ── Décoration input ──────────────────────────────────────────────────────────

class AppInputDecoration {
  AppInputDecoration._();

  static InputDecoration of(String label, {String? hint}) => InputDecoration(
    labelText:      label,
    hintText:       hint,
    labelStyle:     AppTextStyles.label,
    hintStyle:      AppTextStyles.label.copyWith(color: const Color(0xFF555555)),
    filled:         true,
    fillColor:      AppColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color: AppColors.inputBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color: Color(0xFF333333), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color: AppColors.inputBorder, width: 1.5),
    ),
  );
}

// ── Style bouton principal ────────────────────────────────────────────────────

class AppButtonStyle {
  AppButtonStyle._();

  static final primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonBg,
    foregroundColor: const Color(0xFF000000),
    elevation:       0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    minimumSize: const Size(double.infinity, 52),
    textStyle:   AppTextStyles.button,
  );
}

// ── ThemeData global ──────────────────────────────────────────────────────────

ThemeData buildAppTheme() => ThemeData(
  useMaterial3:            true,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    surface: AppColors.surface,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled:     true,
    fillColor:  AppColors.inputFill,
    labelStyle: AppTextStyles.label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color: AppColors.inputBorder),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: AppButtonStyle.primary,
  ),
);
