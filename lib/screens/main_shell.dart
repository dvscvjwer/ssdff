// ─────────────────────────────────────────────────────────────
//  main_shell.dart — SkyLive Redesign (5-tab navigation)
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/title.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'browse_screen.dart';
import 'downloads_screen.dart';
import 'home_screen.dart';
import 'live_tv_screen.dart';
import 'me_screen.dart';

// ─── Shell ───────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final Profile _active = profiles.first;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _pages() => [
        const HomeScreen(),
        BrowseScreen(kind: TitleKind.movie),
        const LiveTvScreen(),
        const DownloadsScreen(),
        MeScreen(
          active: _active,
          onSwitchProfile: () => setState(() {}),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) {
          setState(() {
            _index = i;
          });
        },
        children: _pages(),
      ),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onTap: (i) {
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        },
      ),
    );
  }
}

// ─── Bottom Navigation Bar ───────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final items = [
      _NavItem(Icons.home_filled, Icons.home_outlined, s.navHome),
      _NavItem(Icons.explore, Icons.explore_outlined, s.navMovies),
      _NavItem(Icons.live_tv, Icons.live_tv_outlined, s.navLive),
      _NavItem(Icons.download_rounded, Icons.download_outlined, s.downloadsTitle),
      _NavItem(Icons.person, Icons.person_outline, s.navMe),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF050505),
        border: Border(
          top: BorderSide(
            color: Color(0x0FFFFFFF),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ─ Glowing indicator dot ─
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          width: i == index ? 18 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: i == index
                                ? AppColors.primary
                                : Colors.transparent,
                            boxShadow: i == index
                                ? const [
                                    BoxShadow(
                                      color: Color(0x99E50914),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        Icon(
                          i == index
                              ? items[i].active
                              : items[i].inactive,
                          size: 22,
                          color: i == index
                              ? Colors.white
                              : const Color(0xFF555555),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            color: i == index
                                ? Colors.white
                                : const Color(0xFF555555),
                            fontSize: 10,
                            fontWeight: i == index
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item Model ──────────────────────────────────────────
class _NavItem {
  final IconData active;
  final IconData inactive;
  final String label;
  _NavItem(this.active, this.inactive, this.label);
}
