import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/dio_unwrap.dart';
import '../../data/models/instagram_status_model.dart';
import '../../data/models/instagram_user_post_model.dart';

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

/// Instagram integration surface — auth URL, status, and post.
///
/// Every method routes through [unwrapDio] so callers only ever see
/// [ApiException].
abstract class InstagramRepository {
  /// `GET /api/v1/instagram/auth-url` — returns the URL to load in the
  /// in-app WebView. Side-effect: the backend wipes any prior IG creds
  /// the moment this is called, so don't call it speculatively.
  Future<String> getAuthUrl();

  /// `GET /api/v1/instagram/status`.
  Future<InstagramStatusModel> getStatus();

  /// `GET /api/v1/users/me/instagram-posts?limit=N` — the user's own recent
  /// posts, for the Mode 2 "match style of my post" picker. Surfaces
  /// `INSTAGRAM_NOT_CONNECTED` / `INSTAGRAM_AUTH_FAILED` as [ApiException]
  /// so the caller can prompt a reconnect.
  Future<List<InstagramUserPostModel>> getUserInstagramPosts({int limit = 20});

  /// Publish a completed generation job to the user's connected IG account.
  Future<InstagramPostResult> postToInstagram(String jobId);
}

class InstagramRepositoryImpl implements InstagramRepository {
  final Dio _dio;

  InstagramRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<String> getAuthUrl() {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>('/api/v1/instagram/auth-url');
      return (response.data as Map<String, dynamic>)['auth_url'] as String;
    });
  }

  @override
  Future<InstagramStatusModel> getStatus() {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>('/api/v1/instagram/status');
      return InstagramStatusModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<List<InstagramUserPostModel>> getUserInstagramPosts({
    int limit = 20,
  }) {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>(
        '/api/v1/users/me/instagram-posts',
        queryParameters: {'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['posts'] as List<dynamic>)
          .map((e) =>
              InstagramUserPostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<InstagramPostResult> postToInstagram(String jobId) {
    return unwrapDio(() async {
      final response =
          await _dio.post<dynamic>('/api/v1/instagram/post/$jobId');
      final data = response.data as Map<String, dynamic>;
      return InstagramPostResult(
        igPostId: data['ig_post_id'] as String,
        permalink: data['permalink'] as String?,
        slideCount: data['slide_count'] as int,
      );
    });
  }
}
