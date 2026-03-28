/// Stable image URLs for mocks (picsum seeds).
class MockImages {
  static String product(int seed, {int w = 400, int h = 400}) =>
      'https://picsum.photos/seed/product$seed/$w/$h';

  static String banner(int seed) =>
      'https://picsum.photos/seed/banner$seed/800/400';

  static String avatar(int seed) =>
      'https://picsum.photos/seed/avatar$seed/100/100';

  static String category(int seed) =>
      'https://picsum.photos/seed/cat$seed/200/200';

  static List<String> productImages(int productSeed) => [
        product(productSeed),
        product(productSeed + 100),
        product(productSeed + 200),
        product(productSeed + 300),
        product(productSeed + 400),
      ];
}
