import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../services/locale_controller.dart';
import '../services/profile_manager.dart';
import 'my_list_screen.dart';
import 'settings_screen.dart';

class MeScreen extends StatefulWidget {
  final Profile active;
  final VoidCallback onSwitchProfile;
  const MeScreen({
    super.key,
    required this.active,
    required this.onSwitchProfile,
  });

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  final Color _primaryRed = const Color(0xFFE50914);

  Widget _buildAvatar() {
    if (kIsWeb && profileManager.imageBase64 != null) {
      return Image.memory(
        base64Decode(profileManager.imageBase64!),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    } else if (!kIsWeb && profileManager.imagePath != null) {
      return Image.file(
        File(profileManager.imagePath!),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    } else {
      return Text(
        widget.active.avatar,
        style: GoogleFonts.inter(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: const Color(0xFF222222),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _openLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                AppLocalizations.of(context).menuLanguage,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _LangTile(
                label: 'English',
                locale: const Locale('en'),
                current: localeController.value,
                onTap: () {
                  localeController.setOverride(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              _LangTile(
                label: 'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©',
                locale: const Locale('ar'),
                current: localeController.value,
                onTap: () {
                  localeController.setOverride(const Locale('ar'));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.top + 40),
          ),

          // ─── Minimalist Profile Hero ───
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Clickable Avatar
                AnimatedBuilder(
                  animation: profileManager,
                  builder: (context, _) {
                    return GestureDetector(
                      onTap: () => profileManager.pickAndSaveImage(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _primaryRed, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryRed.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                color: const Color(0xFF151515),
                                alignment: Alignment.center,
                                child: _buildAvatar(),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 3),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Name
                AnimatedBuilder(
                  animation: profileManager,
                  builder: (context, _) {
                    final currentName = profileManager.userName ?? widget.active.name;
                    return GestureDetector(
                      onTap: () async {
                        final controller = TextEditingController(text: currentName);
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (dctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1A1A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Text('Edit Profile', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                            content: TextField(
                              controller: controller,
                              style: GoogleFonts.inter(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                hintStyle: GoogleFonts.inter(color: Colors.white54),
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryRed)),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dctx),
                                child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dctx, controller.text.trim()),
                                child: Text('Save', style: GoogleFonts.inter(color: _primaryRed, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                        if (newName != null && newName.isNotEmpty) {
                          await profileManager.setUserName(newName);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentName,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.edit_rounded, color: Colors.white.withValues(alpha: 0.4), size: 18),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // ─── Premium Subscription Banner ───
                GestureDetector(
                  onTap: () => _toast(context, 'Premium Features Coming Soon'),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE50914), Color(0xFFAA0000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryRed.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sky Live Premium',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Unlock all sports & movies',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.8)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ─── Apple TV Style Settings List ───
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.bookmark_rounded,
                      label: s.actionMyList,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const MyListScreen()),
                      ),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      label: s.menuLanguage,
                      subtitle: localeController.value?.languageCode == 'ar' ? 'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©' : 'English',
                      onTap: _openLanguagePicker,
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      label: 'About Sky Live',
                      onTap: () => _toast(context, 'Sky Live v1.0.0'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: const SizedBox(height: 40),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? textColor;
  final bool showArrow;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.textColor,
    this.showArrow = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor ?? Colors.white.withValues(alpha: 0.7)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: textColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (subtitle != null && showArrow)
              const SizedBox(width: 8),
            if (showArrow)
              Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label;
  final Locale locale;
  final Locale? current;
  final VoidCallback onTap;

  const _LangTile({
    required this.label,
    required this.locale,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current?.languageCode == locale.languageCode;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 18,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFFE50914)) : null,
      onTap: onTap,
    );
  }
}
