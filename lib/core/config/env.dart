/// Build-time configuration for the app.
///
/// Values are supplied via `--dart-define` at build/run time so that the
/// same codebase can point at different Eventiq environments without
/// touching source, e.g.:
///
///   flutter run \
///     --dart-define=API_BASE_URL=https://feetandpedals.com \
///     --dart-define=USE_MOCK_DATA=false
///
/// With no flags at all, the app runs entirely on in-memory mock data so it
/// can be built and demoed before the real Eventiq API is confirmed reachable.
class Env {
  Env._();

  /// Base URL of the Eventiq-backed feetandpedals.com API — no trailing
  /// slash, and no `/api` suffix (`ApiEndpoints` appends that).
  ///
  /// Confirmed live: `curl https://feetandpedals.com/api/categories`
  /// returned a real 200 with real category data (see
  /// `docs/eventiq-api-notes.md`). Per Eventiq's own install docs this is
  /// also just the admin panel's domain with `/admin` dropped — the admin
  /// panel is at `feetandpedals.com/admin`. Override with
  /// `--dart-define=API_BASE_URL=...` only if a different environment
  /// (staging, etc.) is needed.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://feetandpedals.com',
  );

  /// When true (the default), the app talks to an in-memory mock repository
  /// instead of the network. Flip to false once a test account exists and
  /// the endpoint contract in `docs/eventiq-api-notes.md` has been verified
  /// against the live API.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  static const String appName = 'Feet and Pedals';
}
