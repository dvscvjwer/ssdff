import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────
//  AppColors — OLED-optimized cinema palette
// ─────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────
  static const background      = Color(0xFF050505);   // deeper OLED black
  static const surface         = Color(0xFF111111);   // nav bar, base cards
  static const surfaceCard     = Color(0xFF161616);   // card base
  static const surfaceAlt      = Color(0xFF1A1A1A);   // chips, inputs
  static const surfaceHigh     = Color(0xFF222222);   // hover / active
  static const surfaceModal    = Color(0xFF1C1C1E);   // bottom-sheets / dialogs
  static const surfaceElevated = Color(0xFF252525);   // elevated cards, dropdowns
  static const surfaceOverlay  = Color(0x99000000);   // 60% black scrim

  // ── Divider ──────────────────────────────────────
  static const divider = Color(0xFF2A2A2A);

  // ── Brand ────────────────────────────────────────
  static const primary      = Color(0xFFE50914);
  static const primaryDark  = Color(0xFFB2070F);
  static const primaryLight = Color(0xFFFF3B30);     // brighter iOS red
  static const accent       = Color(0xFFFFB400);
  static const accentDark   = Color(0xFFCC8F00);

  // ── Secondary (HBO Max inspired) ─────────────────
  static const secondary     = Color(0xFF6C3FE5);    // series badges, genre accents
  static const secondaryDark = Color(0xFF4B0082);    // deep indigo

  // ── Splash / Accent Colors ───────────────────────
  static const accentCyan    = Color(0xFF00E5FF);    // live indicators, cool highlights
  static const accentMagenta = Color(0xFFFF007F);    // premium glow, trending
  static const orbPurple     = Color(0xFF8A2BE2);    // splash orb

  // ── Premium / Gold ───────────────────────────────
  static const gold      = Color(0xFFFFD700);
  static const goldDark  = Color(0xFFB8860B);
  static const goldLight = Color(0xFFFFF1A0);

  // ── Text ─────────────────────────────────────────
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB1B1B1);
  static const textTertiary  = Color(0xFF555555);    // brighter for 5-tab nav
  static const textDisabled  = Color(0xFF3D3D3D);

  // ── Overlays ─────────────────────────────────────
  static const overlayBlack      = Color(0x80000000);
  static const overlayBlackLight = Color(0x40000000);
  static const overlayBlackHeavy = Color(0xCC000000);

  // ── Gradient stops ───────────────────────────────
  static const gradientRedStart  = Color(0xFFE50914);
  static const gradientRedEnd    = Color(0xFF7A0007);
  static const gradientGoldStart = Color(0xFFFFD700);
  static const gradientGoldEnd   = Color(0xFFA0640A);
  static const gradientDarkStart = Color(0xFF1A1A1A);
  static const gradientDarkEnd   = Color(0xFF050505);

  // ── Glow ─────────────────────────────────────────
  static const glowRed    = Color(0x4DE50914);       // 30% alpha (was 40%)
  static const glowGold   = Color(0x4DFFD700);       // 30% alpha
  static const glowWhite  = Color(0x1AFFFFFF);
  static const glowAccent = Color(0x4DFFB400);
  static const glowCyan   = Color(0x3300E5FF);       // live indicator glow
  static const glowPurple = Color(0x336C3FE5);       // series badge glow
  static const shadowDeep = Color(0x66000000);        // elevated element shadow

  // ── Glass / Card borders ─────────────────────────
  static const glassSurface = Color(0x1AFFFFFF);     // frosted glass overlay
  static const cardBorder   = Color(0x26FFFFFF);     // subtle card rim
}

// ─────────────────────────────────────────────────
//  AppGradients — cinematic gradient system
// ─────────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  /// 6-stop cinematic hero fade — Netflix + Apple TV+ inspired
  static const heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end:   Alignment.bottomCenter,
    stops: [0.0, 0.15, 0.5, 0.75, 0.9, 1.0],
    colors: [
      Color(0xB3000000),   // 70% black — top bar protection
      Color(0x26000000),   // 15% black
      Color(0x00000000),   // transparent — content breathes
      Color(0x80000000),   // 50% black — readability begins
      Color(0xD9000000),   // 85% black
      Color(0xFF050505),   // solid background merge
    ],
  );

  /// Subtle dark card surface
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [
      Color(0xFF161616),   // surfaceCard
      Color(0xFF1A1A1A),   // surfaceAlt
    ],
  );

  /// Premium / VIP gold shimmer — HBO Max prestige
  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [
      AppColors.gold,
      AppColors.accent,
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
      Color(0xFF050505),
    ],
  );

  /// Radial glow — Disney+ ambient color bleed
  static const ambientGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.2,
    colors: [
      Color(0x1AE50914),
      Color(0x0D6C3FE5),
      Color(0x00000000),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Apple TV+ Liquid Glass effect
  static const glassGradient = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end:   Alignment(1.0, 1.0),
    colors: [
      Color(0x1AFFFFFF),   // 10% white
      Color(0x0DFFFFFF),   // 5% white
      Color(0x05FFFFFF),   // 2% white
      Color(0x00FFFFFF),   // transparent
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  /// Radial glow — place behind featured artwork
  static const heroRadialGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 0.9,
    colors: [
      Color(0x33E50914),
      Color(0x00000000),
    ],
  );
}

