import 'package:flutter/material.dart';

// ─── Color tokens (from Claude Design) ────────────────────────────────────────

class AppColors {
  AppColors._();

  // Backgrounds
  static const bgLight = Color(0xFFFEF7EF);
  static const bgLight2 = Color(0xFFFBF1E6);

  // Surfaces
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF5EFE8);

  // Text
  static const textDark = Color(0xFF1F1A14);
  static const textDim = Color(0x9E1F1A14);   // 62% opacity
  static const textMuted = Color(0x6B1F1A14); // 42% opacity

  // Borders
  static const border = Color(0x141F1A14); // 8% opacity

  // Brand
  static const pink = Color(0xFFF5A3B5);
  static const pinkDeep = Color(0xFFE988A0);

  // Section colors
  static const selles = Color(0xFFFF6B6B);
  static const sellesSoft = Color(0xFFFFD1D1);
  static const sellesDeep = Color(0xFFC44848);

  static const poids = Color(0xFFBB86FC);
  static const poidsSoft = Color(0xFFE4D2FF);
  static const poidsDeep = Color(0xFF7E54C0);

  static const meds = Color(0xFFFFB562);
  static const medsSoft = Color(0xFFFFE2C0);
  static const medsDeep = Color(0xFFC7873B);

  static const rdv = Color(0xFF6BCB77);
  static const rdvSoft = Color(0xFFCFEFD4);
  static const rdvDeep = Color(0xFF3F8E48);

  static const analyses = Color(0xFF4D96FF);
  static const analysesSoft = Color(0xFFCFE2FF);
  static const analysesDeep = Color(0xFF2A5DAD);

  // Nav background
  static const navBg = Color(0xC7FFF7EB);
}

// ─── Theme ────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Quicksand',
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.pinkDeep,
        secondary: AppColors.pink,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textDark,
      ),
      textTheme: _textTheme,
      cardTheme: const CardTheme(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      extensions: const [AppThemeExtension.light],
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      // TON TITRE "POOPY" (Playwrite)
      displayLarge: const TextStyle(
        fontFamily: 'Playwrite', 
        fontSize: 68, 
        fontWeight: FontWeight.w400,
        color: AppColors.textDark, 
        letterSpacing: -0.5,
      ),
      // TES TITRES DE PAGES (Playwrite ou Quicksand, selon tes goûts)
      displayMedium: const TextStyle(
        fontFamily: 'Playwrite',
        fontSize: 38, 
        fontWeight: FontWeight.w600,
        color: AppColors.textDark, 
        letterSpacing: -0.5,
      ),
      // TOUT LE RESTE PASSE EN QUICKSAND AUTOMATIQUEMENT
      displaySmall: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppColors.textDark),
      headlineLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textDark),
      headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textDark),
      titleLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
      titleMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
      titleSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 0.5),
      bodyLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark),
      bodyMedium: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textDim),
      bodySmall: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
      labelLarge: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, letterSpacing: 0.2),
      labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.textDim),
    );
  }
}

// ─── Theme extension for custom tokens ────────────────────────────────────────

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color bg;
  final Color bgGradientEnd;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color text;
  final Color textDim;
  final Color textMuted;
  final Color navBg;
  final Color pink;
  final Color pinkDeep;

  const AppThemeExtension({
    required this.bg,
    required this.bgGradientEnd,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.text,
    required this.textDim,
    required this.textMuted,
    required this.navBg,
    required this.pink,
    required this.pinkDeep,
  });

  static const light = AppThemeExtension(
    bg: AppColors.bgLight,
    bgGradientEnd: AppColors.bgLight2,
    surface: AppColors.surfaceLight,
    surfaceMuted: Color(0xFFF5EFE8),
    border: AppColors.border,
    text: AppColors.textDark,
    textDim: AppColors.textDim,
    textMuted: AppColors.textMuted,
    navBg: AppColors.navBg,
    pink: AppColors.pink,
    pinkDeep: AppColors.pinkDeep,
  );

  @override
  AppThemeExtension copyWith({
    Color? bg, Color? bgGradientEnd, Color? surface, Color? surfaceMuted,
    Color? border, Color? text, Color? textDim, Color? textMuted,
    Color? navBg, Color? pink, Color? pinkDeep,
  }) {
    return AppThemeExtension(
      bg: bg ?? this.bg, bgGradientEnd: bgGradientEnd ?? this.bgGradientEnd,
      surface: surface ?? this.surface, surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border, text: text ?? this.text,
      textDim: textDim ?? this.textDim, textMuted: textMuted ?? this.textMuted,
      navBg: navBg ?? this.navBg, pink: pink ?? this.pink, pinkDeep: pinkDeep ?? this.pinkDeep,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      bg: Color.lerp(bg, other.bg, t)!,
      bgGradientEnd: Color.lerp(bgGradientEnd, other.bgGradientEnd, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      navBg: Color.lerp(navBg, other.navBg, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      pinkDeep: Color.lerp(pinkDeep, other.pinkDeep, t)!,
    );
  }
}

// Helper extension for easy access
extension ThemeX on BuildContext {
  AppThemeExtension get t => Theme.of(this).extension<AppThemeExtension>()!;
  TextTheme get tt => Theme.of(this).textTheme;
}
