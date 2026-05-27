import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/scheduled_post_model.dart';
import '../../repository/scheduled_posts_repository/scheduled_posts_repository.dart';

/// Drives the content calendar (`/calendar`). Owns the selected local day and
/// that day's scheduled posts. Mirrors the web `CalendarPage` day-window
/// logic: the query bounds local midnight → next local midnight, sent as UTC
/// ISO strings (the repository converts), and the date only ever changes
/// through [goToPreviousDay] / [goToNextDay] / [goToToday], each of which
/// refetches.
class CalendarController extends GetxController {
  final ScheduledPostsRepository _repo =
      GetIt.I<ScheduledPostsRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  /// Local midnight of the day currently in view.
  final Rx<DateTime> selectedDate = _startOfDay(DateTime.now()).obs;

  final RxList<ScheduledPostModel> posts = <ScheduledPostModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  @override
  void onReady() {
    super.onReady();
    fetch();
  }

  /// Local midnight — the calendar day boundary (matches `startOfDay`).
  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool get isToday {
    final now = DateTime.now();
    final d = selectedDate.value;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// Fetch the selected day's scheduled posts. `start`/`end` bound the local
  /// day; the repository sends them as UTC ISO strings.
  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;

    final start = selectedDate.value;
    final end = start.add(const Duration(days: 1));

    try {
      final result = await _repo.getScheduledPosts(start: start, end: end);
      posts.assignAll(result);
    } on ApiException catch (e) {
      error.value = resolveApiExceptionMessage(e);
      posts.clear();
      _log.w('GET /dashboard/scheduled-posts failed: ${e.code}');
    } finally {
      isLoading.value = false;
    }
  }

  void _selectDay(DateTime date) {
    selectedDate.value = _startOfDay(date);
    fetch();
  }

  void goToPreviousDay() =>
      _selectDay(selectedDate.value.subtract(const Duration(days: 1)));

  void goToNextDay() =>
      _selectDay(selectedDate.value.add(const Duration(days: 1)));

  void goToToday() => _selectDay(DateTime.now());

  /// Cancel a scheduled post before it publishes. Optimistic: drop it from the
  /// list on success, restore on failure.
  Future<bool> cancel(String scheduledPostId) async {
    final index =
        posts.indexWhere((p) => p.scheduledPostId == scheduledPostId);
    if (index < 0) return false;

    final removed = posts[index];
    posts.removeAt(index);

    try {
      await _repo.cancel(scheduledPostId);
      return true;
    } on ApiException catch (e) {
      posts.insert(index, removed);
      Get.snackbar(
        'Could not cancel',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      _log.w('DELETE /dashboard/scheduled-posts/$scheduledPostId failed: '
          '${e.code}');
      return false;
    }
  }

  /// Edit a scheduled post's caption before it publishes. On success, patch
  /// the list entry in place so the new caption shows immediately.
  Future<bool> updateCaption(String scheduledPostId, String caption) async {
    try {
      final saved = await _repo.updateCaption(scheduledPostId, caption);
      final index =
          posts.indexWhere((p) => p.scheduledPostId == scheduledPostId);
      if (index >= 0) {
        posts[index] = posts[index].copyWith(caption: saved);
      }
      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'Could not save caption',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      _log.w('PATCH /dashboard/scheduled-posts/$scheduledPostId failed: '
          '${e.code}');
      return false;
    }
  }
}
