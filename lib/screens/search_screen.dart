import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../theme/app_theme.dart';
import '../widgets/title_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: s.searchHint,
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textSecondary),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? _emptyState()
          : results.isEmpty
              ? _noResults()
              : _resultsGrid(results),
    );
  }

  Widget _emptyState() {
    final s = AppLocalizations.of(context);
    final trending = allTitles().take(6).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        Text(
          s.searchRecent,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
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
                backgroundColor: AppColors.surfaceAlt,
                labelStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          s.searchTrending,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < trending.length; i++)
          _TrendingTile(index: i + 1, title: trending[i]),
      ],
    );
  }

  Widget _noResults() {
    final s = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off,
                size: 52, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              s.searchEmptyTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.searchEmptyHint,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultsGrid(List<TitleItem> results) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: results.length,
      itemBuilder: (_, i) => TitleCard(
        title: results[i],
        width: 120,
        showTitle: true,
      ),
    );
  }
}

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
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: index <= 3 ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
      title: Text(
        title.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${title.genres.take(2).join(" • ")} · ${title.year}',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.north,
        size: 14,
        color: AppColors.textTertiary,
      ),
    );
  }
}
