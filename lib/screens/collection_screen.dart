// ─────────────────────────────────────────────────────────────
//  collection_screen.dart — SkyLive Redesign
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../models/title.dart';
import '../theme/app_theme.dart';
import '../widgets/title_card.dart';

// ─── Screen ──────────────────────────────────────────────────
class CollectionScreen extends StatefulWidget {
  final String title;
  final List<TitleItem> items;
  const CollectionScreen({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Movies', 'Series', 'New', 'Top Rated'];

  List<TitleItem> get _filteredItems {
    switch (_selectedFilter) {
      case 'Movies':
        return widget.items
            .where((t) => t.kind == TitleKind.movie)
            .toList(growable: false);
      case 'Series':
        return widget.items
            .where((t) => t.kind == TitleKind.series)
            .toList(growable: false);
      case 'New':
        return widget.items
            .where((t) => t.year >= 2024)
            .toList(growable: false);
      case 'Top Rated':
        final sorted = List<TitleItem>.from(widget.items)
          ..sort((a, b) => b.rating.compareTo(a.rating));
        return sorted;
      default:
        return widget.items;
    }
  }

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.items.length * 50),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    final totalDuration = 350 + items.length * 50;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Gradient Header AppBar ───
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1F080A),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Sort / Filter Chips ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in _filters)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? filter : 'All';
                            });
                          },
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          backgroundColor: AppColors.surfaceAlt,
                          side: BorderSide(
                            color: _selectedFilter == filter
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : AppColors.divider,
                          ),
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Staggered Grid ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.55,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final start = ((i * 50) / totalDuration).clamp(0.0, 1.0);
                  final end =
                      ((i * 50 + 350) / totalDuration).clamp(0.0, 1.0);
                  final interval =
                      Interval(start, end, curve: Curves.easeOutCubic);
                  return AnimatedBuilder(
                    animation: _staggerController,
                    builder: (_, child) {
                      final t = interval.transform(_staggerController.value);
                      return Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - t)),
                          child: child,
                        ),
                      );
                    },
                    child: TitleCard(
                      title: items[i],
                      width: 120,
                      showTitle: true,
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
