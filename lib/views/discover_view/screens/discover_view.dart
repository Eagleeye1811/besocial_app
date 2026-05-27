import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/dash_shell.dart';
import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/constants/error_messages.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/discover_grid.dart';
import '../widgets/filter_bar.dart';
import '../widgets/refresh_notice.dart';

/// Mirrors the web `DiscoverPage`: an eyebrow + "Discover" heading +
/// description with a 12-hour refresh notice, a format filter bar, and a
/// masonry grid of posts with an explicit "Load more". Tapping a tile opens
/// the detail modal; the heart shortlists in place.
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              _Header(),
              _Content(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'INSPIRATION · TRENDING IN YOUR NICHE',
              //   style: TextStyle(
              //     fontFamily: AppFonts.mono,
              //     fontFamilyFallback: AppFonts.monoFallback,
              //     fontSize: 10.5,
              //     letterSpacing: 0.6,
              //     fontWeight: FontWeight.w500,
              //     color: AppColors.ink3,
              //   ),
              // ),
              // const SizedBox(height: 8),
              Text(
                'Discover',
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.7,
                  height: 1.05,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Posts in your niche, ranked by what's working this week. "
                "Shortlist what resonates — we'll riff on it.",
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.ink3,
                ),
              ),
              const SizedBox(height: 14),
              const RefreshNotice(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        const DiscoverFilterBar(),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _Content extends GetView<DiscoverController> {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.pager.items;
      final loading = controller.pager.isLoading.value;
      final error = controller.pager.error.value;

      // First-load spinner (web: "Loading discover feed…").
      if (items.isEmpty && loading) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Center(
            child: Text(
              'Loading discover feed…',
              style: TextStyle(fontSize: 14, color: AppColors.ink3),
            ),
          ),
        );
      }

      // First-load error (web: "Couldn't load feed" + Try again).
      if (items.isEmpty && error != null) {
        final message = error is ApiException
            ? resolveApiExceptionMessage(error)
            : 'Could not load feed.';
        return _ErrorState(message: message, onRetry: controller.pager.loadFirst);
      }

      return const DiscoverGrid();
    });
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Text(
            "Couldn't load feed",
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.ink3, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
