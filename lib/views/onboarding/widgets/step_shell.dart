import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme_constants.dart';
import 'step_head.dart';

/// Outer chrome shared by every onboarding step: a back-aware AppBar (or
/// none, for loading screens) on top, a scrollable body, and a pinned
/// [FootBar] below.
class StepShell extends StatelessWidget {
  final StepHead? head;
  final Widget body;
  final Widget? footer;
  final bool showBackButton;
  final bool showAppBar;

  const StepShell({
    super.key,
    this.head,
    required this.body,
    this.footer,
    this.showBackButton = true,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: showBackButton && Get.routing.previous.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: Get.back<void>,
                    )
                  : const SizedBox.shrink(),
            )
          : null,
      body: SafeArea(
        top: !showAppBar,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (head != null) ...[
                head!,
                const SizedBox(height: 24),
              ],
              body,
            ],
          ),
        ),
      ),
      bottomNavigationBar: footer,
    );
  }
}
