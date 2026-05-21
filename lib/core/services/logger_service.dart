import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Thin wrapper over the `logger` package. Registered as a singleton in
/// `get_it.dart`; resolve via `GetIt.I<LoggerService>()` rather than
/// instantiating `Logger()` ad-hoc so we get consistent formatting and a
/// single switch for release builds.
class LoggerService {
  late final Logger _logger;

  LoggerService()
      : _logger = Logger(
          // Verbose noise off in profile/release. Errors and above always log.
          level: kReleaseMode ? Level.warning : Level.debug,
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 6,
            colors: false,
            printEmojis: false,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
        );

  void d(Object? message) => _logger.d(message);
  void i(Object? message) => _logger.i(message);
  void w(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);
  void e(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
