class MockConfig {
  /// Toggle to switch between mock and real network data.
  ///
  /// Defaults to FALSE: every run and build talks to the live backend
  /// (see `ApiEndpoints.baseUrl`). Pass `--dart-define=MOCK=true` only to
  /// exercise the mock data paths (e.g. the mock-mode test suite in CI).
  static const bool _mockFromDefine = bool.fromEnvironment(
    'MOCK',
    defaultValue: false,
  );
  static const bool useMock = _mockFromDefine;

  /// Simulated latency for loading states (refresh, submits, etc.).
  static const Duration mockDelay = Duration(milliseconds: 800);

  static Future<T> simulate<T>(T data) async {
    await Future.delayed(mockDelay);
    return data;
  }

  static Future<T> simulateScaled<T>(T data, {int multiplier = 1}) async {
    await Future.delayed(
      Duration(milliseconds: mockDelay.inMilliseconds * multiplier),
    );
    return data;
  }
}
