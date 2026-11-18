import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sky Live'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Stories, on demand.'**
  String get tagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get navMovies;

  /// No description provided for @navSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get navSeries;

  /// No description provided for @navKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get navKids;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @tabForYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get tabForYou;

  /// No description provided for @tabAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get tabAnime;

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get actionPlay;

  /// No description provided for @actionDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get actionDownload;

  /// No description provided for @actionDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get actionDownloaded;

  /// No description provided for @actionMyList.
  ///
  /// In en, this message translates to:
  /// **'My List'**
  String get actionMyList;

  /// No description provided for @actionInMyList.
  ///
  /// In en, this message translates to:
  /// **'On My List'**
  String get actionInMyList;

  /// No description provided for @actionRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get actionRate;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionCast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get actionCast;

  /// No description provided for @snackAddedToMyList.
  ///
  /// In en, this message translates to:
  /// **'Added to My List'**
  String get snackAddedToMyList;

  /// No description provided for @snackRemovedFromMyList.
  ///
  /// In en, this message translates to:
  /// **'Removed from My List'**
  String get snackRemovedFromMyList;

  /// No description provided for @snackDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Download started'**
  String get snackDownloadStarted;

  /// No description provided for @snackDownloadRemoved.
  ///
  /// In en, this message translates to:
  /// **'Download removed'**
  String get snackDownloadRemoved;

  /// No description provided for @snackShareLink.
  ///
  /// In en, this message translates to:
  /// **'Share link copied for {title}'**
  String snackShareLink(String title);

  /// No description provided for @snackCastUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No cast device found'**
  String get snackCastUnavailable;

  /// No description provided for @snackThanksForRating.
  ///
  /// In en, this message translates to:
  /// **'Thanks for rating'**
  String get snackThanksForRating;

  /// No description provided for @snackComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get snackComingSoon;

  /// No description provided for @snackSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get snackSettingsSaved;

  /// No description provided for @detailRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate this title'**
  String get detailRateTitle;

  /// No description provided for @rateLove.
  ///
  /// In en, this message translates to:
  /// **'Loved it'**
  String get rateLove;

  /// No description provided for @rateLike.
  ///
  /// In en, this message translates to:
  /// **'Liked it'**
  String get rateLike;

  /// No description provided for @rateNotForMe.
  ///
  /// In en, this message translates to:
  /// **'Not for me'**
  String get rateNotForMe;

  /// No description provided for @actionInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get actionInfo;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @actionSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get actionSwitch;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Channel, movie, series, person…'**
  String get searchHint;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get searchRecent;

  /// No description provided for @searchTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending Searches'**
  String get searchTrending;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops. We don\'t have that yet.'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different title, actor, or genre.'**
  String get searchEmptyHint;

  /// No description provided for @browseGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get browseGenre;

  /// No description provided for @browseRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get browseRegion;

  /// No description provided for @browseYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get browseYear;

  /// No description provided for @browseSort.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get browseSort;

  /// No description provided for @browseAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get browseAll;

  /// No description provided for @sortNewlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Newly Added'**
  String get sortNewlyAdded;

  /// No description provided for @sortTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get sortTopRated;

  /// No description provided for @sortReleaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get sortReleaseDate;

  /// No description provided for @rowTopPicks.
  ///
  /// In en, this message translates to:
  /// **'Top Picks'**
  String get rowTopPicks;

  /// No description provided for @rowNewReleases.
  ///
  /// In en, this message translates to:
  /// **'New Releases'**
  String get rowNewReleases;

  /// No description provided for @rowTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get rowTrending;

  /// No description provided for @rowContinueWatching.
  ///
  /// In en, this message translates to:
  /// **'Continue Watching'**
  String get rowContinueWatching;

  /// No description provided for @rowCriticsCorner.
  ///
  /// In en, this message translates to:
  /// **'Critics\' Corner'**
  String get rowCriticsCorner;

  /// No description provided for @rowTopMovies.
  ///
  /// In en, this message translates to:
  /// **'Top Movies'**
  String get rowTopMovies;

  /// No description provided for @rowNewMovies.
  ///
  /// In en, this message translates to:
  /// **'New Movies'**
  String get rowNewMovies;

  /// No description provided for @rowActionThriller.
  ///
  /// In en, this message translates to:
  /// **'Action & Thrillers'**
  String get rowActionThriller;

  /// No description provided for @rowDramaPicks.
  ///
  /// In en, this message translates to:
  /// **'Drama Picks'**
  String get rowDramaPicks;

  /// No description provided for @rowTopSeries.
  ///
  /// In en, this message translates to:
  /// **'Top Series'**
  String get rowTopSeries;

  /// No description provided for @rowNewSeries.
  ///
  /// In en, this message translates to:
  /// **'New Series'**
  String get rowNewSeries;

  /// No description provided for @rowMystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery & Thrillers'**
  String get rowMystery;

  /// No description provided for @rowDocumentaries.
  ///
  /// In en, this message translates to:
  /// **'Documentaries'**
  String get rowDocumentaries;

  /// No description provided for @rowForLittleOnes.
  ///
  /// In en, this message translates to:
  /// **'For Little Ones'**
  String get rowForLittleOnes;

  /// No description provided for @rowBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime Stories'**
  String get rowBedtime;

  /// No description provided for @rowLearnPlay.
  ///
  /// In en, this message translates to:
  /// **'Learn & Play'**
  String get rowLearnPlay;

  /// No description provided for @rowAllTitles.
  ///
  /// In en, this message translates to:
  /// **'All Titles'**
  String get rowAllTitles;

  /// No description provided for @rowBrowseByStudio.
  ///
  /// In en, this message translates to:
  /// **'Browse by Studio'**
  String get rowBrowseByStudio;

  /// No description provided for @kindMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get kindMovie;

  /// No description provided for @kindSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get kindSeries;

  /// No description provided for @kindKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kindKids;

  /// No description provided for @detailEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get detailEpisodes;

  /// No description provided for @detailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get detailAbout;

  /// No description provided for @detailMoreLikeThis.
  ///
  /// In en, this message translates to:
  /// **'More Like This'**
  String get detailMoreLikeThis;

  /// No description provided for @detailCast.
  ///
  /// In en, this message translates to:
  /// **'Cast & Crew'**
  String get detailCast;

  /// No description provided for @detailSeason.
  ///
  /// In en, this message translates to:
  /// **'Season {n}'**
  String detailSeason(int n);

  /// No description provided for @aboutGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get aboutGenres;

  /// No description provided for @aboutYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get aboutYear;

  /// No description provided for @aboutRuntime.
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get aboutRuntime;

  /// No description provided for @aboutAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get aboutAudio;

  /// No description provided for @aboutSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get aboutSubtitles;

  /// No description provided for @aboutCastLabel.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get aboutCastLabel;

  /// No description provided for @playerLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get playerLock;

  /// No description provided for @playerNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get playerNext;

  /// No description provided for @playerExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get playerExit;

  /// No description provided for @playerBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get playerBrightness;

  /// No description provided for @playerVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get playerVolume;

  /// No description provided for @playerSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get playerSpeed;

  /// No description provided for @playerQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get playerQuality;

  /// No description provided for @playerSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get playerSubtitles;

  /// No description provided for @playerAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get playerAudio;

  /// No description provided for @playerAspect.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get playerAspect;

  /// No description provided for @playerAspectFit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get playerAspectFit;

  /// No description provided for @playerQualityAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get playerQualityAuto;

  /// No description provided for @meStandardProfile.
  ///
  /// In en, this message translates to:
  /// **'Standard profile'**
  String get meStandardProfile;

  /// No description provided for @meKidsProfile.
  ///
  /// In en, this message translates to:
  /// **'Kids profile'**
  String get meKidsProfile;

  /// No description provided for @meSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get meSwitch;

  /// No description provided for @tileDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get tileDownloads;

  /// No description provided for @tileHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tileHistory;

  /// No description provided for @meWhosWatching.
  ///
  /// In en, this message translates to:
  /// **'Who\'s watching?'**
  String get meWhosWatching;

  /// No description provided for @meWhosWatchingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a profile to start watching'**
  String get meWhosWatchingHint;

  /// No description provided for @meAddProfile.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get meAddProfile;

  /// No description provided for @meKidsBadge.
  ///
  /// In en, this message translates to:
  /// **'KIDS'**
  String get meKidsBadge;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuConnectTV.
  ///
  /// In en, this message translates to:
  /// **'Connect to TV'**
  String get menuConnectTV;

  /// No description provided for @menuParental.
  ///
  /// In en, this message translates to:
  /// **'Parental Controls'**
  String get menuParental;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get menuLanguage;

  /// No description provided for @menuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuNotifications;

  /// No description provided for @menuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get menuHelp;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About Sky Live'**
  String get menuAbout;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get menuLogout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this profile?'**
  String get logoutConfirm;

  /// No description provided for @myListTitle.
  ///
  /// In en, this message translates to:
  /// **'My List'**
  String get myListTitle;

  /// No description provided for @myListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get myListEmptyTitle;

  /// No description provided for @myListEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the + icon on a title to add it here.'**
  String get myListEmptyHint;

  /// No description provided for @downloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// No description provided for @downloadsNote.
  ///
  /// In en, this message translates to:
  /// **'Downloads stay on this device and expire after 30 days.'**
  String get downloadsNote;

  /// No description provided for @downloadsReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to watch'**
  String get downloadsReady;

  /// No description provided for @downloadsDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get downloadsDownloading;

  /// No description provided for @downloadsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get downloadsEmptyTitle;

  /// No description provided for @downloadsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the download icon on any title to save it here.'**
  String get downloadsEmptyHint;

  /// No description provided for @downloadsClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all downloads?'**
  String get downloadsClearTitle;

  /// No description provided for @downloadsClearMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all downloaded titles from this device.'**
  String get downloadsClearMessage;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirm;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock Sky Live Premium'**
  String get premiumUnlock;

  /// No description provided for @premiumPitch.
  ///
  /// In en, this message translates to:
  /// **'4K HDR, no ads, 4 simultaneous screens, offline downloads.'**
  String get premiumPitch;

  /// No description provided for @premiumChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get premiumChoose;

  /// No description provided for @premiumWhat.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get premiumWhat;

  /// No description provided for @premiumFeature4k.
  ///
  /// In en, this message translates to:
  /// **'Up to 4K HDR'**
  String get premiumFeature4k;

  /// No description provided for @premiumFeatureDevices.
  ///
  /// In en, this message translates to:
  /// **'Watch on up to 4 devices'**
  String get premiumFeatureDevices;

  /// No description provided for @premiumFeatureOffline.
  ///
  /// In en, this message translates to:
  /// **'Download and watch offline'**
  String get premiumFeatureOffline;

  /// No description provided for @premiumFeatureNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads, ever'**
  String get premiumFeatureNoAds;

  /// No description provided for @premiumFeatureLangs.
  ///
  /// In en, this message translates to:
  /// **'Multi-language audio & subtitles'**
  String get premiumFeatureLangs;

  /// No description provided for @premiumContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with {plan}'**
  String premiumContinueWith(String plan);

  /// No description provided for @premiumCancel.
  ///
  /// In en, this message translates to:
  /// **'You can cancel any time from settings.'**
  String get premiumCancel;

  /// No description provided for @premiumGoCta.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get premiumGoCta;

  /// No description provided for @premiumGoSub.
  ///
  /// In en, this message translates to:
  /// **'4K + no ads + simultaneous streams'**
  String get premiumGoSub;

  /// No description provided for @planBasicName.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get planBasicName;

  /// No description provided for @planBasicDesc.
  ///
  /// In en, this message translates to:
  /// **'720p · 1 screen'**
  String get planBasicDesc;

  /// No description provided for @planStandardName.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get planStandardName;

  /// No description provided for @planStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'Full HD · 2 screens · Downloads'**
  String get planStandardDesc;

  /// No description provided for @planPremiumName.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get planPremiumName;

  /// No description provided for @planPremiumDesc.
  ///
  /// In en, this message translates to:
  /// **'4K HDR · 4 screens · Downloads'**
  String get planPremiumDesc;

  /// No description provided for @planPerMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get planPerMonth;

  /// No description provided for @premiumRedirect.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to billing…'**
  String get premiumRedirect;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGroupPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsGroupPlayback;

  /// No description provided for @settingsGroupDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get settingsGroupDownloads;

  /// No description provided for @settingsGroupApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsGroupApp;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsAppLanguage;

  /// No description provided for @settingsVideoQuality.
  ///
  /// In en, this message translates to:
  /// **'Video Quality'**
  String get settingsVideoQuality;

  /// No description provided for @settingsSubtitleStyle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Style'**
  String get settingsSubtitleStyle;

  /// No description provided for @settingsPreferredAudio.
  ///
  /// In en, this message translates to:
  /// **'Preferred Audio'**
  String get settingsPreferredAudio;

  /// No description provided for @settingsDataSaver.
  ///
  /// In en, this message translates to:
  /// **'Data Saver'**
  String get settingsDataSaver;

  /// No description provided for @settingsAutoplayNext.
  ///
  /// In en, this message translates to:
  /// **'Auto-play Next'**
  String get settingsAutoplayNext;

  /// No description provided for @settingsAutoplayPreviews.
  ///
  /// In en, this message translates to:
  /// **'Auto-play Previews'**
  String get settingsAutoplayPreviews;

  /// No description provided for @settingsDownloadLocation.
  ///
  /// In en, this message translates to:
  /// **'Download Location'**
  String get settingsDownloadLocation;

  /// No description provided for @settingsDownloadLocationValue.
  ///
  /// In en, this message translates to:
  /// **'Internal · 14.3 GB free'**
  String get settingsDownloadLocationValue;

  /// No description provided for @settingsDownloadQuality.
  ///
  /// In en, this message translates to:
  /// **'Download Quality'**
  String get settingsDownloadQuality;

  /// No description provided for @settingsWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Download on Wi-Fi only'**
  String get settingsWifiOnly;

  /// No description provided for @settingsClearDownloads.
  ///
  /// In en, this message translates to:
  /// **'Clear Downloads'**
  String get settingsClearDownloads;

  /// No description provided for @settingsManageDevices.
  ///
  /// In en, this message translates to:
  /// **'Manage Devices'**
  String get settingsManageDevices;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Sky Live'**
  String get settingsAboutApp;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsAppVersion(String version);

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settingsClearCache;

  /// No description provided for @settingsCacheSize.
  ///
  /// In en, this message translates to:
  /// **'{mb} MB'**
  String settingsCacheSize(int mb);

  /// No description provided for @settingsValueAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsValueAuto;

  /// No description provided for @settingsValueStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get settingsValueStandard;

  /// No description provided for @settingsValueHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get settingsValueHigh;

  /// No description provided for @settingsValueDataSaver.
  ///
  /// In en, this message translates to:
  /// **'Data Saver'**
  String get settingsValueDataSaver;

  /// No description provided for @audioFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get audioFrench;

  /// No description provided for @audioSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get audioSpanish;

  /// No description provided for @subtitleStyleDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get subtitleStyleDefault;

  /// No description provided for @subtitleStyleLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get subtitleStyleLarge;

  /// No description provided for @subtitleStyleSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get subtitleStyleSmall;

  /// No description provided for @languageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get languageDialogTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @qualityHd.
  ///
  /// In en, this message translates to:
  /// **'HD'**
  String get qualityHd;

  /// No description provided for @kidsTopicLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get kidsTopicLearn;

  /// No description provided for @kidsTopicAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get kidsTopicAdventure;

  /// No description provided for @kidsTopicSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get kidsTopicSongs;

  /// No description provided for @kidsTopicStories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get kidsTopicStories;

  /// No description provided for @kidsTopicAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get kidsTopicAnimals;

  /// No description provided for @kidsTopicBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get kidsTopicBedtime;

  /// No description provided for @navLive.
  ///
  /// In en, this message translates to:
  /// **'Live TV'**
  String get navLive;

  /// No description provided for @navGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get navGames;

  /// No description provided for @liveTvTitle.
  ///
  /// In en, this message translates to:
  /// **'Live TV'**
  String get liveTvTitle;

  /// No description provided for @liveCatAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get liveCatAll;

  /// No description provided for @liveCatNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get liveCatNews;

  /// No description provided for @liveCatSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get liveCatSports;

  /// No description provided for @liveCatMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get liveCatMovies;

  /// No description provided for @liveCatEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get liveCatEntertainment;

  /// No description provided for @liveCatKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get liveCatKids;

  /// No description provided for @liveCatMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get liveCatMusic;

  /// No description provided for @liveCatDocs.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get liveCatDocs;

  /// No description provided for @channelGenericName.
  ///
  /// In en, this message translates to:
  /// **'Channel {n}'**
  String channelGenericName(int n);

  /// No description provided for @channelNowGeneric.
  ///
  /// In en, this message translates to:
  /// **'On now'**
  String get channelNowGeneric;

  /// No description provided for @gamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gamesTitle;

  /// No description provided for @gamesFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get gamesFeaturedTitle;

  /// No description provided for @gamesFeaturedSub.
  ///
  /// In en, this message translates to:
  /// **'Win coins by playing today'**
  String get gamesFeaturedSub;

  /// No description provided for @gamesSectionTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get gamesSectionTrending;

  /// No description provided for @gamesSectionCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get gamesSectionCasual;

  /// No description provided for @gamesSectionPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Puzzle'**
  String get gamesSectionPuzzle;

  /// No description provided for @gameGenericName.
  ///
  /// In en, this message translates to:
  /// **'Game {n}'**
  String gameGenericName(int n);

  /// No description provided for @rowTop10.
  ///
  /// In en, this message translates to:
  /// **'Top 10 Today'**
  String get rowTop10;

  /// No description provided for @rowTopChannels.
  ///
  /// In en, this message translates to:
  /// **'Top Live Channels'**
  String get rowTopChannels;

  /// No description provided for @rowNetworks.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get rowNetworks;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'Studio {n}'**
  String networkLabel(int n);

  /// No description provided for @liveTvGuide.
  ///
  /// In en, this message translates to:
  /// **'TV Guide'**
  String get liveTvGuide;

  /// No description provided for @liveNoGuideAvailable.
  ///
  /// In en, this message translates to:
  /// **'No guide available'**
  String get liveNoGuideAvailable;

  /// No description provided for @liveNoChannelsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No channels available in this category'**
  String get liveNoChannelsInCategory;

  /// No description provided for @homeContentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Content coming soon'**
  String get homeContentComingSoon;

  /// No description provided for @homeContentAdminPanel.
  ///
  /// In en, this message translates to:
  /// **'Movies and series will be added from the admin panel'**
  String get homeContentAdminPanel;

  /// No description provided for @actionWatchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get actionWatchNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
