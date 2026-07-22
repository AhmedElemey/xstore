import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/paginated_result.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/notifications/data/datasources/notifications_remote_datasource.dart';

void main() {
  group('NotificationsRemoteDataSourceImpl fetchPage / _parsePaginatedResponse',
      () {
    late NotificationsRemoteDataSourceImpl datasource;

    Map<String, dynamic> sampleItem({String id = 'n1'}) => {
          'id': id,
          'type': 'orderPlaced',
          'title': 'Order placed',
          'body': 'Your order was placed.',
          'createdAt': '2026-07-23T10:00:00.000Z',
        };

    Dio dioReturning(dynamic data) {
      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                data: data,
                statusCode: 200,
              ),
            );
          },
        ),
      );
      return dio;
    }

    setUp(() {
      datasource = NotificationsRemoteDataSourceImpl(dioReturning({}));
    });

    test('normal page stores 0-based page and hasNextPage(0) is true', () async {
      datasource = NotificationsRemoteDataSourceImpl(
        dioReturning({
          'items': [sampleItem()],
          'totalCount': 50,
          'page': 1,
          'pageSize': 20,
          'totalPages': 3,
        }),
      );

      final result = await datasource.fetchPage(
        role: UserRole.consumer,
        page: 0,
        pageSize: 20,
      );

      expect(result.page, 0);
      expect(result.pageSize, 20);
      expect(result.totalCount, 50);
      expect(result.totalPages, 3);
      expect(result.items, hasLength(1));
      expect(result.hasNextPage(0), isTrue);
    });

    test('last wire page returns hasNextPage false for current 0-based page',
        () async {
      datasource = NotificationsRemoteDataSourceImpl(
        dioReturning({
          'items': [sampleItem(id: 'n3')],
          'totalCount': 50,
          'page': 3,
          'pageSize': 20,
          'totalPages': 3,
        }),
      );

      final result = await datasource.fetchPage(
        role: UserRole.consumer,
        page: 2,
        pageSize: 20,
      );

      expect(result.page, 2);
      expect(result.totalPages, 3);
      expect(result.hasNextPage(2), isFalse);
    });

    test('single page inbox has hasNextPage(0) false immediately', () async {
      datasource = NotificationsRemoteDataSourceImpl(
        dioReturning({
          'items': [sampleItem()],
          'totalCount': 1,
          'page': 1,
          'pageSize': 20,
          'totalPages': 1,
        }),
      );

      final result = await datasource.fetchPage(
        role: UserRole.consumer,
        page: 0,
        pageSize: 20,
      );

      expect(result.totalPages, 1);
      expect(result.hasNextPage(0), isFalse);
    });

    test('empty inbox keeps real zeros and hasNextPage false', () async {
      datasource = NotificationsRemoteDataSourceImpl(
        dioReturning({
          'items': <Map<String, dynamic>>[],
          'totalCount': 0,
          'page': 1,
          'pageSize': 20,
          'totalPages': 0,
        }),
      );

      final result = await datasource.fetchPage(
        role: UserRole.consumer,
        page: 0,
        pageSize: 20,
      );

      expect(result.items, isEmpty);
      expect(result.totalCount, 0);
      expect(result.totalPages, 0);
      expect(result.hasNextPage(0), isFalse);
    });

    test('non-Map response falls back to empty PaginatedResult', () async {
      datasource = NotificationsRemoteDataSourceImpl(dioReturning(<dynamic>[]));

      final result = await datasource.fetchPage(
        role: UserRole.consumer,
        page: 0,
        pageSize: 20,
      );

      expect(result.items, isEmpty);
      expect(result.page, 0);
      expect(result.pageSize, 20);
      expect(result.totalCount, 0);
      expect(result.totalPages, 0);
      expect(result.hasNextPage(0), isFalse);
    });

    test('missing pagination fields default to 0 without throwing', () async {
      datasource = NotificationsRemoteDataSourceImpl(
        dioReturning({
          'items': [sampleItem()],
        }),
      );

      final result = await datasource.fetchPage(
        role: UserRole.consumer,
        page: 0,
        pageSize: 20,
      );

      expect(result.items, hasLength(1));
      expect(result.page, 0);
      expect(result.pageSize, 20);
      expect(result.totalCount, 0);
      expect(result.totalPages, 0);
      expect(result.hasNextPage(0), isFalse);
    });
  });
}
