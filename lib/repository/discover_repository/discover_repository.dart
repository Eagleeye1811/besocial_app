import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/dio_unwrap.dart';
import '../../data/dto/discover_feed_response_dto.dart';
import '../../data/models/discover_post_model.dart';

/// Result of `POST /api/v1/dashboard/discover/refresh`. Either the refresh
/// kicked off (`status: "started"`) or the backend reports another refresh
/// is already running (`REFRESH_IN_PROGRESS` 409 — the envelope interceptor
/// surfaces that as an `ApiException`, so the controller never sees it as
/// a [RefreshTriggerResult]).
class RefreshTriggerResult {
  final String status;
  final String sessionId;
  const RefreshTriggerResult({required this.status, required this.sessionId});
}

/// Every method routes through [unwrapDio] so callers only ever see
/// [ApiException].
abstract class DiscoverRepository {
  Future<DiscoverFeedResponseDto> getFeed({
    DiscoverFormat format = DiscoverFormat.all,
    int limit = 24,
    String? cursor,
  });

  /// `action`: `"shortlisted"` | `"skipped"`. Wire-format strings to match
  /// the backend literal — kept loose here to share the call site between
  /// heart and skip taps without an extra enum.
  Future<void> swipe({required String postId, required String action});

  Future<RefreshTriggerResult> refresh();
}

class DiscoverRepositoryImpl implements DiscoverRepository {
  final Dio _dio;

  DiscoverRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<DiscoverFeedResponseDto> getFeed({
    DiscoverFormat format = DiscoverFormat.all,
    int limit = 24,
    String? cursor,
  }) {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>(
        '/api/v1/dashboard/discover/feed',
        queryParameters: <String, dynamic>{
          'format': format.name,
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );
      return DiscoverFeedResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<void> swipe({required String postId, required String action}) {
    return unwrapDio(() async {
      await _dio.post<dynamic>(
        '/api/v1/dashboard/discover/swipe',
        data: {'post_id': postId, 'action': action},
      );
    });
  }

  @override
  Future<RefreshTriggerResult> refresh() {
    return unwrapDio(() async {
      final response =
          await _dio.post<dynamic>('/api/v1/dashboard/discover/refresh');
      final data = response.data as Map<String, dynamic>;
      return RefreshTriggerResult(
        status: data['status'] as String,
        sessionId: data['session_id'] as String,
      );
    });
  }
}
