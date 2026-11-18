import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/title.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'live_tv_screen.dart';
import 'me_screen.dart';

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
        const LiveTvScreen(),
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

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final items = [
      _NavItem(Icons.home_filled, Icons.home_outlined, s.navHome),
      _NavItem(Icons.live_tv, Icons.live_tv_outlined, s.navLive),
      _NavItem(Icons.person, Icons.person_outline, s.navMe),
    ];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glowing indicator dot
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: i == index ? 20 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: i == index ? AppColors.primary : Colors.transparent,
                            boxShadow: i == index
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      spreadRadius: 1,
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
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            color: i == index
                                ? Colors.white
                                : AppColors.textTertiary,
                            fontSize: 10.5,
                            fontWeight: i == index
                                ? FontWeight.w700
                                : FontWeight.w500,
                            letterSpacing: 0.3,
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

class _NavItem {
  final IconData active;
  final IconData inactive;
  final String label;
  _NavItem(this.active, this.inactive, this.label);
}
