/// Feature flags for local-first rollout.
///
/// Phase B: real RSS via Drift when false. Keep true only for offline UI demos.
const bool kUseMockFeed = false;

/// Force mock netizen comments (tests / offline demo only).
/// Production default false: no Key → no filler comments (empty sheet).
const bool kUseMockComments = false;
