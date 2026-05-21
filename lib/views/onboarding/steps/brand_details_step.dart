import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 3 — mirrors `BrandDetailsStep.jsx`. Collects brand name, city,
/// description, and the IG handle. Only `username` rides into the backend
/// via `POST /onboarding/profile`; the other fields stay client-side until
/// a future PATCH adds them (see [OnboardingController.submitBrandDetails]).
class BrandDetailsStep extends StatefulWidget {
  const BrandDetailsStep({super.key});

  @override
  State<BrandDetailsStep> createState() => _BrandDetailsStepState();
}

class _BrandDetailsStepState extends State<BrandDetailsStep> {
  final OnboardingController _c = Get.find<OnboardingController>();

  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _description;
  late final TextEditingController _handle;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: _c.brandName.value ?? '');
    _city = TextEditingController(text: _c.brandCity.value ?? '');
    _description = TextEditingController(text: _c.brandDescription.value ?? '');
    _handle = TextEditingController(text: _c.instagramHandle.value ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _description.dispose();
    _handle.dispose();
    super.dispose();
  }

  bool get _isFormReady =>
      _name.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty &&
      _description.text.trim().isNotEmpty &&
      _handle.text.trim().length >= 2;

  Future<void> _submit() async {
    _c.brandName.value = _name.text.trim();
    _c.brandCity.value = _city.text.trim();
    _c.brandDescription.value = _description.text.trim();
    _c.instagramHandle.value = _handle.text.trim();
    await _c.submitBrandDetails();
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 3 of 8',
        title: 'Tell us about your brand',
        sub: 'A few quick details so our AI can study your niche and '
            'competitors.',
      ),
      body: Column(
        children: [
          _LabeledField(label: 'Business name', controller: _name),
          _LabeledField(
            label: 'City',
            controller: _city,
            hint: 'Mumbai',
          ),
          _LabeledField(
            label: 'Short description',
            controller: _description,
            minLines: 3,
            maxLines: 5,
            hint: 'One sentence about who you serve and what makes you '
                'different.',
          ),
          _LabeledField(
            label: 'Instagram handle',
            controller: _handle,
            prefixText: '@',
          ),
          Obx(() {
            final err = _c.errorMessage.value;
            if (err == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                err,
                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
              ),
            );
          }),
        ],
      ),
      footer: Obx(() => FootBar(
            primary: FootBarPrimaryButton(
              label: "Analyze my account",
              icon: Icons.arrow_forward,
              loading: _c.isLoading.value,
              onPressed: _isFormReady ? _submit : null,
            ),
          )),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefixText;
  final int minLines;
  final int maxLines;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.prefixText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
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
            minLines: minLines,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixText: prefixText,
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }
}
