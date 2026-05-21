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
      assets.add(created);
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
}
