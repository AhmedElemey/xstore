import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this._respond);

  final Object? Function(RequestOptions options) _respond;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final result = _respond(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

void main() {
  final skipMock = MockConfig.useMock
      ? 'MockConfig.useMock short-circuits Dio'
      : false;

  OrdersRemoteDataSourceImpl datasourceFor(
    Object? Function(RequestOptions options) respond,
  ) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(_ScriptedInterceptor(respond));
    return OrdersRemoteDataSourceImpl(dio);
  }

  group('getOrderById (live Dio path)', () {
    test(
      'unwraps {data} and PascalCase Id',
      () async {
        RequestOptions? captured;
        final ds = datasourceFor((options) {
          if (options.path.contains('/listings/')) {
            return {
              'id': 9,
              'titleEn': 'Spare listing',
              'price': 10,
              'imageUrls': ['https://cdn.example/x.jpg'],
              'userId': 7,
              'userName': 'Store',
            };
          }
          captured = options;
          return {
            'isSuccess': true,
            'data': {
              'Id': 42,
              'Status': 'pending',
              'ListingId': 9,
              'Quantity': 2,
              'Total': '150.5',
            },
          };
        });

        final order = await ds.getOrderById('42');

        expect(captured?.path, ApiEndpoints.orderMeById('42'));
        expect(order?.id, '42');
        expect(order?.total, 150.5);
        expect(order?.items.single.listingId, '9');
        expect(order?.items.single.quantity, 2);
        expect(order?.items.single.listingName, 'Spare listing');
        expect(order?.vendorName, 'Store');
      },
      skip: skipMock,
    );

    test(
      'reads nested listing, address, and seller from the order payload',
      () async {
        final ds = datasourceFor((options) {
          if (options.path.contains('/listings/')) {
            fail('should not hydrate when the order already has snapshots');
          }
          return {
            'id': 42,
            'status': 'pending',
            'quantity': 1,
            'listing': {
              'id': 9,
              'titleEn': 'Nike Air Max',
              'price': 1250,
              'imageUrls': ['https://cdn.example/nike.jpg'],
              'categoryNameEn': 'Fashion',
              'condition': 1,
              'userId': 77,
              'userName': 'Karim',
              'userAvatar': 'https://cdn.example/k.jpg',
              'storeName': 'Cairo Fashion Hub',
            },
            'deliveryAddress': {
              'fullName': 'Jane Doe',
              'phone': '01001234567',
              'street': '12 Nile St',
              'city': 'Cairo',
              'governorate': 'Cairo',
            },
          };
        });

        final order = await ds.getOrderById('42');

        expect(order?.items.single.listingName, 'Nike Air Max');
        expect(order?.items.single.listingImage, 'https://cdn.example/nike.jpg');
        expect(order?.items.single.price, 1250);
        expect(order?.items.single.category, 'Fashion');
        expect(order?.deliveryAddress.fullName, 'Jane Doe');
        expect(order?.deliveryAddress.street, '12 Nile St');
        expect(order?.deliveryAddress.city, 'Cairo');
        expect(order?.deliveryAddress.wilaya, 'Cairo');
        expect(order?.consumerName, 'Jane Doe');
        expect(order?.consumerPhone, '01001234567');
        expect(order?.vendorId, '77');
        expect(order?.vendorStoreName, 'Cairo Fashion Hub');
        expect(order?.vendorAvatar, 'https://cdn.example/k.jpg');
      },
      skip: skipMock,
    );

    test(
      'reads nested buyer for consumerName without using listing userName',
      () async {
        final ds = datasourceFor((options) {
          if (options.path.contains('/listings/')) {
            fail('should not hydrate when the order already has snapshots');
          }
          return {
            'id': 42,
            'status': 'pending',
            'quantity': 1,
            'listing': {
              'id': 9,
              'titleEn': 'Nike Air Max',
              'price': 1250,
              'imageUrls': ['https://cdn.example/nike.jpg'],
              'userId': 77,
              'userName': 'Karim',
              'storeName': 'Cairo Fashion Hub',
            },
            'buyer': {
              'id': 15,
              'fullName': 'Nadia Mansouri',
              'phoneNumber': '01022223333',
              'userImageUrl': 'https://cdn.example/n.jpg',
            },
            'deliveryAddress': {
              'street': '12 Nile St',
              'city': 'Cairo',
              'governorate': 'Giza',
            },
          };
        });

        final order = await ds.getOrderById('42');

        expect(order?.consumerId, '15');
        expect(order?.consumerName, 'Nadia Mansouri');
        expect(order?.consumerPhone, '01022223333');
        expect(order?.consumerAvatar, 'https://cdn.example/n.jpg');
        expect(order?.vendorName, 'Karim');
        expect(order?.deliveryAddress.street, '12 Nile St');
        expect(order?.deliveryAddress.city, 'Cairo');
        expect(order?.deliveryAddress.wilaya, 'Giza');
      },
      skip: skipMock,
    );

    test(
      'reads order-root fullName as the buyer, not listing userName',
      () async {
        final ds = datasourceFor((options) {
          if (options.path.contains('/listings/')) {
            fail('should not hydrate when the order already has snapshots');
          }
          return {
            'id': 7,
            'status': 'pending',
            'quantity': 1,
            'phoneNumber': '01019890451',
            'fullName': 'Ahmed Taha',
            'listing': {
              'id': 9,
              'titleEn': 'Nike Air Max',
              'price': 1250,
              'imageUrls': ['https://cdn.example/nike.jpg'],
              'userId': 77,
              'userName': 'Karim',
              'storeName': 'Cairo Fashion Hub',
            },
          };
        });

        final order = await ds.getOrderById('7');

        expect(order?.consumerName, 'Ahmed Taha');
        expect(order?.consumerPhone, '01019890451');
        expect(order?.vendorName, 'Karim');
      },
      skip: skipMock,
    );

    test(
      'reads nested order user as the buyer when that user is not the vendor',
      () async {
        final ds = datasourceFor((options) {
          if (options.path.contains('/listings/')) {
            fail('should not hydrate when the order already has snapshots');
          }
          return {
            'id': 7,
            'status': 'pending',
            'quantity': 1,
            'phoneNumber': '01019890451',
            'user': {
              'id': 15,
              'fullName': 'Ahmed Taha',
              'phoneNumber': '01019890451',
            },
            'listing': {
              'id': 9,
              'titleEn': 'Nike Air Max',
              'price': 1250,
              'imageUrls': ['https://cdn.example/nike.jpg'],
              'userId': 77,
              'userName': 'Karim',
              'storeName': 'Cairo Fashion Hub',
            },
          };
        });

        final order = await ds.getOrderById('7');

        expect(order?.consumerId, '15');
        expect(order?.consumerName, 'Ahmed Taha');
        expect(order?.consumerPhone, '01019890451');
        expect(order?.vendorName, 'Karim');
      },
      skip: skipMock,
    );

    test(
      'reads storeImageUrl from nested listing as the shop avatar',
      () async {
        final ds = datasourceFor((options) {
          if (options.path.contains('/listings/')) {
            fail('should not hydrate when storeImageUrl is already on the listing');
          }
          return {
            'id': 42,
            'status': 'pending',
            'quantity': 1,
            'listing': {
              'id': 9,
              'titleEn': 'Nike Air Max',
              'price': 1250,
              'imageUrls': ['https://cdn.example/nike.jpg'],
              'storeImageUrl': 'https://cdn.example/shop.jpg',
              'storeName': 'Cairo Fashion Hub',
              'userId': 77,
            },
          };
        });

        final order = await ds.getOrderById('42');

        expect(order?.vendorAvatar, 'https://cdn.example/shop.jpg');
        expect(order?.vendorStoreName, 'Cairo Fashion Hub');
      },
      skip: skipMock,
    );

    test(
      'treats an empty items array as the flat listingId shape',
      () async {
        final ds = datasourceFor((options) {
          if (options.path.contains('/listings/')) {
            return {
              'id': 9,
              'titleEn': 'From listing GET',
              'price': 80,
              'imageUrls': ['https://cdn.example/a.jpg'],
              'userId': 3,
              'userName': 'Ahmed',
              'location': 'Maadi, Cairo',
            };
          }
          return {
            'id': 42,
            'status': 'pending',
            'items': <dynamic>[],
            'listingId': 9,
            'quantity': 1,
          };
        });

        final order = await ds.getOrderById('42');

        expect(order?.items.single.listingId, '9');
        expect(order?.items.single.listingName, 'From listing GET');
        expect(order?.vendorName, 'Ahmed');
        expect(order?.deliveryAddress.street, 'Maadi, Cairo');
      },
      skip: skipMock,
    );

    test(
      'returns null on 404 so the repository can fall back to GET /orders/me',
      () async {
        final ds = datasourceFor(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: options, statusCode: 404),
          ),
        );

        expect(await ds.getOrderById('missing'), isNull);
      },
      skip: skipMock,
    );

    test(
      'does not parse a Result envelope with data: null as an order',
      () async {
        final ds = datasourceFor(
          (_) => {
            'isSuccess': false,
            'data': null,
            'errorEn': 'Order not found',
            'statusCode': 404,
          },
        );

        expect(await ds.getOrderById('2'), isNull);
      },
      skip: skipMock,
    );

    test(
      'parses C# OrderStatus integer codes',
      () async {
        final ds = datasourceFor((options) {
          if (options.path.contains('/listings/')) {
            return {
              'id': 9,
              'titleEn': 'Spare listing',
              'price': 10,
              'imageUrls': ['https://cdn.example/x.jpg'],
              'userId': 7,
              'userName': 'Store',
            };
          }
          return {
            'id': 42,
            'status': 3,
            'listingId': 9,
            'quantity': 1,
          };
        });

        final order = await ds.getOrderById('42');
        expect(order?.status, OrderStatus.shipped);
      },
      skip: skipMock,
    );
  });
}
