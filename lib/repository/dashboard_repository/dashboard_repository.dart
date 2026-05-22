import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/dio_unwrap.dart';
import '../../data/dto/dashboard_home_dto.dart';
import '../../data/dto/dashboard_recent_post_dto.dart';
import '../../data/dto/dashboard_trending_dto.dart';

/// Dashboard read endpoints. Cursor-paginated feeds (Discover, Drafts) live
/// in their own repositories; this one only owns the three "show me the
/// shape of the user's account" endpoints rendered on `/home`.
///
/// Every method routes through [unwrapDio] so callers only ever see
/// [ApiException].
abstract class DashboardRepository {
  Future<DashboardHomeDto> getHome();
  Future<List<DashboardRecentPostDto>> getRecentPosts({int limit = 5});
  Future<List<DashboardTrendingPostDto>> getTrending({int limit = 5});
}

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<DashboardHomeDto> getHome() {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>('/api/v1/dashboard/home');
      return DashboardHomeDto.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<List<DashboardRecentPostDto>> getRecentPosts({int limit = 5}) {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>(
        '/api/v1/dashboard/recent-posts',
        queryParameters: {'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['posts'] as List<dynamic>)
          .map((e) => DashboardRecentPostDto.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<List<DashboardTrendingPostDto>> getTrending({int limit = 5}) {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>(
        '/api/v1/dashboard/trending',
        queryParameters: {'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['posts'] as List<dynamic>)
          .map(
            (e) => DashboardTrendingPostDto.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    });
  }
}
