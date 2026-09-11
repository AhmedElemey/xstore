/// Compile-time deployment target (dev staging vs production).
enum AppFlavor {
  dev,
  prod;

  String get name => switch (this) {
        AppFlavor.dev => 'dev',
        AppFlavor.prod => 'prod',
      };

  bool get isDev => this == AppFlavor.dev;
}
