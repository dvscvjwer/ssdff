import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  const HeroBanner({super.key, required this.title});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  late final PageController _pageController;
  late final List<TitleItem> _heroItems;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  // ── Lifecycle ──────────────────────────────
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _heroItems = [widget.title];
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
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return _buildSingleHero(context, widget.title);
  }

  Widget _buildSingleHero(BuildContext context, TitleItem title) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetailScreen(title: title),
          ),
        );
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.60,
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

            // ── Cinematic 6-stop gradient overlay ──
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.15, 0.5, 0.75, 0.9, 1.0],
                  colors: [
                    Color(0xB3000000), // 70% black — top bar protection
                    Color(0x26000000), // 15% black
                    Color(0x00000000), // transparent — content breathes
                    Color(0x80000000), // 50% black — readability begins
                    Color(0xD9000000), // 85% black
                    Color(0xFF050505), // solid background merge
                  ],
                ),
              ),
            ),

            // ── Side vignettes ──
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0x66000000), // 40% black
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0x66000000), // 40% black
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
                    colors: [Color(0xFFFF1A2D), Color(0xFFE50914)],
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

            // ── Page indicators ──
            if (_heroItems.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _heroItems.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _currentPage ? 6 : 4,
                      height: i == _currentPage ? 6 : 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _currentPage
                            ? const Color(0xFFFFFFFF)
                            : const Color(0x4DFFFFFF),
                      ),
                    ),
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
                        color: Colors.white,
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
                        color: Color(0xB3FFFFFF), // 70% white
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
                            color: const Color(0x14FFFFFF), // 8%
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0x1FFFFFFF),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                              color: Color(0xD9FFFFFF), // 85%
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

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
                              final inList =
                                  userState.isInMyList(title.id);
                              final s = AppLocalizations.of(context);
                              return _GlassButton(
                                icon: inList ? Icons.check : Icons.add,
                                label: inList
                                    ? s.actionInMyList
                                    : s.actionMyList,
                                onTap: () async {
                                  final added = await userState
                                      .toggleMyList(title.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      duration:
                                          const Duration(seconds: 2),
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
                              builder: (_) =>
                                  PlayerScreen(title: title),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Info button
                        Expanded(
                          child: _GlassButton(
                            icon: Icons.info_outline_rounded,
                            label:
                                AppLocalizations.of(context).actionInfo,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    DetailScreen(title: title),
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
  const _GlassButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x12FFFFFF), // 7%
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0x1AFFFFFF),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xD9FFFFFF), // 85%
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
            colors: [Color(0xFFFF1A2D), Color(0xFFE50914), Color(0xFFB00710)],
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
