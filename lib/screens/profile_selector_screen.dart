// ─────────────────────────────────────────────────────────────
//  profile_selector_screen.dart — SkyLive Redesign
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../theme/app_theme.dart';

// ─── Screen ──────────────────────────────────────────────────
class ProfileSelectorScreen extends StatelessWidget {
  const ProfileSelectorScreen({super.key});

  static const _gradients = [
    [Color(0xFFFF512F), Color(0xFFDD2476)],
    [Color(0xFFFF9966), Color(0xFFFF5E62)],
    [Color(0xFFFFB75E), Color(0xFFED8F03)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFF1FA2FF), Color(0xFF12D8FA)],
    [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    [Color(0xFFEE0979), Color(0xFFFF6A00)],
    [Color(0xFF56AB2F), Color(0xFFA8E063)],
    [Color(0xFF00C9FF), Color(0xFF92FE9D)],
    [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
    [Color(0xFFFFAFBD), Color(0xFFFFC3A0)],
    [Color(0xFF614385), Color(0xFF516395)],
    [Color(0xFFD66D75), Color(0xFFE29587)],
  ];

  static const _icons = [
    Icons.movie_filter,
    Icons.local_fire_department,
    Icons.star,
    Icons.bolt,
    Icons.favorite,
    Icons.headphones,
    Icons.sports_esports,
    Icons.cake,
    Icons.pets,
    Icons.brightness_2,
    Icons.flash_on,
    Icons.icecream,
    Icons.spa,
    Icons.diamond,
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          s.meWhosWatching,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            letterSpacing: 0.2,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20, 6, 20, 14),
                child: Text(
                  s.meWhosWatchingHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 22,
                    childAspectRatio: 0.74,
                  ),
                  itemCount: profiles.length + 1,
                  itemBuilder: (_, i) {
                    if (i == profiles.length) {
                      return _AddTile(
                        onTap: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            content: Text(s.snackComingSoon),
                          ),
                        ),
                      );
                    }
                    final p = profiles[i];
                    return _ProfileTile(
                      profile: p,
                      gradient: _gradients[i % _gradients.length],
                      icon: _icons[i % _icons.length],
                      isSelected: i == 0,
                      onTap: () => Navigator.pop(context, p.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Tile ────────────────────────────────────────────
class _ProfileTile extends StatelessWidget {
  final Profile profile;
  final List<Color> gradient;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.profile,
    required this.gradient,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.glowRed,
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      icon,
                      color: AppColors.textPrimary.withValues(alpha: 0.5),
                      size: 22,
                    ),
                  ),
                  Center(
                    child: Text(
                      profile.avatar,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (profile.kid)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppLocalizations.of(context).meKidsBadge,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Add Tile ────────────────────────────────────────────────
class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.divider,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).meAddProfile,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
