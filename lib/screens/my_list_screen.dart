// ─────────────────────────────────────────────────────────────
//  my_list_screen.dart — SkyLive Redesign
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../services/user_state.dart';
import '../theme/app_theme.dart';
import '../widgets/title_card.dart';

// ─── Screen ──────────────────────────────────────────────────
class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(s.myListTitle),
      ),
      body: AnimatedBuilder(
        animation: userState,
        builder: (_, __) {
          final ids = userState.myListIds;
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
          if (items.isEmpty) return _empty(context);
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => TitleCard(
              title: items[i],
              width: 120,
              showTitle: true,
            ),
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_border,
                size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              s.myListEmptyTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.myListEmptyHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