// ─────────────────────────────────────────────────
//  AppTextStyles — refined type scale
// ─────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  /// 40 px — Display hero headline (Outfit branding font)
  static TextStyle get displayHero => GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
        height: 0.95,
      );

  /// 28 px — Display title (detail screen, Outfit)
  static TextStyle get displayTitle => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.8,
        height: 1.05,
      );

  /// 48 px — Legacy hero title alias
  static TextStyle get heroTitle => displayHero;

  /// 20 px — Section headers inside lists / rows
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.2,
      );

  /// 13 px — Card title (title below thumbnail)
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
        height: 1.3,
      );

  /// 10 px — Badges, tags, pills (ALL CAPS)
  static TextStyle get badge => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 1.0,
      );

  /// 11 px — Supporting captions, metadata, durations
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
        height: 1.3,
      );

  /// 15 px — Body / description copy
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  /// 14 px — Body medium (episode descriptions, meta)
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  /// 13 px — Subtitle / meta line inside cards
  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        height: 1.3,
      );

  /// 15 px — CTA buttons
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      );

  /// 14 px — Tab bar labels
  static TextStyle get tabLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// 10 px — Bottom nav labels
  static TextStyle get navLabel => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      );

  /// Arabic typography helper — Readex Pro (Shahid VIP inspired)
  static TextStyle arabic({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textPrimary,
    double height = 1.5,
  }) =>
      GoogleFonts.readexPro(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
}

// ─────────────────────────────────────────────────
//  AppShadows — depth & glow system
// ─────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  /// Subtle elevation for standard cards
  static const List<BoxShadow> card = [
    BoxShadow(
      color:        AppColors.shadowDeep,
      blurRadius:   16,
      spreadRadius: 0,
      offset:       Offset(0, 8),
    ),
    BoxShadow(
      color:        Color(0x14000000),
      blurRadius:   2,
      spreadRadius: 0,
      offset:       Offset(0, 1),
    ),
  ];

  /// Red glow — featured artwork, play button, primary CTA
  static const List<BoxShadow> glow = [
    BoxShadow(
      color:        AppColors.glowRed,
      blurRadius:   32,
      spreadRadius: -4,
      offset:       Offset(0, 8),
    ),
    BoxShadow(
      color:        Color(0x33E50914),
      blurRadius:   64,
      spreadRadius: -8,
      offset:       Offset(0, 16),
    ),
  ];

  /// Gold glow — premium / VIP badges and CTAs
  static const List<BoxShadow> premium = [
    BoxShadow(
      color:        AppColors.glowGold,
      blurRadius:   24,
      spreadRadius: -4,
      offset:       Offset(0, 6),
    ),
    BoxShadow(
      color:        Color(0x33FFD700),
      blurRadius:   48,
      spreadRadius: -8,
      offset:       Offset(0, 12),
    ),
  ];

  /// Cyan glow — live indicators
  static const List<BoxShadow> live = [
    BoxShadow(
      color:        AppColors.glowCyan,
      blurRadius:   20,
      spreadRadius: -2,
      offset:       Offset(0, 4),
    ),
  ];

  /// Purple glow — series badges
  static const List<BoxShadow> series = [
    BoxShadow(
      color:        AppColors.glowPurple,
      blurRadius:   20,
      spreadRadius: -2,
      offset:       Offset(0, 4),
    ),
  ];
}

// ─────────────────────────────────────────────────
//  AppDurations — animation timing constants
// ─────────────────────────────────────────────────
class AppDurations {
  AppDurations._();

