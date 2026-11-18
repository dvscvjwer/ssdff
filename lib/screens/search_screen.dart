// ─────────────────────────────────────────────────────────────
//  search_screen.dart — SkyLive Redesign
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../theme/app_theme.dart';
import '../widgets/title_card.dart';

// ─── Screen ──────────────────────────────────────────────────
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  String _query = '';
  final _recent = <String>['summer', 'thriller', 'sci-fi', 'family night'];

  List<TitleItem> get _results {
    if (_query.trim().isEmpty) return [];
    final q = _query.toLowerCase();
    return allTitles().where((t) {
      if (t.title.toLowerCase().contains(q)) return true;
      if (t.genres.any((g) => g.toLowerCase().contains(q))) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final results = _results;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: s.searchHint,
              hintStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF555555),
              ),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? _emptyState()
          : results.isEmpty
              ? _noResults()
              : _ResultsGrid(results: results),
    );
  }

  // ─── Empty state: recent tags + trending ─────────────────
  Widget _emptyState() {
    final s = AppLocalizations.of(context);
    final trending = allTitles().take(6).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        // ─ Section: Recent ─
        Text(
          s.searchRecent,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in _recent)
              Chip(
                label: Text(r),
                backgroundColor: const Color(0xFF1A1A1A),
                labelStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Color(0x1AFFFFFF),
                  ),
                ),
                deleteIcon: const Icon(Icons.close, size: 14),
                deleteIconColor: AppColors.textTertiary,
                onDeleted: () {
                  setState(() => _recent.remove(r));
                },
              ),
          ],
        ),
        const SizedBox(height: 28),

        // ─ Section: Trending ─
        Text(
          s.searchTrending,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < trending.length; i++)
          _TrendingTile(index: i + 1, title: trending[i]),
      ],
    );
  }

  // ─── No results ──────────────────────────────────────────
  Widget _noResults() {
    final s = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off,
                size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              s.searchEmptyTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.searchEmptyHint,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Staggered Results Grid ──────────────────────────────────
class _ResultsGrid extends StatefulWidget {
  final List<TitleItem> results;
  const _ResultsGrid({required this.results});

  @override
  State<_ResultsGrid> createState() => _ResultsGridState();
}

class _ResultsGridState extends State<_ResultsGrid>
    with TickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: 300 + widget.results.length * 100),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _ResultsGrid old) {
    super.didUpdateWidget(old);
    if (old.results.length != widget.results.length) {
      _staggerController
        ..reset()
        ..duration = Duration(
            milliseconds: 300 + widget.results.length * 100)
        ..forward();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: 0.52,
      ),
      itemCount: widget.results.length,
      itemBuilder: (_, i) {
        final total = widget.results.length;
        final start = (i * 100) /
            (300 + total * 100);
        final end = (i * 100 + 300) /
            (300 + total * 100);
        final anim = CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        );
        return FadeTransition(
          opacity: anim,
          child: TitleCard(
            title: widget.results[i],
            width: 120,
            showTitle: true,
          ),
        );
      },
    );
  }
}

// ─── Trending Tile ───────────────────────────────────────────
class _TrendingTile extends StatelessWidget {
  final int index;
  final TitleItem title;
  const _TrendingTile({required this.index, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 28,
        child: Text(
          '$index',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: index <= 3 ? AppColors.primary : const Color(0xFF555555),
          ),
        ),
      ),
      title: Text(
        title.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${title.genres.take(2).join(" • ")} · ${title.year}',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(
        Icons.north,
        size: 14,
        color: AppColors.textTertiary,
      ),
    );
  }
}
