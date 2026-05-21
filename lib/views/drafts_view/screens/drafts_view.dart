import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/dash_shell.dart';
import '../../../controllers/drafts_controller/drafts_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/draft_card.dart';

/// Mirrors the right column of `CalendarPage.jsx`'s `DraftsQueue`. The
/// calendar grid itself is out of scope for v1 — drafts get a dedicated
/// screen as their nav destination.
class DraftsView extends GetView<DraftsController> {
  const DraftsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashShell(
      currentTab: DashTab.drafts,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: controller.pager.loadFirst,
          child: NotificationListener<ScrollNotification>(
            onNotification: (note) {
              if (note.metrics.pixels >=
                  note.metrics.maxScrollExtent - 240) {
                controller.pager.loadMore();
              }
              return false;
            },
            child: Obx(() {
              final items = controller.pager.items;
              final loading = controller.pager.isLoading.value;

              if (items.isEmpty && loading) {
                return ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: 1 +
                    items.length +
                    (controller.pager.hasMore ? 1 : 0) +
                    (items.isEmpty ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == 0) return const _Header();
                  final dataIndex = i - 1;
                  if (items.isEmpty) return const _Empty();
                  if (dataIndex >= items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return DraftCard(draft: items[dataIndex]);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Header extends GetView<DraftsController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drafts',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.6,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            final n = controller.pager.totalInView.value;
            return Text(
              n == null
                  ? 'Carousels generated, ready to post'
                  : '$n draft${n == 1 ? '' : 's'} ready to post',
              style: TextStyle(fontSize: 13, color: AppColors.ink3),
            );
          }),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_note_outlined,
              size: 36, color: AppColors.ink4),
          const SizedBox(height: 12),
          Text(
            'No drafts yet',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Generate from a shortlisted post to start filling this queue.',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 13, color: AppColors.ink3, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.bookmark_outline, size: 16),
            label: const Text('Open Shortlist'),
            onPressed: () => Get.offAllNamed(AppRoutes.shortlist),
          ),
        ],
      ),
    );
  }
}
