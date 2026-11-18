// ─────────────────────────────────────────────────────────────
//  collection_screen.dart — SkyLive Redesign (EXPANDED)
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

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: 350 + widget.items.length * 50),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      Color(0xFF1A0A0A),
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
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter =
                                  selected ? filter : 'All';
                            });
                          },
                          selectedColor: AppColors.primary
                              .withValues(alpha: 0.15),
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
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.55,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final totalDuration =
                      350 + widget.items.length * 50;
                  final start =
                      (i * 50) / totalDuration;
                  final end =
                      (i * 50 + 350) / totalDuration;
                  final anim = CurvedAnimation(
                    parent: _staggerController,
                    curve: Interval(
                      start.clamp(0.0, 1.0),
                      end.clamp(0.0, 1.0),
                      curve: Curves.easeOutCubic,
                    ),
                  );
                  return AnimatedBuilder(
                    animation: anim,
                    builder: (_, child) {
                      return Opacity(
                        opacity: anim.value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - anim.value)),
                          child: child,
                        ),
                      );
                    },
                    child: TitleCard(
                      title: widget.items[i],
                      width: 120,
                      showTitle: true,
                    ),
                  );
                },
                childCount: widget.items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
