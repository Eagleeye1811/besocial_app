import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../services/logger_service.dart';
import '../services/secure_storage_service.dart';
import 'api_config.dart';
import 'api_envelope.dart';
import 'api_exception.dart';

/// Configured Dio singleton.
///
/// Three interceptors run on every request:
///   1. [_AuthHeaderInterceptor] attaches `Authorization` and the onboarding
///      `X-Session-ID` / `X-Session-Token` pair when present. Both can ride
///      simultaneously — the backend uses whichever the route requires.
///   2. [_EnvelopeInterceptor] unwraps `{success,data,error}` so consumers
///      see the inner `data` directly, or throws [ApiException] for
///      `success:false` (4xx and 5xx envelopes both come through here).
///   3. [_DioErrorMapper] converts any remaining [DioException] into a typed
///      [ApiException] with one of the synthetic `CLIENT_*` codes.
///
/// Per-request opt-outs are supported via `options.extra`:
///   - `extra: { 'skipAuth': true }` — don't attach auth headers.
///   - `extra: { 'skipEnvelope': true }` — return raw bytes/data (image
///     proxies, file downloads).
class DioClient {
  final Dio dio;

  DioClient({
    required SecureStorageService secureStorage,
    required LoggerService logger,
  }) : dio = _build(secureStorage: secureStorage, logger: logger);

  static Dio _build({
    required SecureStorageService secureStorage,
    required LoggerService logger,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: <String, String>{'Accept': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    // Staging/debug bypass: a self-signed or hostname-mismatched cert on the
    // staging API was surfacing as `CLIENT_UNKNOWN` because the TLS handshake
    // aborts before any DioException type can be set. Off-release we accept
    // bad certificates so the request reaches the server and any real error
    // can be mapped properly. Release builds keep strict validation.
    if (!kReleaseMode) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );
    }

    dio.interceptors.addAll(<Interceptor>[
      _AuthHeaderInterceptor(secureStorage),
      _EnvelopeInterceptor(),
      _DioErrorMapper(),
      _RequestLogInterceptor(logger),
    ]);

    return dio;
  }
}

class _AuthHeaderInterceptor extends Interceptor {
  static const String _skipFlag = 'skipAuth';

  final SecureStorageService _storage;
  _AuthHeaderInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[_skipFlag] == true) {
      return handler.next(options);
    }

    final jwt = await _storage.readJwt();
    if (jwt != null && jwt.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $jwt';
    }

    final pair = await _storage.readSessionPair();
    if (pair.id != null && pair.id!.isNotEmpty) {
      options.headers['X-Session-ID'] = pair.id;
    }
    if (pair.token != null && pair.token!.isNotEmpty) {
      options.headers['X-Session-Token'] = pair.token;
    }

    handler.next(options);
  }
}

class _EnvelopeInterceptor extends Interceptor {
  static const String _skipFlag = 'skipEnvelope';

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.extra[_skipFlag] == true) {
      return handler.next(response);
    }

    final body = response.data;
    if (body is! Map<String, dynamic> || !body.containsKey('success')) {
      // Non-envelope payload (binary, plain HTML, etc.) — pass through.
      return handler.next(response);
    }

    if (body['success'] == true) {
      response.data = body['data'];
      return handler.next(response);
    }

    // success:false on a 2xx — surface as an error.
    final apiException = _exceptionFromBody(body, response.statusCode);
    handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: apiException,
      ),
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 4xx/5xx responses with our envelope body land here. If we can parse it,
    // upgrade the DioException's `error` to ApiException so downstream sees
    // structured info; otherwise leave it for [_DioErrorMapper] to coerce.
    if (err.requestOptions.extra[_skipFlag] == true) {
      return handler.next(err);
    }
    final body = err.response?.data;
    if (body is Map<String, dynamic> &&
        body['success'] == false &&
        body['error'] is Map<String, dynamic>) {
      final apiException = _exceptionFromBody(body, err.response?.statusCode);
      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: apiException,
          stackTrace: err.stackTrace,
        ),
      );
    }
    handler.next(err);
  }

  static ApiException _exceptionFromBody(
    Map<String, dynamic> body,
    int? httpStatus,
  ) {
    final errorMap = body['error'];
    if (errorMap is Map<String, dynamic>) {
      // ApiError.fromJson can throw a TypeError if the server skips
      // `message` or `code` for some reason. Catch defensively so a
      // malformed error envelope still becomes a usable ApiException
      // instead of an uncaught crash deep inside the interceptor.
      try {
        return ApiException.fromEnvelope(
          ApiError.fromJson(errorMap),
          httpStatus: httpStatus,
        );
      } catch (_) {
        return ApiException(
          code: ApiException.codeBadResponse,
          message: 'Malformed error envelope from the server.',
          httpStatus: httpStatus,
        );
      }
    }
    return ApiException(
      code: ApiException.codeBadResponse,
      message: "Server returned success:false with no error block.",
      httpStatus: httpStatus,
    );
  }
}

class _DioErrorMapper extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is ApiException) {
      // Already mapped by the envelope interceptor; pass through.
      return handler.next(err);
    }

    final mapped = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        ApiException(
          code: ApiException.codeTimeout,
          message: 'Request timed out.',
          httpStatus: err.response?.statusCode,
          cause: err,
          causeStack: err.stackTrace,
        ),
      DioExceptionType.cancel => ApiException(
          code: ApiException.codeCancelled,
          message: 'Request cancelled.',
          cause: err,
          causeStack: err.stackTrace,
        ),
      DioExceptionType.connectionError => ApiException(
          code: ApiException.codeNetwork,
          message: 'Network unavailable.',
          cause: err,
          causeStack: err.stackTrace,
        ),
      DioExceptionType.badCertificate => ApiException(
          code: ApiException.codeNetwork,
          message: 'Secure connection failed.',
          httpStatus: err.response?.statusCode,
          cause: err,
          causeStack: err.stackTrace,
        ),
      DioExceptionType.badResponse => ApiException(
          code: ApiException.codeBadResponse,
          message: err.message ?? 'Unexpected server response.',
          httpStatus: err.response?.statusCode,
          cause: err,
          causeStack: err.stackTrace,
        ),
      DioExceptionType.unknown => ApiException(
          code: ApiException.codeUnknown,
          message: err.message ?? 'Unknown error.',
          cause: err,
          causeStack: err.stackTrace,
        ),
    };

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapped,
        stackTrace: err.stackTrace,
      ),
    );
  }
}

class _RequestLogInterceptor extends Interceptor {
  final LoggerService _log;
  _RequestLogInterceptor(this._log);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _log.d(
      '← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final api = err.error is ApiException ? err.error as ApiException : null;
    _log.w(
      '✗ ${err.requestOptions.method} ${err.requestOptions.uri} '
      '${api ?? err.message ?? err.type.name}',
    );
    handler.next(err);
  }
}
