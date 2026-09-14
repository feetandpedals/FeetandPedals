/// Build-time configuration for the app.
///
/// Values are supplied via `--dart-define` at build/run time so that the
/// same codebase can point at different Eventiq environments without
/// touching source, e.g.:
///
///   flutter run \
///     --dart-define=API_BASE_URL=https://api.feetandpedals.com/v1 \
///     --dart-define=USE_MOCK_DATA=false
///
/// With no flags at all, the app runs entirely on in-memory mock data so it
/// can be built and demoed before the real Eventiq API is wired in.
class Env {
  Env._();

  /// Base URL of the Eventiq-backed feetandpedals.com API.
  ///
  /// Replace the default (or pass `--dart-define=API_BASE_URL=...`) once the
  /// real ticketing API base URL is known.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.feetandpedals.com/v1',
  );

  /// When true (the default), the app talks to an in-memory mock repository
  /// instead of the network. Flip to false once [apiBaseUrl] is real and
  /// reachable.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  static const String appName = 'Feet and Pedals';
}
