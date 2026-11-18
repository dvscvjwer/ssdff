import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/user_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dataSaver = false;
  bool _autoplayNext = true;
  bool _autoplayPreviews = true;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black, // Pure OLED Black
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          s.settingsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // ─── Playback Overrides ───
          _SectionHeader(title: s.settingsGroupPlayback),
          _MinimalToggleTile(
            icon: Icons.data_saver_on_rounded,
            label: s.settingsDataSaver,
            value: _dataSaver,
            onChanged: (v) => setState(() => _dataSaver = v),
          ),
          _MinimalDivider(),
          _MinimalToggleTile(
            icon: Icons.auto_awesome_rounded,
            label: s.settingsAutoplayNext,
            value: _autoplayNext,
            onChanged: (v) => setState(() => _autoplayNext = v),
          ),
          _MinimalDivider(),
          _MinimalToggleTile(
            icon: Icons.preview_rounded,
            label: s.settingsAutoplayPreviews,
            value: _autoplayPreviews,
            onChanged: (v) => setState(() => _autoplayPreviews = v),
          ),
          _SectionFooter(),

          // ─── Storage & Downloads ───
          _SectionHeader(title: s.settingsGroupDownloads),
          _MinimalTile(
            icon: Icons.sd_storage_rounded,
            label: s.settingsDownloadLocation,
            subtitle: s.settingsDownloadLocationValue,
            onTap: () => _toast(s.snackComingSoon),
          ),
          _MinimalDivider(),
          _MinimalTile(
            icon: Icons.cleaning_services_rounded,
            label: s.settingsClearDownloads,
            textColor: const Color(0xFFE50914),
            iconColor: const Color(0xFFE50914),
            showArrow: false,
            onTap: _clearDownloads,
          ),
          _SectionFooter(),

          // ─── App Configuration ───
          _SectionHeader(title: s.settingsGroupApp),
          _MinimalTile(
            icon: Icons.notifications_none_rounded,
            label: s.menuNotifications,
            onTap: () => _toast(s.snackComingSoon),
          ),
          _MinimalDivider(),
          _MinimalTile(
            icon: Icons.family_restroom_rounded,
            label: s.menuParental,
            onTap: () => _toast(s.snackComingSoon),
          ),
          _MinimalDivider(),
          _MinimalTile(
            icon: Icons.devices_other_rounded,
            label: s.settingsManageDevices,
            onTap: () => _toast(s.snackComingSoon),
          ),
          _MinimalDivider(),
          _MinimalTile(
            icon: Icons.delete_sweep_rounded,
            label: s.settingsClearCache,
            subtitle: s.settingsCacheSize(48),
            onTap: () => _toast(s.snackSettingsSaved),
          ),
          _MinimalDivider(),
          _MinimalTile(
            icon: Icons.info_outline_rounded,
            label: s.settingsAboutApp,
            subtitle: s.settingsAppVersion('1.0.0'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Sky Live',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2026 Sky Live',
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF333333),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearDownloads() async {
    final s = AppLocalizations.of(context);
    if (userState.downloadsIds.isEmpty) {
      _toast(s.downloadsEmptyTitle);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text(s.downloadsClearTitle, style: const TextStyle(color: Colors.white)),
        content: Text(s.downloadsClearMessage, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.dialogCancel, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.dialogConfirm, style: const TextStyle(color: Color(0xFFE50914))),
          ),
        ],
      ),
    );
    if (ok != true) return;
    for (final id in userState.downloadsIds.toList()) {
      await userState.toggleDownload(id);
    }
    if (!mounted) return;
    _toast(s.snackSettingsSaved);
  }
}

// ─────────────────────────────────────────
// UI Components
// ─────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SectionFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 32);
  }
}

class _MinimalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }
}

class _MinimalTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? textColor;
  final bool showArrow;
  final VoidCallback onTap;

  const _MinimalTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.textColor,
    this.showArrow = true,
    required this.onTap,
  });

  @override
  State<_MinimalTile> createState() => _MinimalTileState();
}

class _MinimalTileState extends State<_MinimalTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final iColor = widget.iconColor ?? Colors.white.withValues(alpha: 0.6);
    final tColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(widget.icon, size: 24, color: iColor),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: tColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (widget.subtitle != null)
              Text(
                widget.subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            if (widget.subtitle != null && widget.showArrow)
              const SizedBox(width: 8),
            if (widget.showArrow)
              Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3), size: 24),
          ],
        ),
      ),
    );
  }
}

class _MinimalToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MinimalToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.white.withValues(alpha: 0.6)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF34C759), // iOS Green
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
