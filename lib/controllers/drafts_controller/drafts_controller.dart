import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/cursor_pager.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/draft_model.dart';
import '../../data/models/generation_job_model.dart';
// GenerationSlideModel is declared in generation_job_model.dart.
import '../../repository/drafts_repository/drafts_repository.dart';
import '../../repository/generation_repository/generation_repository.dart';
import '../../repository/instagram_repository/instagram_repository.dart';

/// Drives `/drafts`. Owns the cursor-paginated list plus on-demand
/// fetching of the full generation job when the user opens a detail sheet.
class DraftsController extends GetxController {
  final DraftsRepository _drafts = GetIt.I<DraftsRepository>();
  final GenerationRepository _generation = GetIt.I<GenerationRepository>();
  final InstagramRepository _instagram = GetIt.I<InstagramRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  late final CursorPager<DraftModel> pager;

  /// Whether the user's Instagram account is connected. Defaults to `false`
  /// until the status call resolves; any failure leaves it `false` so the UI
  /// falls back to the "Download images" action rather than offering a post
  /// that would just fail. Mirrors the web's `instagramConnected` gate.
  final RxBool isInstagramConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    pager = CursorPager<DraftModel>(_fetchPage);
  }

  @override
  void onReady() {
    super.onReady();
    pager.loadFirst();
    _refreshInstagramStatus();
  }

  /// Fetch the IG connection status once on load. Tolerates errors by
  /// treating the account as not connected.
  Future<void> _refreshInstagramStatus() async {
    try {
      final status = await _instagram.getStatus();
      isInstagramConnected.value = status.connected;
    } on ApiException catch (e) {
      isInstagramConnected.value = false;
      _log.w('GET /instagram/status failed: ${e.code}');
    }
  }

  Future<CursorPage<DraftModel>> _fetchPage(String? cursor) async {
    final response = await _drafts.getDrafts(cursor: cursor);
    return response.toCursorPage();
  }

  /// Load the underlying generation job for the detail sheet (slides +
  /// captions are not on the draft list payload). Returns null on failure
  /// so the sheet can render a graceful error state.
  Future<GenerationJobModel?> loadJob(String jobId) async {
    try {
      return await _generation.getJob(jobId);
    } on ApiException catch (e) {
      _log.w('GET /generation/$jobId failed: ${e.code}');
      return null;
    }
  }

  /// Publish a draft to Instagram. The draft stays in the list afterwards —
  /// the backend marks it as posted server-side but doesn't remove it from
  /// the drafts feed (per the audit; correct behavior here matches the
  /// website client). On success, refresh so any server-side flag flips.
  Future<InstagramPostResult?> postToInstagram(String jobId) async {
    try {
      final result = await _instagram.postToInstagram(jobId);
      await pager.loadFirst();
      return result;
    } on ApiException catch (e) {
      Get.snackbar(
        e.code == 'INSTAGRAM_NOT_CONNECTED'
            ? 'Connect Instagram first'
            : 'Post failed',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      _log.w('POST /instagram/post/$jobId failed: ${e.code}');
      return null;
    }
  }

  /// Download fallback used when Instagram isn't connected. There's no
  /// gallery-saver/share package available, so each slide's image URL is
  /// opened in an external browser where the user can long-press to save.
  /// Opens images sequentially. Returns the number of slides launched, or
  /// `null` on failure (job unavailable / no slides) so the caller can warn.
  ///
  /// The caller may pass [slides] directly (the detail sheet already has the
  /// loaded job) to avoid a second network round-trip; otherwise the job is
  /// fetched here.
  Future<int?> downloadSlides(
    String jobId, {
    List<GenerationSlideModel>? slides,
  }) async {
    var resolved = slides;
    if (resolved == null || resolved.isEmpty) {
      final job = await loadJob(jobId);
      resolved = job?.slides;
    }
    if (resolved == null || resolved.isEmpty) {
      _log.w('Download failed — no slides for job $jobId');
      return null;
    }

    var launched = 0;
    for (final slide in resolved) {
      final uri = Uri.tryParse(slide.imageUrl);
      if (uri == null) continue;
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) launched++;
    }
    return launched;
  }
}
