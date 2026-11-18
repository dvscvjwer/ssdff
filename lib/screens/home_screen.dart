import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../theme/app_theme.dart';
import '../widgets/flixora_logo.dart';
import '../widgets/hero_banner.dart';
import '../widgets/title_row.dart';
import 'live_tv_screen.dart';
import 'search_screen.dart';

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  HomeScreen â€” Redesigned with AppColors/AppTextStyles tokens
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final tabs = [s.tabForYou, s.navMovies, s.navSeries, s.tabAnime];
    final cols = _collectionsForTab(_tab);
    final hero = _heroForTab(_tab);

    return CustomScrollView(
      key: ValueKey('home-tab-$_tab'),
      slivers: [
        // â”€â”€â”€ App Bar â”€â”€â”€
        SliverAppBar(
          pinned: false,
          floating: true,
          snap: true,
          backgroundColor: AppColors.background.withValues(alpha: 0.95),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 16,
          title: Row(
            children: [
              const FlixoraLogo(size: 22),
              const Spacer(),
              _AppBarIcon(
                icon: Icons.search_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
              child: _PremiumTabBar(
                tabs: tabs,
                selectedIndex: _tab,
                onTap: (i) => setState(() => _tab = i),
              ),
            ),
          ),
        ),

        // â”€â”€â”€ Content â”€â”€â”€
        if (cols.isEmpty) ...[
          // â”€â”€â”€ Empty State â”€â”€â”€
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.movie_filter_rounded,
                        size: 40,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.homeContentAdminPanel,
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          // â”€â”€â”€ Hero Banner â”€â”€â”€
          SliverToBoxAdapter(child: HeroBanner(title: hero)),

          // â”€â”€â”€ Continue Watching (only on For You) â”€â”€â”€
          if (_tab == 0 && _pickContinueWatching().isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: _ContinueWatchingRow(
                items: _pickContinueWatching(),
              ),
            ),
          ],

          // â”€â”€â”€ Content Rows â”€â”€â”€
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverList.separated(
            itemCount: cols.length,
            separatorBuilder: (_, __) => const SizedBox(height: 28),
            itemBuilder: (_, i) => TitleRow(
              collection: cols[i],
              showIndex: cols[i].id == 'top10' ||
                  cols[i].id == 'm-top10' ||
                  cols[i].id == 's-top10',
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  List<TitleItem> _pickContinueWatching() {
    final movies = titlesByKind(TitleKind.movie);
    final series = titlesByKind(TitleKind.series);
    if (movies.isEmpty && series.isEmpty) return [];
    final result = <TitleItem>[];
    if (movies.isNotEmpty) result.add(movies.first);
    if (series.isNotEmpty) result.add(series.first);
    if (movies.length > 1) result.add(movies.last);
    return result;
  }

  List<Collection> _collectionsForTab(int tab) {
    switch (tab) {
      case 1:
        return moviesCollections();
      case 2:
        return seriesCollections();
      case 3:
        return _animeCollections();
      case 0:
      default:
        return homeCollections();
    }
  }

  TitleItem _heroForTab(int tab) {
    switch (tab) {
      case 1:
        final movies = titlesByKind(TitleKind.movie);
        return movies.isNotEmpty ? movies.first : featuredTitle();
      case 2:
        final series = titlesByKind(TitleKind.series);
        return series.isNotEmpty ? series.first : featuredTitle();
      case 3:
        final series = titlesByKind(TitleKind.series);
        return series.isNotEmpty ? series.last : featuredTitle();
      case 0:
      default:
        return featuredTitle();
    }
  }

  List<Collection> _animeCollections() {
    final all = allTitles();
    if (all.isEmpty) return [];
    return [
      Collection(
        id: 'an-trend',
        title: 'rowTrending',
        items: all.reversed.take(6).toList(),
      ),
      Collection(
        id: 'an-action',
        title: 'rowActionThriller',
        items: all
            .where((t) =>
                t.genres.contains('Sci-Fi') ||
                t.genres.contains('Fantasy') ||
                t.genres.contains('Adventure'))
            .toList(),
      ),
    ];
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  Premium Components
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

/// Glassmorphism app bar icon button
class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textPrimary.withValues(alpha: 0.07),
          border: Border.all(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

// â”€â”€â”€ Premium Tab Bar with animated glowing underline â”€â”€â”€
class _PremiumTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _PremiumTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: LayoutBuilder(
        builder: (ctx, c) {
          final segWidth = c.maxWidth / tabs.length;
          return Stack(
            children: [
              // Bottom line (subtle)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 1,
                  color: AppColors.textPrimary.withValues(alpha: 0.06),
                ),
              ),
              // Animated glowing underline
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                start: segWidth * selectedIndex + segWidth * 0.2,
                bottom: 0,
                width: segWidth * 0.6,
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1A2D), AppColors.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              // Tab labels
              Row(
                children: [
                  for (int i = 0; i < tabs.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(i),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: selectedIndex == i
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimary.withValues(alpha: 0.4),
                              fontWeight: selectedIndex == i
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                            child: Text(tabs[i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// â”€â”€â”€ Continue Watching Row â”€â”€â”€
class _ContinueWatchingRow extends StatelessWidget {
  final List<TitleItem> items;
  const _ContinueWatchingRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: s.rowContinueWatching),
        SizedBox(
          height: 135,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final item = items[i];
              final progress = [0.35, 0.72, 0.15][i % 3];
              return _ContinueWatchingCard(item: item, progress: progress);
            },
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€ Continue Watching Card â”€â”€â”€
class _ContinueWatchingCard extends StatelessWidget {
  final TitleItem item;
  final double progress;
  const _ContinueWatchingCard({required this.item, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 112,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.backdrop,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.surfaceAlt),
                    errorWidget: (_, __, ___) => Container(color: AppColors.surfaceAlt),
                  ),
                  // Dark overlay at bottom for progress bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xDD000000)],
                        ),
                      ),
                    ),
                  ),
                  // Play icon overlay
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textPrimary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  // Progress bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 3,
                      color: AppColors.textPrimary.withValues(alpha: 0.15),
                      child: FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: progress,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF1A2D), AppColors.primary],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Section Header with glowing red accent bar â”€â”€â”€
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllLabel;
  const _SectionHeader({required this.title, this.onSeeAll, this.seeAllLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 12, 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            margin: const EdgeInsetsDirectional.only(end: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (onSeeAll != null)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      seeAllLabel ?? '',
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.primary.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Networks Strip with Studio Tiles â”€â”€â”€
class _NetworksStrip extends StatelessWidget {
  const _NetworksStrip();

  static const _gradients = [
    [Color(0xFFE50914), Color(0xFF8B0000)],
    [Color(0xFF003366), Color(0xFF001133)],
    [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
    [Color(0xFF004D40), Color(0xFF00251A)],
    [Color(0xFFE65100), Color(0xFFBF360C)],
    [Color(0xFF1B5E20), Color(0xFF0A300D)],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: AppLocalizations.of(context).rowNetworks),
        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: networks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final colors = _gradients[i % _gradients.length];
              final initials = networks[i].substring(0, 1).toUpperCase();

              return _StudioTile(
                name: networks[i],
                initials: initials,
                colors: colors,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      content: Text(AppLocalizations.of(context).snackComingSoon),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€ Studio Tile â”€â”€â”€
class _StudioTile extends StatefulWidget {
  final String name;
  final String initials;
  final List<Color> colors;
  final VoidCallback onTap;

  const _StudioTile({
    required this.name,
    required this.initials,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_StudioTile> createState() => _StudioTileState();
}

class _StudioTileState extends State<_StudioTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 145,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.glassSurface,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.colors[0].withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Huge watermark initial
                Positioned(
                  right: -10,
                  bottom: -20,
                  child: Text(
                    widget.initials,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary.withValues(alpha: 0.08),
                      height: 1.0,
                    ),
                  ),
                ),
                // Glass shine overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-1.0, -1.0),
                        end: const Alignment(1.0, 1.0),
                        colors: [
                          AppColors.textPrimary.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                // Text centered
                Center(
                  child: Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Top Live Channels Row â”€â”€â”€
class _TopLiveChannelsRow extends StatelessWidget {
  const _TopLiveChannelsRow();

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: s.rowTopChannels,
          onSeeAll: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const LiveTvScreen()),
          ),
          seeAllLabel: s.actionSeeAll,
        ),
        SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              return _LiveChannelCard(index: i);
            },
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€ Live Channel Card with pulsing LIVE badge â”€â”€â”€
class _LiveChannelCard extends StatefulWidget {
  final int index;
  const _LiveChannelCard({required this.index});

  @override
  State<_LiveChannelCard> createState() => _LiveChannelCardState();
}

class _LiveChannelCardState extends State<_LiveChannelCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _pulseCtrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);

    final accents = [
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9800),
      const Color(0xFF4CAF50),
      const Color(0xFFF44336),
    ];
    final accent = accents[widget.index % accents.length];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const LiveTvScreen()),
      ),
      child: Container(
        width: 175,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceCard,
          border: Border.all(
            color: AppColors.glassSurface,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Subtle colored glow at the top
              Positioned(
                top: -30,
                left: -30,
                right: -30,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pulsing LIVE badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.textPrimary.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (context, child) {
                              return Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                          alpha: 0.3 + (_pulseCtrl.value * 0.7)),
                                      blurRadius: 4 + (_pulseCtrl.value * 6),
                                      spreadRadius: _pulseCtrl.value * 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      s.channelGenericName(widget.index + 1),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.channelNowGeneric,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
