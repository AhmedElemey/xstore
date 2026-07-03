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
}
