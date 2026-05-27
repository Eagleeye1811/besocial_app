import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/brand_asset_model.dart';

/// Bottom sheet that picks an image from gallery/camera, captures a type +
/// label + primary flag, then uploads. Requires `NSPhotoLibraryUsageDescription`
/// (iOS) and (optionally) `NSCameraUsageDescription` in `Info.plist` for the
/// `image_picker` flow to succeed.
class AssetPickerSheet extends StatefulWidget {
  /// When non-null, the type chooser is hidden and locked to this type
  /// (the section opens the picker pre-scoped to a sub-grid). Mirrors the
  /// web's `lockedType` on AssetPickerModal.
  final BrandAssetType? lockedType;

  const AssetPickerSheet({super.key, this.lockedType});

  static Future<void> show(BuildContext context, {BrandAssetType? lockedType}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AssetPickerSheet(lockedType: lockedType),
    );
  }

  @override
  State<AssetPickerSheet> createState() => _AssetPickerSheetState();
}

class _AssetPickerSheetState extends State<AssetPickerSheet> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _label = TextEditingController();
  File? _file;
  late BrandAssetType _type;
  bool _primary = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _type = widget.lockedType ?? BrandAssetType.face;
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final result =
        await _picker.pickImage(source: source, imageQuality: 90);
    if (result == null || !mounted) return;
    setState(() => _file = File(result.path));
  }

  Future<void> _upload() async {
    if (_file == null || _label.text.trim().isEmpty || _uploading) return;
    setState(() => _uploading = true);
    final controller = Get.find<BrandController>();
    final created = await controller.uploadAsset(
      type: _type,
      label: _label.text.trim(),
      isPrimary: _primary,
      file: _file!,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    if (created != null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              children: [
                Text(
                  'Add brand asset',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontFamilyFallback: AppFonts.displayFallback,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 14),
                _preview(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library_outlined,
                            size: 16),
                        label: const Text('From gallery'),
                        onPressed: () => _pick(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text('Camera'),
                        onPressed: () => _pick(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (widget.lockedType == null) ...[
                  _typePicker(),
                  const SizedBox(height: 14),
                ],
                TextField(
                  controller: _label,
                  decoration: const InputDecoration(
                    hintText: 'Short label (e.g. Hero shot)',
                  ),
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _primary,
                  onChanged: (v) => setState(() => _primary = v ?? false),
                  title: const Text('Make this the primary asset for its type'),
                ),
              ],
            ),
          ),
          _actionBar(),
        ],
      ),
    );
  }

  Widget _preview() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: _file == null
            ? const Center(
                child: Icon(Icons.add_photo_alternate_outlined,
                    size: 32, color: AppColors.ink4),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_file!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _typePicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BrandAssetType.values.map((t) {
        final isOn = t == _type;
        return InkWell(
          onTap: () => setState(() => _type = t),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isOn ? AppColors.accentSoft : AppColors.white,
              border: Border.all(
                color: isOn ? AppColors.accent : AppColors.line,
                width: isOn ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              t.name,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isOn ? AppColors.accentInk : AppColors.ink2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _actionBar() {
    final canUpload =
        _file != null && _label.text.trim().isNotEmpty && !_uploading;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: canUpload ? _upload : null,
                child: _uploading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Upload'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
