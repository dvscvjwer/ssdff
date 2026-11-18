// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sky Live';

  @override
  String get tagline => 'Stories, on demand.';

  @override
  String get navHome => 'Home';

  @override
  String get navMovies => 'Movies';

  @override
  String get navSeries => 'Series';

  @override
  String get navKids => 'Kids';

  @override
  String get navMe => 'Me';

  @override
  String get tabForYou => 'For You';

  @override
  String get tabAnime => 'Anime';

  @override
  String get actionPlay => 'Play';

  @override
  String get actionDownload => 'Download';

  @override
  String get actionDownloaded => 'Downloaded';

  @override
  String get actionMyList => 'My List';

  @override
  String get actionInMyList => 'On My List';

  @override
  String get actionRate => 'Rate';

  @override
  String get actionShare => 'Share';

  @override
  String get actionCast => 'Cast';

  @override
  String get snackAddedToMyList => 'Added to My List';

  @override
  String get snackRemovedFromMyList => 'Removed from My List';

  @override
  String get snackDownloadStarted => 'Download started';

  @override
  String get snackDownloadRemoved => 'Download removed';

  @override
  String snackShareLink(String title) {
    return 'Share link copied for $title';
  }

  @override
  String get snackCastUnavailable => 'No cast device found';

  @override
  String get snackThanksForRating => 'Thanks for rating';

  @override
  String get snackComingSoon => 'Coming soon';

  @override
  String get snackSettingsSaved => 'Settings saved';

  @override
  String get detailRateTitle => 'Rate this title';

  @override
  String get rateLove => 'Loved it';

  @override
  String get rateLike => 'Liked it';

  @override
  String get rateNotForMe => 'Not for me';

  @override
  String get actionInfo => 'Info';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionSwitch => 'Switch';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionClose => 'Close';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Channel, movie, series, person…';

  @override
  String get searchRecent => 'Recent';

  @override
  String get searchTrending => 'Trending Searches';

  @override
  String get searchEmptyTitle => 'Oops. We don\'t have that yet.';

  @override
  String get searchEmptyHint => 'Try a different title, actor, or genre.';

  @override
  String get browseGenre => 'Genre';

  @override
  String get browseRegion => 'Region';

  @override
  String get browseYear => 'Year';

  @override
  String get browseSort => 'Sort by';

  @override
  String get browseAll => 'All';

  @override
  String get sortNewlyAdded => 'Newly Added';

  @override
  String get sortTopRated => 'Top Rated';

  @override
  String get sortReleaseDate => 'Release Date';

  @override
  String get rowTopPicks => 'Top Picks';

  @override
  String get rowNewReleases => 'New Releases';

  @override
  String get rowTrending => 'Trending Now';

  @override
  String get rowContinueWatching => 'Continue Watching';

  @override
  String get rowCriticsCorner => 'Critics\' Corner';

  @override
  String get rowTopMovies => 'Top Movies';

  @override
  String get rowNewMovies => 'New Movies';

  @override
  String get rowActionThriller => 'Action & Thrillers';

  @override
  String get rowDramaPicks => 'Drama Picks';

  @override
  String get rowTopSeries => 'Top Series';

  @override
  String get rowNewSeries => 'New Series';

  @override
  String get rowMystery => 'Mystery & Thrillers';

  @override
  String get rowDocumentaries => 'Documentaries';

  @override
  String get rowForLittleOnes => 'For Little Ones';

  @override
  String get rowBedtime => 'Bedtime Stories';

  @override
  String get rowLearnPlay => 'Learn & Play';

  @override
  String get rowAllTitles => 'All Titles';

  @override
  String get rowBrowseByStudio => 'Browse by Studio';

  @override
  String get kindMovie => 'Movie';

  @override
  String get kindSeries => 'Series';

  @override
  String get kindKids => 'Kids';

  @override
  String get detailEpisodes => 'Episodes';

  @override
  String get detailAbout => 'About';

  @override
  String get detailMoreLikeThis => 'More Like This';

  @override
  String get detailCast => 'Cast & Crew';

  @override
  String detailSeason(int n) {
    return 'Season $n';
  }

  @override
  String get aboutGenres => 'Genres';

  @override
  String get aboutYear => 'Year';

  @override
  String get aboutRuntime => 'Runtime';

  @override
  String get aboutAudio => 'Audio';

  @override
  String get aboutSubtitles => 'Subtitles';

  @override
  String get aboutCastLabel => 'Cast';

  @override
  String get playerLock => 'Lock';

  @override
  String get playerNext => 'Next';

  @override
  String get playerExit => 'Exit';

  @override
  String get playerBrightness => 'Brightness';

  @override
  String get playerVolume => 'Volume';

  @override
  String get playerSpeed => 'Playback Speed';

  @override
  String get playerQuality => 'Quality';

  @override
  String get playerSubtitles => 'Subtitles';

  @override
  String get playerAudio => 'Audio';

  @override
  String get playerAspect => 'Aspect Ratio';

  @override
  String get playerAspectFit => 'Fit';

  @override
  String get playerQualityAuto => 'Auto';

  @override
  String get meStandardProfile => 'Standard profile';

  @override
  String get meKidsProfile => 'Kids profile';

  @override
  String get meSwitch => 'Switch';

  @override
  String get tileDownloads => 'Downloads';

  @override
  String get tileHistory => 'History';

  @override
  String get meWhosWatching => 'Who\'s watching?';

  @override
  String get meWhosWatchingHint => 'Tap a profile to start watching';

  @override
  String get meAddProfile => 'Add Profile';

  @override
  String get meKidsBadge => 'KIDS';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuConnectTV => 'Connect to TV';

  @override
  String get menuParental => 'Parental Controls';

  @override
  String get menuLanguage => 'App Language';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuHelp => 'Help Center';

  @override
  String get menuAbout => 'About Sky Live';

  @override
  String get menuLogout => 'Log out';

  @override
  String get logoutConfirm => 'Sign out of this profile?';

  @override
  String get myListTitle => 'My List';

  @override
  String get myListEmptyTitle => 'Nothing here yet';

  @override
  String get myListEmptyHint => 'Tap the + icon on a title to add it here.';

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadsNote =>
      'Downloads stay on this device and expire after 30 days.';

  @override
  String get downloadsReady => 'Ready to watch';

  @override
  String get downloadsDownloading => 'Downloading…';

  @override
  String get downloadsEmptyTitle => 'No downloads yet';

  @override
  String get downloadsEmptyHint =>
      'Tap the download icon on any title to save it here.';

  @override
  String get downloadsClearTitle => 'Clear all downloads?';

  @override
  String get downloadsClearMessage =>
      'This will remove all downloaded titles from this device.';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumUnlock => 'Unlock Sky Live Premium';

  @override
  String get premiumPitch =>
      '4K HDR, no ads, 4 simultaneous screens, offline downloads.';

  @override
  String get premiumChoose => 'Choose a plan';

  @override
  String get premiumWhat => 'What you get';

  @override
  String get premiumFeature4k => 'Up to 4K HDR';

  @override
  String get premiumFeatureDevices => 'Watch on up to 4 devices';

  @override
  String get premiumFeatureOffline => 'Download and watch offline';

  @override
  String get premiumFeatureNoAds => 'No ads, ever';

  @override
  String get premiumFeatureLangs => 'Multi-language audio & subtitles';

  @override
  String premiumContinueWith(String plan) {
    return 'Continue with $plan';
  }

  @override
  String get premiumCancel => 'You can cancel any time from settings.';

  @override
  String get premiumGoCta => 'Go Premium';

  @override
  String get premiumGoSub => '4K + no ads + simultaneous streams';

  @override
  String get planBasicName => 'Basic';

  @override
  String get planBasicDesc => '720p · 1 screen';

  @override
  String get planStandardName => 'Standard';

  @override
  String get planStandardDesc => 'Full HD · 2 screens · Downloads';

  @override
  String get planPremiumName => 'Premium';

  @override
  String get planPremiumDesc => '4K HDR · 4 screens · Downloads';

  @override
  String get planPerMonth => 'per month';

  @override
  String get premiumRedirect => 'Redirecting to billing…';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGroupPlayback => 'Playback';

  @override
  String get settingsGroupDownloads => 'Downloads';

  @override
  String get settingsGroupApp => 'App';

  @override
  String get settingsAppLanguage => 'App Language';

  @override
  String get settingsVideoQuality => 'Video Quality';

  @override
  String get settingsSubtitleStyle => 'Subtitle Style';

  @override
  String get settingsPreferredAudio => 'Preferred Audio';

  @override
  String get settingsDataSaver => 'Data Saver';

  @override
  String get settingsAutoplayNext => 'Auto-play Next';

  @override
  String get settingsAutoplayPreviews => 'Auto-play Previews';

  @override
  String get settingsDownloadLocation => 'Download Location';

  @override
  String get settingsDownloadLocationValue => 'Internal · 14.3 GB free';

  @override
  String get settingsDownloadQuality => 'Download Quality';

  @override
  String get settingsWifiOnly => 'Download on Wi-Fi only';

  @override
  String get settingsClearDownloads => 'Clear Downloads';

  @override
  String get settingsManageDevices => 'Manage Devices';

  @override
  String get settingsAboutApp => 'About Sky Live';

  @override
  String settingsAppVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsClearCache => 'Clear Cache';

  @override
  String settingsCacheSize(int mb) {
    return '$mb MB';
  }

  @override
  String get settingsValueAuto => 'Auto';

  @override
  String get settingsValueStandard => 'Standard';

  @override
  String get settingsValueHigh => 'High';

  @override
  String get settingsValueDataSaver => 'Data Saver';

  @override
  String get audioFrench => 'French';

  @override
  String get audioSpanish => 'Spanish';

  @override
  String get subtitleStyleDefault => 'Default';

  @override
  String get subtitleStyleLarge => 'Large';

  @override
  String get subtitleStyleSmall => 'Small';

  @override
  String get languageDialogTitle => 'App Language';

  @override
  String get languageSystem => 'Use device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get qualityHd => 'HD';

  @override
  String get kidsTopicLearn => 'Learn';

  @override
  String get kidsTopicAdventure => 'Adventure';

  @override
  String get kidsTopicSongs => 'Songs';

  @override
  String get kidsTopicStories => 'Stories';

  @override
  String get kidsTopicAnimals => 'Animals';

  @override
  String get kidsTopicBedtime => 'Bedtime';

  @override
  String get navLive => 'Live TV';

  @override
  String get navGames => 'Games';

  @override
  String get liveTvTitle => 'Live TV';

  @override
  String get liveCatAll => 'All';

  @override
  String get liveCatNews => 'News';

  @override
  String get liveCatSports => 'Sports';

  @override
  String get liveCatMovies => 'Movies';

  @override
  String get liveCatEntertainment => 'Entertainment';

  @override
  String get liveCatKids => 'Kids';

  @override
  String get liveCatMusic => 'Music';

  @override
  String get liveCatDocs => 'Documentary';

  @override
  String channelGenericName(int n) {
    return 'Channel $n';
  }

  @override
  String get channelNowGeneric => 'On now';

  @override
  String get gamesTitle => 'Games';

  @override
  String get gamesFeaturedTitle => 'Daily Challenge';

  @override
  String get gamesFeaturedSub => 'Win coins by playing today';

  @override
  String get gamesSectionTrending => 'Trending';

  @override
  String get gamesSectionCasual => 'Casual';

  @override
  String get gamesSectionPuzzle => 'Puzzle';

  @override
  String gameGenericName(int n) {
    return 'Game $n';
  }

  @override
  String get rowTop10 => 'Top 10 Today';

  @override
  String get rowTopChannels => 'Top Live Channels';

  @override
  String get rowNetworks => 'Networks';

  @override
  String networkLabel(int n) {
    return 'Studio $n';
  }

  @override
  String get liveTvGuide => 'TV Guide';

  @override
  String get liveNoGuideAvailable => 'No guide available';

  @override
  String get liveNoChannelsInCategory =>
      'No channels available in this category';

  @override
  String get homeContentComingSoon => 'Content coming soon';

  @override
  String get homeContentAdminPanel =>
      'Movies and series will be added from the admin panel';

  @override
  String get actionWatchNow => 'Watch Now';
}
