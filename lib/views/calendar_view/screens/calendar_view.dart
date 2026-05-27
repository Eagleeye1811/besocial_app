import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/dash_shell.dart';
import '../../../controllers/calendar_controller/calendar_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/scheduled_post_model.dart';
import '../widgets/scheduled_detail_sheet.dart';
import '../widgets/scheduled_post_card.dart';

/// Content calendar — the scheduled-posts half of the web `CalendarPage`.
/// A single-day view split into twelve two-hour slots (0-2 … 22-24); each
/// completed generation auto-schedules into its own slot and publishes to
/// Instagram when its time comes.
class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  /// Slot start hours — bucket `scheduled_at` by `floor(localHour / 2) * 2`.
  static const List<int> _slotHours = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22];

  @override
  Widget build(BuildContext context) {
    return DashShell(
      currentTab: DashTab.calendar,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: controller.fetch,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const _Header(),
              const SizedBox(height: 18),
              Obx(() => _body(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (controller.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final err = controller.error.value;
    if (err != null) {
      return _ErrorState(message: err, onRetry: controller.fetch);
    }

    // Bucket posts by their two-hour slot (earliest wins on a collision).
    final bySlot = <int, ScheduledPostModel>{};
    for (final p in controller.posts) {
      final localHour = p.scheduledAt.toLocal().hour;
      final slot = (localHour ~/ 2) * 2;
      bySlot.putIfAbsent(slot, () => p);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < _slotHours.length; i++)
            _Slot(
              hour: _slotHours[i],
              post: bySlot[_slotHours[i]],
              isLast: i == _slotHours.length - 1,
              onTapPost: (post) => ScheduledDetailSheet.show(
                context,
                post: post,
                controller: controller,
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends GetView<CalendarController> {
  const _Header();

  String _dayLabel() {
    if (controller.isToday) return 'Today';
    final d = controller.selectedDate.value;
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content calendar',
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
          'Generated posts publish to Instagram every two hours.',
          style: TextStyle(fontSize: 13, color: AppColors.ink3),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            IconButton(
              onPressed: controller.goToPreviousDay,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous day',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.line),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(() => OutlinedButton(
                    onPressed: controller.goToToday,
                    child: Text(_dayLabel()),
                  )),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: controller.goToNextDay,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next day',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.line),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  final int hour;
  final ScheduledPostModel? post;
  final bool isLast;
  final ValueChanged<ScheduledPostModel> onTapPost;

  const _Slot({
    required this.hour,
    required this.post,
    required this.isLast,
    required this.onTapPost,
  });

  String get _hourLabel {
    final period = hour < 12 ? 'AM' : 'PM';
    final display = hour % 12 == 0 ? 12 : hour % 12;
    return '$display $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.line2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 56,
              padding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.line2)),
              ),
              child: Text(
                _hourLabel,
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 11,
                  color: AppColors.ink3,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: post != null
                    ? ScheduledPostCard(
                        post: post!,
                        onTap: () => onTapPost(post!),
                      )
                    : _EmptySlot(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: const SizedBox(height: 60, width: double.infinity),
    );
  }
}

/// Dashed rounded-rect placeholder, mirroring the web's `1px dashed` empty slot.
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );

    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.ink4),
          const SizedBox(height: 12),
          Text(
            "Couldn't load the calendar",
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
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.ink3, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
