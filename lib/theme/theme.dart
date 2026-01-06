import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // === Hellfire Fantasy Colors ===
  static const Color hellfire = Color(0xFFFF4500);
  static const Color crimson = Color(0xFFDC143C);
  static const Color darkCrimson = Color(0xFF8B0000);
  static const Color blood = Color(0xFF660000);
  static const Color ember = Color(0xFFFF6B35);
  static const Color gold = Color(0xFFFFD700);
  static const Color darkGold = Color(0xFFB8860B);
  static const Color voidPurple = Color(0xFF4A0E4E);
  static const Color deepVoid = Color(0xFF1A0A1A);
  static const Color abyssBlack = Color(0xFF0A0A0A);
  static const Color stoneGray = Color(0xFF3D3D3D);
  static const Color ashGray = Color(0xFF5A5A5A);
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color ice = Color(0xFF87CEEB);
  static const Color poison = Color(0xFF32CD32);
  static const Color mana = Color(0xFF4169E1);

  // === Rarity Colors ===
  static const Color rarityCommon = Color(0xFF9D9D9D);
  static const Color rarityUncommon = Color(0xFF1EFF00);
  static const Color rarityRare = Color(0xFF0070DD);
  static const Color rarityEpic = Color(0xFFA335EE);
  static const Color rarityLegendary = Color(0xFFFF8000);

  // === Class Colors ===
  static const Color fighterColor = Color(0xFFC79C6E);
  static const Color wizardColor = Color(0xFF69CCF0);
  static const Color rogueColor = Color(0xFFFFF569);
  static const Color clericColor = Color(0xFFFFFFFF);

  // === Gradients ===
  static const LinearGradient hellfireGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF6B00),
      Color(0xFFFF4500),
      Color(0xFFDC143C),
      Color(0xFF8B0000),
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient goldTextGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE566),
      Color(0xFFFFD700),
      Color(0xFFB8860B),
      Color(0xFF8B6914),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient voidGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2D1B3D),
      Color(0xFF1A0A1A),
      Color(0xFF0A0A0A),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A3020),
      Color(0xFF2A1A10),
    ],
  );

  // === Text Styles ===
  static TextStyle get titleStyle => GoogleFonts.cinzelDecorative(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: gold,
        shadows: [
          const Shadow(
            color: Colors.black,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
          Shadow(
            color: hellfire.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      );

  static TextStyle get subtitleStyle => GoogleFonts.cinzel(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: boneWhite,
        letterSpacing: 4,
      );

  static TextStyle get bodyStyle => GoogleFonts.sourceCodePro(
        fontSize: 14,
        color: boneWhite,
      );

  static TextStyle get statStyle => GoogleFonts.sourceCodePro(
        fontSize: 12,
        color: ashGray,
      );

  static TextStyle get damageStyle => GoogleFonts.vt323(
        fontSize: 20,
        color: crimson,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get healStyle => GoogleFonts.vt323(
        fontSize: 20,
        color: poison,
        fontWeight: FontWeight.w700,
      );

  // === Theme Data ===
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: abyssBlack,
    colorScheme: const ColorScheme.dark(
      primary: hellfire,
      secondary: gold,
      surface: Color(0xFF1A1A1A),
      error: crimson,
    ),
    textTheme: TextTheme(
      displayLarge: titleStyle,
      displayMedium: subtitleStyle,
      bodyLarge: bodyStyle,
      bodyMedium: statStyle,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.cinzel(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: gold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: stoneGray,
        foregroundColor: boneWhite,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: darkGold, width: 2),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1A1A),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: stoneGray.withValues(alpha: 0.5), width: 1),
      ),
    ),
    iconTheme: const IconThemeData(
      color: gold,
      size: 24,
    ),
  );

  // === Box Decorations ===
  static BoxDecoration get panelDecoration => BoxDecoration(
        color: const Color(0xFF1A1410),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: darkGold.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get runeFrameDecoration => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3D2817),
            Color(0xFF1A0E08),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: gold.withValues(alpha: 0.3),
          width: 1,
        ),
      );

  // === Helper Methods ===
  static Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return rarityCommon;
      case 'uncommon':
        return rarityUncommon;
      case 'rare':
        return rarityRare;
      case 'epic':
        return rarityEpic;
      case 'legendary':
        return rarityLegendary;
      default:
        return rarityCommon;
    }
  }

  static Color getClassColor(String className) {
    switch (className.toLowerCase()) {
      case 'fighter':
        return fighterColor;
      case 'wizard':
        return wizardColor;
      case 'rogue':
        return rogueColor;
      case 'cleric':
        return clericColor;
      default:
        return boneWhite;
    }
  }
}
