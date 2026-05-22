import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Shared wrapper used by every `*RepositoryImpl` so that controllers can
/// rely on a single error type — [ApiException] — across the whole app.
///
/// Without this, callers receive a `DioException` whose `.error` *contains*
/// the typed [ApiException] the Dio interceptor produced, which means
/// `on ApiException catch` clauses never match and snackbars never fire.
///
/// The function:
///   - Rethrows a bare [ApiException] untouched.
///   - Unwraps `DioException.error` when it's already an [ApiException]
///     (the standard interceptor path).
///   - Wraps any other [DioException] in a synthetic [ApiException] using
///     [ApiException.codeUnknown] and preserves the original as `cause`.
///   - Wraps any other thrown object (TypeError from `as Map`, etc.) the
///     same way, so the controller can never be blindsided.
Future<T> unwrapDio<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on ApiException {
    rethrow;
  } on DioException catch (e, st) {
    final inner = e.error;
    if (inner is ApiException) throw inner;
    throw ApiException(
      code: ApiException.codeUnknown,
      message: e.message ?? 'The network request failed.',
      httpStatus: e.response?.statusCode,
      cause: e,
      causeStack: st,
    );
  } catch (e, st) {
    throw ApiException(
      code: ApiException.codeUnknown,
      message: 'Unexpected client error: $e',
      cause: e,
      causeStack: st,
    );
  }
}
