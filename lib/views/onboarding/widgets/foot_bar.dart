import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';

/// Mirrors `frontend/src/components/patterns/FootBar.jsx` — pinned to the
/// bottom of every onboarding screen, hosts the primary CTA on the right
/// and an optional secondary action (back, skip, …) on the left.
class FootBar extends StatelessWidget {
  final Widget? left;
  final Widget primary;

  const FootBar({super.key, this.left, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (left != null) Expanded(child: left!) else const Spacer(),
            primary,
          ],
        ),
      ),
    );
  }
}

class FootBarPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const FootBarPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                if (icon != null) ...[
                  const SizedBox(width: 6),
                  Icon(icon, size: 16),
                ],
              ],
            ),
    );
  }
}
