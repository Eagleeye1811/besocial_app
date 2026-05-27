import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/dio_unwrap.dart';
import '../../data/dto/scheduled_posts_response_dto.dart';
import '../../data/models/scheduled_post_model.dart';

/// Brand calendar data access — the scheduled-posts half of the web's
/// `dashboard.js`. Every method funnels through [unwrapDio] so callers only
/// ever see [ApiException].
abstract class ScheduledPostsRepository {
  /// `GET /dashboard/scheduled-posts?start=<iso>&end=<iso>`. [start]/[end]
  /// bound a single local day, sent as UTC ISO strings.
  Future<List<ScheduledPostModel>> getScheduledPosts({
    required DateTime start,
    required DateTime end,
  });

  /// `DELETE /dashboard/scheduled-posts/{id}` — cancel before it publishes.
  Future<void> cancel(String scheduledPostId);

  /// `PATCH /dashboard/scheduled-posts/{id}` with `{ caption }`. Returns the
  /// caption echoed back by the backend.
  Future<String> updateCaption(String scheduledPostId, String caption);
}

class ScheduledPostsRepositoryImpl implements ScheduledPostsRepository {
  final Dio _dio;

  ScheduledPostsRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<List<ScheduledPostModel>> getScheduledPosts({
    required DateTime start,
    required DateTime end,
  }) {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>(
        '/api/v1/dashboard/scheduled-posts',
        queryParameters: <String, dynamic>{
          'start': start.toUtc().toIso8601String(),
          'end': end.toUtc().toIso8601String(),
        },
      );
      return ScheduledPostsResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      ).posts;
    });
  }

  @override
  Future<void> cancel(String scheduledPostId) {
    return unwrapDio(() async {
      await _dio.delete<dynamic>(
        '/api/v1/dashboard/scheduled-posts/$scheduledPostId',
      );
    });
  }

  @override
  Future<String> updateCaption(String scheduledPostId, String caption) {
    return unwrapDio(() async {
      final response = await _dio.patch<dynamic>(
        '/api/v1/dashboard/scheduled-posts/$scheduledPostId',
        data: <String, dynamic>{'caption': caption},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['caption'] as String?) ?? caption;
    });
  }
}
