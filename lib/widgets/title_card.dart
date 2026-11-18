import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/title.dart';
import '../screens/detail_screen.dart';
import '../theme/app_theme.dart';

class TitleCard extends StatefulWidget {
  final TitleItem title;
  final double width;
  final bool showTitle;
  final bool showRating;
  final double aspectRatio;

  const TitleCard({
    super.key,
    required this.title,
    this.width = 130,
    this.showTitle = true,
    this.showRating = true,
    this.aspectRatio = 2 / 3,
  });

  @override
  State<TitleCard> createState() => _TitleCardState();
}

class _TitleCardState extends State<TitleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isNew = widget.title.year >= 2025;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetailScreen(title: widget.title),
          ),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // â”€â”€â”€ Poster Image â”€â”€â”€
              AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        CachedNetworkImage(
                          imageUrl: widget.title.poster,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _shimmerPlaceholder(),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceAlt,
                            child: const Icon(Icons.broken_image_rounded,
                                color: AppColors.textTertiary),
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
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.25),
                                ],
                                stops: const [0.0, 0.25, 0.65, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Bottom gradient for text
                        Positioned(
                          left: 0, right: 0, bottom: 0,
                          child: Container(
                            height: 60,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xEE000000)],
                              ),
                            ),
                          ),
                        ),

                        // â”€â”€â”€ Badges â”€â”€â”€
                        // Rating badge (top left)
                        if (widget.showRating)
                          PositionedDirectional(
                            top: 7,
                            start: 7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.accent, size: 13),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.title.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // NEW badge (top right) for 2025+ titles
                        if (isNew)
                          PositionedDirectional(
                            top: 7,
                            end: 7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF1A2D), Color(0xFFE50914)],
                                ),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE50914).withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),

                        // HD badge (bottom right)
                        PositionedDirectional(
                          bottom: 7,
                          end: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: const Text(
                              'HD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        // Series indicator (bottom left)
                        if (widget.title.kind == TitleKind.series)
                          PositionedDirectional(
                            bottom: 7,
                            start: 7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C3FE5).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.title.runtime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // â”€â”€â”€ Title text below card â”€â”€â”€
              if (widget.showTitle) ...[
                const SizedBox(height: 8),
                Text(
                  widget.title.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.title.year} â€¢ ${widget.title.genres.take(2).join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceAlt,
            AppColors.surfaceHigh,
            AppColors.surfaceAlt,
          ],
        ),
      ),
    );
  }
}
