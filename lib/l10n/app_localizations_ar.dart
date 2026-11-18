// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سكاي لايف';

  @override
  String get tagline => 'قصص حسب الطلب.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMovies => 'أفلام';

  @override
  String get navSeries => 'مسلسلات';

  @override
  String get navKids => 'أطفال';

  @override
  String get navMe => 'حسابي';

  @override
  String get tabForYou => 'مقترح لك';

  @override
  String get tabAnime => 'أنمي';

  @override
  String get actionPlay => 'تشغيل';

  @override
  String get actionDownload => 'تنزيل';

  @override
  String get actionDownloaded => 'تم التنزيل';

  @override
  String get actionMyList => 'قائمتي';

  @override
  String get actionInMyList => 'في قائمتي';

  @override
  String get actionRate => 'تقييم';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionCast => 'بث';

  @override
  String get snackAddedToMyList => 'تمت الإضافة إلى قائمتي';

  @override
  String get snackRemovedFromMyList => 'تمت الإزالة من قائمتي';

  @override
  String get snackDownloadStarted => 'بدأ التنزيل';

  @override
  String get snackDownloadRemoved => 'تم حذف التنزيل';

  @override
  String snackShareLink(String title) {
    return 'تم نسخ رابط المشاركة لـ $title';
  }

  @override
  String get snackCastUnavailable => 'لم يتم العثور على جهاز بث';

  @override
  String get snackThanksForRating => 'شكراً على تقييمك';

  @override
  String get snackComingSoon => 'قريباً';

  @override
  String get snackSettingsSaved => 'تم حفظ الإعدادات';

  @override
  String get detailRateTitle => 'قيّم هذا العنوان';

  @override
  String get rateLove => 'أعجبني جداً';

  @override
  String get rateLike => 'أعجبني';

  @override
  String get rateNotForMe => 'لم يعجبني';

  @override
  String get actionInfo => 'تفاصيل';

  @override
  String get actionSeeAll => 'عرض الكل';

  @override
  String get actionSwitch => 'تبديل';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get search => 'بحث';

  @override
  String get searchHint => 'قناة، فيلم، مسلسل، شخص…';

  @override
  String get searchRecent => 'الأخيرة';

  @override
  String get searchTrending => 'الأكثر بحثاً';

  @override
  String get searchEmptyTitle => 'آسفون، لا تتوفر لدينا.';

  @override
  String get searchEmptyHint => 'جرّب عنواناً، أو ممثلاً، أو نوعاً آخر.';

  @override
  String get browseGenre => 'النوع';

  @override
  String get browseRegion => 'المنطقة';

  @override
  String get browseYear => 'السنة';

  @override
  String get browseSort => 'الفرز';

  @override
  String get browseAll => 'الكل';

  @override
  String get sortNewlyAdded => 'أضيف حديثاً';

  @override
  String get sortTopRated => 'الأعلى تقييماً';

  @override
  String get sortReleaseDate => 'تاريخ الإصدار';

  @override
  String get rowTopPicks => 'أفضل الاختيارات';

  @override
  String get rowNewReleases => 'إصدارات جديدة';

  @override
  String get rowTrending => 'الأكثر رواجاً';

  @override
  String get rowContinueWatching => 'متابعة المشاهدة';

  @override
  String get rowCriticsCorner => 'اختيارات النقاد';

  @override
  String get rowTopMovies => 'أفضل الأفلام';

  @override
  String get rowNewMovies => 'أفلام جديدة';

  @override
  String get rowActionThriller => 'أكشن وإثارة';

  @override
  String get rowDramaPicks => 'اختيارات درامية';

  @override
  String get rowTopSeries => 'أفضل المسلسلات';

  @override
  String get rowNewSeries => 'مسلسلات جديدة';

  @override
  String get rowMystery => 'غموض وإثارة';

  @override
  String get rowDocumentaries => 'وثائقيات';

  @override
  String get rowForLittleOnes => 'للصغار';

  @override
  String get rowBedtime => 'قصص قبل النوم';

  @override
  String get rowLearnPlay => 'تعلّم والعب';

  @override
  String get rowAllTitles => 'كل العناوين';

  @override
  String get rowBrowseByStudio => 'تصفّح حسب الاستوديو';

  @override
  String get kindMovie => 'فيلم';

  @override
  String get kindSeries => 'مسلسل';

  @override
  String get kindKids => 'أطفال';

  @override
  String get detailEpisodes => 'الحلقات';

  @override
  String get detailAbout => 'حول';

  @override
  String get detailMoreLikeThis => 'أعمال مشابهة';

  @override
  String get detailCast => 'طاقم العمل';

  @override
  String detailSeason(int n) {
    return 'الموسم $n';
  }

  @override
  String get aboutGenres => 'الأنواع';

  @override
  String get aboutYear => 'السنة';

  @override
  String get aboutRuntime => 'المدة';

  @override
  String get aboutAudio => 'الصوت';

  @override
  String get aboutSubtitles => 'الترجمة';

  @override
  String get aboutCastLabel => 'الطاقم';

  @override
  String get playerLock => 'قفل';

  @override
  String get playerNext => 'التالي';

  @override
  String get playerExit => 'خروج';

  @override
  String get playerBrightness => 'السطوع';

  @override
  String get playerVolume => 'الصوت';

  @override
  String get playerSpeed => 'سرعة التشغيل';

  @override
  String get playerQuality => 'الجودة';

  @override
  String get playerSubtitles => 'الترجمة';

  @override
  String get playerAudio => 'الصوت';

  @override
  String get playerAspect => 'نسبة العرض';

  @override
  String get playerAspectFit => 'ملاءمة';

  @override
  String get playerQualityAuto => 'تلقائي';

  @override
  String get meStandardProfile => 'حساب اعتيادي';

  @override
  String get meKidsProfile => 'حساب أطفال';

  @override
  String get meSwitch => 'تبديل';

  @override
  String get tileDownloads => 'التنزيلات';

  @override
  String get tileHistory => 'سجل المشاهدة';

  @override
  String get meWhosWatching => 'من يشاهد؟';

  @override
  String get meWhosWatchingHint => 'اضغط على ملف لبدء المشاهدة';

  @override
  String get meAddProfile => 'إضافة حساب';

  @override
  String get meKidsBadge => 'أطفال';

  @override
  String get menuSettings => 'الإعدادات';

  @override
  String get menuConnectTV => 'الاتصال بالتلفاز';

  @override
  String get menuParental => 'الرقابة الأبوية';

  @override
  String get menuLanguage => 'لغة التطبيق';

  @override
  String get menuNotifications => 'الإشعارات';

  @override
  String get menuHelp => 'مركز المساعدة';

  @override
  String get menuAbout => 'عن سكاي لايف';

  @override
  String get menuLogout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل تريد تسجيل الخروج من هذا الملف؟';

  @override
  String get myListTitle => 'قائمتي';

  @override
  String get myListEmptyTitle => 'لا يوجد شيء هنا بعد';

  @override
  String get myListEmptyHint => 'اضغط على أيقونة + لإضافة عمل إلى قائمتك.';

  @override
  String get downloadsTitle => 'التنزيلات';

  @override
  String get downloadsNote =>
      'تبقى التنزيلات على هذا الجهاز وتنتهي صلاحيتها بعد 30 يوماً.';

  @override
  String get downloadsReady => 'جاهز للمشاهدة';

  @override
  String get downloadsDownloading => 'جارٍ التنزيل…';

  @override
  String get downloadsEmptyTitle => 'لا توجد تنزيلات بعد';

  @override
  String get downloadsEmptyHint =>
      'اضغط على أيقونة التنزيل في أي عنوان لحفظه هنا.';

  @override
  String get downloadsClearTitle => 'حذف كل التنزيلات؟';

  @override
  String get downloadsClearMessage =>
      'سيتم إزالة جميع العناوين المنزّلة من هذا الجهاز.';

  @override
  String get dialogCancel => 'إلغاء';

  @override
  String get dialogConfirm => 'تأكيد';

  @override
  String get premiumTitle => 'البريميوم';

  @override
  String get premiumUnlock => 'افتح سكاي لايف بريميوم';

  @override
  String get premiumPitch =>
      'جودة 4K HDR، بدون إعلانات، 4 شاشات في وقت واحد، تنزيل للمشاهدة دون اتصال.';

  @override
  String get premiumChoose => 'اختر باقة';

  @override
  String get premiumWhat => 'ما تحصل عليه';

  @override
  String get premiumFeature4k => 'حتى 4K HDR';

  @override
  String get premiumFeatureDevices => 'المشاهدة على 4 أجهزة';

  @override
  String get premiumFeatureOffline => 'تنزيل ومشاهدة دون اتصال';

  @override
  String get premiumFeatureNoAds => 'بدون إعلانات';

  @override
  String get premiumFeatureLangs => 'صوت وترجمة بعدة لغات';

  @override
  String premiumContinueWith(String plan) {
    return 'المتابعة مع $plan';
  }

  @override
  String get premiumCancel => 'يمكنك الإلغاء في أي وقت من الإعدادات.';

  @override
  String get premiumGoCta => 'اشترك في البريميوم';

  @override
  String get premiumGoSub => '4K + بدون إعلانات + بث متزامن';

  @override
  String get planBasicName => 'أساسية';

  @override
  String get planBasicDesc => '720p · شاشة واحدة';

  @override
  String get planStandardName => 'قياسية';

  @override
  String get planStandardDesc => 'Full HD · شاشتان · تنزيل';

  @override
  String get planPremiumName => 'بريميوم';

  @override
  String get planPremiumDesc => '4K HDR · 4 شاشات · تنزيل';

  @override
  String get planPerMonth => 'شهرياً';

  @override
  String get premiumRedirect => 'جارٍ التحويل إلى الدفع…';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsGroupPlayback => 'التشغيل';

  @override
  String get settingsGroupDownloads => 'التنزيلات';

  @override
  String get settingsGroupApp => 'التطبيق';

  @override
  String get settingsAppLanguage => 'لغة التطبيق';

  @override
  String get settingsVideoQuality => 'جودة الفيديو';

  @override
  String get settingsSubtitleStyle => 'نمط الترجمة';

  @override
  String get settingsPreferredAudio => 'اللغة الصوتية المفضّلة';

  @override
  String get settingsDataSaver => 'موفّر البيانات';

  @override
  String get settingsAutoplayNext => 'تشغيل تلقائي للحلقة التالية';

  @override
  String get settingsAutoplayPreviews => 'تشغيل تلقائي للمعاينات';

  @override
  String get settingsDownloadLocation => 'موقع التنزيل';

  @override
  String get settingsDownloadLocationValue =>
      'الذاكرة الداخلية · 14.3 جيجا متاحة';

  @override
  String get settingsDownloadQuality => 'جودة التنزيل';

  @override
  String get settingsWifiOnly => 'التنزيل عبر Wi-Fi فقط';

  @override
  String get settingsClearDownloads => 'مسح التنزيلات';

  @override
  String get settingsManageDevices => 'إدارة الأجهزة';

  @override
  String get settingsAboutApp => 'عن سكاي لايف';

  @override
  String settingsAppVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsClearCache => 'مسح الذاكرة المؤقتة';

  @override
  String settingsCacheSize(int mb) {
    return '$mb ميجا';
  }

  @override
  String get settingsValueAuto => 'تلقائي';

  @override
  String get settingsValueStandard => 'قياسي';

  @override
  String get settingsValueHigh => 'عالي';

  @override
  String get settingsValueDataSaver => 'موفر البيانات';

  @override
  String get audioFrench => 'الفرنسية';

  @override
  String get audioSpanish => 'الإسبانية';

  @override
  String get subtitleStyleDefault => 'افتراضي';

  @override
  String get subtitleStyleLarge => 'كبير';

  @override
  String get subtitleStyleSmall => 'صغير';

  @override
  String get languageDialogTitle => 'لغة التطبيق';

  @override
  String get languageSystem => 'حسب لغة الجهاز';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get qualityHd => 'جودة عالية';

  @override
  String get kidsTopicLearn => 'تعلّم';

  @override
  String get kidsTopicAdventure => 'مغامرات';

  @override
  String get kidsTopicSongs => 'أغانٍ';

  @override
  String get kidsTopicStories => 'قصص';

  @override
  String get kidsTopicAnimals => 'حيوانات';

  @override
  String get kidsTopicBedtime => 'ما قبل النوم';

  @override
  String get navLive => 'البث المباشر';

  @override
  String get navGames => 'ألعاب';

  @override
  String get liveTvTitle => 'البث المباشر';

  @override
  String get liveCatAll => 'الكل';

  @override
  String get liveCatNews => 'أخبار';

  @override
  String get liveCatSports => 'رياضة';

  @override
  String get liveCatMovies => 'أفلام';

  @override
  String get liveCatEntertainment => 'ترفيه';

  @override
  String get liveCatKids => 'أطفال';

  @override
  String get liveCatMusic => 'موسيقى';

  @override
  String get liveCatDocs => 'وثائقي';

  @override
  String channelGenericName(int n) {
    return 'قناة $n';
  }

  @override
  String get channelNowGeneric => 'الآن على الهواء';

  @override
  String get gamesTitle => 'الألعاب';

  @override
  String get gamesFeaturedTitle => 'تحدي اليوم';

  @override
  String get gamesFeaturedSub => 'اربح عملات بالمشاركة اليوم';

  @override
  String get gamesSectionTrending => 'الأكثر رواجاً';

  @override
  String get gamesSectionCasual => 'كاجوال';

  @override
  String get gamesSectionPuzzle => 'ألغاز';

  @override
  String gameGenericName(int n) {
    return 'لعبة $n';
  }

  @override
  String get rowTop10 => 'الأكثر مشاهدة اليوم';

  @override
  String get rowTopChannels => 'أفضل القنوات المباشرة';

  @override
  String get rowNetworks => 'الشبكات';

  @override
  String networkLabel(int n) {
    return 'استوديو $n';
  }

  @override
  String get liveTvGuide => 'دليل القنوات';

  @override
  String get liveNoGuideAvailable => 'لا يوجد دليل متاح';

  @override
  String get liveNoChannelsInCategory => 'لا توجد قنوات حالياً في هذه الفئة';

  @override
  String get homeContentComingSoon => 'المحتوى قادم قريباً';

  @override
  String get homeContentAdminPanel =>
      'سيتم إضافة المسلسلات والأفلام من لوحة الإدارة';

  @override
  String get actionWatchNow => 'شاهد الآن';
}
