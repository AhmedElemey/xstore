/// Compile-time deployment target (dev staging vs production).
enum AppFlavor {
  dev,
  prod;

  String get name => switch (this) {
        AppFlavor.dev => 'dev',
        AppFlavor.prod => 'prod',
      };

  String get displayName => switch (this) {
        AppFlavor.dev => 'xStore Dev',
        AppFlavor.prod => 'xStore',
      };

  bool get isDev => this == AppFlavor.dev;

  bool get isProd => this == AppFlavor.prod;

  /// Client ingestion key for the matching Amplitude project. Overridable
  /// at build time with `--dart-define=AMPLITUDE_API_KEY=...`. These are
  /// project write keys, same class as a Firebase/Maps key — they already
  /// ship in `Taskfile.yml` and are not treated as secrets.
  String get amplitudeApiKey => switch (this) {
        AppFlavor.dev => '997771c9a79e1c8d7448c4c8359c3025',
        AppFlavor.prod => 'cc112c1d0642a9a8e7fb28a3f8566f12',
      };
}
