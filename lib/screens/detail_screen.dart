import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../services/user_state.dart';
import '../theme/app_theme.dart';
import '../util/i18n.dart';
import '../widgets/title_row.dart';
import 'player_screen.dart';
import 'search_screen.dart';

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  DetailScreen â€” Redesigned with AppColors/AppTextStyles tokens
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

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
          // â”€â”€â”€ SliverAppBar: expandedHeight 380 (was 340) â”€â”€â”€
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
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
              collapseMode: CollapseMode.parallax,
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
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
                  // â”€â”€â”€ Gradient stops [0.35, 0.75, 1.0] â”€â”€â”€
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0x80000000),
                          AppColors.background,
                        ],
                        stops: const [0.35, 0.75, 1.0],
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
          // â”€â”€â”€ Meta Chips â”€â”€â”€
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
          // â”€â”€â”€ Section Tabs with animated indicator â”€â”€â”€
          SliverToBoxAdapter(child: _sectionTabs(sections)),
          // â”€â”€â”€ Tab content with AnimatedSwitcher â”€â”€â”€
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey('section-$_section'),
                child: _sectionBody(sections, t),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // â”€â”€â”€ Header: Title with GoogleFonts.outfit() 28px w800 â”€â”€â”€
  Widget _header(BuildContext ctx, TitleItem t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              Text(
                '${t.rating.toStringAsFixed(1)} â€¢ ${localizedKindLabel(ctx, t.kind)}',
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

  // â”€â”€â”€ Action Bar with AnimatedSwitcher for icon transitions â”€â”€â”€
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

  // â”€â”€â”€ Icon Action with AnimatedSwitcher for 300ms easeOutBack transitions â”€â”€â”€
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
            // â”€â”€â”€ Icon size 24 (was 22) + AnimatedSwitcher â”€â”€â”€
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                icon,
                key: ValueKey(icon),
                color:
                    highlight ? AppColors.primary : AppColors.textPrimary,
                size: 24,
              ),
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

  // â”€â”€â”€ Meta Chip: padding h10v4, borderRadius 6, bg #FF1A1A1A, text 12px â”€â”€â”€
  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // AppColors.surfaceAlt
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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

  // â”€â”€â”€ Section Tabs with animated indicator â”€â”€â”€
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
                    // â”€â”€â”€ Animated indicator â”€â”€â”€
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      height: 3,
                      width: _section == i
                          ? (sections[i].length * 7.5 + 8).clamp(32.0, 110.0)
                          : 0,
                      decoration: BoxDecoration(
                        color: _section == i
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
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

  // â”€â”€â”€ Episodes with updated specs â”€â”€â”€
  Widget _episodes(TitleItem t) {
    final season = t.seasons[_seasonIdx];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€â”€ Season Selector: borderRadius:8 bg:#FF1A1A1A padding:h14v10 â”€â”€â”€
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
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), // AppColors.surfaceAlt
                  borderRadius: BorderRadius.circular(8),
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
                    // â”€â”€â”€ Chevron: 20px â”€â”€â”€
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // â”€â”€â”€ Episode Rows â”€â”€â”€
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
                  // â”€â”€â”€ Thumbnail: 130x73 borderRadius:8 â”€â”€â”€
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: ep.still,
                          width: 130,
                          height: 73,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 130,
                            height: 73,
                            color: AppColors.surfaceAlt,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 130,
                            height: 73,
                            color: AppColors.surfaceAlt,
                          ),
                        ),
                        // â”€â”€â”€ Play icon: 32px â”€â”€â”€
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white70,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // â”€â”€â”€ Title: 14px w700 â”€â”€â”€
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
                        // â”€â”€â”€ Description: 13px maxLines:3 â”€â”€â”€
                        Text(
                          ep.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
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
