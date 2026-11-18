class TitleItem {
  final String id;
  final String title;
  final String poster;
  final String backdrop;
  final String description;
  final double rating;
  final int year;
  final String runtime;
  final List<String> genres;
  final List<String> cast;
  final List<String> audio;
  final List<String> subtitles;
  final TitleKind kind;
  final List<Season> seasons;

  const TitleItem({
    required this.id,
    required this.title,
    required this.poster,
    required this.backdrop,
    required this.description,
    required this.rating,
    required this.year,
    required this.runtime,
    required this.genres,
    required this.cast,
    required this.audio,
    required this.subtitles,
    required this.kind,
    this.seasons = const [],
  });
}

enum TitleKind { movie, series, kids }

class Season {
  final int number;
  final List<Episode> episodes;
  const Season(this.number, this.episodes);
}

class Episode {
  final int number;
  final String title;
  final String still;
  final String duration;
  final String description;
  const Episode({
    required this.number,
    required this.title,
    required this.still,
    required this.duration,
    required this.description,
  });
}

class Collection {
  final String id;
  final String title;
  final String? link;
  final List<TitleItem> items;
  const Collection({
    required this.id,
    required this.title,
    required this.items,
    this.link,
  });
}

class Profile {
  final String id;
  final String name;
  final String avatar;
  final bool kid;
  const Profile({
    required this.id,
    required this.name,
    required this.avatar,
    this.kid = false,
  });
}
