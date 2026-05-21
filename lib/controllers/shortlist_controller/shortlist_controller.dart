import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

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
    refresh();
    // Resume polling for any items the server says are mid-generation —
    // covers the case where the user closed the app during a generation.
    _resumeInFlightPolls();
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
      Get.snackbar(
        'Could not remove',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Kick a fresh generation. Updates the card to `generating` then polls
  /// the new job until terminal, replacing the card with the final status.
  Future<void> generate(ShortlistItemModel item) async {
    try {
      final jobId = await _repo.generate(item.postId);
      _replaceItem(item.postId, (current) => _withStatus(
            current,
            ShortlistGenerationStatus.generating,
            jobId: jobId,
          ));
      _spawnPollForJob(item.postId, jobId);
    } on ApiException catch (e) {
      Get.snackbar(
        'Generation failed to start',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
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
      final nextStatus = job.status == GenerationJobStatus.completed
          ? ShortlistGenerationStatus.generated
          : ShortlistGenerationStatus.failed;
      _replaceItem(
        postId,
        (current) => _withStatus(current, nextStatus, jobId: jobId),
      );
    }).catchError((Object e, StackTrace st) {
      _activePolls.remove(postId);
      _log.w('Poll for $jobId errored: $e');
      _replaceItem(
        postId,
        (current) => _withStatus(
          current,
          ShortlistGenerationStatus.failed,
          jobId: jobId,
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
      Get.snackbar(
        'Could not save settings',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
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

  ShortlistItemModel _withStatus(
    ShortlistItemModel current,
    ShortlistGenerationStatus next, {
    String? jobId,
  }) {
    return ShortlistItemModel(
      postId: current.postId,
      authorHandle: current.authorHandle,
      thumbnailUrl: current.thumbnailUrl,
      images: current.images,
      caption: current.caption,
      likeCount: current.likeCount,
      format: current.format,
      slideCount: current.slideCount,
      generationStatus: next,
      generationJobId: jobId ?? current.generationJobId,
      shortlistedAt: current.shortlistedAt,
    );
  }
}
