import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/features/home/domain/entities/category_entity.dart';
import 'package:xstore/features/home/presentation/widgets/category_chip_row.dart';
import 'package:xstore/shared/widgets/app_cached_network_image.dart';

void main() {
  Future<void> pumpRow(WidgetTester tester, List<CategoryEntity> categories) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: CategoryChipRow(categories: categories))),
    );
    // Let the staggered fade-in finish; the image itself is never awaited.
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('a category with a picture shows it as the chip avatar', (tester) async {
    await pumpRow(tester, const [
      CategoryEntity(id: '4', name: 'Beauty', iconUrl: '/uploads/beauty.png'),
    ]);

    expect(tester.takeException(), isNull);
    final image = tester.widget<AppCachedNetworkImage>(find.byType(AppCachedNetworkImage));
    expect(image.imageUrl, '/uploads/beauty.png');
    // Decoded at chip size, not the upload's full resolution.
    expect(image.memCacheWidth, isNotNull);
    expect(image.memCacheWidth! <= 24 * 3, isTrue);
  });

  testWidgets('while loading (or on a 404) the avatar shows the first letter', (tester) async {
    await pumpRow(tester, const [
      CategoryEntity(id: '4', name: 'Beauty', iconUrl: 'https://example.test/missing'),
    ]);

    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('a category without a picture stays a plain text chip', (tester) async {
    await pumpRow(tester, const [CategoryEntity(id: '9', name: 'Books')]);

    expect(find.byType(AppCachedNetworkImage), findsNothing);
    expect(find.text('Books'), findsOneWidget);
  });
}
