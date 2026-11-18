import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/title.dart';

/// Resolves an l10n key (e.g. "rowTopPicks") to the localized string for the
/// current context. Returns the original key if no mapping exists, so callers
/// fall back to the literal value used in the data layer.
String tr(BuildContext context, String key) {
  final s = AppLocalizations.of(context);
  switch (key) {
    case 'rowTopPicks':
      return s.rowTopPicks;
    case 'rowNewReleases':
      return s.rowNewReleases;
    case 'rowTrending':
      return s.rowTrending;
    case 'rowContinueWatching':
      return s.rowContinueWatching;
    case 'rowCriticsCorner':
      return s.rowCriticsCorner;
    case 'rowTopMovies':
      return s.rowTopMovies;
    case 'rowNewMovies':
      return s.rowNewMovies;
    case 'rowActionThriller':
      return s.rowActionThriller;
    case 'rowDramaPicks':
      return s.rowDramaPicks;
    case 'rowTopSeries':
      return s.rowTopSeries;
    case 'rowNewSeries':
      return s.rowNewSeries;
    case 'rowMystery':
      return s.rowMystery;
    case 'rowDocumentaries':
      return s.rowDocumentaries;
    case 'rowForLittleOnes':
      return s.rowForLittleOnes;
    case 'rowBedtime':
      return s.rowBedtime;
    case 'rowLearnPlay':
      return s.rowLearnPlay;
    case 'rowAllTitles':
      return s.rowAllTitles;
    case 'rowBrowseByStudio':
      return s.rowBrowseByStudio;
    case 'rowTop10':
      return s.rowTop10;
    case 'rowTopChannels':
      return s.rowTopChannels;
    case 'rowNetworks':
      return s.rowNetworks;
  }
  return key;
}

String localizedKindLabel(BuildContext context, TitleKind k) {
  final s = AppLocalizations.of(context);
  switch (k) {
    case TitleKind.movie:
      return s.kindMovie;
    case TitleKind.series:
      return s.kindSeries;
    case TitleKind.kids:
      return s.kindKids;
  }
}
