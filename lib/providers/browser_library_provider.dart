import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/browser/browser_store.dart';
import '../data/browser/web_bookmark.dart';
import '../data/browser/web_history_item.dart';

export '../data/browser/web_bookmark.dart';
export '../data/browser/web_history_item.dart';

const int kMaxWebHistoryItems = 200;

final webBookmarkProvider =
    NotifierProvider<WebBookmarkNotifier, List<WebBookmark>>(
      WebBookmarkNotifier.new,
    );

final webHistoryProvider =
    NotifierProvider<WebHistoryNotifier, List<WebHistoryItem>>(
      WebHistoryNotifier.new,
    );

class WebBookmarkNotifier extends Notifier<List<WebBookmark>> {
  final _store = BrowserJsonStore('browser_bookmarks.json');

  @override
  List<WebBookmark> build() {
    Future.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final raw = await _store.load();
    state = raw
        .map(WebBookmark.fromJson)
        .where((e) => e.url.isNotEmpty)
        .toList();
  }

  Future<void> _persist() =>
      _store.save(state.map((e) => e.toJson()).toList());

  bool isBookmarked(String url) => state.any((e) => e.url == url);

  /// Toggle bookmark. Returns true if now bookmarked.
  Future<bool> toggle(String url, String title) async {
    if (url.isEmpty) return false;
    if (isBookmarked(url)) {
      state = state.where((e) => e.url != url).toList();
      await _persist();
      return false;
    }
    state = [
      WebBookmark(
        url: url,
        title: title.isNotEmpty ? title : url,
        createdAt: DateTime.now(),
      ),
      ...state.where((e) => e.url != url),
    ];
    await _persist();
    return true;
  }

  Future<void> removeByUrl(String url) async {
    state = state.where((e) => e.url != url).toList();
    await _persist();
  }

  Future<void> rename(String url, String title) async {
    final t = title.trim();
    if (t.isEmpty) return;
    state = [
      for (final e in state)
        if (e.url == url) e.copyWith(title: t) else e,
    ];
    await _persist();
  }

  Future<void> clearAll() async {
    state = const [];
    await _persist();
  }
}

class WebHistoryNotifier extends Notifier<List<WebHistoryItem>> {
  final _store = BrowserJsonStore('browser_history.json');

  @override
  List<WebHistoryItem> build() {
    Future.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final raw = await _store.load();
    state = raw
        .map(WebHistoryItem.fromJson)
        .where((e) => e.url.isNotEmpty)
        .toList();
  }

  Future<void> _persist() =>
      _store.save(state.map((e) => e.toJson()).toList());

  /// Record a visit. Same URL is moved to the top (title/time updated).
  Future<void> record(String url, String title) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty) {
      return;
    }

    final item = WebHistoryItem(
      url: url,
      title: title.isNotEmpty ? title : url,
      visitedAt: DateTime.now(),
    );
    final list = [item, ...state.where((e) => e.url != url)];
    state = list.length > kMaxWebHistoryItems
        ? list.sublist(0, kMaxWebHistoryItems)
        : list;
    await _persist();
  }

  Future<void> removeByUrl(String url) async {
    state = state.where((e) => e.url != url).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    state = const [];
    await _persist();
  }
}
