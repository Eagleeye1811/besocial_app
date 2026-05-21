import 'package:get/get.dart';

/// One page returned by a cursor-paginated endpoint.
///
/// Mirrors the wire shape used by `/dashboard/discover/feed` and
/// `/dashboard/drafts` after envelope unwrapping: a list, an optional
/// opaque next cursor, and the `total_in_view` count.
class CursorPage<T> {
  final List<T> items;
  final String? nextCursor;
  final int? totalInView;

  const CursorPage({
    required this.items,
    this.nextCursor,
    this.totalInView,
  });
}

/// Reusable opaque-cursor paginator. Controllers compose one per feed.
///
/// State is exposed as GetX `Rx` so views observe via `Obx`. The fetcher is
/// the only feature-specific piece — give it `(cursor) => repository.page(cursor)`
/// and `loadFirst()` / `loadMore()` handle the rest.
///
/// Cursors are treated as opaque tokens — never parsed, never assumed.
class CursorPager<T> {
  final Future<CursorPage<T>> Function(String? cursor) _fetch;

  final RxList<T> items = <T>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<int> totalInView = Rxn<int>();
  final Rxn<Object> error = Rxn<Object>();

  String? _cursor;
  bool _hasMore = true;

  CursorPager(this._fetch);

  bool get hasMore => _hasMore;
  String? get cursor => _cursor;

  Future<void> loadFirst() async {
    _cursor = null;
    _hasMore = true;
    items.clear();
    await _loadInternal(replace: true);
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoading.value) return;
    await _loadInternal(replace: false);
  }

  Future<void> _loadInternal({required bool replace}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = null;

    try {
      final page = await _fetch(_cursor);
      if (replace) {
        items.value = page.items;
      } else {
        items.addAll(page.items);
      }
      _cursor = page.nextCursor;
      _hasMore = page.nextCursor != null;
      totalInView.value = page.totalInView;
    } catch (e) {
      error.value = e;
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    _cursor = null;
    _hasMore = true;
    items.clear();
    totalInView.value = null;
    error.value = null;
  }
}
