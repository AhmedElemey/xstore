import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/home/domain/entities/banner_entity.dart';
import 'package:xstore/features/home/presentation/widgets/hero_banner_carousel.dart';

const _image = 'https://example.test/banner.jpg';

Widget _harness({
  required List<BannerEntity> banners,
  void Function(String url)? onBannerTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: HeroBannerCarousel(
        banners: banners,
        onBannerTap: onBannerTap,
      ),
    ),
  );
}

void main() {
  testWidgets('tapping a banner with actionUrl calls onBannerTap',
      (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(
      _harness(
        banners: const [
          BannerEntity(
            id: 'b1',
            title: 'Sale',
            imageUrl: _image,
            actionUrl: '/explore?category=Electronics',
          ),
        ],
        onBannerTap: tapped.add,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey<String>('banner-action-b1')));
    await tester.pump();

    expect(tapped, ['/explore?category=Electronics']);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a banner without actionUrl has no tap target', (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(
      _harness(
        banners: const [
          BannerEntity(
            id: 'b2',
            title: 'Live banner',
            imageUrl: _image,
          ),
        ],
        onBannerTap: tapped.add,
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('banner-action-b2')), findsNothing);
    await tester.tap(find.text('Live banner'), warnIfMissed: false);
    await tester.pump();
    expect(tapped, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('whitespace-only actionUrl is treated as inert', (tester) async {
    await tester.pumpWidget(
      _harness(
        banners: const [
          BannerEntity(
            id: 'b3',
            title: 'Blank link',
            imageUrl: _image,
            actionUrl: '   ',
          ),
        ],
        onBannerTap: (_) {},
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('banner-action-b3')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
