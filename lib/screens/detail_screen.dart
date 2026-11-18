import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../services/user_state.dart';
import '../theme/app_theme.dart';
import '../util/i18n.dart';
import '../widgets/title_row.dart';
import 'player_screen.dart';
import 'search_screen.dart';

class DetailScreen extends StatefulWidget {
  final TitleItem title;
  const DetailScreen({super.key, required this.title});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _section = 0;
  int _seasonIdx = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.title;
    final s = AppLocalizations.of(context);
    final sections = t.seasons.isNotEmpty
        ? [s.detailEpisodes, s.detailAbout, s.detailMoreLikeThis]
        : [s.detailAbout, s.detailMoreLikeThis];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.cast),
                onPressed: () => _showSnack(
                  context,
                  AppLocalizations.of(context).snackCastUnavailable,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SearchScreen(),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: t.backdrop,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surface),
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.surface),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x99000000),
                          AppColors.background,
                        ],
                        stops: [0.3, 0.75, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _header(context, t)),
          SliverToBoxAdapter(child: _actionBar(context, t)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                t.description,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  _metaChip('${t.year}'),
                  _metaChip(t.runtime),
                  for (final g in t.genres) _metaChip(g),
                ],
              ),
            ),
          ),
          if (t.cast.isNotEmpty)
            SliverToBoxAdapter(child: _castSection(t)),
          SliverToBoxAdapter(child: _sectionTabs(sections)),
          SliverToBoxAdapter(child: _sectionBody(sections, t)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _header(BuildContext ctx, TitleItem t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              Text(
                '${t.rating.toStringAsFixed(1)} • ${localizedKindLabel(ctx, t.kind)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBar(BuildContext ctx, TitleItem t) {
    return AnimatedBuilder(
      animation: userState,
      builder: (_, __) {
        final s = AppLocalizations.of(ctx);
        final inList = userState.isInMyList(t.id);
        final downloaded = userState.isDownloaded(t.id);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PlayerScreen(title: t),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 22),
                  label: Text(
                    s.actionPlay,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _toggleDownload(ctx, t),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide.none,
                    backgroundColor: AppColors.surfaceAlt,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  icon: Icon(downloaded
                      ? Icons.download_done
                      : Icons.download_outlined),
                  label: Text(
                      downloaded ? s.actionDownloaded : s.actionDownload),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _iconAction(
                    inList ? Icons.check : Icons.add,
                    inList ? s.actionInMyList : s.actionMyList,
                    () => _toggleMyList(ctx, t),
                    highlight: inList,
                  ),
                  _iconAction(
                    Icons.thumb_up_off_alt,
                    s.actionRate,
                    () => _showRate(ctx),
                  ),
                  _iconAction(
                    Icons.share_outlined,
                    s.actionShare,
                    () => _share(ctx, t),
                  ),
                  _iconAction(
                    Icons.cast,
                    s.actionCast,
                    () => _showSnack(ctx, s.snackCastUnavailable),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleMyList(BuildContext ctx, TitleItem t) async {
    final s = AppLocalizations.of(ctx);
    final added = await userState.toggleMyList(t.id);
    if (!ctx.mounted) return;
    _showSnack(ctx, added ? s.snackAddedToMyList : s.snackRemovedFromMyList);
  }

  Future<void> _toggleDownload(BuildContext ctx, TitleItem t) async {
    final s = AppLocalizations.of(ctx);
    final added = await userState.toggleDownload(t.id);
    if (!ctx.mounted) return;
    _showSnack(
        ctx, added ? s.snackDownloadStarted : s.snackDownloadRemoved);
  }

  void _share(BuildContext ctx, TitleItem t) {
    final s = AppLocalizations.of(ctx);
    _showSnack(ctx, s.snackShareLink(t.title));
  }

  void _showRate(BuildContext ctx) {
    final s = AppLocalizations.of(ctx);
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: AppColors.surface,
      builder: (sctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                s.detailRateTitle,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            for (final pair in const [
              [Icons.thumb_up, 'rateLove'],
              [Icons.sentiment_satisfied, 'rateLike'],
              [Icons.thumb_down, 'rateNotForMe'],
            ])
              ListTile(
                leading: Icon(pair[0] as IconData),
                title: Text(_rateLabel(s, pair[1] as String)),
                onTap: () {
                  Navigator.pop(sctx);
                  _showSnack(ctx, s.snackThanksForRating);
                },
              ),
          ],
        ),
      ),
    );
  }

  String _rateLabel(AppLocalizations s, String key) {
    switch (key) {
      case 'rateLove':
        return s.rateLove;
      case 'rateLike':
        return s.rateLike;
      case 'rateNotForMe':
        return s.rateNotForMe;
    }
    return '';
  }

  void _showSnack(BuildContext ctx, String text) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _iconAction(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool highlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  highlight ? AppColors.primary : AppColors.textPrimary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: highlight
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 11,
                fontWeight:
                    highlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
      ),
    );
  }

  Widget _castSection(TitleItem t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).detailCast,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.cast.join(', '),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTabs(List<String> sections) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 22, 16, 0),
      child: Row(
        children: [
          for (int i = 0; i < sections.length; i++)
            GestureDetector(
              onTap: () => setState(() => _section = i),
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                    end: i == sections.length - 1 ? 0 : 22),
                child: Column(
                  children: [
                    Text(
                      sections[i],
                      style: TextStyle(
                        color: _section == i
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: _section == i
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 3,
                      width: 36,
                      color: _section == i
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionBody(List<String> sections, TitleItem t) {
    final s = AppLocalizations.of(context);
    final name = sections[_section];
    if (name == s.detailEpisodes) {
      return _episodes(t);
    }
    if (name == s.detailAbout) {
      return _about(t);
    }
    return _moreLikeThis(t);
  }

  Widget _episodes(TitleItem t) {
    final season = t.seasons[_seasonIdx];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: AppColors.surface,
                  builder: (ctx) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < t.seasons.length; i++)
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)
                                .detailSeason(t.seasons[i].number),
                          ),
                          trailing: i == _seasonIdx
                              ? const Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            setState(() => _seasonIdx = i);
                            Navigator.pop(ctx);
                          },
                        ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)
                          .detailSeason(season.number),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: season.episodes.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (_, i) {
              final ep = season.episodes[i];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: ep.still,
                          width: 120,
                          height: 68,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 120,
                            height: 68,
                            color: AppColors.surfaceAlt,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 120,
                            height: 68,
                            color: AppColors.surfaceAlt,
                          ),
                        ),
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white70,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ep.number}. ${ep.title}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ep.duration,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ep.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_outlined, size: 22),
                    onPressed: () => _showSnack(
                      context,
                      AppLocalizations.of(context).snackDownloadStarted,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _about(TitleItem t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _aboutRow(AppLocalizations.of(context).aboutGenres, t.genres.join(', ')),
          _aboutRow(AppLocalizations.of(context).aboutYear, '${t.year}'),
          _aboutRow(AppLocalizations.of(context).aboutRuntime, t.runtime),
          _aboutRow(AppLocalizations.of(context).aboutAudio, t.audio.join(', ')),
          _aboutRow(AppLocalizations.of(context).aboutSubtitles, t.subtitles.join(', ')),
          if (t.cast.isNotEmpty)
            _aboutRow(AppLocalizations.of(context).aboutCastLabel, t.cast.join(', ')),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moreLikeThis(TitleItem t) {
    final others = allTitles().where((o) => o.id != t.id).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TitleRow(
        collection: Collection(
          id: 'similar',
          title: '',
          items: others.take(8).toList(),
        ),
        showMore: false,
      ),
    );
  }


}
