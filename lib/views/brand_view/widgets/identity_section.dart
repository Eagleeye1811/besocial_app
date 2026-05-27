import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/dto/brand_patch_dto.dart';
import '../../../data/models/brand_profile_model.dart';
import 'brand_options.dart';
import 'section_card.dart';

/// Identity — brand name, single-select business type, multi-select visual
/// styles (max 3). Mirrors IdentitySection.jsx.
class IdentitySection extends StatefulWidget {
  final BrandProfileModel profile;
  const IdentitySection({super.key, required this.profile});

  @override
  State<IdentitySection> createState() => _IdentitySectionState();
}

class _IdentitySectionState extends State<IdentitySection> {
  late final TextEditingController _name;
  late String? _businessType;
  late List<String> _selectedStyles;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name ?? '');
    _businessType = widget.profile.businessType;
    _selectedStyles = List<String>.from(widget.profile.selectedStyles);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _toggleStyle(String id) {
    setState(() {
      if (_selectedStyles.contains(id)) {
        _selectedStyles.remove(id);
      } else {
        // Cap at kMaxStyles — silently reject the 4th add (matches web).
        if (_selectedStyles.length >= kMaxStyles) return;
        _selectedStyles.add(id);
      }
    });
  }

  Future<void> _save() async {
    final controller = Get.find<BrandController>();
    await controller.patchSection(BrandPatchDto(
      name: _name.text.trim().isEmpty ? null : _name.text.trim(),
      businessType: _businessType,
      selectedStyles: _selectedStyles,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    return BrandSectionCard(
      eyebrow: 'Identity',
      title: 'Who you are',
      actions: Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value ? null : _save,
            child: Text(controller.isSaving.value ? 'Saving…' : 'Save'),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandLabeledField(
            label: 'Brand name',
            controller: _name,
            hint: 'e.g. Maison Lumière',
          ),
          const SizedBox(height: 4),
          const BrandSubLabel('Business type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: kBusinessTypes
                .map((bt) => BrandChip(
                      label: bt.label,
                      active: _businessType == bt.id,
                      onTap: () => setState(() => _businessType = bt.id),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          BrandSubLabel(
            'Visual styles  · up to $kMaxStyles',
            trailing: BrandCounter(
              count: _selectedStyles.length,
              max: kMaxStyles,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: kStylePresets
                .map((s) => BrandChip(
                      label: s.label,
                      active: _selectedStyles.contains(s.id),
                      onTap: () => _toggleStyle(s.id),
                    ))
                .toList(),
          ),
          if (widget.profile.instagramUsername != null) ...[
            const SizedBox(height: 18),
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
