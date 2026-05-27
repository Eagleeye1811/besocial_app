import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../core/network/api_config.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/brand_asset_model.dart';
import 'asset_picker_sheet.dart';
import 'section_card.dart';

/// Display order + labels for the per-type sub-grids. Mirrors AssetsSection.jsx
/// ASSET_TYPES.
const List<({BrandAssetType type, String label, String singular})>
    _assetTypeRows = <({BrandAssetType type, String label, String singular})>[
  (type: BrandAssetType.face, label: 'Face photos', singular: 'face photo'),
  (
    type: BrandAssetType.product,
    label: 'Product photos',
    singular: 'product photo'
  ),
  (type: BrandAssetType.logo, label: 'Logos', singular: 'logo'),
  (
    type: BrandAssetType.background,
    label: 'Backgrounds',
    singular: 'background'
  ),
  (type: BrandAssetType.custom, label: 'Custom assets', singular: 'custom asset'),
];

/// Brand assets — one sub-grid per asset type, each with a header (count +
/// Add button), per-type empty state, primary badge, delete + set-primary
/// actions. Mirrors AssetsSection.jsx + AssetTypeGrid.jsx.
class AssetsSection extends StatelessWidget {
  const AssetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();

    return BrandSectionCard(
      eyebrow: 'Assets',
      title: 'Brand assets',
      child: Obx(() {
        final assets = controller.assets;
        final unsupported = controller.setPrimaryUnsupported.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photos and logos the AI uses when generating posts. The primary '
              'asset of each type is the default.',
              style: TextStyle(
                fontFamily: AppFonts.ui,
                fontFamilyFallback: AppFonts.uiFallback,
                fontSize: 12.5,
                color: AppColors.ink3,
              ),
            ),
            if (unsupported != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unsupported,
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontFamilyFallback: AppFonts.uiFallback,
                    fontSize: 12,
                    color: AppColors.accentInk,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            for (final row in _assetTypeRows)
              _AssetTypeGrid(
                type: row.type,
                typeLabel: row.label,
                singular: row.singular,
                assets: assets.where((a) => a.type == row.type).toList(),
                setPrimaryUnsupported: unsupported != null,
              ),
          ],
        );
      }),
    );
  }
}

/// One asset type's sub-grid.
class _AssetTypeGrid extends StatelessWidget {
  final BrandAssetType type;
  final String typeLabel;
  final String singular;
  final List<BrandAssetModel> assets;
  final bool setPrimaryUnsupported;

  const _AssetTypeGrid({
    required this.type,
    required this.typeLabel,
    required this.singular,
    required this.assets,
    required this.setPrimaryUnsupported,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                typeLabel,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  letterSpacing: -0.14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${assets.length} ${assets.length == 1 ? 'asset' : 'assets'}',
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 11,
                  color: AppColors.ink3,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    AssetPickerSheet.show(context, lockedType: type),
                icon: const Icon(Icons.add, size: 16),
                label: Text('Add $singular'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (assets.isEmpty)
            _emptyState()
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
              children: assets
                  .map((a) => _AssetTile(
                        asset: a,
                        setPrimaryUnsupported: setPrimaryUnsupported,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        'No ${typeLabel.toLowerCase()} yet. The AI will use brand defaults '
        'until you upload one.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppFonts.ui,
          fontFamilyFallback: AppFonts.uiFallback,
          fontSize: 13,
          color: AppColors.ink3,
        ),
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final BrandAssetModel asset;
  final bool setPrimaryUnsupported;

  const _AssetTile({
    required this.asset,
    required this.setPrimaryUnsupported,
  });

  String get _resolvedUrl {
    final raw = asset.filePath;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return '${ApiConfig.baseUrl}$raw';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    final showSetPrimary = !asset.isPrimary && !setPrimaryUnsupported;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: asset.isPrimary ? AppColors.accent : AppColors.line,
          width: asset.isPrimary ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: _resolvedUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surface2),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surface2,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppColors.ink4),
                    ),
                  ),
                ),
                if (asset.isPrimary)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRIMARY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: const CircleBorder(
                      side: BorderSide(color: AppColors.line),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _confirmDelete(context, controller),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.close, size: 13, color: AppColors.ink2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontFamilyFallback: AppFonts.uiFallback,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                if (showSetPrimary)
                  GestureDetector(
                    onTap: () => controller.setAssetPrimary(asset),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Set primary',
                        style: TextStyle(
                          fontFamily: AppFonts.ui,
                          fontFamilyFallback: AppFonts.uiFallback,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentInk,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, BrandController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Delete asset'),
        content: Text('Delete "${asset.label}"? This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteAsset(asset);
    }
  }
}
