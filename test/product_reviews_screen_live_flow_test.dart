// Screen-level, LIVE-mode (MOCK=false) test of ProductReviewsScreen's
// edit-review flow — a real user tapping through the app, not fixture
// data. Matches test/orders_screen_live_flow_test.dart's established
// pattern: real screen + real ProductReviewsNotifier -> ProductRepositoryImpl
// -> ProductRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted (against the CONFIRMED PUT /api/listings/{id}/reviews/{reviewId}
// wire contract).
//
// Unlike OrdersScreen, this screen's own review fetch (`refresh()`, fired
// from `ProductReviewsNotifier.build()`) doesn't gate on `authProvider`
// resolving first — reviews are a public read — so none of the
// auth-prewarm machinery orders_screen_live_flow_test.dart needed applies
// here; a plain ProviderScope + pump loop is enough.
//
// Run with: flutter test test/product_reviews_screen_live_flow_test.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/product/presentation/screens/product_reviews_screen.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as orders_screen_live_flow_test.dart's `_RoutedInterceptor`.
class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes);

  final Map<String, Object? Function(RequestOptions options)> _routes;

  String _key(RequestOptions o) => '${o.method} ${o.path}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final route = _routes[_key(options)];
    if (route == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: StateError('unscripted request: ${_key(options)}'),
        ),
      );
      return;
    }
    final result = route(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

Dio _fakeDio(Map<String, Object? Function(RequestOptions)> routes) {
  final d = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
  d.interceptors.add(_RoutedInterceptor(routes));
  return d;
}

DioException _serverErrorResponse(
  RequestOptions options, {
  int statusCode = 500,
  required String errorEn,
}) => DioException(
  requestOptions: options,
  type: DioExceptionType.badResponse,
  response: Response(
    requestOptions: options,
    statusCode: statusCode,
    data: {
      'isSuccess': false,
      'data': null,
      'errorEn': errorEn,
      'statusCode': statusCode,
    },
  ),
);

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

Map<String, dynamic> _reviewJson({
  String id = 'review_1',
  String userId = 'consumer_1',
  double rating = 4,
  String comment = 'Good product',
}) => {
  'id': id,
  'userId': userId,
  'userName': 'Test Buyer',
  'rating': rating,
  'comment': comment,
  'createdAt': '2026-08-01T00:00:00.000Z',
};

Widget _harness(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: const MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProductReviewsScreen(listingId: '9001'),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from orders_screen_live_flow_test.dart. This
/// screen has no `flutter_animate` entrance animation, but the popup menu
/// and bottom sheet transitions still get pumped this way for consistency
/// and to avoid re-discovering the same class of hang.
Future<void> _settle(
  WidgetTester tester, {
  int times = 15,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'consumer edits their own review and the live PUT wire call refreshes the list',
    // Exercises ProductRemoteDataSourceImpl's LIVE (non-mock) branch.
    skip: MockConfig.useMock,
    (tester) async {
      // Captured and asserted on AFTER the pump loop — an expect() failure
      // thrown from inside a Dio interceptor callback doesn't surface as a
      // normal TestFailure; it hangs the pump loop instead of failing fast
      // (see orders_screen_live_flow_test.dart's note on the same issue).
      RequestOptions? putRequest;
      var rating = 4.0;
      var comment = 'Good product';
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiListingReviews('9001')}': (_) => {
          'items': [_reviewJson(rating: rating, comment: comment)],
          'totalCount': 1,
        },
        'PUT ${ApiEndpoints.apiListingReview('9001', 'review_1')}': (options) {
          putRequest = options;
          rating = 5;
          comment = 'Even better after using it more!';
          return _reviewJson(rating: rating, comment: comment);
        },
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('Good product'), findsOneWidget);

      // Only the review's own author sees the edit/delete menu.
      await tester.tap(find.byType(PopupMenuButton<String>));
      await _settle(tester);
      await tester.tap(find.text('Edit Review'));
      await _settle(tester);

      expect(find.text('Edit Review'), findsWidgets);
      // The sheet pre-fills rating=4 (stars 1-4 filled, 5th empty) and the
      // existing comment — a real user bumping the rating to 5 and
      // rewriting the comment before submitting. Scoped to the sheet
      // itself: the review card behind it also renders a starOff icon for
      // its own (unfilled 5th star) display of the same rating.
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byIcon(LucideIcons.starOff),
        ),
      );
      await tester.enterText(
        find.byType(TextField),
        'Even better after using it more!',
      );
      await tester.tap(find.widgetWithText(XstoreButton, 'Submit'));
      await _settle(tester);

      expect(putRequest, isNotNull);
      expect(putRequest!.data, {
        'rating': 5.0,
        'comment': 'Even better after using it more!',
      });
      expect(
        find.text('Even better after using it more!'),
        findsOneWidget,
        reason: 'a successful update refetches and shows the new comment',
      );
      expect(find.text('Good product'), findsNothing);
    },
  );

  testWidgets(
    'consumer sees the server error when updating a review fails',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiListingReviews('9001')}': (_) => {
          'items': [_reviewJson()],
          'totalCount': 1,
        },
        'PUT ${ApiEndpoints.apiListingReview('9001', 'review_1')}':
            (options) => _serverErrorResponse(
              options,
              errorEn: 'Failed to update review. Please try again.',
            ),
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(find.text('Good product'), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await _settle(tester);
      await tester.tap(find.text('Edit Review'));
      await _settle(tester);

      await tester.enterText(find.byType(TextField), 'Updated comment');
      await tester.tap(find.widgetWithText(XstoreButton, 'Submit'));
      await _settle(tester);

      // A failed update keeps the sheet open (submitReview returns false,
      // ProductReviewsScreen's _submit only pops on success), surfaces the
      // server error, and leaves the original review unchanged.
      expect(find.widgetWithText(XstoreButton, 'Submit'), findsOneWidget);
      expect(
        find.text('Failed to update review. Please try again.'),
        findsOneWidget,
      );
      // "Good product" is the saved review card's text; "Updated comment"
      // only exists as the still-open sheet's unsaved TextField content —
      // the underlying data was never actually persisted.
      expect(find.text('Good product'), findsOneWidget);
    },
  );
}
