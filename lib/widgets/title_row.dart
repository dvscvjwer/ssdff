import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../screens/collection_screen.dart';
import '../screens/detail_screen.dart';
import '../theme/app_theme.dart';
import '../util/i18n.dart';
import 'title_card.dart';

class TitleRow extends StatelessWidget {
  final Collection collection;
  final double cardWidth;
  final bool showMore;
  final bool showIndex;

  const TitleRow({
    super.key,
    required this.collection,
    this.cardWidth = 130,
    this.showMore = true,
    this.showIndex = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use featured layout for "Continue Watching" or "Critics Corner"
    final isFeatured = collection.id == 'critics' || collection.id == 'trending';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // â”€â”€â”€ Section Header â”€â”€â”€
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 12, 12),
          child: Row(
            children: [
              // Glowing red accent bar
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
                  tr(context, collection.title),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (showMore)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CollectionScreen(
                        title: tr(context, collection.title),
                        items: collection.items,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context).actionSeeAll,
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: AppColors.primary.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // â”€â”€â”€ Content Row â”€â”€â”€
        if (isFeatured)
          _buildFeaturedRow(context)
        else if (showIndex)
          _buildRankedRow(context)
        else
          _buildStandardRow(context),
      ],
    );
  }

  /// Standard horizontal card row
  Widget _buildStandardRow(BuildContext context) {
    return SizedBox(
      height: cardWidth * 1.5 + 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: collection.items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          return TitleCard(title: collection.items[i], width: cardWidth);
        },
      ),
    );
  }

  /// Featured landscape cards row (wider, with backdrop images)
  Widget _buildFeaturedRow(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: collection.items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final item = collection.items[i];
          return _FeaturedCard(item: item);
        },
      ),
    );
  }

  /// Top 10 ranked row with dramatic numbers
  Widget _buildRankedRow(BuildContext context) {
    return SizedBox(
      height: cardWidth * 1.5 + 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: collection.items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          return _RankedCard(
            index: i + 1,
            item: collection.items[i],
            width: cardWidth,
          );
        },
      ),
    );
  }
}

/// Featured landscape card with backdrop image
class _FeaturedCard extends StatefulWidget {
  final TitleItem item;
  const _FeaturedCard({required this.item});

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DetailScreen(title: widget.item),
        ),
      ),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop image
                CachedNetworkImage(
                  imageUrl: widget.item.backdrop,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.surfaceAlt),
                  errorWidget: (_, __, ___) => Container(color: AppColors.surfaceAlt),
                ),
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4, 0.7, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
                // Rating badge top-left
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          widget.item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Play button overlay
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.85),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                // Title & info at bottom
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${widget.item.year}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.item.genres.join(' â€¢ '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

/// Ranked card with dramatic gradient number
class _RankedCard extends StatelessWidget {
  final int index;
  final TitleItem item;
  final double width;
  const _RankedCard({
    required this.index,
    required this.item,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + 48,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomStart,
        children: [
          // Dramatic stroke number
          PositionedDirectional(
            start: -2,
            bottom: 30,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: width * 1.1,
                height: 0.75,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.5
                  ..shader = const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF1A2D), Color(0xFF660000)],
                  ).createShader(Rect.fromLTWH(0, 0, 100, width * 1.1)),
              ),
            ),
          ),
          // Filled number (dark inside)
          PositionedDirectional(
            start: -2,
            bottom: 30,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: width * 1.1,
                height: 0.75,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F0F0F),
              ),
            ),
          ),
          // The card itself, offset to the right
          PaddingDirectional(
            startPadding: 40,
            child: TitleCard(title: item, width: width, showRating: false),
          ),
        ],
      ),
    );
  }
}

class PaddingDirectional extends StatelessWidget {
  final double startPadding;
  final Widget child;
  const PaddingDirectional({
    super.key,
    required this.startPadding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: startPadding),
      child: child,
    );
  }
}
