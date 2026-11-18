import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/title.dart';
import '../screens/detail_screen.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  TitleCard — Poster card with badges & shimmer
// ─────────────────────────────────────────────
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

class _TitleCardState extends State<TitleCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _shimmerCtrl;

  // ── Lifecycle ──────────────────────────────
  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────
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
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Poster Image ──
              AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000), // 40%
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── Image ──
                        CachedNetworkImage(
                          imageUrl: widget.title.poster,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              _buildAnimatedShimmer(),
                          errorWidget: (_, __, ___) => const ColoredBox(
                            color: AppColors.surfaceAlt,
                            child: Icon(Icons.broken_image_rounded,
                                color: AppColors.textTertiary),
                          ),
                        ),

                        // ── Glass shine overlay ──
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-1.0, -1.0),
                                end: Alignment(1.0, 1.0),
                                colors: [
                                  Color(0x14FFFFFF), // 8%
                                  Color(0x00FFFFFF),
                                  Color(0x00FFFFFF),
                                  Color(0x33000000), // 20%
                                ],
                                stops: [0.0, 0.3, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // ── Bottom gradient for text ──
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 60,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xEE000000),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ── Badges ──

                        // Rating badge (top-left)
                        if (widget.showRating)
                          PositionedDirectional(
                            top: 6,
                            start: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xB3000000), // 70%
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: const Color(0x1AFFFFFF),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.accent, size: 12),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.title.rating
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // NEW badge (top-right)
                        if (isNew)
                          PositionedDirectional(
                            top: 6,
                            end: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF1A2D),
                                    Color(0xFFE50914),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x80E50914),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),

                        // HD badge (bottom-right)
                        PositionedDirectional(
                          bottom: 6,
                          end: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x26FFFFFF), // 15%
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: const Color(0x4DFFFFFF), // 30%
                                width: 0.5,
                              ),
                            ),
                            child: const Text(
                              'HD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        // Series indicator (bottom-left)
                        if (widget.title.kind == TitleKind.series)
                          PositionedDirectional(
                            bottom: 6,
                            start: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xD96C3FE5), // 85%
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

              // ── Title text below card ──
              if (widget.showTitle) ...[
                const SizedBox(height: 8),
                Text(
                  widget.title.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.title.year} • ${widget.title.genres.take(2).join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0x73FFFFFF), // 45%
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

  // ── Animated shimmer placeholder ──
  Widget _buildAnimatedShimmer() {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final double translate =
                _shimmerCtrl.value * (bounds.width * 2) - bounds.width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFF1A1A1A),
                Color(0xFF252525),
                Color(0xFF1A1A1A),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(translate),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(color: const Color(0xFF1A1A1A)),
        );
      },
    );
  }
}

// ── Gradient transform helper ──
class _SlidingGradientTransform extends GradientTransform {
  final double slideAmount;
  const _SlidingGradientTransform(this.slideAmount);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(slideAmount, 0.0, 0.0);
  }
}
