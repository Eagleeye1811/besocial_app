import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/dto/brand_patch_dto.dart';
import '../../../data/models/brand_profile_model.dart';
import 'section_card.dart';

class IdentitySection extends StatefulWidget {
  final BrandProfileModel profile;
  const IdentitySection({super.key, required this.profile});

  @override
  State<IdentitySection> createState() => _IdentitySectionState();
}

class _IdentitySectionState extends State<IdentitySection> {
  late final TextEditingController _name;
  late final TextEditingController _business;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name ?? '');
    _business =
        TextEditingController(text: widget.profile.businessType ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _business.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final controller = Get.find<BrandController>();
    await controller.patchSection(BrandPatchDto(
      name: _name.text.trim().isEmpty ? null : _name.text.trim(),
      businessType:
          _business.text.trim().isEmpty ? null : _business.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    return BrandSectionCard(
      eyebrow: 'Identity',
      title: 'Brand name and business type',
      actions: Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value ? null : _save,
            child: Text(controller.isSaving.value ? 'Saving…' : 'Save'),
          )),
      child: Column(
        children: [
          BrandLabeledField(
            label: 'Display name',
            controller: _name,
            hint: 'Your studio, salon, or brand name',
          ),
          BrandLabeledField(
            label: 'Business type',
            controller: _business,
            hint: 'restaurant · salon · gym · …',
          ),
          if (widget.profile.instagramUsername != null) ...[
            Row(
              children: [
                Text(
                  'IG',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 11,
                    letterSpacing: 0.44,
                    color: AppColors.ink4,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '@${widget.profile.instagramUsername}',
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontFamilyFallback: AppFonts.uiFallback,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
