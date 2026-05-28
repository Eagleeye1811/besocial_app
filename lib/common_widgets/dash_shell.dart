import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/theme_constants.dart';
import '../core/utils/responsive.dart';
import 'dash_top_bar.dart';

/// Bottom-nav scaffold shared by every signed-in dashboard surface
/// (Home, Discover, Shortlist, Drafts, Calendar). Brand is reached from the
/// top bar instead of the nav. Mirrors the web's `DashShell.jsx`. Tapping a
/// tab does an `offAllNamed` so we don't pile up routes — the dashboard is a
/// flat 5-way selector, not a stack.
class DashShell extends StatelessWidget {
  final DashTab currentTab;
  final Widget body;

  /// Top bar. Defaults to the shared [DashTopBar] (logo + wordmark +
  /// settings); pass a different bar, or `null` via [hideAppBar], to override.
  final PreferredSizeWidget? appBar;

  /// Set when a surface wants no top bar at all (the default bar is used
  /// otherwise, since `appBar == null` can't distinguish "unset" from "none").
  final bool hideAppBar;

  const DashShell({
    super.key,
    required this.currentTab,
    required this.body,
    this.appBar,
    this.hideAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: hideAppBar ? null : (appBar ?? const DashTopBar()),
      body: body,
      bottomNavigationBar: _DashBottomNav(currentTab: currentTab),
    );
  }
}

enum DashTab { home, discover, shortlist, drafts, calendar, brand }

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
      case DashTab.calendar:
        return AppRoutes.calendar;
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
    _NavEntry(DashTab.calendar, Icons.calendar_today_outlined,
        Icons.calendar_today, 'Calendar'),
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
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            // Slightly tighter on compact phones so 5 labels
                            // never wrap; otherwise keep the design size.
                            fontSize:
                                Responsive.isCompact(context) ? 10 : 11,
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
