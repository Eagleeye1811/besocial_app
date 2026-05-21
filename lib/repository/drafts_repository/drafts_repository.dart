import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../data/dto/drafts_feed_response_dto.dart';

abstract class DraftsRepository {
  Future<DraftsFeedResponseDto> getDrafts({int limit = 24, String? cursor});
}

class DraftsRepositoryImpl implements DraftsRepository {
  final Dio _dio;

  DraftsRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<DraftsFeedResponseDto> getDrafts({int limit = 24, String? cursor}) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/dashboard/drafts',
      queryParameters: <String, dynamic>{
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return DraftsFeedResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
