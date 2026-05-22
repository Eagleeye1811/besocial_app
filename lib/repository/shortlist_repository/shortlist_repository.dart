import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/dio_unwrap.dart';
import '../../data/models/mode2_config_model.dart';
import '../../data/models/shortlist_item_model.dart';

/// `/api/v1/dashboard/shortlist` surface. Not cursor-paginated — the
/// endpoint returns the full list ordered by `shortlisted_at desc` and a
/// `total` count.
///
/// Every method routes through [unwrapDio] so callers only ever see
/// [ApiException].
abstract class ShortlistRepository {
  Future<List<ShortlistItemModel>> getShortlist();

  /// Remove a post from the shortlist.
  Future<void> remove(String postId);

  /// Kick off a generation for this post. Returns the freshly-minted job id;
  /// the controller hands it to `GenerationRepository.pollUntilTerminal`.
  Future<String> generate(String postId);

  /// Returns null when no override has been saved (the backend will fall
  /// back to the user's default brand voice/palette).
  Future<Mode2ConfigModel?> getConfig(String postId);

  /// PATCH the mode-2 config. The backend enforces mutual-exclusivity per
  /// `style_source`; the [Mode2ConfigSheet] UI gates construction so we
  /// never PATCH an invalid shape.
  Future<Mode2ConfigModel> patchConfig(String postId, Mode2ConfigModel patch);
}

class ShortlistRepositoryImpl implements ShortlistRepository {
  final Dio _dio;

  ShortlistRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<List<ShortlistItemModel>> getShortlist() {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>('/api/v1/dashboard/shortlist');
      final data = response.data as Map<String, dynamic>;
      return (data['posts'] as List<dynamic>)
          .map((e) => ShortlistItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<void> remove(String postId) {
    return unwrapDio(() async {
      await _dio.delete<dynamic>('/api/v1/dashboard/shortlist/$postId');
    });
  }

  @override
  Future<String> generate(String postId) {
    return unwrapDio(() async {
      final response = await _dio
          .post<dynamic>('/api/v1/dashboard/shortlist/$postId/generate');
      return (response.data as Map<String, dynamic>)['job_id'] as String;
    });
  }

  @override
  Future<Mode2ConfigModel?> getConfig(String postId) {
    return unwrapDio(() async {
      final response = await _dio
          .get<dynamic>('/api/v1/dashboard/shortlist/$postId/config');
      if (response.data == null) return null;
      return Mode2ConfigModel.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Mode2ConfigModel> patchConfig(
    String postId,
    Mode2ConfigModel patch,
  ) {
    return unwrapDio(() async {
      final response = await _dio.patch<dynamic>(
        '/api/v1/dashboard/shortlist/$postId/config',
        data: patch.toJson(),
      );
      return Mode2ConfigModel.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
