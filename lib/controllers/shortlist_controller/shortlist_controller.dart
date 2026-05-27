import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/app_snackbar.dart';
import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/polling_service.dart';
import '../../data/models/generation_job_model.dart';
import '../../data/models/mode2_config_model.dart';
import '../../data/models/shortlist_item_model.dart';
import '../../repository/generation_repository/generation_repository.dart';
import '../../repository/shortlist_repository/shortlist_repository.dart';

/// Drives `/shortlist`. Holds the list, the per-card config sheets, and
/// the per-job poll tokens that flip cards from `generating` → `generated`
/// or `failed` without a full list refresh.
class ShortlistController extends GetxController {
  final ShortlistRepository _repo = GetIt.I<ShortlistRepository>();
  final GenerationRepository _generation = GetIt.I<GenerationRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  final RxList<ShortlistItemModel> items = <ShortlistItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  /// Active poll tokens keyed by `postId` so navigating away cancels them.
  final Map<String, PollerCancel> _activePolls = <String, PollerCancel>{};

  @override
  void onReady() {
    super.onReady();
    // `refresh()` resumes in-flight polls itself once the list is loaded —
    // don't resume here (items aren't fetched yet at this point).
    refresh();
  }

  @override
  void onClose() {
    for (final c in _activePolls.values) {
      c.cancel();
    }
    _activePolls.clear();
    super.onClose();
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final fresh = await _repo.getShortlist();
      items.assignAll(fresh);
      // The backend never flips the shortlist row back from `generating` once
      // a job finishes (only the generation job tracks completion). So for any
      // item the server still reports as in-flight, resume polling its job —
      // the poll reconciles it to `generated`/`failed`. Without this, a card
      // whose generation already completed stays stuck on "Generating…" after
      // navigating back to this screen.
      _resumeInFlightPolls();
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
      _log.w('GET /shortlist failed: ${e.code}');
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================
  // Mutations
  // ===========================================
  Future<void> remove(ShortlistItemModel item) async {
    final idx = items.indexWhere((x) => x.postId == item.postId);
    if (idx < 0) return;
    items.removeAt(idx);
    _activePolls.remove(item.postId)?.cancel();
    try {
      await _repo.remove(item.postId);
    } on ApiException catch (e) {
      items.insert(idx, item);
      AppSnackbar.error(
        'Could not remove',
        resolveApiExceptionMessage(e),
      );
    }
  }

  /// Kick a fresh generation. Mirrors the web `handleGenerate`: the card
  /// flips to `generating` immediately (optimistic); on a failed kickoff it
  /// reverts to `ready`; on success the job id is stashed and polled until
  /// the card reaches a terminal status.
  Future<void> generate(ShortlistItemModel item) async {
    // Optimistic flip — instant feedback before the POST resolves.
    _replaceItem(
      item.postId,
      (current) => current.copyWith(
        generationStatus: ShortlistGenerationStatus.generating,
      ),
    );
    try {
      final jobId = await _repo.generate(item.postId);
      _replaceItem(
        item.postId,
        (current) => current.copyWith(
          generationStatus: ShortlistGenerationStatus.generating,
          generationJobId: jobId,
        ),
      );
      _spawnPollForJob(item.postId, jobId);
    } on ApiException catch (e) {
      // Kickoff failed — roll the card back to ready.
      _replaceItem(
        item.postId,
        (current) => current.copyWith(
          generationStatus: ShortlistGenerationStatus.ready,
        ),
      );
      AppSnackbar.error(
        'Generation failed to start',
        resolveApiExceptionMessage(e),
      );
      _log.w('POST /shortlist/{post_id}/generate failed: ${e.code}');
    }
  }

  void _resumeInFlightPolls() {
    for (final item in items) {
      if (item.generationStatus == ShortlistGenerationStatus.generating &&
          item.generationJobId != null) {
        _spawnPollForJob(item.postId, item.generationJobId!);
      }
    }
  }

  void _spawnPollForJob(String postId, String jobId) {
    // If a previous poll for this post is still running, cancel it first.
    _activePolls.remove(postId)?.cancel();
    final cancel = PollerCancel();
    _activePolls[postId] = cancel;

    _generation.pollUntilTerminal(jobId, cancel: cancel).then((job) {
      _activePolls.remove(postId);
      final completed = job.status == GenerationJobStatus.completed;
      _replaceItem(
        postId,
        (current) => current.copyWith(
          generationStatus: completed
              ? ShortlistGenerationStatus.generated
              : ShortlistGenerationStatus.failed,
          generationJobId: jobId,
          // Capture the failure cause so the card can render mapped copy.
          generationError: completed ? null : job.errorMessage,
          generationErrorCode: completed ? null : job.errorCode,
        ),
      );
    }).catchError((Object e, StackTrace st) {
      _activePolls.remove(postId);
      _log.w('Poll for $jobId errored: $e');
      _replaceItem(
        postId,
        (current) => current.copyWith(
          generationStatus: ShortlistGenerationStatus.failed,
          generationJobId: jobId,
        ),
      );
    });
  }

  // ===========================================
  // Config
  // ===========================================
  Future<Mode2ConfigModel?> loadConfig(String postId) async {
    try {
      return await _repo.getConfig(postId);
    } on ApiException catch (e) {
      _log.w('GET /shortlist/$postId/config failed: ${e.code}');
      return null;
    }
  }

  Future<bool> saveConfig(String postId, Mode2ConfigModel patch) async {
    try {
      await _repo.patchConfig(postId, patch);
      return true;
    } on ApiException catch (e) {
      AppSnackbar.error(
        'Could not save settings',
        resolveApiExceptionMessage(e),
      );
      return false;
    }
  }

  // ===========================================
  // Internals
  // ===========================================
  void _replaceItem(
    String postId,
    ShortlistItemModel Function(ShortlistItemModel current) transform,
  ) {
    final idx = items.indexWhere((x) => x.postId == postId);
    if (idx < 0) return;
    items[idx] = transform(items[idx]);
  }
}
