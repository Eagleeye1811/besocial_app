import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/theme_constants.dart';

/// Bottom-nav scaffold shared by every signed-in dashboard surface
/// (Home, Discover, Shortlist, Drafts, Brand). Mirrors the web's
/// `DashShell.jsx`. Tapping a tab does an `offAllNamed` so we don't pile
/// up routes — the dashboard is a flat 5-way selector, not a stack.
class DashShell extends StatelessWidget {
  final DashTab currentTab;
  final Widget body;
  final PreferredSizeWidget? appBar;

  const DashShell({
    super.key,
    required this.currentTab,
    required this.body,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: appBar,
      body: body,
      bottomNavigationBar: _DashBottomNav(currentTab: currentTab),
    );
  }
}

enum DashTab { home, discover, shortlist, drafts, brand }

extension DashTabRoute on DashTab {
  String get route {
    switch (this) {
      case DashTab.home:
        return AppRoutes.home;
      case DashTab.discover:
        return AppRoutes.discover;
      case DashTab.shortlist:
        return AppRoutes.shortlist;
      case DashTab.drafts:
        return AppRoutes.drafts;
      case DashTab.brand:
        return AppRoutes.brand;
    }
  }
}

class _DashBottomNav extends StatelessWidget {
  final DashTab currentTab;
  const _DashBottomNav({required this.currentTab});

  static const List<_NavEntry> _entries = <_NavEntry>[
    _NavEntry(DashTab.home, Icons.home_outlined, Icons.home, 'Home'),
    _NavEntry(DashTab.discover, Icons.explore_outlined, Icons.explore,
        'Discover'),
    _NavEntry(DashTab.shortlist, Icons.bookmark_outline, Icons.bookmark,
        'Shortlist'),
    _NavEntry(DashTab.drafts, Icons.edit_note_outlined, Icons.edit_note,
        'Drafts'),
    _NavEntry(DashTab.brand, Icons.palette_outlined, Icons.palette, 'Brand'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _entries.map((e) {
              final isActive = e.tab == currentTab;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (isActive) return;
                    Get.offAllNamed(e.tab.route);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? e.activeIcon : e.icon,
                          size: 22,
                          color:
                              isActive ? AppColors.accent : AppColors.ink3,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? AppColors.accentInk
                                : AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavEntry {
  final DashTab tab;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavEntry(this.tab, this.icon, this.activeIcon, this.label);
}
