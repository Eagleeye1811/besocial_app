import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/dio_unwrap.dart';
import '../../core/services/polling_service.dart';
import '../../data/models/generation_job_model.dart';

/// Generation backend surface. Phase 5 needs `createJob` + `getJob` + the
/// shared polling helper; Phase 9 will reuse all three when Shortlist gets
/// its tap-to-watch UI, so the API is kept generic (not onboarding-specific).
///
/// Every direct HTTP method routes through [unwrapDio]; `pollUntilTerminal`
/// inherits the contract since it composes `getJob`.
abstract class GenerationRepository {
  /// `POST /api/v1/generation` — no body. Returns the fresh job id; pipeline
  /// runs in the background. Errors with `USER_NOT_READY` if onboarding
  /// hasn't seeded niche/personalization yet, or `REFERENCE_POST_NOT_FOUND`
  /// if the picked post is gone.
  Future<String> createJob();

  /// `GET /api/v1/generation/{job_id}` — single snapshot.
  Future<GenerationJobModel> getJob(String jobId);

  /// Poll `getJob` until the job reaches a terminal status. Configurable
  /// timeout / cancel token so a caller's `onClose` can stop the poll.
  Future<GenerationJobModel> pollUntilTerminal(
    String jobId, {
    Duration timeout = const Duration(minutes: 8),
    PollerCancel? cancel,
  });
}

class GenerationRepositoryImpl implements GenerationRepository {
  final Dio _dio;

  GenerationRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<String> createJob() {
    return unwrapDio(() async {
      final response = await _dio.post<dynamic>('/api/v1/generation');
      final data = response.data as Map<String, dynamic>;
      return data['job_id'] as String;
    });
  }

  @override
  Future<GenerationJobModel> getJob(String jobId) {
    return unwrapDio(() async {
      final response = await _dio.get<dynamic>('/api/v1/generation/$jobId');
      return GenerationJobModel.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<GenerationJobModel> pollUntilTerminal(
    String jobId, {
    Duration timeout = const Duration(minutes: 8),
    PollerCancel? cancel,
  }) {
    return Poller.until<GenerationJobModel>(
      fetch: () => getJob(jobId),
      isTerminal: (job) => job.isTerminal,
      initialDelay: const Duration(seconds: 3),
      maxDelay: const Duration(seconds: 8),
      backoffFactor: 1.4,
      timeout: timeout,
      cancel: cancel,
    );
  }
}
