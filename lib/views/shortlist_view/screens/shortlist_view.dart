import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/dash_shell.dart';
import '../../../controllers/shortlist_controller/shortlist_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/shortlist_item_model.dart';
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
                children: [
                  const SizedBox(height: 120),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Loading your shortlist…',
                      style: TextStyle(fontSize: 14, color: AppColors.ink3),
                    ),
                  ),
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
            final generated = items
                .where((i) =>
                    i.generationStatus == ShortlistGenerationStatus.generated)
                .length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _ShortlistHeader(count: items.length, generated: generated),
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

/// Page header for the Shortlist tab. Mirrors the web `ShortlistHeader.jsx`:
/// eyebrow + title + subtitle, plus a stat pill ("{count} posts ready to
/// generate"), with a secondary "· {n} generated" segment when any item has
/// finished generating.
class _ShortlistHeader extends StatelessWidget {
  final int count;
  final int generated;
  const _ShortlistHeader({required this.count, required this.generated});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CUSTOMIZE · GENERATE',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 11,
            color: AppColors.ink3,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your shortlist',
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 28,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.6,
            color: AppColors.ink,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Customize each post — edit slide text, attach your assets — and '
          'generate when ready.',
          style: TextStyle(fontSize: 13, color: AppColors.ink3, height: 1.5),
        ),
        const SizedBox(height: 14),
        _StatPill(count: count, generated: generated),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final int count;
  final int generated;
  const _StatPill({required this.count, required this.generated});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome,
                size: 13, color: AppColors.accent),
          ),
          const SizedBox(width: 8),
          Text(
            '$count post${count == 1 ? '' : 's'} ready to generate',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (generated > 0) ...[
            const SizedBox(width: 10),
            Container(width: 1, height: 14, color: AppColors.line),
            const SizedBox(width: 10),
            Text(
              '$generated generated',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.good,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
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
            "Couldn't load shortlist",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.ink3),
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
