// ─────────────────────────────────────────────────────────────
//  browse_screen.dart — SkyLive Redesign
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../theme/app_theme.dart';
import '../widgets/title_card.dart';
import '../widgets/title_row.dart';
import 'search_screen.dart';

// ─── Screen ──────────────────────────────────────────────────
class BrowseScreen extends StatefulWidget {
  final TitleKind kind;
  const BrowseScreen({
    super.key,
    required this.kind,
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

enum _SortKey { newest, topRated, releaseDate }

String _sortLabel(BuildContext c, _SortKey k) {
  final s = AppLocalizations.of(c);
  switch (k) {
    case _SortKey.newest:
      return s.sortNewlyAdded;
    case _SortKey.topRated:
      return s.sortTopRated;
    case _SortKey.releaseDate:
      return s.sortReleaseDate;
  }
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _genre = 'All';
  String _region = 'All';
  int? _year;
  _SortKey _sort = _SortKey.newest;

  List<TitleItem> get _filtered {
    final base = titlesByKind(widget.kind);
    return base.where((t) {
      if (_genre != 'All' && !t.genres.contains(_genre)) return false;
      if (_year != null && t.year != _year) return false;
      return true;
    }).toList();
  }

  List<Collection> get _collections {
    switch (widget.kind) {
      case TitleKind.movie:
        return moviesCollections();
      case TitleKind.series:
        return seriesCollections();
      case TitleKind.kids:
        return kidsCollections();
    }
  }

  String _heading(BuildContext c) {
    final s = AppLocalizations.of(c);
    return switch (widget.kind) {
      TitleKind.movie => s.navMovies,
      TitleKind.series => s.navSeries,
      TitleKind.kids => s.navKids,
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return CustomScrollView(
      slivers: [
        // ─── App Bar ───
        SliverAppBar(
          pinned: true,
          floating: true,
          backgroundColor: AppColors.background.withValues(alpha: 0.9),
          title: Text(
            _heading(context),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SearchScreen(),
                ),
              ),
              icon: const Icon(Icons.search, color: AppColors.textPrimary),
            ),
          ],
        ),

        // ─── Filter Bar ───
        SliverToBoxAdapter(
            child: _FilterBar(
          genre: _genre,
          region: _region,
          year: _year,
          sort: _sort,
          onGenre: (v) => setState(() => _genre = v),
          onRegion: (v) => setState(() => _region = v),
          onYear: (v) => setState(() => _year = v),
          onSort: (v) => setState(() => _sort = v),
          kind: widget.kind,
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // ─── Kids or Collections ───
        if (widget.kind == TitleKind.kids)
          SliverToBoxAdapter(child: _KidsTopicStrip())
        else
          SliverList.separated(
            itemCount: _collections.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (_, i) => TitleRow(collection: _collections[i]),
          ),

        // ─── All Titles Grid ───
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              AppLocalizations.of(context).rowAllTitles,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => TitleCard(
                title: items[i],
                width: 120,
                showTitle: true,
              ),
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Filter Bar ──────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final String genre;
  final String region;
  final int? year;
  final _SortKey sort;
  final TitleKind kind;
  final ValueChanged<String> onGenre;
  final ValueChanged<String> onRegion;
  final ValueChanged<int?> onYear;
  final ValueChanged<_SortKey> onSort;
  const _FilterBar({
    required this.genre,
    required this.region,
    required this.year,
    required this.sort,
    required this.onGenre,
    required this.onRegion,
    required this.onYear,
    required this.onSort,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: genre == 'All' ? s.browseGenre : genre,
              isActive: genre != 'All',
              onTap: () => _pickGenre(context),
            ),
            _FilterChip(
              label: region == 'All' ? s.browseRegion : region,
              isActive: region != 'All',
              onTap: () => _pickRegion(context),
            ),
            _FilterChip(
              label: year == null ? s.browseYear : '$year',
              isActive: year != null,
              onTap: () => _pickYear(context),
            ),
            _FilterChip(
              label: _sortLabel(context, sort),
              isActive: sort != _SortKey.newest,
              onTap: () => _pickSort(context),
            ),
          ],
        ),
      ),
    );
  }

  void _pickGenre(BuildContext context) {
    final s = AppLocalizations.of(context);
    _showPicker<String>(
      context,
      title: s.browseGenre,
      values: ['All', ...genres],
      selected: genre,
      labelOf: (g) => g == 'All' ? s.browseAll : g,
      onPick: onGenre,
    );
  }

  void _pickRegion(BuildContext context) {
    final s = AppLocalizations.of(context);
    _showPicker<String>(
      context,
      title: s.browseRegion,
      values: regions,
      selected: region,
      labelOf: (r) => r == 'All' ? s.browseAll : r,
      onPick: onRegion,
    );
  }

  void _pickYear(BuildContext context) {
    final s = AppLocalizations.of(context);
    _showPicker<int?>(
      context,
      title: s.browseYear,
      values: <int?>[null, ...years],
      selected: year,
      labelOf: (y) => y == null ? s.browseAll : '$y',
      onPick: onYear,
    );
  }

  void _pickSort(BuildContext context) {
    final s = AppLocalizations.of(context);
    _showPicker<_SortKey>(
      context,
      title: s.browseSort,
      values: _SortKey.values,
      selected: sort,
      labelOf: (v) => _sortLabel(context, v),
      onPick: onSort,
    );
  }

  void _showPicker<T>(
    BuildContext context, {
    required String title,
    required List<T> values,
    required T selected,
    required String Function(T) labelOf,
    required ValueChanged<T> onPick,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceModal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: values.length,
                itemBuilder: (_, i) {
                  final v = values[i];
                  final isSel = v == selected;
                  return ListTile(
                    title: Text(
                      labelOf(v),
                      style: TextStyle(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight:
                            isSel ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSel
                        ? const Icon(Icons.check,
                            color: AppColors.primary)
                        : null,
                    onTap: () {
                      onPick(v);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0x1AE50914)
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive
                  ? const Color(0x66E50914)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Kids Topic Strip ────────────────────────────────────────
class _KidsTopicStrip extends StatelessWidget {
  static const _topicGradients = [
    [Color(0xFFE74C3C), Color(0xFFFF8A65)],
    [Color(0xFF1E88E5), Color(0xFF26C6DA)],
    [Color(0xFF8E44AD), Color(0xFFE040FB)],
    [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    [Color(0xFFFFB300), Color(0xFFFFE082)],
    [Color(0xFF3F51B5), Color(0xFF9FA8DA)],
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final labels = [
      s.kidsTopicLearn,
      s.kidsTopicAdventure,
      s.kidsTopicSongs,
      s.kidsTopicStories,
      s.kidsTopicAnimals,
      s.kidsTopicBedtime,
    ];
    final topics = [
      for (int i = 0; i < labels.length; i++)
        (labels[i], _topicGradients[i]),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
        children: [
          for (final t in topics)
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: t.$2,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: t.$2.first.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                t.$1,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
