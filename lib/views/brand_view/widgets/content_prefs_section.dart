import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/dto/brand_patch_dto.dart';
import '../../../data/models/brand_profile_model.dart';
import 'section_card.dart';

class ContentPrefsSection extends StatefulWidget {
  final BrandProfileModel profile;
  const ContentPrefsSection({super.key, required this.profile});

  @override
  State<ContentPrefsSection> createState() => _ContentPrefsSectionState();
}

class _ContentPrefsSectionState extends State<ContentPrefsSection> {
  String? _facePreference;
  bool _faceInContent = false;
  bool _hasProduct = false;
  late final TextEditingController _pillars;

  @override
  void initState() {
    super.initState();
    final p = widget.profile.personalization ?? const <String, dynamic>{};
    _facePreference = p['face_preference'] as String?;
    _faceInContent = p['face_in_content'] as bool? ?? false;
    _hasProduct = p['has_product'] as bool? ?? false;
    final pillars = p['content_pillars'];
    _pillars = TextEditingController(
      text: pillars is List ? pillars.join(', ') : '',
    );
  }

  @override
  void dispose() {
    _pillars.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final controller = Get.find<BrandController>();
    final pillarsList = _pillars.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    await controller.patchSection(BrandPatchDto(
      facePreference: _facePreference,
      faceInContent: _faceInContent,
      hasProduct: _hasProduct,
      contentPillars: pillarsList.isEmpty ? null : pillarsList,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    return BrandSectionCard(
      eyebrow: 'Content prefs',
      title: 'What goes into every post',
      actions: Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value ? null : _save,
            child: Text(controller.isSaving.value ? 'Saving…' : 'Save'),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(text: 'Face preference'),
          const SizedBox(height: 6),
          Row(
            children: [
              _RadioPill(
                label: 'Appears in content',
                selected: _facePreference == 'appears_in_content',
                onTap: () => setState(
                    () => _facePreference = 'appears_in_content'),
              ),
              const SizedBox(width: 8),
              _RadioPill(
                label: 'No face',
                selected: _facePreference == 'no_face',
                onTap: () => setState(() => _facePreference = 'no_face'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _faceInContent,
            onChanged: (v) => setState(() => _faceInContent = v ?? false),
            title: const Text('Show my face in slides when relevant'),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _hasProduct,
            onChanged: (v) => setState(() => _hasProduct = v ?? false),
            title: const Text('I sell a product (vs. service-only)'),
          ),
          const SizedBox(height: 8),
          BrandLabeledField(
            label: 'Content pillars (comma-separated)',
            controller: _pillars,
            hint: 'transformations, behind-the-scenes, education',
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: AppFonts.mono,
        fontFamilyFallback: AppFonts.monoFallback,
        fontSize: 10.5,
        letterSpacing: 0.4,
        color: AppColors.ink4,
      ),
    );
  }
}

class _RadioPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.accentInk : AppColors.ink2,
          ),
        ),
      ),
    );
  }
}
