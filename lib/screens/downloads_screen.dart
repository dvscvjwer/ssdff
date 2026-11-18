// ─────────────────────────────────────────────────────────────
//  downloads_screen.dart — SkyLive Redesign
// ─────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../services/user_state.dart';
import '../theme/app_theme.dart';

// ─── Screen ──────────────────────────────────────────────────
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(s.downloadsTitle),
        actions: [
          IconButton(
            onPressed: () => _confirmClearAll(context),
            icon: const Icon(Icons.delete_outline,
                color: AppColors.textSecondary),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: userState,
        builder: (_, __) {
          final ids = userState.downloadsIds.toList();
          final items = ids
              .map<TitleItem?>((id) {
                try {
                  return titleById(id);
                } catch (_) {
                  return null;
                }
              })
              .whereType<TitleItem>()
              .toList();
          return _DownloadsList(items: items);
        },
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final s = AppLocalizations.of(context);
    if (userState.downloadsIds.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceModal,
        title: Text(s.downloadsClearTitle),
        content: Text(s.downloadsClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.dialogConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    for (final id in userState.downloadsIds.toList()) {
      await userState.toggleDownload(id);
    }
  }
}

// ─── Animated Downloads List ─────────────────────────────────
class _DownloadsList extends StatefulWidget {
  final List<TitleItem> items;
  const _DownloadsList({required this.items});

  @override
  State<_DownloadsList> createState() => _DownloadsListState();
}

class _DownloadsListState extends State<_DownloadsList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: 400 + widget.items.length * 60),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _DownloadsList old) {
    super.didUpdateWidget(old);
    if (old.items.length != widget.items.length) {
      _staggerController
        ..reset()
        ..duration = Duration(
            milliseconds: 400 + widget.items.length * 60)
        ..forward();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // ─── Storage Banner ───
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.phonelink_lock,
                    color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.downloadsNote,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.items.isEmpty)
          _empty(context)
        else
          for (int i = 0; i < widget.items.length; i++)
            _animatedTile(context, widget.items[i], i),
      ],
    );
  }

  Widget _animatedTile(BuildContext context, TitleItem t, int i) {
    final totalDuration = 400 + widget.items.length * 60;
    final start = (i * 60) / totalDuration;
    final end = (i * 60 + 400) / totalDuration;
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
            offset: Offset(30 * (1 - anim.value), 0),
            child: child,
          ),
        );
      },
      child: _downloadTile(context, t, i),
    );
  }

  Widget _empty(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        children: [
          const Icon(Icons.download_done_outlined,
              size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            s.downloadsEmptyTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.downloadsEmptyHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _downloadTile(BuildContext context, TitleItem t, int i) {
    final s = AppLocalizations.of(context);
    final hash = t.id.codeUnits.fold<int>(0, (a, b) => a + b);
    final progressOptions = [1.0, 0.68, 0.34, 0.92, 0.55, 0.18];
    final progress = progressOptions[hash % progressOptions.length];
    final done = progress >= 1.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: t.poster,
                width: 72,
                height: 108,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 72,
                  height: 108,
                  color: AppColors.surfaceAlt,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 72,
                  height: 108,
                  color: AppColors.surfaceAlt,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    done ? s.downloadsReady : s.downloadsDownloading,
                    style: TextStyle(
                      color: done
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: AppColors.surfaceAlt,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).round()}% • ${s.qualityHd}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              iconSize: 30,
              onPressed: () => userState.toggleDownload(t.id),
              icon: Icon(
                done ? Icons.play_circle_fill : Icons.delete_outline,
                color: done ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
