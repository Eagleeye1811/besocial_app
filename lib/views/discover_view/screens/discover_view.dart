import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/dash_shell.dart';
import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/discover_grid.dart';
import '../widgets/discover_mode_toggle.dart';
import '../widgets/discover_swipe_view.dart';
import '../widgets/filter_bar.dart';
import '../widgets/refresh_notice.dart';

/// Mirrors `DiscoverPage.jsx`. Header + countdown banner + format chips +
/// cursor-paginated grid. The swipe-style card stack from onboarding's
/// inspiration step lives elsewhere — this screen is grid-first.
class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashShell(
      currentTab: DashTab.discover,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: controller.pager.loadFirst,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    'Discover',
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontFamilyFallback: AppFonts.displayFallback,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.6,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
              const SliverToBoxAdapter(child: RefreshNotice()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              const SliverToBoxAdapter(child: DiscoverModeToggle()),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverToBoxAdapter(child: DiscoverFilterBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Obx(
                  () => controller.viewMode.value == DiscoverViewMode.swipe
                      ? const DiscoverSwipeView()
                      : const DiscoverGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
