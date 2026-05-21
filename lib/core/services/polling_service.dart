import 'dart:async';

/// Co-operative cancel signal. Pass into [Poller.until] and call [cancel]
/// from any controller `onClose()` to stop a long-running poll without
/// throwing.
class PollerCancel {
  bool _cancelled = false;
  void cancel() => _cancelled = true;
  bool get isCancelled => _cancelled;
}

/// Thrown when a poll exceeds its `timeout` without reaching a terminal state.
class PollerTimeout implements Exception {
  final Duration elapsed;
  final Object? lastValue;
  const PollerTimeout(this.elapsed, this.lastValue);

  @override
  String toString() =>
      'PollerTimeout: no terminal value after ${elapsed.inSeconds}s';
}

/// Exponential-backoff poller for the backend's terminal-status endpoints
/// (`/onboarding/session`, `/generation/{job_id}`, etc.).
///
/// `fetch` runs immediately, then waits `initialDelay` and retries, multiplying
/// by `backoffFactor` (clamped to `maxDelay`) until either:
///   - `isTerminal(value)` returns `true` (returns that value);
///   - `timeout` elapses (throws [PollerTimeout]);
///   - `cancel.cancel()` is called (returns the most recent value).
class Poller {
  Poller._();

  static Future<T> until<T>({
    required Future<T> Function() fetch,
    required bool Function(T value) isTerminal,
    Duration initialDelay = const Duration(seconds: 2),
    Duration maxDelay = const Duration(seconds: 10),
    double backoffFactor = 1.5,
    Duration? timeout,
    PollerCancel? cancel,
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration delay = initialDelay;
    T lastValue;

    while (true) {
      lastValue = await fetch();
      if (cancel?.isCancelled ?? false) return lastValue;
      if (isTerminal(lastValue)) return lastValue;
      if (timeout != null && stopwatch.elapsed >= timeout) {
        throw PollerTimeout(stopwatch.elapsed, lastValue);
      }

      await Future<void>.delayed(delay);
      if (cancel?.isCancelled ?? false) return lastValue;

      final nextMs = (delay.inMilliseconds * backoffFactor).round();
      delay = Duration(
        milliseconds: nextMs.clamp(0, maxDelay.inMilliseconds),
      );
    }
  }
}
