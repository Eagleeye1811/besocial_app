import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../data/models/instagram_status_model.dart';

/// Result of `POST /api/v1/instagram/post/{job_id}` — minimal shape, used by
/// Drafts' "Post Now" action and (later) Shortlist's tap-to-publish.
class InstagramPostResult {
  final String igPostId;
  final String? permalink;
  final int slideCount;

  const InstagramPostResult({
    required this.igPostId,
    this.permalink,
    required this.slideCount,
  });
}

/// Instagram integration surface. Phase 10 only needs the post endpoint;
/// Phase 12 will extend this with `getAuthUrl` / `getStatus` for the
/// connect flow. Keep the abstraction so Phase 12 can add methods without
/// rewriting callers.
abstract class InstagramRepository {
  /// Publish a completed generation job to the user's connected IG account.
  Future<InstagramPostResult> postToInstagram(String jobId);

  /// Mirror of `GET /api/v1/instagram/status`. Phase 12 wires the connect
  /// flow; consumers today only need the boolean to gate the Post Now CTA.
  Future<InstagramStatusModel> getStatus();
}

class InstagramRepositoryImpl implements InstagramRepository {
  final Dio _dio;

  InstagramRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<InstagramPostResult> postToInstagram(String jobId) async {
    final response =
        await _dio.post<dynamic>('/api/v1/instagram/post/$jobId');
    final data = response.data as Map<String, dynamic>;
    return InstagramPostResult(
      igPostId: data['ig_post_id'] as String,
      permalink: data['permalink'] as String?,
      slideCount: data['slide_count'] as int,
    );
  }

  @override
  Future<InstagramStatusModel> getStatus() async {
    final response = await _dio.get<dynamic>('/api/v1/instagram/status');
    return InstagramStatusModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
