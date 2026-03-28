class MockConfig {
  /// Toggle to switch between mock and real network data.
  static const bool useMock = true;

  /// Simulated latency for loading states (refresh, submits, etc.).
  static const Duration mockDelay = Duration(milliseconds: 800);

  static Future<T> simulate<T>(T data) async {
    await Future.delayed(mockDelay);
    return data;
  }
}
