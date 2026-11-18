import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../services/user_state.dart';
import '../theme/app_theme.dart';
import '../widgets/title_card.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.myListTitle)),
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
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
                size: 52, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              s.myListEmptyTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.myListEmptyHint,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
