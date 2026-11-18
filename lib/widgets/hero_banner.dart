import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../screens/detail_screen.dart';
import '../screens/player_screen.dart';
import '../services/user_state.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  HeroBanner — Cinematic auto-scrolling hero
// ─────────────────────────────────────────────
class HeroBanner extends StatefulWidget {
  final TitleItem title;
  final List<TitleItem>? items;

  const HeroBanner({
    super.key,
    required this.title,
    this.items,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  late final PageController _pageController;
  late List<TitleItem> _heroItems;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  // ── Lifecycle ──────────────────────────────
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _heroItems = _resolveHeroItems();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (_pageController.hasClients && _heroItems.length > 1) {
        final next = (_currentPage + 1) % _heroItems.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant HeroBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title.id != widget.title.id ||
        oldWidget.items != widget.items) {
      _heroItems = _resolveHeroItems();
      if (_currentPage >= _heroItems.length) {
        _currentPage = 0;
      }
    }
  }

  List<TitleItem> _resolveHeroItems() {
    if (widget.items != null && widget.items!.isNotEmpty) {
      return widget.items!;
    }
    final extras = allTitles()
        .where((t) => t.id != widget.title.id)
        .take(4)
        .toList(growable: false);
    return [widget.title, ...extras];
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.of(context).size.height * 0.60;
    if (_heroItems.length <= 1) {
      return SizedBox(
        height: heroHeight,
        child: _buildHeroSlide(context, _heroItems.first),
      );
    }

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _heroItems.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, idx) =>
                _buildHeroSlide(context, _heroItems[idx]),
          ),

          // ── Page indicators (above action buttons) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 84,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _heroItems.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 16 : 5,
                    height: i == _currentPage ? 6 : 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i == _currentPage
                          ? AppColors.textPrimary
                          : const Color(0x4DFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Single Slide ───────────────────────────
  Widget _buildHeroSlide(BuildContext context, TitleItem title) {
    final bottomReserve = _heroItems.length > 1 ? 26.0 : 18.0;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetailScreen(title: title),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──
          CachedNetworkImage(
            imageUrl: title.backdrop,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.surfaceAlt, AppColors.background],
                ),
              ),
            ),
            errorWidget: (_, __, ___) =>
                const ColoredBox(color: AppColors.surface),
          ),

          // ── Ambient glow bleed ──
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.ambientGlow),
          ),

          // ── Cinematic 6-stop gradient overlay ──
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.heroGradient),
          ),

          // ── Side vignettes ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0x66000000),
                ],
                stops: [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),

          // ── TOP 10 Badge ──
          PositionedDirectional(
            top: 16,
            start: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1A2D), AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99E50914),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'TOP 10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content at bottom ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Column(
              children: [
                // ── Large dramatic title (Outfit) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    title.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      height: 0.95,
                      shadows: const [
                        Shadow(
                          color: Color(0xE6000000),
                          offset: Offset(0, 3),
                          blurRadius: 12,
                        ),
                        Shadow(
                          color: Color(0x33E50914),
                          offset: Offset(0, 0),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Description ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    title.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Genre pills ──
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final genre in title.genres)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0x1FFFFFFF),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            color: Color(0xD9FFFFFF),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: bottomReserve),

                // ── Action buttons ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // My List button
                      Expanded(
                        child: AnimatedBuilder(
                          animation: userState,
                          builder: (_, __) {
                            final inList = userState.isInMyList(title.id);
                            final s = AppLocalizations.of(context);
                            return _GlassButton(
                              icon: inList ? Icons.check : Icons.add,
                              label:
                                  inList ? s.actionInMyList : s.actionMyList,
                              onTap: () async {
                                final added =
                                    await userState.toggleMyList(title.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                    content: Text(added
                                        ? s.snackAddedToMyList
                                        : s.snackRemovedFromMyList),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // PLAY button (prominent)
                      _PlayButton(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PlayerScreen(title: title),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Info button
                      Expanded(
                        child: _GlassButton(
                          icon: Icons.info_outline_rounded,
                          label: AppLocalizations.of(context).actionInfo,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DetailScreen(title: title),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _GlassButton — Glass-morphism side button
// ─────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x12FFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.glassSurface,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _PlayButton — Premium animated play button
// ─────────────────────────────────────────────
class _PlayButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF1A2D), AppColors.primary, Color(0xFFB00710)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80E50914),
              blurRadius: 24,
              spreadRadius: 0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context).actionPlay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
