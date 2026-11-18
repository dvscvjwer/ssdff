import 'dart:math' as math;
import 'dart:ui' show FontFeature, ImageFilter;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
// ─────────────────────────────────────────────────────────────────────────────
//  Crimson Cinema & Full-Bleed Minimalist Palette — SkyLive Broadcast v5.0
//  (SlothUI Design 4 Glowing Showcase + HBO Design 5 Open Backdrop)
// ─────────────────────────────────────────────────────────────────────────────
class LiveLuxuryPalette {
  LiveLuxuryPalette._();
  // ── Obsidian & Smoked Surfaces ──
  static const Color obsidianCanvas    = AppColors.background; // #050505
  static const Color smokedPanel       = Color(0xFF0D0D10);
  static const Color obsidianCard      = Color(0xFF101014);
  static const Color salonTile         = Color(0xFF131318);
  static const Color salonTileActive   = Color(0xFF17171C);
  static const Color mutedPill         = Color(0xFF1C1C23);
  static const Color velvetHudGlass    = Color(0xCC0E0E12);
  // ── Specular Hairlines ──
  static const Color hairlineSubtle    = Color(0x12FFFFFF);
  static const Color hairlineMedium    = Color(0x24FFFFFF);
  // ── SlothUI Crimson Cinema + HBO Warm Minimalist Accents ──
  static const Color textPrimary       = AppColors.textPrimary; // #FFFFFF
  static const Color silverSecondary   = Color(0xFF9E9EA8);
  static const Color silverMuted       = Color(0xFF686874);
  static const Color cinemaSilver      = Color(0xFFB0B4C0);
  static const Color champagneSoft     = Color(0xFFD6BA8A);
  static const Color warmNowStreaming  = Color(0xFFF5A623);
  static const Color rubyLive          = AppColors.primary;    // #E50914
  static const Color crimsonActiveRim  = Color(0xFFFF2A3C);    // Design 4 active card rim & progress
  static const Color crimsonActiveGlow = Color(0x75E50914);    // Design 4 active card halo
  static const Color crimsonCtaStart   = Color(0xFFFF1E2D);
  static const Color crimsonCtaEnd     = Color(0xFFD90712);
}
// ─────────────────────────────────────────────────────────────────────────────
//  Typography & RTL/LTR Engine — SkyLive Broadcast v5.0
// ─────────────────────────────────────────────────────────────────────────────
class LiveBroadcastType {
  LiveBroadcastType._();
  static bool isAr(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';
  static TextStyle style(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double height = 1.3,
    double letterSpacing = 0.0,
    bool display = false,
    bool tabular = false,
  }) {
    final bool arabic = isAr(context);
    final List<FontFeature>? features =
        tabular ? const <FontFeature>[FontFeature.tabularFigures()] : null;
    if (arabic) {
      return AppTextStyles.arabic(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      ).copyWith(fontFeatures: features);
    }
    if (display) {
      return GoogleFonts.outfit(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontFeatures: features,
      );
    }
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: features,
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
//  Broadcast Domain Models (Bilingual AR / EN + Dynamic EPG + Verified Backdrops)
// ─────────────────────────────────────────────────────────────────────────────
enum LiveCategory {
  all,
  sports,
  movies,
  entertainment,
  news,
  favorites,
}
extension LiveCategoryX on LiveCategory {
  String label(BuildContext context, [AppLocalizations? l10n]) {
    final bool ar = LiveBroadcastType.isAr(context);
    switch (this) {
      case LiveCategory.all:
        return l10n?.liveCatAll ?? (ar ? 'الكل' : 'All');
      case LiveCategory.sports:
        return l10n?.liveCatSports ?? (ar ? 'رياضة' : 'Sports');
      case LiveCategory.movies:
        return l10n?.liveCatMovies ?? (ar ? 'أفلام' : 'Movies');
      case LiveCategory.entertainment:
        return l10n?.liveCatDocs ?? (ar ? 'وثائقي' : 'Docs');
      case LiveCategory.news:
        return l10n?.liveCatNews ?? (ar ? 'أخبار' : 'News');
      case LiveCategory.favorites:
        return ar ? 'المفضلة' : 'Favorites';
    }
  }
  IconData get icon {
    switch (this) {
      case LiveCategory.all:
        return Icons.grid_view_rounded;
      case LiveCategory.sports:
        return Icons.sports_soccer_rounded;
      case LiveCategory.movies:
        return Icons.local_movies_rounded;
      case LiveCategory.entertainment:
        return Icons.explore_rounded;
      case LiveCategory.news:
        return Icons.public_rounded;
      case LiveCategory.favorites:
        return Icons.favorite_rounded;
    }
  }
}
enum EmblemStyle {
  royalGold,
  ribbonSplit,
  saudiCrest,
  yellowPortal,
  newsTicker,
  cinemaGlow,
}
class LiveMatchInfo {
  final String competitionAr;
  final String competitionEn;
  final String stageAr;
  final String stageEn;
  final String homeTeamAr;
  final String homeTeamEn;
  final String homeShort;
  final Color homeColor;
  final int homeScore;
  final String awayTeamAr;
  final String awayTeamEn;
  final String awayShort;
  final Color awayColor;
  final int awayScore;
  final String minuteLabel;
  final int homePossession;
  final int homeShotsOnTarget;
  final int awayShotsOnTarget;
  final String eventsAr;
  final String eventsEn;
  const LiveMatchInfo({
    required this.competitionAr,
    required this.competitionEn,
    required this.stageAr,
    required this.stageEn,
    required this.homeTeamAr,
    required this.homeTeamEn,
    required this.homeShort,
    required this.homeColor,
    required this.homeScore,
    required this.awayTeamAr,
    required this.awayTeamEn,
    required this.awayShort,
    required this.awayColor,
    required this.awayScore,
    required this.minuteLabel,
    required this.homePossession,
    required this.homeShotsOnTarget,
    required this.awayShotsOnTarget,
    required this.eventsAr,
    required this.eventsEn,
  });
  String competition(bool ar) => ar ? competitionAr : competitionEn;
  String stage(bool ar) => ar ? stageAr : stageEn;
  String homeTeam(bool ar) => ar ? homeTeamAr : homeTeamEn;
  String awayTeam(bool ar) => ar ? awayTeamAr : awayTeamEn;
  String events(bool ar) => ar ? eventsAr : eventsEn;
  String summaryPill(bool ar) =>
      '${homeTeam(ar)} $homeScore - $awayScore ${awayTeam(ar)}  •  $minuteLabel';
}
class EpgProgramSeed {
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final int durationMinutes;
  const EpgProgramSeed({
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.durationMinutes,
  });
}
class EpgSlot {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final DateTime startTime;
  final DateTime endTime;
  final bool isLive;
  const EpgSlot({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.startTime,
    required this.endTime,
    required this.isLive,
  });
  String title(bool ar) => ar ? titleAr : titleEn;
  String description(bool ar) => ar ? descAr : descEn;
  double progressAt(DateTime now) {
    final int totalSec = endTime.difference(startTime).inSeconds;
    if (totalSec <= 0) {
      return 0.5;
    }
    final int elapsedSec = now.difference(startTime).inSeconds;
    return (elapsedSec / totalSec).clamp(0.06, 0.96);
  }
  int remainingMinutesAt(DateTime now) {
    final int mins = endTime.difference(now).inMinutes;
    return mins < 1 ? 1 : mins;
  }
  static String formatClock(DateTime dt) {
    final String h = dt.hour.toString().padLeft(2, '0');
    final String m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
  String get timeRangeLabel =>
      '${formatClock(startTime)} - ${formatClock(endTime)}';
}
class LiveChannel {
  final String id;
  final String number;
  final String nameAr;
  final String nameEn;
  final String emblemTop;
  final String emblemBottom;
  final String qualityTag;
  final String audioTagAr;
  final String audioTagEn;
  final LiveCategory category;
  final Color brandPrimary;
  final Color brandSecondary;
  final Color brandAccent;
  final EmblemStyle emblemStyle;
  final String streamUrl;
  final String backdropUrl;
  final int initialSeekSeconds;
  final double baseViewersK;
  final int liveElapsedMinutes;
  final LiveMatchInfo? liveMatch;
  final List<EpgProgramSeed> programSeeds;
  const LiveChannel({
    required this.id,
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.emblemTop,
    required this.emblemBottom,
    required this.qualityTag,
    required this.audioTagAr,
    required this.audioTagEn,
    required this.category,
    required this.brandPrimary,
    required this.brandSecondary,
    required this.brandAccent,
    required this.emblemStyle,
    required this.streamUrl,
    required this.backdropUrl,
    required this.initialSeekSeconds,
    required this.baseViewersK,
    required this.liveElapsedMinutes,
    required this.programSeeds,
    this.liveMatch,
  });
  String name(bool ar) => ar ? nameAr : nameEn;
  String audioTag(bool ar) => ar ? audioTagAr : audioTagEn;
  List<EpgSlot> buildSchedule(DateTime now) {
    final DateTime anchorMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    DateTime cursor =
        anchorMinute.subtract(Duration(minutes: liveElapsedMinutes));
    final List<EpgSlot> result = <EpgSlot>[];
    for (int i = 0; i < programSeeds.length; i++) {
      final EpgProgramSeed seed = programSeeds[i];
      final DateTime slotStart = cursor;
      final DateTime slotEnd =
          slotStart.add(Duration(minutes: seed.durationMinutes));
      result.add(
        EpgSlot(
          id: '${id}_slot_$i',
          titleAr: seed.titleAr,
          titleEn: seed.titleEn,
          descAr: seed.descAr,
          descEn: seed.descEn,
          startTime: slotStart,
          endTime: slotEnd,
          isLive: i == 0,
        ),
      );
      cursor = slotEnd;
    }
    return result;
  }
}
// ─────────────────────────────────────────────────────────────────────────────
//  13 World-Class Channels Catalog
//  (100% HTTP-200 Verified H.264 MP4 Streams + 16:9 Unsplash Cinema Backdrops)
// ─────────────────────────────────────────────────────────────────────────────
class LiveBroadcastCatalog {
  LiveBroadcastCatalog._();
  static const String fallbackStreamUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  static const List<LiveChannel> channels = <LiveChannel>[
    LiveChannel(
      id: 'bein_1_premium',
      number: '01',
      nameAr: 'بي إن سبورتس 1 بريميوم',
      nameEn: 'beIN 1 PREMIUM',
      emblemTop: 'beIN 1',
      emblemBottom: 'PREMIUM',
      qualityTag: '4K HDR',
      audioTagAr: 'دولبي أتموس • تعليق عربي',
      audioTagEn: 'DOLBY ATMOS • DUAL AUDIO',
      category: LiveCategory.sports,
      brandPrimary: Color(0xFF5C2D91),
      brandSecondary: Color(0xFF230A44),
      brandAccent: Color(0xFFFFD700),
      emblemStyle: EmblemStyle.royalGold,
      streamUrl: 'https://res.cloudinary.com/demo/video/upload/forest_bike.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 1,
      baseViewersK: 128.4,
      liveElapsedMinutes: 67,
      liveMatch: LiveMatchInfo(
        competitionAr: 'دوري أبطال أوروبا',
        competitionEn: 'UEFA Champions League',
        stageAr: 'ربع النهائي • الإياب',
        stageEn: 'Quarter-Final • 2nd Leg',
        homeTeamAr: 'ريال مدريد',
        homeTeamEn: 'Real Madrid',
        homeShort: 'RMA',
        homeColor: Color(0xFF3E6AE1),
        homeScore: 2,
        awayTeamAr: 'مانشستر سيتي',
        awayTeamEn: 'Man City',
        awayShort: 'MCI',
        awayColor: Color(0xFF00B4D8),
        awayScore: 1,
        minuteLabel: "67'",
        homePossession: 54,
        homeShotsOnTarget: 7,
        awayShotsOnTarget: 5,
        eventsAr:
            "⚽ 23' فينيسيوس جونيور  •  ⚽ 51' هالاند  •  ⚽ 64' جود بيلينغهام",
        eventsEn:
            "⚽ 23' Vinícius Jr  •  ⚽ 51' E. Haaland  •  ⚽ 64' J. Bellingham",
      ),
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'ريال مدريد × مانشستر سيتي — ليالي الأبطال',
          titleEn: 'Real Madrid vs Manchester City — UCL Live',
          descAr:
              'قمة ربع نهائي دوري أبطال أوروبا بتغطية استوديو 4K HDR مع إحصائيات تكتيكية حية وكاميرات الملعب الخاصة.',
          descEn:
              'Champions League blockbuster in native 4K HDR with live tactical telemetry and pitch-side analysis.',
          durationMinutes: 105,
        ),
        EpgProgramSeed(
          titleAr: 'الاستوديو التحليلي لما بعد القمة',
          titleEn: 'UCL Post-Match Tactical Studio',
          descAr: 'تحليل شامل للأهداف والحالات التحكيمية ومقابلات حصرية من الملعب.',
          descEn: 'Full breakdown of key goals, xG heatmaps, and pitch-side interviews.',
          durationMinutes: 45,
        ),
        EpgProgramSeed(
          titleAr: 'ملخصات ليالي الأبطال الأوروبية',
          titleEn: 'Champions League Goals & Highlights',
          descAr: 'أجمل أهداف ولقطات الجولة الأوروبية بتقنية التصوير البطيء الفائق.',
          descEn: 'Every goal and decisive moment from across Europe in ultra-slow motion.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'وثائقي: ملوك القارة العجوز',
          titleEn: 'Kings of Europe: Road to the Final',
          descAr: 'كواليس حصرية من غرف الملابس لمسيرة الأبطال نحو اللقب الأوروبي.',
          descEn: 'Behind-the-scenes locker room access chronicling the European title race.',
          durationMinutes: 60,
        ),
      ],
    ),
    LiveChannel(
      id: 'sky_sports_pl',
      number: '02',
      nameAr: 'سكاي سبورتس البريميرليغ',
      nameEn: 'SKY SPORTS PL',
      emblemTop: 'SKY',
      emblemBottom: 'SPORTS PL',
      qualityTag: '4K UHD',
      audioTagAr: 'صوت الملعب المحيطي',
      audioTagEn: 'STADIUM FX • 5.1',
      category: LiveCategory.sports,
      brandPrimary: Color(0xFFE50914),
      brandSecondary: Color(0xFF0B1F4D),
      brandAccent: Color(0xFF00E5FF),
      emblemStyle: EmblemStyle.ribbonSplit,
      streamUrl: 'https://res.cloudinary.com/demo/video/upload/snow_horses.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 1,
      baseViewersK: 96.2,
      liveElapsedMinutes: 81,
      liveMatch: LiveMatchInfo(
        competitionAr: 'الدوري الإنجليزي الممتاز',
        competitionEn: 'Premier League',
        stageAr: 'قمة الجولة 32 • أنفيلد',
        stageEn: 'Matchweek 32 • Anfield',
        homeTeamAr: 'ليفربول',
        homeTeamEn: 'Liverpool',
        homeShort: 'LIV',
        homeColor: Color(0xFFD00027),
        homeScore: 3,
        awayTeamAr: 'أرسنال',
        awayTeamEn: 'Arsenal',
        awayShort: 'ARS',
        awayColor: Color(0xFFEF0107),
        awayScore: 2,
        minuteLabel: "81'",
        homePossession: 58,
        homeShotsOnTarget: 9,
        awayShotsOnTarget: 6,
        eventsAr:
            "⚽ 14' محمد صلاح  •  ⚽ 39' ساكا  •  ⚽ 58' لويس دياز  •  ⚽ 71' أوديغارد  •  ⚽ 78' صلاح",
        eventsEn:
            "⚽ 14' M. Salah  •  ⚽ 39' B. Saka  •  ⚽ 58' L. Díaz  •  ⚽ 71' Ødegaard  •  ⚽ 78' Salah",
      ),
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'ليفربول × أرسنال — قمة البريميرليغ',
          titleEn: 'Liverpool vs Arsenal — Super Sunday',
          descAr:
              'صراع الصدارة المشتعل من ملعب أنفيلد مع إحصائيات السرعة والضغط العالي لحظة بلحظة.',
          descEn:
              'Title-deciding clash live from Anfield with real-time sprint and pressing metrics.',
          durationMinutes: 100,
        ),
        EpgProgramSeed(
          titleAr: 'ليلة الاثنين التكتيكية (Monday Night)',
          titleEn: 'Monday Night Tactical Lab',
          descAr: 'قراءة معمقة بالرسوم التفاعلية لسباق اللقب الإنجليزي.',
          descEn: 'Interactive touch-screen analysis of the Premier League title race.',
          durationMinutes: 50,
        ),
        EpgProgramSeed(
          titleAr: 'أفضل 50 هدفاً في البريميرليغ',
          titleEn: 'Premier League Top 50 Screamers',
          descAr: 'عد تنازلي لأروع التسديدات الصاروخية في تاريخ البطولة.',
          descEn: 'Countdown of the most iconic long-range strikes in league history.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'أساطير أنفيلد وهايبري',
          titleEn: 'PL Icons: Anfield & Highbury',
          descAr: 'حوار خاص مع أبرز نجوم الجيل الذهبي في الكرة الإنجليزية.',
          descEn: 'Exclusive roundtable with iconic legends of English football.',
          durationMinutes: 60,
        ),
      ],
    ),
    LiveChannel(
      id: 'ssc_extra_1',
      number: '03',
      nameAr: 'الرياضية السعودية SSC EXTRA 1',
      nameEn: 'SSC EXTRA 1',
      emblemTop: 'SSC',
      emblemBottom: 'EXTRA 1',
      qualityTag: '4K HDR',
      audioTagAr: 'تعليق عربي مزدوج',
      audioTagEn: 'AR/EN DUAL TRACK',
      category: LiveCategory.sports,
      brandPrimary: Color(0xFF008755),
      brandSecondary: Color(0xFF003B73),
      brandAccent: Color(0xFFFFD700),
      emblemStyle: EmblemStyle.saudiCrest,
      streamUrl:
          'https://res.cloudinary.com/demo/video/upload/samples/cld-sample-video.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 1,
      baseViewersK: 112.9,
      liveElapsedMinutes: 74,
      liveMatch: LiveMatchInfo(
        competitionAr: 'دوري روشن السعودي',
        competitionEn: 'Roshn Saudi League',
        stageAr: 'ديربي الرياض الكبير • المملكة أرينا',
        stageEn: 'Riyadh Super Derby • Kingdom Arena',
        homeTeamAr: 'الهلال',
        homeTeamEn: 'Al-Hilal',
        homeShort: 'HIL',
        homeColor: Color(0xFF0057B8),
        homeScore: 2,
        awayTeamAr: 'النصر',
        awayTeamEn: 'Al-Nassr',
        awayShort: 'NAS',
        awayColor: Color(0xFFFFB800),
        awayScore: 2,
        minuteLabel: "74'",
        homePossession: 56,
        homeShotsOnTarget: 8,
        awayShotsOnTarget: 7,
        eventsAr:
            "⚽ 19' سالم الدوسري  •  ⚽ 34' كريستيانو رونالدو  •  ⚽ 61' ميتروفيتش  •  ⚽ 70' أندرسون تاليسكا",
        eventsEn:
            "⚽ 19' S. Al-Dawsari  •  ⚽ 34' C. Ronaldo  •  ⚽ 61' A. Mitrović  •  ⚽ 70' Talisca",
      ),
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'الهلال × النصر — ديربي الرياض الكبير',
          titleEn: 'Al-Hilal vs Al-Nassr — Riyadh Super Derby',
          descAr:
              'قمة دوري روشن السعودي بنقل جوي عبر كاميرات العنكبوت و28 كاميرا سينمائية من المملكة أرينا.',
          descEn:
              'Roshn Saudi League derby broadcast with spider-cam aerials and 28 cinema cameras.',
          durationMinutes: 100,
        ),
        EpgProgramSeed(
          titleAr: 'أكشن مع وليد — تغطية خاصة للديربي',
          titleEn: 'Riyadh Derby Live Reactions & Debates',
          descAr: 'نقاشات ساخنة وتصريحات حصرية للاعبين والمدربين عقب صافرة النهاية.',
          descEn: 'Post-match debates, coach pressers, and instant fan reactions.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'حصاد جولة روشن',
          titleEn: 'Roshn League Matchweek Review',
          descAr: 'ملخص شامل لكافة مباريات الجولة وأجمل التصديات والأهداف.',
          descEn: 'Complete roundup of every match, top saves, and standout goals.',
          durationMinutes: 45,
        ),
        EpgProgramSeed(
          titleAr: 'نجوم الملاعب الآسيوية',
          titleEn: 'Asian Champions Spotlight',
          descAr: 'تقارير ميدانية خاصة عن استعدادات الأندية في البطولة القارية.',
          descEn: 'Special features on clubs competing on the continental stage.',
          durationMinutes: 60,
        ),
      ],
    ),
    LiveChannel(
      id: 'tod_360_ultra',
      number: '04',
      nameAr: 'تود 360 ألترا الرياضية',
      nameEn: 'TOD 360 ULTRA',
      emblemTop: 'TOD 360',
      emblemBottom: 'ULTRA 4K',
      qualityTag: '4K HDR',
      audioTagAr: 'كاميرا تكتيكية 360°',
      audioTagEn: 'MULTI-CAM 360°',
      category: LiveCategory.sports,
      brandPrimary: Color(0xFF00B4D8),
      brandSecondary: Color(0xFF03045E),
      brandAccent: Color(0xFF00E5FF),
      emblemStyle: EmblemStyle.cinemaGlow,
      streamUrl:
          'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 1,
      baseViewersK: 68.5,
      liveElapsedMinutes: 53,
      liveMatch: LiveMatchInfo(
        competitionAr: 'قمة السوبر الأوروبي',
        competitionEn: 'European Elite Showcase',
        stageAr: 'البث التكتيكي التفاعلي TOD 360',
        stageEn: 'TOD 360 Tactical Feed',
        homeTeamAr: 'برشلونة',
        homeTeamEn: 'Barcelona',
        homeShort: 'BAR',
        homeColor: Color(0xFFA50044),
        homeScore: 1,
        awayTeamAr: 'بايرن ميونخ',
        awayTeamEn: 'Bayern Munich',
        awayShort: 'BAY',
        awayColor: Color(0xFFDC052D),
        awayScore: 1,
        minuteLabel: "53'",
        homePossession: 61,
        homeShotsOnTarget: 6,
        awayShotsOnTarget: 5,
        eventsAr: "⚽ 18' لامين يامال  •  ⚽ 44' هاري كين",
        eventsEn: "⚽ 18' Lamine Yamal  •  ⚽ 44' Harry Kane",
      ),
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'برشلونة × بايرن ميونخ — البث التكتيكي 360°',
          titleEn: 'Barcelona vs Bayern Munich — 360° Tactical Feed',
          descAr:
              'بث خاص بزاوية تكتيكية شاملة لكامل الملعب مع خريطة التمريرات والسرعات اللحظية.',
          descEn:
              'Full-pitch tactical camera angle enhanced with live passing network overlays.',
          durationMinutes: 95,
        ),
        EpgProgramSeed(
          titleAr: 'مختبر البيانات الرياضية الحية',
          titleEn: 'xG & Telemetry Analytics Show',
          descAr: 'قراءة رقمية دقيقة لمعدلات الأهداف المتوقعة وتحركات الخطوط.',
          descEn: 'Data-driven breakdown of expected goals and pressing zones.',
          durationMinutes: 45,
        ),
        EpgProgramSeed(
          titleAr: 'سباق الفورمولا 1: التجارب الحرة الليلية',
          titleEn: 'Formula 1 Night Practice Feed',
          descAr: 'تغطية مباشرة من الحلبة مع القياسات الحية للإطارات والسرعة.',
          descEn: 'Trackside live feed with telemetry, sector splits, and team radio.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'أبطال التنس: الماسترز',
          titleEn: 'Masters 1000 Center Court',
          descAr: 'أقوى مواجهات الكرة الصفراء بدقة فائقة الوضوح.',
          descEn: 'Center court prime-time tennis showcase in crystal-clear UHD.',
          durationMinutes: 60,
        ),
      ],
    ),
    LiveChannel(
      id: 'hbo_max_live',
      number: '05',
      nameAr: 'إتش بي أو ماكس سينما',
      nameEn: 'HBO MAX LIVE',
      emblemTop: 'HBO',
      emblemBottom: 'MAX LIVE',
      qualityTag: '4K HDR',
      audioTagAr: 'دولبي فيجن • ترجمة عربية',
      audioTagEn: 'DOLBY VISION • SUBS',
      category: LiveCategory.movies,
      brandPrimary: Color(0xFF6C3FE5),
      brandSecondary: Color(0xFF120826),
      brandAccent: Color(0xFF00E5FF),
      emblemStyle: EmblemStyle.cinemaGlow,
      streamUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 4,
      baseViewersK: 44.1,
      liveElapsedMinutes: 38,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'أعماق المحيط المجهول (نسخة 4K السينمائية)',
          titleEn: 'Oceans: The Deep Horizon (4K Remaster)',
          descAr:
              'تحفة سينمائية تأخذك في رحلة بصرية غامرة عبر العوالم البحرية الخفية بتقنية HDR10+ ودولبي أتموس.',
          descEn:
              'Breathtaking widescreen theatrical odyssey restored in native 4K HDR10+.',
          durationMinutes: 90,
        ),
        EpgProgramSeed(
          titleAr: 'الكثيب: الجزء الثاني (عرض السهرة الأول)',
          titleEn: 'Dune: Part Two — Prime Showcase',
          descAr: 'ملحمة الخيال العلمي الحائزة على الأوسكار بصوت دولبي أتموس الكامل.',
          descEn: 'Academy Award-winning sci-fi epic presented with full Dolby Atmos sound.',
          durationMinutes: 150,
        ),
        EpgProgramSeed(
          titleAr: 'كواليس صناع السينما العالمية',
          titleEn: 'HBO Directors Cut: Behind the Lens',
          descAr: 'لقاءات حصرية مع كبار المخرجين حول المؤثرات البصرية وتصميم الصوت.',
          descEn: 'Intimate conversations with visionary filmmakers on practical VFX.',
          durationMinutes: 45,
        ),
        EpgProgramSeed(
          titleAr: 'ذا لاست أوف أس — ليلة الماراثون',
          titleEn: 'Prestige Drama Late Marathon',
          descAr: 'حلقات مختارة من أضخم الإنتاجات الدرامية العالمية بدون فواصل.',
          descEn: 'Back-to-back episodes of flagship drama originals commercial-free.',
          durationMinutes: 60,
        ),
      ],
    ),
    LiveChannel(
      id: 'sky_cinema',
      number: '06',
      nameAr: 'سكاي سينما بريمير',
      nameEn: 'SKY CINEMA',
      emblemTop: 'SKY',
      emblemBottom: 'CINEMA',
      qualityTag: '4K UHD',
      audioTagAr: 'صوت سينمائي محيطي',
      audioTagEn: 'THEATRICAL 7.1',
      category: LiveCategory.movies,
      brandPrimary: Color(0xFFC8102E),
      brandSecondary: Color(0xFF1B0C1A),
      brandAccent: Color(0xFFFFD700),
      emblemStyle: EmblemStyle.ribbonSplit,
      streamUrl:
          'https://res.cloudinary.com/demo/video/upload/glide-over-coastal-beach.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 1,
      baseViewersK: 31.7,
      liveElapsedMinutes: 29,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'أفق الساحل الذهبي: الهروب الكبير',
          titleEn: 'Golden Coastline: The Grand Escape',
          descAr:
              'إثارة وتشويق على حافة الهاوية بتصوير جوي سينمائي عريض وعدسات IMAX فائقة النقاء.',
          descEn:
              'High-stakes coastal thriller shot on large-format aerial cinema lenses.',
          durationMinutes: 85,
        ),
        EpgProgramSeed(
          titleAr: 'أوبنهايمر (النسخة السينمائية الكاملة)',
          titleEn: 'Oppenheimer (IMAX Ratio Edition)',
          descAr: 'الفيلم التاريخي الأضخم بتدرج لوني سينمائي مخصص للشاشات الكبيرة.',
          descEn: 'Masterpiece biographical thriller presented in expanded aspect ratio.',
          durationMinutes: 165,
        ),
        EpgProgramSeed(
          titleAr: 'نادي النقاد السينمائي',
          titleEn: 'Sky Cinema Red Carpet Special',
          descAr: 'جولة خاصة في أحدث العروض العالمية ومهرجانات السينما الدولية.',
          descEn: 'Exclusive premieres and red-carpet interviews from global festivals.',
          durationMinutes: 40,
        ),
        EpgProgramSeed(
          titleAr: 'كلاسيكيات الخيال العلمي',
          titleEn: 'Midnight Sci-Fi Vault',
          descAr: 'روائع الخيال العلمي المرممة رقمياً بدقة 4K.',
          descEn: 'Digitally restored science-fiction classics in pristine 4K.',
          durationMinutes: 90,
        ),
      ],
    ),
    LiveChannel(
      id: 'osn_plus_movies',
      number: '07',
      nameAr: 'أو إس إن+ أفلام السهرة',
      nameEn: 'OSN+ MOVIES',
      emblemTop: 'OSN+',
      emblemBottom: 'MOVIES',
      qualityTag: '1080p FHD',
      audioTagAr: 'ترجمة عربية احترافية',
      audioTagEn: 'ARABIC SUBTITLES',
      category: LiveCategory.movies,
      brandPrimary: Color(0xFFFF0055),
      brandSecondary: Color(0xFF1F0A24),
      brandAccent: Color(0xFFFFB400),
      emblemStyle: EmblemStyle.cinemaGlow,
      streamUrl:
          'https://res.cloudinary.com/demo/video/upload/samples/dance-2.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 1,
      baseViewersK: 27.5,
      liveElapsedMinutes: 44,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'ليلة الأضواء الهوليوودية الكبرى',
          titleEn: 'Hollywood Spotlight Premiere',
          descAr:
              'عرض أول وحصري لأحدث إنتاجات هوليوود الدرامية والموسيقية بدون أي فواصل إعلانية.',
          descEn:
              'First-run Hollywood showcase uncut and completely commercial-free.',
          durationMinutes: 95,
        ),
        EpgProgramSeed(
          titleAr: 'ذا باتمان: ظلال غوثام',
          titleEn: 'The Batman: Shadows of Gotham',
          descAr: 'تحقيقات مثيرة وأجواء نوار سينمائية مبهرة في شوارع غوثام المظلمة.',
          descEn: 'Neo-noir detective thriller set in the rain-soaked streets of Gotham.',
          durationMinutes: 145,
        ),
        EpgProgramSeed(
          titleAr: 'شباك التذاكر العالمي',
          titleEn: 'Box Office Insider Weekly',
          descAr: 'تعرف على أكثر الأفلام تحقيقاً للإيرادات هذا الأسبوع حول العالم.',
          descEn: 'Countdown of the top-grossing theatrical releases worldwide.',
          durationMinutes: 30,
        ),
        EpgProgramSeed(
          titleAr: 'سهرة الإثارة والغموض',
          titleEn: 'Late Night Mystery Feature',
          descAr: 'فيلم تشويق نفسي يحبس الأنفاس حتى اللحظة الأخيرة.',
          descEn: 'Edge-of-your-seat psychological suspense feature presentation.',
          durationMinutes: 100,
        ),
      ],
    ),
    LiveChannel(
      id: 'al_jazeera_live',
      number: '08',
      nameAr: 'الجزيرة الإخبارية مباشر',
      nameEn: 'AL JAZEERA',
      emblemTop: 'الجزيرة',
      emblemBottom: 'AL JAZEERA',
      qualityTag: '1080p FHD',
      audioTagAr: 'بث إخباري حي 24/7',
      audioTagEn: 'LIVE NEWSROOM 24/7',
      category: LiveCategory.news,
      brandPrimary: Color(0xFFFA9000),
      brandSecondary: Color(0xFF121E36),
      brandAccent: Color(0xFFFFD700),
      emblemStyle: EmblemStyle.newsTicker,
      streamUrl:
          'https://res.cloudinary.com/demo/video/upload/docs/walking_talking.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 1,
      baseViewersK: 63.8,
      liveElapsedMinutes: 22,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'حصاد اليوم الإخباري المباشر',
          titleEn: 'Global News Hour — Live Coverage',
          descAr:
              'تغطية ميدانية حية عبر شبكة المراسلين في العواصم العالمية وتحليل معمق لآخر المستجدات.',
          descEn:
              'Breaking international dispatches from bureaus across the globe.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'ما وراء الخبر',
          titleEn: 'Beyond the Headlines',
          descAr: 'نقاش تحليلي معمق مع نخبة من الخبراء وصناع القرار حول ملفات الساعة.',
          descEn: 'In-depth analytical debate unpacking the most urgent global stories.',
          durationMinutes: 45,
        ),
        EpgProgramSeed(
          titleAr: 'الاقتصاد والأسواق العالمية',
          titleEn: 'Global Markets & Energy Report',
          descAr: 'قراءة فورية لمؤشرات البورصات وأسعار الطاقة والتقنية الحديثة.',
          descEn: 'Real-time market trackers, energy insights, and tech economy briefings.',
          durationMinutes: 30,
        ),
        EpgProgramSeed(
          titleAr: 'تحقيقات استقصائية خاصة',
          titleEn: 'Special Investigative Documentary',
          descAr: 'ملفات وثائقية حصرية تكشف الحقائق بالوثائق والشهادات الحية.',
          descEn: 'Award-winning investigative journalism from around the world.',
          durationMinutes: 60,
        ),
      ],
    ),
    LiveChannel(
      id: 'sky_news_live',
      number: '09',
      nameAr: 'سكاي نيوز عربية HD',
      nameEn: 'SKY NEWS',
      emblemTop: 'SKY',
      emblemBottom: 'NEWS HD',
      qualityTag: '1080p FHD',
      audioTagAr: 'غرفة الأخبار العاجلة',
      audioTagEn: 'BREAKING DESK',
      category: LiveCategory.news,
      brandPrimary: Color(0xFFD90000),
      brandSecondary: Color(0xFF181822),
      brandAccent: Color(0xFFFFFFFF),
      emblemStyle: EmblemStyle.newsTicker,
      streamUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 0,
      baseViewersK: 39.2,
      liveElapsedMinutes: 16,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'غرفة الأخبار العاجلة والأسواق',
          titleEn: 'World Breaking Briefing',
          descAr:
              'آخر الأنباء العاجلة، تحديثات التكنولوجيا، وموجز الأسواق المالية العالمية لحظة بلحظة.',
          descEn:
              'Up-to-the-minute world headlines, tech breakthroughs, and market pulse.',
          durationMinutes: 45,
        ),
        EpgProgramSeed(
          titleAr: 'رادار المستقبل والذكاء الاصطناعي',
          titleEn: 'Future Tech & AI Radar',
          descAr: 'جولة في أحدث ابتكارات الذكاء الاصطناعي والفضاء والطاقة النظيفة.',
          descEn: 'Inside the latest breakthroughs in AI, robotics, and spaceflight.',
          durationMinutes: 45,
        ),
        EpgProgramSeed(
          titleAr: 'بانوراما المساء الإخبارية',
          titleEn: 'Prime Evening Panorama',
          descAr: 'ملخص شامل لأبرز الأحداث الإقليمية والدولية بالخرائط التفاعلية.',
          descEn: 'Comprehensive evening news wrap featuring interactive data walls.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'عالم الرياضة الإخباري',
          titleEn: 'World Sports Tonight',
          descAr: 'نتائج الملاعب الأوروبية والعربية وأخبار الانتقالات الحصرية.',
          descEn: 'Global football scores, transfer exclusives, and championship news.',
          durationMinutes: 30,
        ),
      ],
    ),
    LiveChannel(
      id: 'nat_geo_wild',
      number: '10',
      nameAr: 'ناشيونال جيوغرافيك وايلد 4K',
      nameEn: 'NAT GEO WILD',
      emblemTop: 'NAT GEO',
      emblemBottom: 'WILD 4K',
      qualityTag: '4K HDR',
      audioTagAr: 'صوت الطبيعة المحيطي',
      audioTagEn: 'PURE NATURE 5.1',
      category: LiveCategory.entertainment,
      brandPrimary: Color(0xFFFFCC00),
      brandSecondary: Color(0xFF111111),
      brandAccent: Color(0xFFFFCC00),
      emblemStyle: EmblemStyle.yellowPortal,
      streamUrl:
          'https://res.cloudinary.com/demo/video/upload/samples/elephants.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 1,
      baseViewersK: 29.6,
      liveElapsedMinutes: 31,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'أسرار البرية الأفريقية 4K: عمالقة السافانا',
          titleEn: 'Untamed Savanna 4K: Giants of Africa',
          descAr:
              'عدسات سينمائية فائقة الدقة ترصد رحلة الفيلة والأسود المهيبة في قلب السافانا الأفريقية.',
          descEn:
              'Ultra-HD wildlife cinematography following majestic elephant herds.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'كوكب المحيطات المضيئة',
          titleEn: 'Planet Ocean: Bioluminescent Deep',
          descAr: 'استكشاف الكائنات المضيئة في أعمق نقاط المحيط الهادئ.',
          descEn: 'Submersible expedition into the glowing creatures of the deep sea.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'قمم الجليد المتجمدة',
          titleEn: 'Frozen Kingdoms of the North',
          descAr: 'قصص البقاء المدهشة في القطب الشمالي وسط العواصف الثلجية.',
          descEn: 'Remarkable stories of survival across the Arctic frontier.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'أسرع الكائنات على وجه الأرض',
          titleEn: 'Predator Speed: 1000 FPS',
          descAr: 'تصوير بطيء بسرعة 1000 إطار في الثانية لأبرع الصيادين في الطبيعة.',
          descEn: 'High-speed 1000fps camera study of nature’s fastest apex hunters.',
          durationMinutes: 60,
        ),
      ],
    ),
    LiveChannel(
      id: 'discovery_hd',
      number: '11',
      nameAr: 'ديسكفري العلمية HD',
      nameEn: 'DISCOVERY HD',
      emblemTop: 'DISC',
      emblemBottom: 'SCIENCE HD',
      qualityTag: '4K UHD',
      audioTagAr: 'دبلجة عربية / EN',
      audioTagEn: 'ARABIC / EN AUDIO',
      category: LiveCategory.entertainment,
      brandPrimary: Color(0xFF0077C8),
      brandSecondary: Color(0xFF071A30),
      brandAccent: Color(0xFF00E5FF),
      emblemStyle: EmblemStyle.cinemaGlow,
      streamUrl:
          'https://res.cloudinary.com/demo/video/upload/samples/sea-turtle.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 1,
      baseViewersK: 22.4,
      liveElapsedMinutes: 19,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'عالم المرجان الأزرق: استكشاف الأعماق',
          titleEn: 'Blue Reef Odyssey: Deep Dive UHD',
          descAr:
              'مهمة علمية حديثة لتصوير الشعاب المرجانية النادرة والكائنات البحرية بتقنيات الإضاءة الطيفية.',
          descEn:
              'Marine expedition capturing rare coral ecosystems in true-color UHD.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'هندسة المحركات والمشاريع العملاقة',
          titleEn: 'Mega Engineering: Future Machines',
          descAr: 'داخل أضخم المصانع المختصة ببناء الجسور المعلقة والقطارات المغناطيسية.',
          descEn: 'Inside the world’s most ambitious aerospace and megastructure builds.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'عجائب الكون الفسيح: تلسكوب جيمس ويب',
          titleEn: 'Cosmos Uncovered: Deep Field',
          descAr: 'أحدث الصور والاكتشافات المذهلة لنشأة المجرات البعيدة.',
          descEn: 'New revelations from deep-space observatories charting distant galaxies.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'كيف صُنعت؟ النسخة التقنية',
          titleEn: 'How It’s Built: Supercars',
          descAr: 'خطوط إنتاج السيارات الخارقة المصنوعة من ألياف الكربون.',
          descEn: 'Precision carbon-fiber craftsmanship inside hypercar factories.',
          durationMinutes: 45,
        ),
      ],
    ),
    LiveChannel(
      id: 'mbc_action',
      number: '12',
      nameAr: 'إم بي سي أكشن HD',
      nameEn: 'MBC ACTION',
      emblemTop: 'MBC',
      emblemBottom: 'ACTION',
      qualityTag: '1080p FHD',
      audioTagAr: 'ترجمة عربية فورية',
      audioTagEn: 'ACTION • AR SUBS',
      category: LiveCategory.movies,
      brandPrimary: Color(0xFFFF5500),
      brandSecondary: Color(0xFF151515),
      brandAccent: Color(0xFFFFB400),
      emblemStyle: EmblemStyle.ribbonSplit,
      streamUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1541447271487-09612b3f49f7?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 0,
      baseViewersK: 51.0,
      liveElapsedMinutes: 27,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'تحدي السرعة والفورمولا الليلي المباشر',
          titleEn: 'Night Formula & Adrenaline Rush',
          descAr:
              'منافسات سرعة خارقة وتحديات حلبات ليلية تحبس الأنفاس بمشاركة نخبة السائقين عالمياً.',
          descEn:
              'High-octane night track motorsport stunts and extreme precision challenges.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'توب غير: سباق الصحراء الكبرى',
          titleEn: 'Desert Supercars Showdown',
          descAr: 'اختبار أقصى قدرات السيارات الرياضية على الكثبان الرملية.',
          descEn: 'Three exotic supercars face off across 500 miles of desert dunes.',
          durationMinutes: 60,
        ),
        EpgProgramSeed(
          titleAr: 'ليلة الفنون القتالية الحاسمة',
          titleEn: 'Octagon Main Event Night',
          descAr: 'نزالات البطولة الرئيسية مع تحليل فني من أبطال العالم.',
          descEn: 'Championship main-card bouts with cage-side technical commentary.',
          durationMinutes: 90,
        ),
        EpgProgramSeed(
          titleAr: 'مهمة مستحيلة: سهرة الأكشن',
          titleEn: 'Action Blockbuster Feature',
          descAr: 'مطاردات مثيرة ومشاهد حركة حقيقية بدون بديل.',
          descEn: 'Non-stop espionage thriller packed with practical stunt sequences.',
          durationMinutes: 120,
        ),
      ],
    ),
    LiveChannel(
      id: 'anime_live_4k',
      number: '13',
      nameAr: 'سكاي أنمي لايف 4K',
      nameEn: 'ANIME LIVE',
      emblemTop: 'ANIME',
      emblemBottom: 'LIVE 4K',
      qualityTag: '4K HDR',
      audioTagAr: 'ياباني أصلي • ترجمة عربية',
      audioTagEn: 'JP AUDIO • AR/EN SUBS',
      category: LiveCategory.movies,
      brandPrimary: Color(0xFFFF007F),
      brandSecondary: Color(0xFF3A0CA3),
      brandAccent: Color(0xFF00E5FF),
      emblemStyle: EmblemStyle.royalGold,
      streamUrl:
          'https://cdn.jsdelivr.net/gh/mediaelement/mediaelement-files@master/big_buck_bunny.mp4',
      backdropUrl:
          'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=1600&h=900&q=85',
      initialSeekSeconds: 12,
      baseViewersK: 47.3,
      liveElapsedMinutes: 35,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'ماراثون عالم الأنمي والخيال (بث متواصل)',
          titleEn: 'Fantasy Anime Marathon (Non-Stop)',
          descAr:
              'مغامرات ملحمية في أضواء طوكيو المستقبلية وتحريك سينمائي فائق السلاسة بمعدل 60 إطاراً.',
          descEn:
              'Epic animated adventure remastered with vibrant Neo-Tokyo HDR colors.',
          durationMinutes: 75,
        ),
        EpgProgramSeed(
          titleAr: 'ليلة السيف المتوهج: الفصل الأخير',
          titleEn: 'Cyber Blade Chronicles: Finale',
          descAr: 'المواجهة الحاسمة المنتظرة بأصوات الممثلين اليابانيين الأصليين.',
          descEn: 'Climactic season finale with original Japanese voice cast and subs.',
          durationMinutes: 50,
        ),
        EpgProgramSeed(
          titleAr: 'استوديو طوكيو: كيف يُرسم الأنمي؟',
          titleEn: 'Inside Tokyo Animation Studios',
          descAr: 'زيارة حصرية لأشهر استوديوهات التحريك في اليابان.',
          descEn: 'Behind the scenes with master key-frame animators in Tokyo.',
          durationMinutes: 40,
        ),
        EpgProgramSeed(
          titleAr: 'أفلام الخيال اليابانية المختارة',
          titleEn: 'Neo-Tokyo Theatrical Feature',
          descAr: 'فيلم أنمي سينمائي طويل حائز على جوائز المهرجانات الدولية.',
          descEn: 'Critically acclaimed animated feature film with orchestral score.',
          durationMinutes: 110,
        ),
      ],
    ),
  ];
}
// ─────────────────────────────────────────────────────────────────────────────
//  1. NetworkEmblem — Compact Velvet Broadcast Badge (Design 4 Corner Emblem)
// ─────────────────────────────────────────────────────────────────────────────
class NetworkEmblem extends StatelessWidget {
  final LiveChannel channel;
  final double size;
  final double borderRadius;
  const NetworkEmblem({
    super.key,
    required this.channel,
    this.size = 28,
    this.borderRadius = 7,
  });
  Color _temper(Color c, [double darkness = 0.16]) =>
      Color.lerp(c, const Color(0xFF0E0E12), darkness)!;
  Color _temperAccent(Color c) =>
      Color.lerp(c, const Color(0xFFE8E4DC), 0.20)!;
  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.all(Radius.circular(borderRadius));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildStyledBody(),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const <double>[0.0, 0.45, 1.0],
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStyledBody() {
    switch (channel.emblemStyle) {
      case EmblemStyle.yellowPortal:
        final Color portalTone = _temperAccent(channel.brandAccent);
        return Container(
          color: _temper(channel.brandSecondary, 0.14),
          padding: EdgeInsets.all(size * 0.11),
          child: Row(
            children: <Widget>[
              Container(
                width: size * 0.18,
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: portalTone,
                    width: size >= 36 ? 1.5 : 1.1,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
              SizedBox(width: size * 0.08),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        channel.emblemTop,
                        style: GoogleFonts.outfit(
                          color: LiveLuxuryPalette.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          height: 1.05,
                        ),
                      ),
                      Text(
                        channel.emblemBottom,
                        style: GoogleFonts.outfit(
                          color: portalTone,
                          fontWeight: FontWeight.w700,
                          fontSize: 8.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case EmblemStyle.ribbonSplit:
        return Column(
          children: <Widget>[
            Expanded(
              flex: 54,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      _temper(channel.brandPrimary, 0.10),
                      _temper(channel.brandPrimary, 0.24),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    channel.emblemTop,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 0.6,
              color: Colors.white.withValues(alpha: 0.22),
            ),
            Expanded(
              flex: 46,
              child: Container(
                width: double.infinity,
                color: _temper(channel.brandSecondary, 0.18),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    channel.emblemBottom,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.90),
                      fontWeight: FontWeight.w700,
                      fontSize: 8.0,
                      letterSpacing: 0.45,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case EmblemStyle.saudiCrest:
        final Color crestTone = _temperAccent(channel.brandAccent);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                _temper(channel.brandPrimary, 0.14),
                _temper(channel.brandSecondary, 0.22),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              PositionedDirectional(
                top: 0,
                start: 0,
                end: 0,
                child: Container(
                  height: size * 0.06,
                  color: crestTone.withValues(alpha: 0.78),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(size * 0.11),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        channel.emblemTop,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.7,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        channel.emblemBottom,
                        style: GoogleFonts.inter(
                          color: crestTone,
                          fontWeight: FontWeight.w800,
                          fontSize: 7.5,
                          letterSpacing: 0.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case EmblemStyle.newsTicker:
        final Color wordmarkTone =
            Color.lerp(channel.brandPrimary, Colors.white, 0.26)!;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                _temper(channel.brandSecondary, 0.16),
                const Color(0xFF0A0C12),
              ],
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        channel.emblemTop,
                        style: AppTextStyles.arabic(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: wordmarkTone,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
                color: _temper(channel.brandPrimary, 0.16),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    channel.emblemBottom,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w800,
                      fontSize: 7.0,
                      letterSpacing: 0.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case EmblemStyle.royalGold:
      case EmblemStyle.cinemaGlow:
        final bool isGold = channel.emblemStyle == EmblemStyle.royalGold;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                _temper(channel.brandPrimary, 0.12),
                _temper(channel.brandSecondary, 0.22),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              PositionedDirectional(
                end: -size * 0.22,
                top: -size * 0.22,
                child: Container(
                  width: size * 0.62,
                  height: size * 0.62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(size * 0.11),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        channel.emblemTop,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.0,
                          letterSpacing: 0.4,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 1.5),
                      Text(
                        channel.emblemBottom,
                        style: GoogleFonts.inter(
                          color: isGold
                              ? LiveLuxuryPalette.champagneSoft
                              : Colors.white.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w700,
                          fontSize: 7.6,
                          letterSpacing: 0.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
// ─────────────────────────────────────────────────────────────────────────────
//  2. CinemaChannelCard — SlothUI Design 4 Glowing 16:9 Showcase Card
// ─────────────────────────────────────────────────────────────────────────────
class CinemaChannelCard extends StatefulWidget {
  final LiveChannel channel;
  final DateTime now;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  const CinemaChannelCard({
    super.key,
    required this.channel,
    required this.now,
    required this.isSelected,
    required this.onTap,
    this.width = 236,
    this.height = 134,
    this.isFavorite = false,
    this.onToggleFavorite,
  });
  @override
  State<CinemaChannelCard> createState() => _CinemaChannelCardState();
}
class _CinemaChannelCardState extends State<CinemaChannelCard> {
  bool _isHovered = false;
  bool _isPressed = false;
  double get _cardScale {
    if (_isPressed) {
      return 0.985;
    }
    if (widget.isSelected) {
      return 1.02;
    }
    if (_isHovered) {
      return 1.012;
    }
    return 1.0;
  }
  @override
  Widget build(BuildContext context) {
    final bool ar = LiveBroadcastType.isAr(context);
    final bool compactCard = widget.height < 108;
    final EpgSlot slot = widget.channel.buildSchedule(widget.now).first;
    final double progress = slot.progressAt(widget.now);
    final LiveMatchInfo? match = widget.channel.liveMatch;
    final String topMetaLabel = match != null
        ? 'CH ${widget.channel.number}  •  ${match.homeShort} ${match.homeScore} - ${match.awayScore} ${match.awayShort}'
        : 'CH ${widget.channel.number}  •  ${slot.timeRangeLabel}';
    const BorderRadius outerRadius = BorderRadius.all(Radius.circular(14));
    const BorderRadius innerRadius = BorderRadius.all(Radius.circular(12.4));
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onToggleFavorite,
        child: AnimatedScale(
          scale: _cardScale,
          duration: AppDurations.normal,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: AppDurations.normal,
            curve: Curves.easeOutCubic,
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: outerRadius,
              border: widget.isSelected
                  ? Border.all(
                      color: LiveLuxuryPalette.crimsonActiveRim,
                      width: 1.8,
                    )
                  : Border.all(
                      color: Colors.white.withValues(
                        alpha: _isHovered ? 0.30 : 0.14,
                      ),
                      width: 1.0,
                    ),
              boxShadow: widget.isSelected
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: LiveLuxuryPalette.crimsonActiveGlow,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Color(0x73000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: _isHovered ? 0.56 : 0.38,
                        ),
                        blurRadius: _isHovered ? 16 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: innerRadius,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CinemaBackdropFallback(channel: widget.channel),
                  CachedNetworkImage(
                    imageUrl: widget.channel.backdropUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 260),
                    placeholder: (BuildContext context, String _) =>
                        CinemaBackdropFallback(channel: widget.channel),
                    errorWidget: (BuildContext context, String _, Object __) =>
                        CinemaBackdropFallback(channel: widget.channel),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const <double>[0.0, 0.34, 0.58, 1.0],
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.58),
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.44),
                          Colors.black.withValues(alpha: 0.86),
                        ],
                      ),
                    ),
                  ),
                  if (_isHovered && !widget.isSelected)
                    ColoredBox(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      12,
                      compactCard ? 7 : 10,
                      12,
                      compactCard ? 7 : 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            if (match != null) ...<Widget>[
                              Container(
                                width: 5.5,
                                height: 5.5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: LiveLuxuryPalette.crimsonActiveRim,
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                            Expanded(
                              child: Text(
                                topMetaLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LiveBroadcastType.style(
                                  context,
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.88),
                                  tabular: true,
                                ).copyWith(
                                  shadows: const <Shadow>[
                                    Shadow(
                                      color: Color(0x99000000),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            NetworkEmblem(
                              channel: widget.channel,
                              size: compactCard ? 24 : 28,
                              borderRadius: compactCard ? 6 : 7,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.channel.name(ar),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: LiveBroadcastType.style(
                                      context,
                                      size: compactCard ? 12.5 : 13.5,
                                      weight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.18,
                                    ).copyWith(
                                      shadows: const <Shadow>[
                                        Shadow(
                                          color: Color(0xB3000000),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    slot.title(ar),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: LiveBroadcastType.style(
                                      context,
                                      size: 11,
                                      weight: FontWeight.w500,
                                      color: const Color(0xFFC8CCD8),
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 2.2,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isSelected
                                      ? LiveLuxuryPalette.crimsonActiveRim
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class CinemaBackdropFallback extends StatelessWidget {
  final LiveChannel channel;
  const CinemaBackdropFallback({
    super.key,
    required this.channel,
  });
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(const Color(0xFF0E0E15), channel.brandPrimary, 0.34)!,
            Color.lerp(const Color(0xFF08080D), channel.brandSecondary, 0.42)!,
            const Color(0xFF050507),
          ],
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
//  3. CinemaScheduleSheet — On-Demand Frosted Glass Schedule & Reminder Sheet
// ─────────────────────────────────────────────────────────────────────────────
class CinemaScheduleSheet extends StatefulWidget {
  final LiveChannel channel;
  final DateTime? now;
  final List<EpgSlot>? slots;
  final Set<String> remindedSlotIds;
  final ValueChanged<EpgSlot> onToggleReminder;
  final VoidCallback? onWatchLive;
  const CinemaScheduleSheet({
    super.key,
    required this.channel,
    this.now,
    this.slots,
    this.remindedSlotIds = const <String>{},
    required this.onToggleReminder,
    this.onWatchLive,
  });
  static Future<void> show(
    BuildContext context, {
    required LiveChannel channel,
    DateTime? now,
    List<EpgSlot>? slots,
    Set<String> remindedSlotIds = const <String>{},
    required ValueChanged<EpgSlot> onToggleReminder,
    VoidCallback? onWatchLive,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CinemaScheduleSheet(
        channel: channel,
        now: now,
        slots: slots,
        remindedSlotIds: remindedSlotIds,
        onToggleReminder: onToggleReminder,
        onWatchLive: onWatchLive,
      ),
    );
  }
  @override
  State<CinemaScheduleSheet> createState() => _CinemaScheduleSheetState();
}
class _CinemaScheduleSheetState extends State<CinemaScheduleSheet> {
  late Set<String> _localRemindedIds;
  @override
  void initState() {
    super.initState();
    _localRemindedIds = Set<String>.from(widget.remindedSlotIds);
  }
  @override
  void didUpdateWidget(covariant CinemaScheduleSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remindedSlotIds != widget.remindedSlotIds) {
      _localRemindedIds = Set<String>.from(widget.remindedSlotIds);
    }
  }
  void _handleToggleReminder(EpgSlot slot) {
    setState(() {
      if (_localRemindedIds.contains(slot.id)) {
        _localRemindedIds.remove(slot.id);
      } else {
        _localRemindedIds.add(slot.id);
      }
    });
    widget.onToggleReminder(slot);
  }
  @override
  Widget build(BuildContext context) {
    final bool ar = LiveBroadcastType.isAr(context);
    final DateTime effectiveNow = widget.now ?? DateTime.now();
    final List<EpgSlot> schedule =
        widget.slots ?? widget.channel.buildSchedule(effectiveNow);
    final LiveMatchInfo? match = widget.channel.liveMatch;
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.78;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: maxSheetHeight,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xEB0B0B10),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 0.8,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          NetworkEmblem(
                            channel: widget.channel,
                            size: 42,
                            borderRadius: 10,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.channel.name(ar),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: LiveBroadcastType.style(
                                    context,
                                    size: 16.5,
                                    weight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  ar
                                      ? 'قناة ${widget.channel.number}  •  ${widget.channel.qualityTag}  •  جدول البث والتذكيرات'
                                      : 'CH ${widget.channel.number}  •  ${widget.channel.qualityTag}  •  Broadcast Schedule',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: LiveBroadcastType.style(
                                    context,
                                    size: 11.5,
                                    weight: FontWeight.w500,
                                    color: LiveLuxuryPalette.cinemaSilver,
                                    tabular: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Colors.white.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                      if (match != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 6.5,
                                height: 6.5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: LiveLuxuryPalette.crimsonActiveRim,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${match.competition(ar)}  •  ${match.summaryPill(ar)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: LiveBroadcastType.style(
                                    context,
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: Colors.white,
                                    tabular: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: schedule.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (BuildContext context, int index) {
                            final EpgSlot slot = schedule[index];
                            final bool isLive = slot.isLive;
                            final bool isReminded =
                                _localRemindedIds.contains(slot.id);
                            final int remainingMins =
                                slot.remainingMinutesAt(effectiveNow);
                            final String badgeLabel = isLive
                                ? (ar ? 'يُبث الآن' : 'LIVE NOW')
                                : index == 1
                                    ? (ar ? 'التالي' : 'UP NEXT')
                                    : (ar ? 'لاحقاً' : 'LATER');
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isLive
                                    ? LiveLuxuryPalette.crimsonActiveRim
                                        .withValues(alpha: 0.10)
                                    : Colors.white.withValues(alpha: 0.04),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                border: Border.all(
                                  color: isLive
                                      ? LiveLuxuryPalette.crimsonActiveRim
                                          .withValues(alpha: 0.55)
                                      : Colors.white.withValues(alpha: 0.10),
                                  width: isLive ? 1.1 : 0.7,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isLive
                                              ? LiveLuxuryPalette
                                                  .crimsonActiveRim
                                              : Colors.white
                                                  .withValues(alpha: 0.08),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(999),
                                          ),
                                        ),
                                        child: Text(
                                          badgeLabel,
                                          style: LiveBroadcastType.style(
                                            context,
                                            size: 10.5,
                                            weight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: Text(
                                          isLive
                                              ? '${slot.timeRangeLabel}  •  ${ar ? 'متبقي $remainingMins د' : '${remainingMins}m left'}'
                                              : slot.timeRangeLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: LiveBroadcastType.style(
                                            context,
                                            size: 11.5,
                                            weight: FontWeight.w600,
                                            color: isLive
                                                ? LiveLuxuryPalette
                                                    .warmNowStreaming
                                                : LiveLuxuryPalette
                                                    .cinemaSilver,
                                            tabular: true,
                                          ),
                                        ),
                                      ),
                                      if (isLive && widget.onWatchLive != null)
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            widget.onWatchLive!();
                                          },
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(999),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(999),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const Icon(
                                                  Icons.play_arrow_rounded,
                                                  size: 15,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  ar ? 'مشاهدة' : 'Watch',
                                                  style:
                                                      LiveBroadcastType.style(
                                                    context,
                                                    size: 11,
                                                    weight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else if (!isLive)
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () =>
                                                _handleToggleReminder(slot),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(999),
                                            ),
                                            child: AnimatedContainer(
                                              duration: AppDurations.fast,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isReminded
                                                    ? LiveLuxuryPalette
                                                        .warmNowStreaming
                                                        .withValues(alpha: 0.18)
                                                    : Colors.white.withValues(
                                                        alpha: 0.07,
                                                      ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(999),
                                                ),
                                                border: Border.all(
                                                  color: isReminded
                                                      ? LiveLuxuryPalette
                                                          .warmNowStreaming
                                                          .withValues(
                                                          alpha: 0.55,
                                                        )
                                                      : Colors.white.withValues(
                                                          alpha: 0.14,
                                                        ),
                                                  width: 0.7,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Icon(
                                                    isReminded
                                                        ? Icons
                                                            .notifications_active_rounded
                                                        : Icons
                                                            .notifications_none_rounded,
                                                    size: 15,
                                                    color: isReminded
                                                        ? LiveLuxuryPalette
                                                            .warmNowStreaming
                                                        : Colors.white
                                                            .withValues(
                                                            alpha: 0.85,
                                                          ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    isReminded
                                                        ? (ar
                                                            ? 'مفعّل'
                                                            : 'Reminded')
                                                        : (ar
                                                            ? 'ذكّرني'
                                                            : 'Remind'),
                                                    style:
                                                        LiveBroadcastType.style(
                                                      context,
                                                      size: 11,
                                                      weight: FontWeight.w600,
                                                      color: isReminded
                                                          ? LiveLuxuryPalette
                                                              .warmNowStreaming
                                                          : Colors.white
                                                              .withValues(
                                                              alpha: 0.85,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Text(
                                    slot.title(ar),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: LiveBroadcastType.style(
                                      context,
                                      size: 14,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    slot.description(ar),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: LiveBroadcastType.style(
                                      context,
                                      size: 12,
                                      weight: FontWeight.w400,
                                      color: LiveLuxuryPalette.cinemaSilver,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (isLive) ...<Widget>[
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(3),
                                      ),
                                      child: Container(
                                        height: 3,
                                        width: double.infinity,
                                        color:
                                            Colors.white.withValues(alpha: 0.14),
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: FractionallySizedBox(
                                          widthFactor:
                                              slot.progressAt(effectiveNow),
                                          child: Container(
                                            color: LiveLuxuryPalette
                                                .crimsonActiveRim,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
//  4. EqualizerBars, AnimatedStudioCanvas, FloatingUnmutePill & QualityPickerSheet
// ─────────────────────────────────────────────────────────────────────────────
class EqualizerBars extends StatelessWidget {
  final Animation<double> animation;
  final bool isActive;
  final Color color;
  final double height;
  final double barWidth;
  const EqualizerBars({
    super.key,
    required this.animation,
    required this.isActive,
    this.color = const Color(0xFFD0D0DA),
    this.height = 12,
    this.barWidth = 2.0,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, _) {
        final double t = animation.value * 2 * math.pi;
        const List<double> phases = <double>[0.0, 1.3, 2.5, 3.8];
        const List<double> speeds = <double>[1.0, 2.0, 1.5, 2.5];
        return SizedBox(
          height: height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List<Widget>.generate(4, (int i) {
              final double factor = isActive
                  ? (0.26 +
                      0.74 * ((math.sin(t * speeds[i] + phases[i]) + 1.0) * 0.5))
                  : 0.24;
              return Container(
                width: barWidth,
                height: (height * factor).clamp(2.5, height),
                margin: EdgeInsetsDirectional.only(end: i < 3 ? 1.8 : 0.0),
                decoration: BoxDecoration(
                  color: isActive ? color : color.withValues(alpha: 0.32),
                  borderRadius: const BorderRadius.all(Radius.circular(1.5)),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
class AnimatedStudioCanvas extends StatelessWidget {
  final Animation<double> animation;
  final LiveChannel channel;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  const AnimatedStudioCanvas({
    super.key,
    required this.channel,
    required this.animation,
    this.isLoading = false,
    this.hasError = false,
    required this.onRetry,
  });
  @override
  Widget build(BuildContext context) {
    final bool ar = LiveBroadcastType.isAr(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, _) {
            return CustomPaint(
              painter: _StudioBackdropPainter(
                progress: animation.value,
                primary: channel.brandPrimary,
                secondary: channel.brandSecondary,
              ),
            );
          },
        ),
        if (isLoading || hasError)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xD60C0C10),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: LiveLuxuryPalette.hairlineMedium,
                          width: 0.6,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              if (!hasError)
                                SizedBox(
                                  width: 68,
                                  height: 68,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    color: LiveLuxuryPalette.crimsonActiveRim,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.10),
                                  ),
                                ),
                              NetworkEmblem(
                                channel: channel,
                                size: 48,
                                borderRadius: 12,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hasError
                                ? (ar
                                    ? 'تعذر استلام إشارة البث المباشر حالياً'
                                    : 'Live broadcast signal interrupted')
                                : (ar
                                    ? 'جاري تهيئة البث المباشر...'
                                    : 'Preparing live broadcast...'),
                            style: LiveBroadcastType.style(
                              context,
                              size: 12.5,
                              weight: FontWeight.w500,
                              color: LiveLuxuryPalette.cinemaSilver,
                            ),
                          ),
                          if (hasError) ...<Widget>[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: onRetry,
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.08),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 38),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 9,
                                ),
                                side: const BorderSide(
                                  color: LiveLuxuryPalette.hairlineMedium,
                                  width: 0.7,
                                ),
                                shape: const StadiumBorder(),
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 15),
                              label: Text(
                                ar ? 'إعادة الاتصال' : 'Reconnect',
                                style: LiveBroadcastType.style(
                                  context,
                                  size: 12,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
class _StudioBackdropPainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color secondary;
  const _StudioBackdropPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final Rect full = Offset.zero & size;
    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color.lerp(const Color(0xFF0A0A0F), secondary, 0.22)!,
          const Color(0xFF07070A),
          LiveLuxuryPalette.obsidianCanvas,
        ],
      ).createShader(full);
    canvas.drawRect(full, basePaint);
    final double angle = progress * 2 * math.pi;
    final Offset orb1 = Offset(
      size.width * (0.30 + 0.12 * math.cos(angle)),
      size.height * (0.36 + 0.10 * math.sin(angle)),
    );
    final Offset orb2 = Offset(
      size.width * (0.72 + 0.10 * math.sin(angle)),
      size.height * (0.66 + 0.12 * math.cos(angle)),
    );
    final double r1 = size.shortestSide * 0.66;
    canvas.drawCircle(
      orb1,
      r1,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            primary.withValues(alpha: 0.18),
            primary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: orb1, radius: r1)),
    );
    final double r2 = size.shortestSide * 0.54;
    canvas.drawCircle(
      orb2,
      r2,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            secondary.withValues(alpha: 0.14),
            secondary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: orb2, radius: r2)),
    );
  }
  @override
  bool shouldRepaint(covariant _StudioBackdropPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary;
  }
}
class FloatingUnmutePill extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;
  const FloatingUnmutePill({
    super.key,
    required this.pulseAnimation,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final bool ar = LiveBroadcastType.isAr(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: pulseAnimation,
          builder: (BuildContext context, Widget? child) {
            final double rimAlpha = 0.14 + 0.08 * pulseAnimation.value;
            return ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xD90E0E12),
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: rimAlpha),
                      width: 0.7,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.volume_off_rounded,
                size: 15.5,
                color: Colors.white,
              ),
              const SizedBox(width: 7),
              Text(
                ar ? 'اضغط لتشغيل الصوت' : 'Tap to Unmute',
                style: LiveBroadcastType.style(
                  context,
                  size: 12,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class QualityPickerSheet extends StatelessWidget {
  final String selectedQuality;
  final ValueChanged<String> onSelect;
  const QualityPickerSheet({
    super.key,
    required this.selectedQuality,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) {
    final bool ar = LiveBroadcastType.isAr(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    final List<({String id, String title, String sub, String badge})> options =
        <({String id, String title, String sub, String badge})>[
      (
        id: 'Auto',
        title: l10n?.playerQualityAuto ?? (ar ? 'تلقائي ذكي' : 'Auto Adaptive'),
        sub: ar
            ? 'أفضل استقرار وزمن استجابة منخفض'
            : 'Instant start & zero buffering',
        badge: 'AUTO',
      ),
      (
        id: '4K HDR',
        title: ar ? 'فائق الوضوح 4K UHD' : '4K Ultra HD HDR',
        sub: '2160p60 • HDR10 • 24 Mbps',
        badge: '4K',
      ),
      (
        id: '1080p FHD',
        title: ar ? 'عالي الوضوح الكامل' : '1080p Full HD',
        sub: '1080p60 • High Frame Rate • 8.5 Mbps',
        badge: 'FHD',
      ),
      (
        id: '720p HD',
        title: ar ? 'جودة توفير البيانات' : '720p HD Data Saver',
        sub: '720p • Smooth Mobile Stream • 4 Mbps',
        badge: 'HD',
      ),
    ];
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.82;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: maxSheetHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: LiveLuxuryPalette.smokedPanel,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: LiveLuxuryPalette.hairlineSubtle,
              width: 0.6,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 36,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.tune_rounded,
                        color: LiveLuxuryPalette.silverSecondary,
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          l10n?.playerQuality ??
                              (ar ? 'جودة البث المباشر' : 'Stream Quality'),
                          style: LiveBroadcastType.style(
                            context,
                            size: 16.5,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: LiveLuxuryPalette.silverMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (final opt in options)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    onSelect(opt.id);
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedQuality == opt.id
                                          ? LiveLuxuryPalette.salonTileActive
                                          : LiveLuxuryPalette.obsidianCard,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(14),
                                      ),
                                      border: Border.all(
                                        color: selectedQuality == opt.id
                                            ? LiveLuxuryPalette.crimsonActiveRim
                                                .withValues(alpha: 0.55)
                                            : LiveLuxuryPalette.hairlineSubtle,
                                        width:
                                            selectedQuality == opt.id ? 1.0 : 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 48,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: LiveLuxuryPalette.mutedPill,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: LiveLuxuryPalette
                                                  .hairlineSubtle,
                                              width: 0.5,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            opt.badge,
                                            style: GoogleFonts.outfit(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.4,
                                              color: opt.id == '4K HDR'
                                                  ? LiveLuxuryPalette
                                                      .champagneSoft
                                                  : const Color(0xFFD0D0DA),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                opt.title,
                                                style: LiveBroadcastType.style(
                                                  context,
                                                  size: 13.5,
                                                  weight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                opt.sub,
                                                style: LiveBroadcastType.style(
                                                  context,
                                                  size: 11.5,
                                                  weight: FontWeight.w400,
                                                  color: LiveLuxuryPalette
                                                      .silverSecondary,
                                                  tabular: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (selectedQuality == opt.id)
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: LiveLuxuryPalette
                                                  .crimsonActiveRim,
                                            ),
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
