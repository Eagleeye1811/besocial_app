import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../data/dto/onboarding_dto.dart';
import '../../data/models/analysis_data_model.dart';
import '../../data/models/niche_data_model.dart';
import '../../data/models/post_data_model.dart';
import '../../data/models/session_model.dart';
import '../../data/models/trending_post_model.dart';

/// Bundles the result of `POST /api/v1/onboarding/profile` — the IG profile
/// snapshot (kept as a loose map; not currently typed because the audit
/// didn't surface a consumer that needs typed access) plus the fresh
/// `session_token` the backend mints.
class ProfileCreatedResult {
  final Map<String, dynamic> profile;
  final String sessionToken;
  const ProfileCreatedResult({required this.profile, required this.sessionToken});
}

/// Result of `POST /api/v1/onboarding/analyze`. The pipeline runs in the
/// background; this synchronous response returns the niche/analysis derived
/// from the seed pass plus the initial post snapshot.
class AnalyzeResult {
  final NicheDataModel niche;
  final AnalysisDataModel analysis;
  final List<PostDataModel> posts;
  const AnalyzeResult({
    required this.niche,
    required this.analysis,
    required this.posts,
  });
}

class BrandAssetUploadResult {
  final String kind;
  final int? slot;
  final String url;
  const BrandAssetUploadResult({
    required this.kind,
    this.slot,
    required this.url,
  });
}

/// All endpoints under `/api/v1/onboarding`. Auth happens via the session
/// header pair (pre-OAuth) or the JWT (post-OAuth); the Dio interceptor
/// attaches both so the backend picks whichever the route requires.
abstract class OnboardingRepository {
  Future<ProfileCreatedResult> createProfile(String instagramUsername);
  Future<AnalyzeResult> analyze();
  Future<SessionStatusModel> getSessionStatus();
  Future<List<TrendingPostModel>> getFeed({int limit = 20, bool skipped = false});
  Future<void> patchSession(OnboardingPatchDto patch);
  Future<void> swipe({required String postId, required String action});
  Future<BrandAssetUploadResult> uploadAsset({
    required String kind,
    int? slot,
    required File file,
  });
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  final Dio _dio;

  OnboardingRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<ProfileCreatedResult> createProfile(String instagramUsername) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/onboarding/profile',
      data: {'username': instagramUsername},
    );
    final data = response.data as Map<String, dynamic>;
    final sessionToken = data['session_token'] as String;
    final profile = Map<String, dynamic>.from(data)..remove('session_token');
    return ProfileCreatedResult(profile: profile, sessionToken: sessionToken);
  }

  @override
  Future<AnalyzeResult> analyze() async {
    final response = await _dio.post<dynamic>('/api/v1/onboarding/analyze');
    final data = response.data as Map<String, dynamic>;
    return AnalyzeResult(
      niche: NicheDataModel.fromJson(data['niche'] as Map<String, dynamic>),
      analysis: AnalysisDataModel.fromJson(
        data['analysis'] as Map<String, dynamic>,
      ),
      posts: (data['posts'] as List<dynamic>)
          .map((e) => PostDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<SessionStatusModel> getSessionStatus() async {
    final response = await _dio.get<dynamic>('/api/v1/onboarding/session');
    return SessionStatusModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<TrendingPostModel>> getFeed({
    int limit = 20,
    bool skipped = false,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/onboarding/feed',
      queryParameters: {'limit': limit, 'skipped': skipped},
    );
    final data = response.data as Map<String, dynamic>;
    return (data['posts'] as List<dynamic>)
        .map((e) => TrendingPostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> patchSession(OnboardingPatchDto patch) async {
    await _dio.patch<dynamic>(
      '/api/v1/onboarding/session',
      data: patch.toJson(),
    );
  }

  @override
  Future<void> swipe({required String postId, required String action}) async {
    await _dio.post<dynamic>(
      '/api/v1/onboarding/swipe',
      data: {'post_id': postId, 'action': action},
    );
  }

  @override
  Future<BrandAssetUploadResult> uploadAsset({
    required String kind,
    int? slot,
    required File file,
  }) async {
    final form = FormData.fromMap({
      'kind': kind,
      if (slot != null) 'slot': slot,
      'file': await MultipartFile.fromFile(file.path),
    });
    final response = await _dio.post<dynamic>(
      '/api/v1/onboarding/assets/upload',
      data: form,
    );
    final data = response.data as Map<String, dynamic>;
    return BrandAssetUploadResult(
      kind: data['kind'] as String,
      slot: data['slot'] as int?,
      url: data['url'] as String,
    );
  }
}
