import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/cursor_pager.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/draft_model.dart';
import '../../data/models/generation_job_model.dart';
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

  @override
  void onInit() {
    super.onInit();
    pager = CursorPager<DraftModel>(_fetchPage);
  }

  @override
  void onReady() {
    super.onReady();
    pager.loadFirst();
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
}
