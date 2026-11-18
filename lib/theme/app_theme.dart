import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  AppColors
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppColors {
  AppColors._();

  // â”€â”€ Backgrounds â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const background   = Color(0xFF0A0A0A);
  static const surface      = Color(0xFF141414);
  static const surfaceAlt   = Color(0xFF1E1E1E);
  static const surfaceHigh  = Color(0xFF262626);
  static const surfaceCard  = Color(0xFF191919);    // card base
  static const surfaceModal = Color(0xFF1C1C1E);    // bottom-sheets / dialogs

  // â”€â”€ Divider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const divider = Color(0xFF2A2A2A);

  // â”€â”€ Brand â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const primary      = Color(0xFFE50914);
  static const primaryDark  = Color(0xFFB2070F);
  static const primaryLight = Color(0xFFFF3D47);
  static const accent       = Color(0xFFFFB400);
  static const accentDark   = Color(0xFFCC8F00);

  // â”€â”€ Premium / Gold â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const gold         = Color(0xFFFFD700);
  static const goldDark     = Color(0xFFB8860B);
  static const goldLight    = Color(0xFFFFF1A0);

  // â”€â”€ Text â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB1B1B1);
  static const textTertiary  = Color(0xFF666666);
  static const textDisabled  = Color(0xFF3D3D3D);

  // â”€â”€ Overlays â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const overlayBlack       = Color(0x80000000);
  static const overlayBlackLight  = Color(0x40000000);
  static const overlayBlackHeavy  = Color(0xCC000000);

  // â”€â”€ Gradient stops â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const gradientRedStart  = Color(0xFFE50914);
  static const gradientRedEnd    = Color(0xFF7A0007);
  static const gradientGoldStart = Color(0xFFFFD700);
  static const gradientGoldEnd   = Color(0xFFA0640A);
  static const gradientDarkStart = Color(0xFF1E1E1E);
  static const gradientDarkEnd   = Color(0xFF0A0A0A);

  // â”€â”€ Glow â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const glowRed    = Color(0x66E50914);
  static const glowGold   = Color(0x66FFD700);
  static const glowWhite  = Color(0x1AFFFFFF);
  static const glowAccent = Color(0x66FFB400);

  // -- Glass / Card borders ------------------------------------
  static const glassSurface = Color(0x1AFFFFFF);   // frosted glass overlay
  static const cardBorder   = Color(0x26FFFFFF);   // subtle card rim
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  AppGradients
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppGradients {
  AppGradients._();

  /// Full-bleed hero â€” dark top â†’ red-tinted bottom
  static const heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end:   Alignment.bottomCenter,
    colors: [
      Color(0xCC000000),
      Color(0x00000000),
      Color(0xFFE50914),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Subtle dark card surface with a faint red shimmer on the leading edge
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [
      AppColors.surfaceCard,
      AppColors.surfaceAlt,
    ],
  );

  /// Premium / VIP gold shimmer
  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [
      AppColors.gold,
      AppColors.accentDark,
      AppColors.goldDark,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Bottom nav / persistent bar fade
  static const navGradient = LinearGradient(
    begin: Alignment.topCenter,
    end:   Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0xFF0A0A0A),
    ],
  );

  /// Radial glow â€” place behind featured artwork
  static const heroRadialGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 0.9,
    colors: [
      Color(0x33E50914),
      Color(0x00000000),
    ],
  );
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  AppTextStyles
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppTextStyles {
  AppTextStyles._();

  /// 48 px â€” Large hero headline (e.g. show title on detail screen)
  static TextStyle get heroTitle => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
        height: 1.0,
      );

  /// 22 px â€” Section headers inside lists / rows
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  /// 14 px â€” Card title (title below thumbnail)
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  /// 11 px â€” Badges, tags, pills (ALL CAPS)
  static TextStyle get badge => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.8,
      );

  /// 12 px â€” Supporting captions, metadata, durations
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      );

  /// 16 px â€” Body / description copy
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  /// 13 px â€” Subtitle / meta line inside cards
  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      );
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  AppShadows
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppShadows {
  AppShadows._();

  /// Subtle elevation for standard cards
  static const List<BoxShadow> card = [
    BoxShadow(
      color:       Color(0x33000000),
      blurRadius:  12,
      spreadRadius: 0,
      offset:      Offset(0, 4),
    ),
    BoxShadow(
      color:       Color(0x14000000),
      blurRadius:  2,
      spreadRadius: 0,
      offset:      Offset(0, 1),
    ),
  ];

  /// Red glow â€” featured artwork, play button, primary CTA
  static const List<BoxShadow> glow = [
    BoxShadow(
      color:       AppColors.glowRed,
      blurRadius:  32,
      spreadRadius: -4,
      offset:      Offset(0, 8),
    ),
    BoxShadow(
      color:       Color(0x33E50914),
      blurRadius:  64,
      spreadRadius: -8,
      offset:      Offset(0, 16),
    ),
  ];

  /// Gold glow â€” premium / VIP badges and CTAs
  static const List<BoxShadow> premium = [
    BoxShadow(
      color:       AppColors.glowGold,
      blurRadius:  24,
      spreadRadius: -4,
      offset:      Offset(0, 6),
    ),
    BoxShadow(
      color:       Color(0x33FFD700),
      blurRadius:  48,
      spreadRadius: -8,
      offset:      Offset(0, 12),
    ),
  ];
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  buildDarkTheme
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
ThemeData buildDarkTheme() {
  final base      = ThemeData.dark(useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor:    AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,

    // â”€â”€ Colour scheme â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    colorScheme: const ColorScheme.dark(
      surface:        AppColors.background,
      primary:        AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary:      AppColors.accent,
      secondaryContainer: AppColors.accentDark,
      tertiary:       AppColors.gold,
      onPrimary:      Colors.white,
      onSecondary:    Colors.black,
      onSurface:      AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline:        AppColors.divider,
      error:          Color(0xFFCF6679),
    ),

    // â”€â”€ App bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),

    // â”€â”€ Text â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    textTheme: textTheme,

    // â”€â”€ Divider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    dividerTheme: const DividerThemeData(
      color:     AppColors.divider,
      thickness: 0.5,
      space:     0.5,
    ),

    // â”€â”€ Icons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),

    // â”€â”€ Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    cardTheme: CardTheme(
      color:        AppColors.surfaceCard,
      elevation:    0,
      margin:       EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
      ),
    ),

    // â”€â”€ Bottom nav â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:     AppColors.surface,
      selectedItemColor:   AppColors.textPrimary,
      unselectedItemColor: AppColors.textTertiary,
      type:                BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle:   TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
      elevation: 0,
    ),

    // â”€â”€ Elevated button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation:       0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        minimumSize: const Size(0, 48),
      ),
    ),

    // â”€â”€ Outlined button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(0, 48),
      ),
    ),

    // â”€â”€ Text button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // â”€â”€ Input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: AppColors.surfaceAlt,
      hintStyle: const TextStyle(color: AppColors.textTertiary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   const BorderSide(color: AppColors.divider, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // â”€â”€ Chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    chipTheme: ChipThemeData(
      backgroundColor:     AppColors.surfaceAlt,
      selectedColor:       AppColors.primary,
      labelStyle:          const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13),
      side:                BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // â”€â”€ SnackBar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: GoogleFonts.inter(
        color:      AppColors.textPrimary,
        fontSize:   14,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor:  AppColors.primary,
      behavior:         SnackBarBehavior.floating,
      elevation:        8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    // â”€â”€ Dialog â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surfaceModal,
      elevation:       24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: GoogleFonts.inter(
        color:      AppColors.textPrimary,
        fontSize:   18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: GoogleFonts.inter(
        color:      AppColors.textSecondary,
        fontSize:   14,
        fontWeight: FontWeight.w400,
        height:     1.5,
      ),
    ),

    // â”€â”€ Bottom sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor:    AppColors.surfaceModal,
      modalBackgroundColor: AppColors.surfaceModal,
      elevation:          16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // â”€â”€ Page transitions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS:   CupertinoPageTransitionsBuilder(),
      },
    ),

    // â”€â”€ Progress indicator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color:              AppColors.primary,
      linearTrackColor:   AppColors.surfaceHigh,
      circularTrackColor: AppColors.surfaceHigh,
    ),

    // â”€â”€ Slider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    sliderTheme: const SliderThemeData(
      activeTrackColor:   AppColors.primary,
      inactiveTrackColor: AppColors.surfaceHigh,
      thumbColor:         AppColors.textPrimary,
      overlayColor:       AppColors.glowRed,
    ),

    // â”€â”€ Tab bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    tabBarTheme: const TabBarTheme(
      labelColor:         AppColors.textPrimary,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor:     AppColors.primary,
      indicatorSize:      TabBarIndicatorSize.label,
      labelStyle:         TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
    ),
  );
}
