import 'dart:io';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/logger_service.dart';
import '../../data/dto/brand_patch_dto.dart';
import '../../data/models/brand_asset_model.dart';
import '../../data/models/brand_profile_model.dart';
import '../../repository/brand_repository/brand_repository.dart';

/// Drives `/brand`. One source of truth for profile + assets; PATCH calls
/// always replace `profile.value` with the server's authoritative response.
class BrandController extends GetxController {
  final BrandRepository _repo = GetIt.I<BrandRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  final Rxn<BrandProfileModel> profile = Rxn<BrandProfileModel>();
  final RxList<BrandAssetModel> assets = <BrandAssetModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxnString errorMessage = RxnString();

  /// Non-null once a set-primary PATCH comes back 404/405 — the backend route
  /// hasn't shipped. Hides the "Set primary" action across all tiles and
  /// surfaces the web's fallback banner. Mirrors AssetsSection.jsx.
  final RxnString setPrimaryUnsupported = RxnString();

  @override
  void onReady() {
    super.onReady();
    refreshAll();
  }

  Future<void> refreshAll() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait<Object>([
        _repo.getProfile(),
        _repo.listAssets(),
      ]);
      profile.value = results[0] as BrandProfileModel;
      assets.assignAll(results[1] as List<BrandAssetModel>);
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
      _log.w('Brand refresh failed: ${e.code}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Save a section's slice. Returns true on success so callers can flash
  /// a confirmation and close edit mode.
  Future<bool> patchSection(BrandPatchDto patch) async {
    if (isSaving.value) return false;
    isSaving.value = true;
    try {
      profile.value = await _repo.patchProfile(patch);
      Get.snackbar(
        'Saved',
        'Your brand profile was updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'Save failed',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      _log.w('PATCH /brand failed: ${e.code}');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ===========================================
  // Assets
  // ===========================================
  Future<BrandAssetModel?> uploadAsset({
    required BrandAssetType type,
    required String label,
    bool isPrimary = false,
    required File file,
  }) async {
    try {
      final created = await _repo.uploadAsset(
        type: type,
        label: label,
        isPrimary: isPrimary,
        file: file,
      );
      // Refetch so the list reflects the backend's canonical primary-sorted
      // order and any demote-on-set side effects. Mirrors AssetsSection.jsx.
      try {
        assets.assignAll(await _repo.listAssets());
      } on ApiException {
        assets.add(created);
      }
      return created;
    } on ApiException catch (e) {
      Get.snackbar(
        'Upload failed',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      _log.w('POST /brand/assets failed: ${e.code}');
      return null;
    }
  }

  Future<void> deleteAsset(BrandAssetModel asset) async {
    final idx = assets.indexWhere((a) => a.assetId == asset.assetId);
    if (idx < 0) return;
    assets.removeAt(idx);
    try {
      await _repo.deleteAsset(asset.assetId);
    } on ApiException catch (e) {
      assets.insert(idx, asset);
      Get.snackbar(
        'Could not remove',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Promote [asset] to the primary of its type. Optimistic: flip locally
  /// (demoting any current primary of the same type — mirrors the backend's
  /// documented demote-on-set), then PATCH. On 404/405 the route isn't live
  /// yet, so we roll back and latch [setPrimaryUnsupported]. Any other failure
  /// rolls back with a snackbar.
  Future<void> setAssetPrimary(BrandAssetModel asset) async {
    if (asset.isPrimary || setPrimaryUnsupported.value != null) return;

    final snapshot = List<BrandAssetModel>.from(assets);
    assets.assignAll(assets.map((a) {
      if (a.assetId == asset.assetId) return a.copyWith(isPrimary: true);
      if (a.type == asset.type && a.isPrimary) {
        return a.copyWith(isPrimary: false);
      }
      return a;
    }).toList());

    try {
      await _repo.patchAsset(asset.assetId, isPrimary: true);
    } on ApiException catch (e) {
      assets.assignAll(snapshot);
      if (e.httpStatus == 404 || e.httpStatus == 405) {
        setPrimaryUnsupported.value =
            'Set-primary will be available in a future update. Re-upload an '
            'asset to make it primary for now.';
      } else {
        _log.w('PATCH /brand/assets primary failed: ${e.code}');
        Get.snackbar(
          'Could not set primary',
          resolveApiExceptionMessage(e),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
