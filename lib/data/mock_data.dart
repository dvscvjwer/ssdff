import '../models/title.dart';

/// Data layer
String _pic(int seed, {int w = 500, int h = 750}) =>
    'https://picsum.photos/seed/flixora$seed/$w/$h';

String _backdrop(int seed) =>
    'https://picsum.photos/seed/flixora-b$seed/1280/720';

// Empty catalog â€” content will be added via the Admin panel.
final List<TitleItem> _catalog = [];

TitleItem titleById(String id) =>
    _catalog.firstWhere((t) => t.id == id, orElse: () => _placeholderTitle());

List<TitleItem> allTitles() => List.unmodifiable(_catalog);

List<TitleItem> titlesByKind(TitleKind k) =>
    _catalog.where((t) => t.kind == k).toList();

TitleItem featuredTitle() =>
    _catalog.isNotEmpty ? _catalog.first : _placeholderTitle();

List<TitleItem> _pickByIds(List<String> ids) =>
    ids.map((id) => _catalog.where((t) => t.id == id)).expand((e) => e).toList(growable: false);

/// Placeholder title
TitleItem _placeholderTitle() => TitleItem(
      id: 'placeholder',
      title: 'Sky Live',
      poster: _pic(0),
      backdrop: _backdrop(0),
      description: 'Ø§Ù„Ù…Ø­ØªÙˆÙ‰ Ù‚Ø§Ø¯Ù… Ù‚Ø±ÙŠØ¨Ø§Ù‹ â€” ØªØ±Ù‚Ø¨ÙˆØ§ Ø§Ù„Ø¬Ø¯ÙŠØ¯!',
      rating: 0.0,
      year: 2025,
      runtime: '',
      genres: [],
      cast: [],
      audio: [],
      subtitles: [],
      kind: TitleKind.movie,
    );

List<Collection> homeCollections() => [];
List<Collection> moviesCollections() => [];
List<Collection> seriesCollections() => [];
List<Collection> kidsCollections() => [];

List<String> networks = [
  'Sky Live Originals',
  'Starlight',
  'Prime Stage',
  'Bluebird',
  'Orbit+',
  'Saga',
];

List<Profile> profiles = [
  const Profile(id: 'p1', name: 'You', avatar: 'A'),
  const Profile(id: 'p2', name: 'Family', avatar: 'F'),
  const Profile(id: 'p3', name: 'Kids', avatar: 'K', kid: true),
  const Profile(id: 'p4', name: 'Guest', avatar: 'G'),
];

List<String> genres = const [
  'Action',
  'Drama',
  'Comedy',
  'Thriller',
  'Sci-Fi',
  'Horror',
  'Romance',
  'Documentary',
  'Mystery',
  'Fantasy',
  'Adventure',
  'Animation',
  'Crime',
  'Sports',
];

List<String> regions = const [
  'All',
  'US',
  'UK',
  'France',
  'Japan',
  'Korea',
  'India',
  'MENA',
  'Brazil',
];

List<int> years = [
  for (int y = 2026; y >= 2015; y--) y,
];
