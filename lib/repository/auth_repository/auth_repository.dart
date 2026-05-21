import 'package:dio/dio.dart';

import '../../core/network/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/user_model.dart';

/// Auth-related backend calls.
///
/// Surface mirrors the FastAPI auth router 1:1; nothing about OAuth UX
/// (the in-app WebView, redirect interception, …) lives here. That's
/// orchestrated by `AuthService` and `AuthController`.
abstract class AuthRepository {
  /// `POST /api/v1/auth/invite/validate` → returns the signed short-lived
  /// `invite_token` the caller hands to Google sign-in.
  Future<String> validateInvite(String code);

  /// `GET /api/v1/auth/google` → returns the Google authorize URL to load in
  /// the WebView. `sessionId` is always passed so the backend can promote
  /// onboarding-session data to the user on callback; `inviteToken` is
  /// required for new-user signup only.
  Future<String> getGoogleAuthorizeUrl({
    required String sessionId,
    String? inviteToken,
  });

  /// `GET /api/v1/auth/me` → returns the currently-authenticated user.
  /// Requires an `Authorization` header — set by the Dio interceptor when
  /// the JWT has been persisted.
  Future<UserModel> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<String> validateInvite(String code) async {
    final response = await _dio.post<dynamic>(
      '${ApiConfig.baseUrl}/api/v1/auth/invite/validate'.replaceFirst(
        ApiConfig.baseUrl,
        '',
      ),
      data: {'code': code},
    );
    // Envelope interceptor has already unwrapped `data` → `{invite_token: …}`.
    final data = response.data as Map<String, dynamic>;
    return data['invite_token'] as String;
  }

  @override
  Future<String> getGoogleAuthorizeUrl({
    required String sessionId,
    String? inviteToken,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/auth/google',
      queryParameters: <String, dynamic>{
        'session_id': sessionId,
        if (inviteToken != null) 'invite_token': inviteToken,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['authorize_url'] as String;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get<dynamic>('/api/v1/auth/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
