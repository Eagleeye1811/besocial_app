import 'dart:async';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/app_snackbar.dart';
import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/cursor_pager.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/discover_post_model.dart';
import '../../repository/discover_repository/discover_repository.dart';

/// Drives `/discover`, mirroring the web `DiscoverPage`. Owns the format
/// filter, a [CursorPager] feeding the masonry grid, the optimistic
/// shortlist set shared by the grid hearts and the detail modal, and the
/// 12-hour auto-refresh countdown.
///
/// Shortlisting toggles a post in place — it never removes the post from the
/// feed (matching the web, where the heart simply fills/empties).
class DiscoverController extends GetxController {
  final DiscoverRepository _repo = GetIt.I<DiscoverRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  late final CursorPager<DiscoverPostModel> pager;

  final Rx<DiscoverFormat> selectedFormat = DiscoverFormat.all.obs;

  /// Optimistic shortlist set, keyed by `post_id`. Shared by the grid heart
  /// and the detail modal CTA. Mirrors the web `shortlistedIds` map.
  final RxMap<String, bool> shortlistedIds = <String, bool>{}.obs;

  // 12-hour refresh cadence, sourced from the latest feed response.
  final Rxn<DateTime> nextRefreshAt = Rxn<DateTime>();
  final Rxn<Duration> timeUntilRefresh = Rxn<Duration>();

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    pager = CursorPager<DiscoverPostModel>(_fetchPage);
  }

  @override
  void onReady() {
    super.onReady();
    pager.loadFirst();
    _startCountdownTimer();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<CursorPage<DiscoverPostModel>> _fetchPage(String? cursor) async {
    final response = await _repo.getFeed(
      format: selectedFormat.value,
      cursor: cursor,
    );
    nextRefreshAt.value = response.nextRefreshAt;
    _recomputeCountdown();
    return response.toCursorPage();
  }

  // ===========================================
  // Format filter — resets the deck (web: handleFormatChange).
  // ===========================================
  Future<void> setFormat(DiscoverFormat format) async {
    if (selectedFormat.value == format) return;
    selectedFormat.value = format;
    await pager.loadFirst();
  }

  // ===========================================
  // Shortlist toggle — optimistic, with rollback on failure. Never removes
  // the post from the feed. Web: handleShortlistToggle.
  // ===========================================
  bool isShortlisted(String postId) => shortlistedIds[postId] ?? false;

  Future<void> toggleShortlist(DiscoverPostModel post) async {
    final wasShortlisted = isShortlisted(post.postId);
    // Optimistic flip (RxMap []=/remove auto-notify).
    if (wasShortlisted) {
      shortlistedIds.remove(post.postId);
    } else {
      shortlistedIds[post.postId] = true;
    }

    final action = wasShortlisted ? 'skipped' : 'shortlisted';
    try {
      await _repo.swipe(postId: post.postId, action: action);
    } on ApiException catch (e) {
      // Roll back.
      if (wasShortlisted) {
        shortlistedIds[post.postId] = true;
      } else {
        shortlistedIds.remove(post.postId);
      }
      AppSnackbar.error(
        'Could not update shortlist',
        resolveApiExceptionMessage(e),
      );
      _log.w('Shortlist toggle failed: ${e.code}');
    }
  }

  // ===========================================
  // Countdown
  // ===========================================
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _recomputeCountdown(),
    );
  }

  void _recomputeCountdown() {
    final target = nextRefreshAt.value;
    if (target == null) {
      timeUntilRefresh.value = null;
      return;
    }
    final remaining = target.difference(DateTime.now());
    timeUntilRefresh.value = remaining.isNegative ? Duration.zero : remaining;
  }
}