  static const Duration fast      = Duration(milliseconds: 100);
  static const Duration normal    = Duration(milliseconds: 200);
  static const Duration medium    = Duration(milliseconds: 300);
  static const Duration slow      = Duration(milliseconds: 400);
  static const Duration pageSwitch = Duration(milliseconds: 500);
  static const Duration shimmer   = Duration(milliseconds: 1500);
  static const Duration heroScroll = Duration(milliseconds: 800);
  static const Duration splash    = Duration(milliseconds: 2800);
}

// ─────────────────────────────────────────────────
//  buildDarkTheme — OLED cinema experience
// ─────────────────────────────────────────────────
ThemeData buildDarkTheme({Locale? locale}) {
  final base      = ThemeData.dark(useMaterial3: true);
  final isArabic  = locale?.languageCode == 'ar';
  final rawTheme  = isArabic
      ? GoogleFonts.readexProTextTheme(base.textTheme)
      : GoogleFonts.interTextTheme(base.textTheme);
  final textTheme = rawTheme.apply(
    bodyColor:    AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
    fontFamilyFallback: [
      GoogleFonts.readexPro().fontFamily ?? 'Readex Pro',
    ],
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,

    // ── Colour scheme ────────────────────────────
    colorScheme: const ColorScheme.dark(
      surface:            AppColors.background,
      primary:            AppColors.primary,
      primaryContainer:   AppColors.primaryDark,
      secondary:          AppColors.secondary,
      secondaryContainer: AppColors.secondaryDark,
      tertiary:           AppColors.gold,
      onPrimary:          Colors.white,
      onSecondary:        Colors.white,
      onSurface:          AppColors.textPrimary,
      onSurfaceVariant:   AppColors.textSecondary,
      outline:            AppColors.divider,
      error:              Color(0xFFCF6679),
    ),

    // ── App bar ──────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),

    // ── Text ─────────────────────────────────────
    textTheme: textTheme,

    // ── Divider ──────────────────────────────────
    dividerTheme: const DividerThemeData(
      color:     AppColors.divider,
      thickness: 0.5,
      space:     0.5,
    ),

    // ── Icons ────────────────────────────────────
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),

    // ── Card ─────────────────────────────────────
    cardTheme: CardThemeData(
      color:        AppColors.surfaceCard,
      elevation:    0,
      margin:       EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.glassSurface, width: 0.5),
      ),
    ),

    // ── Bottom nav ───────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:     AppColors.background,
      selectedItemColor:   AppColors.textPrimary,
      unselectedItemColor: AppColors.textTertiary,
      type:                BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle:   TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 0.3),
      elevation: 0,
    ),

    // ── Elevated button ──────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation:       0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        minimumSize: const Size(0, 48),
      ),
    ),

    // ── Outlined button ──────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: const Size(0, 48),
      ),
    ),

    // ── Text button ──────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // ── Input ────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: AppColors.surfaceAlt,
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.divider, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // ── Chip ─────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor:     AppColors.surfaceAlt,
      selectedColor:       AppColors.primary,
      labelStyle:          const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13),
      side:                BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // ── SnackBar ─────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: GoogleFonts.inter(
        color:      AppColors.textPrimary,
        fontSize:   14,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor:  AppColors.primary,
      behavior:         SnackBarBehavior.floating,
      elevation:        8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // ── Dialog ────────────────────────────────────
    dialogTheme: DialogThemeData(
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

    // ── Bottom sheet ─────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor:     AppColors.surfaceModal,
      modalBackgroundColor: AppColors.surfaceModal,
      elevation:           16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // ── Page transitions ─────────────────────────
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS:     ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS:   ZoomPageTransitionsBuilder(),
      },
    ),

    // ── Progress indicator ───────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color:              AppColors.primary,
      linearTrackColor:   AppColors.surfaceHigh,
      circularTrackColor: AppColors.surfaceHigh,
    ),

    // ── Slider ───────────────────────────────────
    sliderTheme: const SliderThemeData(
      activeTrackColor:   AppColors.primary,
      inactiveTrackColor: AppColors.surfaceHigh,
      thumbColor:         AppColors.textPrimary,
      overlayColor:       AppColors.glowRed,
    ),

    // ── Tab bar ──────────────────────────────────
    tabBarTheme: const TabBarThemeData(
      labelColor:           AppColors.textPrimary,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor:       AppColors.primary,
      indicatorSize:        TabBarIndicatorSize.label,
      labelStyle:           TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
    ),

    // ── Tooltip ──────────────────────────────────
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
    ),
  );
}
