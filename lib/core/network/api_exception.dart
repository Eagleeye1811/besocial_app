import 'api_envelope.dart';

/// Single typed exception raised by the network layer.
///
/// Thrown in two situations by `dio_client.dart`'s response interceptor:
///   1. The HTTP call returned an [ApiEnvelope] with `success: false` —
///      [code] and [message] come straight from the backend's [ApiError].
///   2. The HTTP call never produced an envelope (timeout, socket failure,
///      cancellation, 5xx with HTML body, …) — [code] is one of the synthetic
///      constants below and [cause] preserves the underlying error.
///
/// Feature controllers `catch (e) on ApiException` and map [code] to either
/// recovery logic (e.g. `INVALID_TOKEN` → logout) or user-facing copy via
/// `core/constants/error_messages.dart`.
class ApiException implements Exception {
  // Synthetic codes used when the backend never produced an envelope.
  // Distinct from any value emitted by `src/api/exception_handlers.py`.
  static const String codeNetwork = 'CLIENT_NETWORK';
  static const String codeTimeout = 'CLIENT_TIMEOUT';
  static const String codeCancelled = 'CLIENT_CANCELLED';
  static const String codeBadResponse = 'CLIENT_BAD_RESPONSE';
  static const String codeUnknown = 'CLIENT_UNKNOWN';

  final String code;
  final String message;
  final int? httpStatus;
  final Object? cause;
  final StackTrace? causeStack;

  const ApiException({
    required this.code,
    required this.message,
    this.httpStatus,
    this.cause,
    this.causeStack,
  });

  /// Build from a parsed backend envelope error.
  factory ApiException.fromEnvelope(ApiError error, {int? httpStatus}) =>
      ApiException(
        code: error.code,
        message: error.message,
        httpStatus: httpStatus,
      );

  /// True when [code] is one of the client-side synthetic codes — i.e. the
  /// failure happened before the backend could speak.
  bool get isTransport =>
      code == codeNetwork ||
      code == codeTimeout ||
      code == codeCancelled ||
      code == codeBadResponse;

  @override
  String toString() {
    final status = httpStatus != null ? ' [HTTP $httpStatus]' : '';
    return 'ApiException($code$status): $message';
  }
}
