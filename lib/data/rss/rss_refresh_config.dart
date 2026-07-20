/// Tuning for RSS refresh concurrency and timeouts (§15.10).
///
/// Network may run in parallel; SQLite writes stay single-writer in the repo.
enum RssRefreshMode {
  /// Pull-to-refresh / manual refresh from the UI.
  foreground,

  /// WorkManager / background isolate.
  background,
}

/// Default pool sizes and HTTP timeouts by [RssRefreshMode].
class RssRefreshLimits {
  const RssRefreshLimits({
    required this.poolSize,
    required this.timeout,
  });

  final int poolSize;
  final Duration timeout;

  /// Foreground: snappier fail, higher concurrency (user can pull again).
  static const foreground = RssRefreshLimits(
    poolSize: 6,
    timeout: Duration(seconds: 15),
  );

  /// Background: smaller pool, slightly longer timeout.
  static const background = RssRefreshLimits(
    poolSize: 3,
    timeout: Duration(seconds: 20),
  );

  /// First-time [addFeed] parse is a bit more patient.
  static const addFeedTimeout = Duration(seconds: 20);

  /// Manual single-source refresh uses foreground timeout.
  static const singleFeedTimeout = Duration(seconds: 15);

  /// After this many consecutive failures, alternate-round skip applies.
  static const unhealthyFailureThreshold = 3;

  static RssRefreshLimits forMode(RssRefreshMode mode) {
    return switch (mode) {
      RssRefreshMode.foreground => foreground,
      RssRefreshMode.background => background,
    };
  }
}
