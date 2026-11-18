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
      initialSeekSeconds: 4,
      baseViewersK: 44.1,
      liveElapsedMinutes: 38,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'الملحمة السينمائية: أعماق المحيط المجهول (4K)',
          titleEn: 'Oceans: The Deep Horizon (4K Remaster)',
          descAr:
              'تحفة بصرية تأخذك في رحلة سينمائية مذهلة عبر العوالم الخفية بتقنية HDR10+.',
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
      initialSeekSeconds: 1,
      baseViewersK: 31.7,
      liveElapsedMinutes: 29,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'أفق الساحل الذهبي: الهروب الكبير',
          titleEn: 'Golden Coastline: The Grand Escape',
          descAr:
              'إثارة وتشويق على حافة الهاوية بتصوير جوي سينمائي فائق النقاء.',
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
          descAr: 'جولة خاصة في أحدث العروض العالمية ومهرانات السينما الدولية.',
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
      initialSeekSeconds: 1,
      baseViewersK: 27.5,
      liveElapsedMinutes: 44,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'ليلة الأضواء الهوليوودية الكبرى',
          titleEn: 'Hollywood Spotlight Premiere',
          descAr:
              'عرض أول لأحدث إنتاجات هوليوود الموسيقية والدرامية بدون أي فواصل إعلانية.',
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
      initialSeekSeconds: 1,
      baseViewersK: 63.8,
      liveElapsedMinutes: 22,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'حصاد اليوم الإخباري المباشر',
          titleEn: 'Global News Hour — Live Coverage',
          descAr:
              'تغطية ميدانية حية عبر شبكة المراسلين في العواصم العالمية وتحليل آخر المستجدات.',
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
      initialSeekSeconds: 0,
      baseViewersK: 39.2,
      liveElapsedMinutes: 16,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'غرفة الأخبار العاجلة والأسواق',
          titleEn: 'World Breaking Briefing',
          descAr:
              'آخر الأنباء العاجلة، تحديثات التكنولوجيا، وموجز الأسواق المالية لحظة بلحظة.',
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
      initialSeekSeconds: 1,
      baseViewersK: 29.6,
      liveElapsedMinutes: 31,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'أسرار البرية الأفريقية 4K: عمالقة السافانا',
          titleEn: 'Untamed Savanna 4K: Giants of Africa',
          descAr:
              'عدسات فائقة الدقة ترصد رحلة الفيلة والأسود في قلب السافانا الأفريقية.',
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
      initialSeekSeconds: 1,
      baseViewersK: 22.4,
      liveElapsedMinutes: 19,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'عالم المرجان الأزرق: استكشاف الأعماق',
          titleEn: 'Blue Reef Odyssey: Deep Dive UHD',
          descAr:
              'مهمة علمية حديثة لتصوير الشعاب المرجانية النادرة بتقنيات الإضاءة الطيفية.',
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
      category: LiveCategory.entertainment,
      brandPrimary: Color(0xFFFF5500),
      brandSecondary: Color(0xFF151515),
      brandAccent: Color(0xFFFFB400),
      emblemStyle: EmblemStyle.ribbonSplit,
      streamUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      initialSeekSeconds: 0,
      baseViewersK: 51.0,
      liveElapsedMinutes: 27,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'تحدي السرعة والأدرينالين المباشر',
          titleEn: 'Adrenaline Rush: Extreme Challenge',
          descAr:
              'منافسات سرعة ومغامرات تحبس الأنفاس بمشاركة نخبة المحترفين عالمياً.',
          descEn:
              'High-octane motorsport stunts and extreme precision challenges.',
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
      category: LiveCategory.entertainment,
      brandPrimary: Color(0xFFFF007F),
      brandSecondary: Color(0xFF3A0CA3),
      brandAccent: Color(0xFF00E5FF),
      emblemStyle: EmblemStyle.royalGold,
      streamUrl:
          'https://cdn.jsdelivr.net/gh/mediaelement/mediaelement-files@master/big_buck_bunny.mp4',
      initialSeekSeconds: 12,
      baseViewersK: 47.3,
      liveElapsedMinutes: 35,
      programSeeds: <EpgProgramSeed>[
        EpgProgramSeed(
          titleAr: 'ماراثون عالم الأنمي والخيال (بث متواصل)',
          titleEn: 'Fantasy Anime Marathon (Non-Stop)',
          descAr:
              'مغامرات ملحمية وتحريك سينمائي فائق السلاسة بمعدل 60 إطاراً في الثانية.',
          descEn:
              'Epic animated adventure remastered with vibrant HDR colors.',
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
//  1. NetworkEmblem — Zero-External-Image Programmatic Broadcast Emblem
// ─────────────────────────────────────────────────────────────────────────────

class NetworkEmblem extends StatelessWidget {
  final LiveChannel channel;
  final double size;
  final double borderRadius;

  const NetworkEmblem({
    super.key,
    required this.channel,
    this.size = 48,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: channel.brandPrimary.withValues(alpha: 0.28),
            blurRadius: size * 0.24,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        child: _buildStyledBody(),
      ),
    );
  }

  Widget _buildStyledBody() {
    switch (channel.emblemStyle) {
      case EmblemStyle.yellowPortal:
        return Container(
          decoration: BoxDecoration(
            color: channel.brandSecondary,
            border: Border.all(
              color: channel.brandAccent.withValues(alpha: 0.85),
              width: size >= 44 ? 2.2 : 1.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          padding: EdgeInsets.all(size * 0.10),
          child: Row(
            children: <Widget>[
              Container(
                width: size * 0.18,
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: channel.brandAccent,
                    width: size >= 44 ? 2.0 : 1.3,
                  ),
                ),
              ),
              SizedBox(width: size * 0.07),
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
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          height: 1.05,
                        ),
                      ),
                      Text(
                        channel.emblemBottom,
                        style: GoogleFonts.outfit(
                          color: channel.brandAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 8.5,
                          letterSpacing: 0.6,
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
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 54,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          channel.brandPrimary,
                          channel.brandPrimary.withValues(alpha: 0.82),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        channel.emblemTop,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                Expanded(
                  flex: 46,
                  child: Container(
                    width: double.infinity,
                    color: channel.brandSecondary,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        channel.emblemBottom,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w800,
                          fontSize: 8.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.glassGradient,
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ],
        );

      case EmblemStyle.saudiCrest:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[channel.brandPrimary, channel.brandSecondary],
            ),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            border: Border.all(
              color: channel.brandAccent.withValues(alpha: 0.55),
              width: 1.0,
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
                  height: size * 0.08,
                  color: channel.brandAccent,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(size * 0.12),
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
                          fontSize: 15,
                          letterSpacing: 1.0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: channel.brandAccent,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          channel.emblemBottom,
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 7.5,
                            letterSpacing: 0.5,
                          ),
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[channel.brandSecondary, const Color(0xFF0A0F1D)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            border: Border.all(
              color: channel.brandPrimary.withValues(alpha: 0.65),
              width: 1.0,
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        channel.emblemTop,
                        style: AppTextStyles.arabic(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: channel.brandPrimary,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                color: channel.brandPrimary,
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    channel.emblemBottom,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 7.5,
                      letterSpacing: 0.5,
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
              colors: <Color>[channel.brandPrimary, channel.brandSecondary],
            ),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            border: Border.all(
              color: (isGold ? channel.brandAccent : Colors.white)
                  .withValues(alpha: isGold ? 0.45 : 0.20),
              width: 1.0,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              PositionedDirectional(
                end: -size * 0.22,
                top: -size * 0.22,
                child: Container(
                  width: size * 0.65,
                  height: size * 0.65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: channel.brandAccent.withValues(alpha: 0.18),
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
                          fontSize: 13.5,
                          letterSpacing: 0.5,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        channel.emblemBottom,
                        style: GoogleFonts.inter(
                          color: isGold
                              ? channel.brandAccent
                              : Colors.white.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w800,
                          fontSize: 8.0,
                          letterSpacing: 0.7,
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
    this.color = AppColors.accentCyan,
    this.height = 14,
    this.barWidth = 2.6,
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
                  ? (0.28 +
                      0.72 *
                          ((math.sin(t * speeds[i] + phases[i]) + 1.0) * 0.5))
                  : 0.22;
              return Container(
                width: barWidth,
                height: (height * factor).clamp(3.0, height),
                margin: EdgeInsetsDirectional.only(end: i < 3 ? 2.0 : 0.0),
                decoration: BoxDecoration(
                  color: isActive ? color : color.withValues(alpha: 0.40),
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}