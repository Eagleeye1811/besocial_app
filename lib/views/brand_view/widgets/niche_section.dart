import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../data/dto/brand_patch_dto.dart';
import '../../../data/models/brand_profile_model.dart';
import 'section_card.dart';

/// Niche editor — disabled when the user hasn't completed onboarding (backend
/// returns NICHE_NOT_INITIALIZED on PATCH if profile.niche is null). Mirrors
/// NicheSection.jsx.
class NicheSection extends StatefulWidget {
  final BrandProfileModel profile;
  const NicheSection({super.key, required this.profile});

  @override
  State<NicheSection> createState() => _NicheSectionState();
}

class _NicheSectionState extends State<NicheSection> {
  late final TextEditingController _primary;
  late final TextEditingController _sub;
  late final TextEditingController _micro;

  bool get _isInitialized => widget.profile.niche != null;

  @override
  void initState() {
    super.initState();
    final niche = widget.profile.niche ?? const <String, dynamic>{};
    _primary = TextEditingController(text: (niche['niche'] as String?) ?? '');
    _sub = TextEditingController(text: (niche['sub_niche'] as String?) ?? '');
    _micro =
        TextEditingController(text: (niche['micro_niche'] as String?) ?? '');
  }

  @override
  void dispose() {
    _primary.dispose();
    _sub.dispose();
    _micro.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final controller = Get.find<BrandController>();
    await controller.patchSection(BrandPatchDto(
      nichePrimary: _primary.text.trim().isEmpty ? null : _primary.text.trim(),
      nicheSub: _sub.text.trim().isEmpty ? null : _sub.text.trim(),
      nicheMicro: _micro.text.trim().isEmpty ? null : _micro.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    return BrandSectionCard(
      eyebrow: 'Niche',
      title: 'What kind of brand we see you as',
      actions: _isInitialized
          ? Obx(() => ElevatedButton(
                onPressed: controller.isSaving.value ? null : _save,
                child: Text(controller.isSaving.value ? 'Saving…' : 'Save'),
              ))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isInitialized)
            const BrandDisabledReason(
              "Niche is set during onboarding. Once it's set, you can refine "
              'it here.',
            ),
          BrandDisabledGate(
            disabled: !_isInitialized,
            child: Column(
              children: [
                BrandLabeledField(
                  label: 'Primary niche',
                  controller: _primary,
                  hint: 'e.g. Wellness',
                ),
                BrandLabeledField(
                  label: 'Sub-niche',
                  controller: _sub,
                  hint: 'e.g. Mindfulness',
                ),
                BrandLabeledField(
                  label: 'Micro-niche',
                  controller: _micro,
                  hint: 'e.g. Daily affirmations for working moms',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
