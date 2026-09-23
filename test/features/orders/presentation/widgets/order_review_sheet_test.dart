import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/core/network/paginated_result.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/domain/entities/order_item_entity.dart';
import 'package:xstore/features/orders/presentation/widgets/order_review_sheet.dart';
import 'package:xstore/features/product/domain/entities/review_entity.dart';
import 'package:xstore/features/product/presentation/providers/product_dependencies.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

import '../../../../helpers/fake_async_auth_notifier.dart';
import '../../../../helpers/stub_product_remote_datasource.dart';

final _order = OrderEntity(
  id: 'order_1',
  consumerId: mockConsumerUser.id,
  consumerName: 'Jane',
  consumerPhone: '0100',
  vendorId: 'vendor_1',
  vendorName: 'Ahmed',
  vendorStoreName: 'Ahmed Store',
  items: const [
    OrderItemEntity(
      id: 'item_1',
      listingId: 'listing_1',
      listingName: 'Earbuds',
      listingImage: '',
      category: 'Electronics',
      condition: 'New',
      price: 500,
      quantity: 1,
      total: 500,
    ),
  ],
  status: OrderStatus.delivered,
  paymentMethod: PaymentMethod.cashOnDelivery,
  deliveryAddress: const OrderAddress(
    fullName: 'Jane',
    phone: '0100',
    street: 'St',
    city: 'Cairo',
    wilaya: 'Cairo',
  ),
  subtotal: 500,
  shippingCost: 0,
  discount: 0,
  total: 500,
  createdAt: DateTime(2026, 8, 1),
  updatedAt: DateTime(2026, 8, 1),
);

Future<void> _frames(WidgetTester tester, [int n = 10]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('Submit is disabled while posting, so a double tap posts once', (
    tester,
  ) async {
    var posts = 0;
    final pending = Completer<ReviewEntity>();
    final datasource = StubProductRemoteDataSource(
      onFetchProductReviews:
          ({required listingId, required page, required pageSize}) async =>
              const PaginatedResult<ReviewEntity>(
                items: [],
                page: 0,
                pageSize: 20,
                totalCount: 0,
              ),
      onCreateReview: ({required listingId, required params}) {
        posts++;
        return pending.future;
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(mockConsumerUser)),
          productRemoteDataSourceProvider.overrideWithValue(datasource),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => TextButton(
                onPressed: () => showOrderReviewFlow(context, ref, _order),
                child: const Text('open-review'),
              ),
            ),
          ),
        ),
      ),
    );
    await _frames(tester);

    await tester.tap(find.text('open-review'));
    await _frames(tester);
    await tester.enterText(find.byType(TextField), 'Great earbuds');
    await tester.pump();

    await tester.tap(find.byType(XstoreButton));
    await tester.pump();
    await tester.tap(find.byType(XstoreButton), warnIfMissed: false);
    await tester.pump();

    expect(posts, 1);

    pending.complete(
      ReviewEntity(
        id: 'r1',
        userId: mockConsumerUser.id,
        userName: 'Jane',
        rating: 5,
        comment: 'Great earbuds',
        createdAt: DateTime(2026, 9, 1),
      ),
    );
    await _frames(tester);

    expect(find.byType(XstoreButton), findsNothing, reason: 'sheet closed');
    expect(find.text('Thanks for your review!'), findsOneWidget);
    expect(posts, 1);
  });
}
