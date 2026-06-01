import 'package:flutter/material.dart';

// ─── Color tokens ───────────────────────

class AppColors {
  AppColors._();

  // Backgrounds
  static const bgLight = Color(0xFFFEF7EF); // Ton beige d'origine
  static const bgLight2 = Color(0xFFFBF1E6);
  
  // 🌙 Nouveaux Backgrounds Dark (FIDÈLES AUX IMAGES)
  static const bgDark = Color(0xFF0F1521); // Bleu-noir très sombre du fond
  static const bgDark2 = Color(0xFF141A28); // Légère variante pour gradients

  // Surfaces
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF5EFE8);
  
  // 🌙 Nouvelles Surfaces Dark (FIDÈLES AUX IMAGES)
  static const surfaceDark = Color(0xFF192031); // Bleu-gris sombre des cartes
  static const surfaceMutedDark = Color(0xFF232B3E); // Variante pour bordures/inputs

  // Text
  static const textDark = Color(0xFF1F1A14); // Marron très foncé d'origine
  static const textDim = Color(0x9E1F1A14);   // 62% opacity
  static const textMuted = Color(0x6B1F1A14); // 42% opacity
  
  // 🌙 Nouveaux Textes Dark (FIDÈLES AUX IMAGES)
  static const textLight = Color(0xFFF0F4F8); // Blanc bleuté très clair
  static const textDimLight = Color(0x9EF0F4F8); // 62% opacity
  static const textMutedLight = Color(0x6BF0F4F8); // 42% opacity

  // Borders
  static const border = Color(0x141F1A14); // 8% opacity d'origine
  
  // 🌙 Nouvelles Bordures Dark (FIDÈLES AUX IMAGES)
  static const borderDark = Color(0x14F0F4F8); // 8% opacity du texte clair

  // Brand
  static const pink = Color(0xFFF5A3B5); // Rose clair d'origine
  static const pinkDeep = Color(0xFFE988A0); // Rose profond d'origine

  // Section colors (Couleurs vives conservées)
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
  static const navBg = Color(0xC7FFF7EB); // Beige d'origine
  
  // 🌙 Nouveau Nav Bg Dark (FIDÈLE AUX IMAGES)
  static const navBgDark = Color(0xC7192031); // Même bleu que les cartes
}

// ─── Theme ────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // Thème Clair d'origine
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
      textTheme: _getTextTheme(AppColors.textDark, AppColors.textDim, AppColors.textMuted),
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
          fontFamily: 'Quicksand', fontSize: 18,
          fontWeight: FontWeight.w600, color: AppColors.textDark,
        ),
      ),
      extensions: const [AppThemeExtension.light],
    );
  }

  // 🌙 NOUVEAU Thème Sombre (FIDÈLE AUX IMAGES)
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Quicksand',
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.pinkDeep,
        secondary: AppColors.pink,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textLight,
      ),
      textTheme: _getTextTheme(AppColors.textLight, AppColors.textDimLight, AppColors.textMutedLight),
      cardTheme: const CardTheme(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textLight),
        titleTextStyle: TextStyle(
          fontFamily: 'Quicksand', fontSize: 18,
          fontWeight: FontWeight.w600, color: AppColors.textLight,
        ),
      ),
      extensions: const [AppThemeExtension.dark],
    );
  }

  static TextTheme _getTextTheme(Color text, Color dim, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Playwrite', fontSize: 68, fontWeight: FontWeight.w400, color: text, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: 'Playwrite', fontSize: 38, fontWeight: FontWeight.w600, color: text, letterSpacing: -0.5),
      displaySmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: text),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: text),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: text),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: text),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text),
      titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: dim, letterSpacing: 0.5),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: text),
      bodyMedium: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: dim),
      bodySmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: muted),
      labelLarge: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, letterSpacing: 0.2),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2, color: dim),
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
    required this.bg, required this.bgGradientEnd,
    required this.surface, required this.surfaceMuted,
    required this.border, required this.text,
    required this.textDim, required this.textMuted,
    required this.navBg, required this.pink, required this.pinkDeep,
  });

  static const light = AppThemeExtension(
    bg: AppColors.bgLight, bgGradientEnd: AppColors.bgLight2,
    surface: AppColors.surfaceLight, surfaceMuted: Color(0xFFF5EFE8),
    border: AppColors.border, text: AppColors.textDark,
    textDim: AppColors.textDim, textMuted: AppColors.textMuted,
    navBg: AppColors.navBg, pink: AppColors.pink, pinkDeep: AppColors.pinkDeep,
  );

  // 🌙 Configuration Dark pour l'extension (FIDÈLE AUX IMAGES)
  static const dark = AppThemeExtension(
    bg: AppColors.bgDark, bgGradientEnd: AppColors.bgDark2,
    surface: AppColors.surfaceDark, surfaceMuted: AppColors.surfaceMutedDark,
    border: AppColors.borderDark, text: AppColors.textLight,
    textDim: AppColors.textDimLight, textMuted: AppColors.textMutedLight,
    navBg: AppColors.navBgDark, pink: AppColors.pink, pinkDeep: AppColors.pinkDeep,
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

extension ThemeX on BuildContext {
  AppThemeExtension get t => Theme.of(this).extension<AppThemeExtension>()!;
  TextTheme get tt => Theme.of(this).textTheme;
}