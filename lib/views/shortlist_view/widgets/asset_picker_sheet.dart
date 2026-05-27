import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/error_messages.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/brand_asset_model.dart';
import '../../../repository/brand_repository/brand_repository.dart';

/// Single-select brand-asset picker, mirroring the web `AssetPickerModal`.
///
/// Type chips switch the listed category (face / product / logo / background /
/// custom); tapping a tile selects it; "Use this asset" returns the chosen
/// `asset_id`. Upload is intentionally omitted on mobile (deferred — image
/// picker not yet wired in this surface); the web modal's upload tile has no
/// mobile counterpart here.
class AssetPickerSheet extends StatefulWidget {
  final String? initialSelectedId;

  const AssetPickerSheet({super.key, this.initialSelectedId});

  /// Opens the picker. Resolves to the chosen `asset_id`, or `null` if the
  /// user cancelled.
  static Future<String?> show(
    BuildContext context, {
    String? initialSelectedId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AssetPickerSheet(initialSelectedId: initialSelectedId),
    );
  }

  @override
  State<AssetPickerSheet> createState() => _AssetPickerSheetState();
}

class _AssetPickerSheetState extends State<AssetPickerSheet> {
  final BrandRepository _brand = GetIt.I<BrandRepository>();

  // Same id namespace as the web ASSET_TYPES list.
  static const List<BrandAssetType> _types = <BrandAssetType>[
    BrandAssetType.face,
    BrandAssetType.product,
    BrandAssetType.logo,
    BrandAssetType.background,
    BrandAssetType.custom,
  ];

  BrandAssetType _activeType = BrandAssetType.face;
  List<BrandAssetModel> _assets = const <BrandAssetModel>[];
  bool _loading = false;
  String? _error;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedId;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final assets = await _brand.listAssets(type: _activeType);
      if (!mounted) return;
      setState(() {
        _assets = assets;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = resolveApiExceptionMessage(e);
        _loading = false;
      });
    }
  }

  String _typeLabel(BrandAssetType t) {
    switch (t) {
      case BrandAssetType.face:
        return 'Face';
      case BrandAssetType.product:
        return 'Product';
      case BrandAssetType.logo:
        return 'Logo';
      case BrandAssetType.background:
        return 'Background';
      case BrandAssetType.custom:
        return 'Custom';
    }
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick a brand asset',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontFamilyFallback: AppFonts.displayFallback,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose an existing asset to attach.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.ink3),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final t = _types[i];
                final active = t == _activeType;
                return GestureDetector(
                  onTap: active
                      ? null
                      : () {
                          setState(() => _activeType = t);
                          _load();
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          active ? AppColors.accentSoft : Colors.transparent,
                      border: Border.all(
                        color: active
                            ? const Color(0xFFF4D7C4)
                            : AppColors.line,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _typeLabel(t),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: active ? AppColors.accentInk : AppColors.ink2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _body(scrollController)),
          _ConfirmBar(
            canConfirm: _selectedId != null,
            onConfirm: () => Navigator.of(context).pop(_selectedId),
          ),
        ],
      ),
    );
  }

  Widget _body(ScrollController scrollController) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.ink2),
          ),
        ),
      );
    }
    if (_assets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No ${_typeLabel(_activeType).toLowerCase()} assets yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.ink3),
          ),
        ),
      );
    }
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: _assets.length,
      itemBuilder: (_, i) {
        final asset = _assets[i];
        return _AssetTile(
          asset: asset,
          selected: _selectedId == asset.assetId,
          onTap: () => setState(() => _selectedId = asset.assetId),
        );
      },
    );
  }
}

class _AssetTile extends StatelessWidget {
  final BrandAssetModel asset;
  final bool selected;
  final VoidCallback onTap;

  const _AssetTile({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  String get _resolvedUrl {
    final raw = asset.filePath;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return '${ApiConfig.baseUrl}$raw';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.line,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.ink4,
                          size: 18,
                        ),
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
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  if (selected)
                    const Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.accent,
                        child: Icon(Icons.check,
                            size: 13, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                asset.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  final bool canConfirm;
  final VoidCallback onConfirm;

  const _ConfirmBar({required this.canConfirm, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
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
                onPressed: canConfirm ? onConfirm : null,
                child: const Text('Use this asset'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
