import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/dio_unwrap.dart';
import '../../data/dto/brand_patch_dto.dart';
import '../../data/models/brand_asset_model.dart';
import '../../data/models/brand_profile_model.dart';

/// Every method routes through [unwrapDio] so callers only ever see
/// [ApiException].
abstract class BrandRepository {
  Future<BrandProfileModel> getProfile();
  Future<BrandProfileModel> patchProfile(BrandPatchDto patch);

  Future<List<BrandAssetModel>> listAssets({
    BrandAssetType? type,
    bool primaryOnly = false,
  });
  Future<BrandAssetModel> uploadAsset({
    required BrandAssetType type,
    required String label,
    bool isPrimary = false,
    required File file,
  });
  Future<void> deleteAsset(String assetId);
}

class BrandRepositoryImpl implements BrandRepository {
  final Dio _dio;

  BrandRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<BrandProfileModel> getProfile() {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>('/api/v1/brand');
      return BrandProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<BrandProfileModel> patchProfile(BrandPatchDto patch) {
    return unwrapDio(() async {
      final response = await _dio.patch<dynamic>(
        '/api/v1/brand',
        data: patch.toJson(),
      );
      return BrandProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<List<BrandAssetModel>> listAssets({
    BrandAssetType? type,
    bool primaryOnly = false,
  }) {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>(
        '/api/v1/brand/assets',
        queryParameters: <String, dynamic>{
          if (type != null) 'type': type.name,
          if (primaryOnly) 'primary_only': true,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return (data['assets'] as List<dynamic>)
          .map((e) => BrandAssetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<BrandAssetModel> uploadAsset({
    required BrandAssetType type,
    required String label,
    bool isPrimary = false,
    required File file,
  }) {
    return unwrapDio(() async {
      final form = FormData.fromMap({
        'type': type.name,
        'label': label,
        'is_primary': isPrimary,
        'file': await MultipartFile.fromFile(file.path),
      });
      final response = await _dio.post<dynamic>(
        '/api/v1/brand/assets',
        data: form,
      );
      return BrandAssetModel.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<void> deleteAsset(String assetId) {
    return unwrapDio(() async {
      await _dio.delete<dynamic>('/api/v1/brand/assets/$assetId');
    });
  }
}
