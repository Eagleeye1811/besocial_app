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

/// Instagram integration surface — auth URL, status, and post.
abstract class InstagramRepository {
  /// `GET /api/v1/instagram/auth-url` — returns the URL to load in the
  /// in-app WebView. Side-effect: the backend wipes any prior IG creds
  /// the moment this is called, so don't call it speculatively.
  Future<String> getAuthUrl();

  /// `GET /api/v1/instagram/status`.
  Future<InstagramStatusModel> getStatus();

  /// Publish a completed generation job to the user's connected IG account.
  Future<InstagramPostResult> postToInstagram(String jobId);
}

class InstagramRepositoryImpl implements InstagramRepository {
  final Dio _dio;

  InstagramRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<String> getAuthUrl() async {
    final response = await _dio.get<dynamic>('/api/v1/instagram/auth-url');
    return (response.data as Map<String, dynamic>)['auth_url'] as String;
  }

  @override
  Future<InstagramStatusModel> getStatus() async {
    final response = await _dio.get<dynamic>('/api/v1/instagram/status');
    return InstagramStatusModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

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
}
