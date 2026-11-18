import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../screens/detail_screen.dart';
import '../screens/player_screen.dart';
import '../services/user_state.dart';
import '../theme/app_theme.dart';

/// Auto-scrolling cinematic hero carousel with animated page indicators
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Build 3 hero items from the title + related
    _heroItems = [widget.title];
    // Add 2 more items if available
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients && _heroItems.length > 1) {
        final next = (_currentPage + 1) % _heroItems.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
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

  @override
  Widget build(BuildContext context) {
    // Use single hero for now (expandable to carousel later)
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
        height: MediaQuery.of(context).size.height * 0.62,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: title.backdrop,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surfaceAlt,
                      AppColors.background,
                    ],
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(color: AppColors.surface),
            ),

            // Cinematic multi-layer gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.1, 0.45, 0.7, 0.85, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.85),
                    const Color(0xFF0F0F0F),
                  ],
                ),
              ),
            ),

            // Side vignettes
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),

            // TOP 10 Badge
            PositionedDirectional(
              top: 16,
              start: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1A2D), Color(0xFFCC0000)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE50914).withValues(alpha: 0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Column(
                children: [
                  // Large dramatic title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      title.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.9),
                            offset: const Offset(0, 4),
                            blurRadius: 15,
                          ),
                          Shadow(
                            color: const Color(0xFFE50914).withValues(alpha: 0.25),
                            offset: const Offset(0, 0),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description (1-line teaser)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      title.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.5,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Genre pills as actual pill chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final genre in title.genres)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
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
                                label: inList ? s.actionInMyList : s.actionMyList,
                                onTap: () async {
                                  final added = await userState.toggleMyList(title.id);
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
      ),
    );
  }
}

/// Glass-morphism side button
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium animated play button
class _PlayButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF1A2D), Color(0xFFE50914), Color(0xFFB00710)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE50914).withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context).actionPlay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
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
