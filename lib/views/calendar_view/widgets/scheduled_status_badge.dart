import 'package:flutter/material.dart';

import '../../../data/models/scheduled_post_model.dart';

/// Publish-lifecycle badge, color-coded per status. Mirrors the web
/// `STATUS_STYLE` map (scheduled / publishing / published / failed).
class ScheduledStatusBadge extends StatelessWidget {
  final ScheduledPostStatus status;
  const ScheduledStatusBadge({super.key, required this.status});

  static _Style _styleFor(ScheduledPostStatus status) {
    switch (status) {
      case ScheduledPostStatus.scheduled:
        return const _Style('Scheduled', Color(0xFF3F6212), Color(0xFFECFCCB));
      case ScheduledPostStatus.publishing:
        return const _Style('Publishing', Color(0xFF854D0E), Color(0xFFFEF9C3));
      case ScheduledPostStatus.published:
        return const _Style('Published', Color(0xFF166534), Color(0xFFDCFCE7));
      case ScheduledPostStatus.failed:
        return const _Style('Failed', Color(0xFF991B1B), Color(0xFFFEE2E2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        s.label.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: s.fg,
        ),
      ),
    );
  }
}

class _Style {
  final String label;
  final Color fg;
  final Color bg;
  const _Style(this.label, this.fg, this.bg);
}
