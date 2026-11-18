import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../services/user_state.dart';
import '../theme/app_theme.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.downloadsTitle),
        actions: [
          IconButton(
            onPressed: () => _confirmClearAll(context),
            icon: const Icon(Icons.delete_outline),
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
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phonelink_lock,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.downloadsNote,
                          style: TextStyle(
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.95),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (items.isEmpty)
                _empty(context)
              else
                for (int i = 0; i < items.length; i++)
                  _downloadTile(context, items[i], i),
            ],
          );
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

  Widget _empty(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        children: [
          const Icon(Icons.download_done_outlined,
              size: 52, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            s.downloadsEmptyTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
    // Stable per-id pseudo-progress so the demo looks varied.
    final hash = t.id.codeUnits.fold<int>(0, (a, b) => a + b);
    final progressOptions = [1.0, 0.68, 0.34, 0.92, 0.55, 0.18];
    final progress = progressOptions[hash % progressOptions.length];
    final done = progress >= 1.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  done ? s.downloadsReady : s.downloadsDownloading,
                  style: TextStyle(
                    color: done ? AppColors.accent : AppColors.textSecondary,
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
    );
  }
}
