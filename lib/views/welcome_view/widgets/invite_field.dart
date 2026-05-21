import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';

class InviteField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  const InviteField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INVITE CODE',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 11,
            letterSpacing: 0.44,
            color: AppColors.ink4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          autocorrect: false,
          textCapitalization: TextCapitalization.characters,
          onSubmitted: onSubmitted,
          decoration: const InputDecoration(
            hintText: 'Enter your invite code to start',
          ),
        ),
      ],
    );
  }
}
