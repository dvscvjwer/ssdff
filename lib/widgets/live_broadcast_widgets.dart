import 'dart:math' as math;
import 'dart:ui' show FontFeature, ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Typography & RTL/LTR Engine — SkyLive Broadcast v3.0
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
//  Broadcast Domain Models (Bilingual AR / EN + Dynamic EPG)
// ─────────────────────────────────────────────────────────────────────────────

enum LiveCategory {
  all,
  favorites,
  sports,
  movies,
  news,
  entertainment,
}

extension LiveCategoryX on LiveCategory {
  String label(BuildContext context, AppLocalizations? l10n) {
    final bool ar = LiveBroadcastType.isAr(context);
    switch (this) {
      case LiveCategory.all:
        return l10n?.liveCatAll ?? (ar ? 'الكل' : 'All');
      case LiveCategory.favorites:
        return ar ? 'المفضلة' : 'Favorites';
      case LiveCategory.sports:
        return l10n?.liveCatSports ?? (ar ? 'الرياضة' : 'Sports');
      case LiveCategory.movies:
        return l10n?.liveCatMovies ?? (ar ? 'الأفلام' : 'Movies');
      case LiveCategory.news:
        return l10n?.liveCatNews ?? (ar ? 'الأخبار' : 'News');
      case LiveCategory.entertainment:
        return ar ? 'الوثائقيات والترفيه' : 'Docs & Ent.';
    }
  }

  IconData get icon {
    switch (this) {
      case LiveCategory.all:
        return Icons.grid_view_rounded;
      case LiveCategory.favorites:
        return Icons.favorite_rounded;
      case LiveCategory.sports:
        return Icons.sports_soccer_rounded;
      case LiveCategory.movies:
        return Icons.local_movies_rounded;
      case LiveCategory.news:
        return Icons.public_rounded;
      case LiveCategory.entertainment:
        return Icons.explore_rounded;
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
//  13 World-Class Channels Catalog (100% CORS Verified HTTPS H.264 MP4s)
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
          titleAr: 'مباشر: ريال مدريد × مانشستر سيتي',
          titleEn: 'LIVE: Real Madrid vs Manchester City',
          descAr:
              'قمة ليالي الأبطال بتغطية استوديو 4K HDR مع إحصائيات تكتيكية حية وكاميرات خاصة.',
          descEn:
              'Champions League blockbuster in native 4K HDR with live tactical telemetry and studio analysis.',
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
          titleAr: 'مباشر: ليفربول × أرسنال (قمة البريميرليغ)',
          titleEn: 'LIVE: Liverpool vs Arsenal — Super Sunday',
          descAr:
              'صراع الصدارة المشتعل من ملعب أنفيلد مع إحصائيات السرعة والضغط العالي.',
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
          titleAr: 'مباشر: الهلال × النصر — ديربي الرياض',
          titleEn: 'LIVE: Al-Hilal vs Al-Nassr — Riyadh Derby',
          descAr:
              'قمة دوري روشن السعودي بنقل جوي عبر كاميرات العنكبوت و28 كاميرا سينمائية.',
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
          titleAr: 'مباشر 360°: برشلونة × بايرن ميونخ',
          titleEn: 'LIVE 360°: Barcelona vs Bayern Munich',
          descAr:
              'بث خاص بزاوية تكتيكية كاملة للملعب مع خريطة التمريرات الحية.',
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
          titleAr: 'سباق الفورمولا 1: التجارب الحرة',
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