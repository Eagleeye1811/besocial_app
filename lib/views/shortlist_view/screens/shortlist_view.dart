import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/dash_shell.dart';
import '../../../controllers/shortlist_controller/shortlist_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/shortlist_card.dart';

/// Mirrors `ShortlistPage.jsx`. List of shortlist cards each carrying
/// status + actions; empty state takes over when there are no items.
class ShortlistView extends GetView<ShortlistController> {
  const ShortlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashShell(
      currentTab: DashTab.shortlist,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: controller.refresh,
          child: Obx(() {
            final items = controller.items;
            final loading = controller.isLoading.value;
            final err = controller.errorMessage.value;

            if (loading && items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (err != null && items.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  _ErrorBlock(
                    message: err,
                    onRetry: controller.refresh,
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  'Shortlist',
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
                Text(
                  '${items.length} post${items.length == 1 ? '' : 's'} ready to generate from',
                  style: TextStyle(fontSize: 13, color: AppColors.ink3),
                ),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  const ShortlistEmptyState()
                else
                  ...items.map((item) => ShortlistCard(item: item)),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.error_outline,
              size: 28, color: Color(0xFFDC2626)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.ink2),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
