import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xff0c0e13);
  static const surface = Color(0xff14171f);
  static const surfaceHigh = Color(0xff1b1f2a);
  static const border = Color(0xff242938);
  static const accent = Color(0xffef3346);
  static const accentSoft = Color(0x1fef3346);
  static const text = Color(0xfff2f4f8);
  static const textMuted = Color(0xff9aa1b2);
  static const textFaint = Color(0xff6b7385);
  static const success = Color(0xff3ddc97);
  static const warning = Color(0xffffb454);
}

class AppText {
  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    letterSpacing: -.2,
  );
  static const heading = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
  static const body = TextStyle(
    fontSize: 13,
    height: 1.4,
    color: AppColors.text,
  );
  static const bodyStrong = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
  static const muted = TextStyle(
    fontSize: 12.5,
    height: 1.4,
    color: AppColors.textMuted,
  );
  static const caption = TextStyle(
    fontSize: 11,
    height: 1.35,
    color: AppColors.textFaint,
  );
  static const label = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: .9,
    color: AppColors.textFaint,
  );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.accent,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    outline: AppColors.border,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 52,
      titleTextStyle: AppText.heading,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHigh,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textFaint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 62,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.accentSoft,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? AppColors.text
              : AppColors.textFaint,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.textFaint,
        ),
      ),
    ),
  );
}
