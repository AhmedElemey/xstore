import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/legacy_route_options.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/mock/mock_orders.dart';
import '../../../../core/mock/mock_users.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

abstract interface class OrdersRemoteDataSource {
  Future<List<OrderModel>> getConsumerOrders({
    required String consumerId,
    required int page,
    required int pageSize,
  });

  Future<List<OrderModel>> getVendorOrders({
    required String vendorId,
    required int page,
    required int pageSize,
  });

  /// Orders assigned to a platform courier ("Delivered by xStore").
  Future<List<OrderModel>> getCourierOrders({
    required String courierId,
    required int page,
    required int pageSize,
  });

  Future<OrderModel?> getOrderById(String orderId);

  Future<OrderStatsEntity> getVendorOrderStats({required String vendorId});

  Future<OrderModel> cancelOrder({
    required String orderId,
    required String reason,
    required bool isVendorSession,
  });

  Future<OrderModel> confirmOrder(String orderId);

  Future<OrderModel> rejectOrder({
    required String orderId,
    required String reason,
  });

  Future<OrderModel> markProcessing(String orderId);

  Future<OrderModel> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
  });

  Future<OrderModel> markDelivered(String orderId);

  /// Inserts a consumer order after checkout (mock persistence).
  Future<void> registerPlacedConsumerOrder(OrderModel order);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// Hosted backend returns 404 for the whole legacy `/orders/*` module until
  /// it is deployed — treat as "no data" so vendor/consumer screens show the
  /// empty state instead of error spam.
  static bool _isOrdersRouteMissing(DioException e) =>
      e.response?.statusCode == 404;

  Options get _legacyOptions => LegacyRouteOptions.allowNotFound();

  static const _emptyVendorStats = OrderStatsEntity(
    pendingCount: 0,
    activeCount: 0,
    monthCount: 0,
    totalCount: 0,
    totalRevenue: 0,
  );

  static List<OrderModel>? _consumerCache;
  static List<OrderModel>? _vendorCache;

  /// Drops the mock in-memory order fixtures. Called on logout/user switch so
  /// session data never survives into the next account (mock mode only —
  /// live mode always fetches from the API).
  static void clearSessionCache() {
    _consumerCache = null;
    _vendorCache = null;
  }

  List<OrderModel> get _consumerOrders {
    _consumerCache ??= _seedConsumerOrders();
    return _consumerCache!;
  }

  List<OrderModel> get _vendorOrders {
    _vendorCache ??= _seedVendorOrders();
    return _vendorCache!;
  }

  OrderItemModel _lineFromListing(
    String listingId,
    int quantity, {
    required String lineId,
  }) {
    final listing = mockListingModels.firstWhere((e) => e.id == listingId);
    final img = listing.imageUrls.isNotEmpty ? listing.imageUrls.first : '';
    final total = listing.price * quantity;
    return OrderItemModel(
      id: lineId,
      listingId: listing.id,
      listingName: listing.title,
      listingImage: img,
      category: listing.categoryLabel,
      condition: listing.conditionLabel,
      price: listing.price,
      quantity: quantity,
      total: total,
    );
  }

  PaymentMethod _paymentFromLabel(String label) {
    final t = label.toLowerCase();
    if (t.contains('cib')) return PaymentMethod.cibCard;
    if (t.contains('dahabi')) return PaymentMethod.dahabiCard;
    if (t.contains('baridi')) return PaymentMethod.baridimob;
    return PaymentMethod.cashOnDelivery;
  }

  OrderStatus _statusFromMock(MockOrderStatus s) => switch (s) {
        MockOrderStatus.pending => OrderStatus.pending,
        MockOrderStatus.confirmed => OrderStatus.confirmed,
        MockOrderStatus.shipped => OrderStatus.shipped,
        MockOrderStatus.delivered => OrderStatus.delivered,
        MockOrderStatus.cancelled => OrderStatus.cancelled,
      };

  OrderModel _fromMockConsumerRow(MockOrderEntity m) {
    final listing = m.listingSnapshot;
    final item = _lineFromListing(
      listing.id,
      m.quantity,
      lineId: 'line_${m.id}',
    );
    final addrParts =
        m.deliveryAddress.split(',').map((e) => e.trim()).toList();
    final street = addrParts.isNotEmpty ? addrParts.first : m.deliveryAddress;
    final rest = addrParts.length > 1
        ? addrParts.sublist(1).join(', ')
        : m.deliveryAddress;
    final ship = m.totalPrice >= 500 ? 500.0 : 0.0;
    final sub = m.totalPrice - ship;
    return OrderModel(
      id: m.id,
      consumerId: m.consumerId,
      consumerName: mockConsumerUser.name,
      consumerPhone: mockConsumerUser.phoneNumber,
      consumerAvatar: MockImages.avatar(2),
      vendorId: m.vendorId,
      vendorName: mockVendorUser.name,
      vendorStoreName: mockVendorUser.storeName ?? mockVendorUser.name,
      vendorAvatar: MockImages.avatar(1),
      vendorRating: mockVendorUser.rating ?? 4.8,
      items: [item],
      status: _statusFromMock(m.status),
      paymentMethod: _paymentFromLabel(m.paymentMethod),
      isPaid: m.paymentMethod.toLowerCase().contains('cib'),
      deliveryAddress: OrderAddressModel(
        fullName: mockConsumerUser.name,
        phone: mockConsumerUser.phoneNumber,
        street: street,
        city: rest.isNotEmpty ? rest : mockConsumerUser.location ?? 'Oran',
        wilaya: rest.isNotEmpty ? rest : 'Oran',
      ),
      subtotal: sub,
      shippingCost: ship,
      discount: 0,
      total: m.totalPrice,
      trackingNumber: m.trackingNumber,
      courierName: m.trackingNumber != null ? 'xStore Logistics' : null,
      trackingLocation: m.status == MockOrderStatus.shipped
          ? 'In transit — Algiers hub'
          : null,
      estimatedDelivery: m.estimatedDelivery,
      cancelReason: m.cancelReason,
      notes: null,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      confirmedAt: m.status != MockOrderStatus.pending &&
              m.status != MockOrderStatus.cancelled
          ? m.createdAt.add(const Duration(hours: 1))
          : null,
      shippedAt: m.status == MockOrderStatus.shipped ||
              m.status == MockOrderStatus.delivered
          ? m.updatedAt.subtract(const Duration(hours: 2))
          : null,
      deliveredAt: m.status == MockOrderStatus.delivered
          ? m.updatedAt
          : null,
      cancelledAt: m.status == MockOrderStatus.cancelled
          ? m.updatedAt
          : null,
    );
  }

  List<OrderModel> _seedConsumerOrders() =>
      mockOrders.map(_fromMockConsumerRow).toList();

  OrderModel _vendorOrderTemplate({
    required String id,
    String consumerId = 'consumer_guest',
    required String consumerName,
    required String consumerPhone,
    required OrderStatus status,
    required List<OrderItemModel> items,
    required double total,
    required DateTime createdAt,
    PaymentMethod payment = PaymentMethod.cashOnDelivery,
    String? trackingNumber,
    DateTime? estimatedDelivery,
    String? cancelReason,
    DateTime? deliveredAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? cancelledAt,
    String? city,
    String? wilaya,
    String? street,
    String? notes,
    String? courierId,
    String? courierName,
  }) {
    final subtotal = total >= 500 ? total - 500 : total;
    final shipping = total >= 500 ? 500.0 : 0.0;
    return OrderModel(
      id: id,
      consumerId: consumerId,
      consumerName: consumerName,
      consumerPhone: consumerPhone,
      consumerAvatar: MockImages.avatar(3),
      vendorId: mockVendorUser.id,
      vendorName: mockVendorUser.name,
      vendorStoreName: mockVendorUser.storeName ?? mockVendorUser.name,
      vendorAvatar: MockImages.avatar(1),
      vendorRating: mockVendorUser.rating ?? 4.8,
      items: items,
      status: status,
      paymentMethod: payment,
      isPaid: payment != PaymentMethod.cashOnDelivery,
      deliveryAddress: OrderAddressModel(
        fullName: consumerName,
        phone: consumerPhone,
        street: street ?? '12 Rue Didouche Mourad',
        city: city ?? 'Oran',
        wilaya: wilaya ?? city ?? 'Oran',
      ),
      subtotal: subtotal,
      shippingCost: shipping,
      discount: 0,
      total: total,
      trackingNumber: trackingNumber,
      courierId: courierId,
      courierName: courierName ??
          (trackingNumber != null ? 'xStore Logistics' : null),
      trackingLocation: status == OrderStatus.shipped
          ? 'In transit — Algiers hub'
          : null,
      estimatedDelivery: estimatedDelivery,
      cancelReason: cancelReason,
      notes: notes,
      createdAt: createdAt,
      updatedAt: createdAt,
      confirmedAt: confirmedAt ??
          (status != OrderStatus.pending && status != OrderStatus.cancelled
              ? createdAt.add(const Duration(hours: 1))
              : null),
      shippedAt: shippedAt ??
          (status == OrderStatus.shipped || status == OrderStatus.delivered
              ? createdAt.add(const Duration(days: 2))
              : null),
      deliveredAt: deliveredAt,
      cancelledAt: cancelledAt ??
          (status == OrderStatus.cancelled ? createdAt.add(const Duration(days: 1)) : null),
    );
  }

  List<OrderModel> _seedVendorOrders() {
    final now = DateTime.now();
    return [
      _vendorOrderTemplate(
        id: 'XS-2024-V001',
        consumerId: 'consumer_001',
        consumerName: 'Sara Khelifi',
        consumerPhone: '+20 101 987 6543',
        status: OrderStatus.pending,
        items: [
          _lineFromListing('listing_001', 1, lineId: 'line_xs_1'),
        ],
        total: 185500,
        createdAt: now.subtract(const Duration(minutes: 30)),
        payment: PaymentMethod.cashOnDelivery,
        city: 'Oran',
        wilaya: 'Oran',
        notes: 'Please wrap it carefully',
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V002',
        consumerName: 'Karim Boudiaf',
        consumerPhone: '+20 112 123 7890',
        status: OrderStatus.pending,
        items: [
          _lineFromListing('listing_013', 1, lineId: 'line_xs_2'),
        ],
        total: 32500,
        createdAt: now.subtract(const Duration(hours: 2)),
        payment: PaymentMethod.cibCard,
        city: 'Algiers',
        wilaya: 'Algiers',
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V003',
        consumerName: 'Nadia Mansouri',
        consumerPhone: '+20 122 444 2223',
        status: OrderStatus.confirmed,
        items: [
          _lineFromListing('listing_005', 1, lineId: 'line_xs_3a'),
        ],
        total: 280500,
        createdAt: now.subtract(const Duration(days: 1)),
        confirmedAt: now.subtract(const Duration(hours: 20)),
        payment: PaymentMethod.cibCard,
        city: 'Constantine',
        wilaya: 'Constantine',
        courierId: mockCourierUser.id,
        courierName: mockCourierUser.name,
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V004',
        consumerName: 'Youcef Tlemceni',
        consumerPhone: '+20 155 888 1112',
        status: OrderStatus.processing,
        items: [
          _lineFromListing('listing_009', 1, lineId: 'line_xs_4'),
          _lineFromListing('listing_003', 2, lineId: 'line_xs_4b'),
        ],
        total: 120500,
        createdAt: now.subtract(const Duration(days: 2)),
        confirmedAt: now.subtract(const Duration(days: 1, hours: 20)),
        payment: PaymentMethod.cashOnDelivery,
        city: 'Annaba',
        wilaya: 'Annaba',
        courierId: mockCourierUser.id,
        courierName: mockCourierUser.name,
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V005',
        consumerName: 'Amira Setifienne',
        consumerPhone: '+20 101 333 9994',
        status: OrderStatus.shipped,
        items: [
          _lineFromListing('listing_008', 1, lineId: 'line_xs_5'),
        ],
        total: 98500,
        payment: PaymentMethod.dahabiCard,
        trackingNumber: 'YAL-2024-8842',
        courierName: 'Yalidine Express',
        estimatedDelivery: now.add(const Duration(days: 1)),
        city: 'Setif',
        wilaya: 'Setif',
        shippedAt: now.subtract(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V006',
        consumerName: 'Riad Kebir',
        consumerPhone: '+20 122 610 6105',
        status: OrderStatus.delivered,
        items: [
          _lineFromListing('listing_002', 1, lineId: 'line_xs_6'),
        ],
        total: 145500,
        payment: PaymentMethod.cashOnDelivery,
        city: 'Oran',
        wilaya: 'Oran',
        deliveredAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 10)),
        courierId: mockCourierUser.id,
        courierName: mockCourierUser.name,
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V007',
        consumerName: 'Meriem Hadj',
        consumerPhone: '+20 155 700 0016',
        status: OrderStatus.cancelled,
        items: [
          _lineFromListing('listing_006', 1, lineId: 'line_xs_7'),
        ],
        total: 55500,
        payment: PaymentMethod.cashOnDelivery,
        city: 'Algiers',
        wilaya: 'Algiers',
        cancelReason: 'Buyer changed their mind',
        cancelledAt: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V008',
        consumerName: 'Sofiane Rahmani',
        consumerPhone: '+20 112 730 7307',
        status: OrderStatus.confirmed,
        items: [
          _lineFromListing('listing_013', 1, lineId: 'line_xs_8a'),
          _lineFromListing('listing_012', 1, lineId: 'line_xs_8b'),
        ],
        total: 35700,
        payment: PaymentMethod.baridimob,
        city: 'Bejaia',
        wilaya: 'Bejaia',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  List<OrderModel> _page(List<OrderModel> all, int page, int pageSize) {
    final start = (page - 1) * pageSize;
    if (start >= all.length) return [];
    final end = (start + pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  @override
  Future<List<OrderModel>> getConsumerOrders({
    required String consumerId,
    required int page,
    required int pageSize,
  }) async {
    if (MockConfig.useMock) {
      final mine =
          _consumerOrders.where((e) => e.consumerId == consumerId).toList();
      return MockConfig.simulate(_page(mine, page, pageSize));
    }
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.ordersConsumer(consumerId),
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) return const [];
      final list = response.data ?? const [];
      return list
          .whereType<Map>()
          .map((e) => _orderFromApiMap(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      if (_isOrdersRouteMissing(e)) return const [];
      throw ServerException(e.message ?? 'Failed to fetch consumer orders');
    }
  }

  @override
  Future<List<OrderModel>> getVendorOrders({
    required String vendorId,
    required int page,
    required int pageSize,
  }) async {
    if (MockConfig.useMock) {
      final mine = _vendorOrders.where((e) => e.vendorId == vendorId).toList();
      return MockConfig.simulate(_page(mine, page, pageSize));
    }
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.ordersVendor(vendorId),
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) return const [];
      final list = response.data ?? const [];
      return list
          .whereType<Map>()
          .map((e) => _orderFromApiMap(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      if (_isOrdersRouteMissing(e)) return const [];
      throw ServerException(e.message ?? 'Failed to fetch vendor orders');
    }
  }

  @override
  Future<List<OrderModel>> getCourierOrders({
    required String courierId,
    required int page,
    required int pageSize,
  }) async {
    if (MockConfig.useMock) {
      final mine = [..._consumerOrders, ..._vendorOrders]
          .where((e) => e.courierId == courierId)
          .toList();
      return MockConfig.simulate(_page(mine, page, pageSize));
    }
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.ordersCourier(courierId),
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) return const [];
      final list = response.data ?? const [];
      return list
          .whereType<Map>()
          .map((e) => _orderFromApiMap(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      if (_isOrdersRouteMissing(e)) return const [];
      throw ServerException(e.message ?? 'Failed to fetch courier orders');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    if (MockConfig.useMock) {
      for (final o in _consumerOrders) {
        if (o.id == orderId) return MockConfig.simulate(o);
      }
      for (final o in _vendorOrders) {
        if (o.id == orderId) return MockConfig.simulate(o);
      }
      return MockConfig.simulate(null);
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.orderById(orderId),
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) return null;
      final data = response.data;
      if (data == null) return null;
      return _orderFromApiMap(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ServerException(e.message ?? 'Failed to fetch order');
    }
  }

  @override
  Future<OrderStatsEntity> getVendorOrderStats({
    required String vendorId,
  }) async {
    if (MockConfig.useMock) {
      final mine = _vendorOrders.where((e) => e.vendorId == vendorId).toList();
      final pending =
          mine.where((e) => e.status == OrderStatus.pending).length;
      final active = mine
          .where((e) =>
              e.status == OrderStatus.confirmed ||
              e.status == OrderStatus.processing ||
              e.status == OrderStatus.shipped)
          .length;
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month);
      final monthCount =
          mine.where((e) => !e.createdAt.isBefore(monthStart)).length;
      final revenue = mine
          .where((e) => e.status == OrderStatus.delivered)
          .fold<double>(0, (a, b) => a + b.total);
      return MockConfig.simulate(
        OrderStatsEntity(
          pendingCount: pending,
          activeCount: active,
          monthCount: monthCount,
          totalCount: mine.length,
          totalRevenue: revenue,
        ),
      );
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.ordersVendorStats(vendorId),
        options: _legacyOptions,
      );
      if (LegacyRouteOptions.isNotFound(response)) return _emptyVendorStats;
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty vendor order stats');
      }
      return OrderStatsEntity(
        pendingCount: (data['pendingCount'] as num?)?.toInt() ?? 0,
        activeCount: (data['activeCount'] as num?)?.toInt() ?? 0,
        monthCount: (data['monthCount'] as num?)?.toInt() ?? 0,
        totalCount: (data['totalCount'] as num?)?.toInt() ?? 0,
        totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0,
      );
    } on DioException catch (e) {
      if (_isOrdersRouteMissing(e)) return _emptyVendorStats;
      throw ServerException(e.message ?? 'Failed to fetch vendor order stats');
    }
  }

  void _replace(OrderModel next) {
    final ci = _consumerOrders.indexWhere((e) => e.id == next.id);
    if (ci >= 0) {
      _consumerCache = [..._consumerOrders]..[ci] = next;
      return;
    }
    final vi = _vendorOrders.indexWhere((e) => e.id == next.id);
    if (vi >= 0) {
      _vendorCache = [..._vendorOrders]..[vi] = next;
    }
  }

  @override
  Future<OrderModel> cancelOrder({
    required String orderId,
    required String reason,
    required bool isVendorSession,
  }) async {
    if (MockConfig.useMock) {
      final row = await getOrderById(orderId);
      if (row == null) throw StateError('order');
      final now = DateTime.now();
      final next = row.copyWith(
        status: OrderStatus.cancelled,
        cancelReason: reason,
        cancelledAt: now,
        updatedAt: now,
      );
      _replace(next);
      return MockConfig.simulate(next);
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderCancel(orderId),
        data: {'reason': reason, 'isVendorSession': isVendorSession},
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty order response');
      return _orderFromApiMap(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to cancel order');
    }
  }

  @override
  Future<OrderModel> confirmOrder(String orderId) async {
    if (MockConfig.useMock) {
      final row = await getOrderById(orderId);
      if (row == null) throw StateError('order');
      final now = DateTime.now();
      final next = row.copyWith(
        status: OrderStatus.confirmed,
        confirmedAt: now,
        updatedAt: now,
      );
      _replace(next);
      return MockConfig.simulate(next);
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderConfirm(orderId),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty order response');
      return _orderFromApiMap(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to confirm order');
    }
  }

  @override
  Future<OrderModel> rejectOrder({
    required String orderId,
    required String reason,
  }) async {
    if (MockConfig.useMock) {
      final row = await getOrderById(orderId);
      if (row == null) throw StateError('order');
      final now = DateTime.now();
      final next = row.copyWith(
        status: OrderStatus.cancelled,
        cancelReason: reason,
        cancelledAt: now,
        updatedAt: now,
      );
      _replace(next);
      return MockConfig.simulate(next);
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderReject(orderId),
        data: {'reason': reason},
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty order response');
      return _orderFromApiMap(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to reject order');
    }
  }

  @override
  Future<OrderModel> markProcessing(String orderId) async {
    if (MockConfig.useMock) {
      final row = await getOrderById(orderId);
      if (row == null) throw StateError('order');
      final now = DateTime.now();
      final next = row.copyWith(
        status: OrderStatus.processing,
        updatedAt: now,
      );
      _replace(next);
      return MockConfig.simulate(next);
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderProcessing(orderId),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty order response');
      return _orderFromApiMap(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to mark order processing');
    }
  }

  @override
  Future<OrderModel> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
  }) async {
    if (MockConfig.useMock) {
      final row = await getOrderById(orderId);
      if (row == null) throw StateError('order');
      final now = DateTime.now();
      final tn = shippingInfo.trackingNumber?.trim().isNotEmpty == true
          ? shippingInfo.trackingNumber
          : 'XS-TRACK-$orderId';
      final next = row.copyWith(
        status: OrderStatus.shipped,
        trackingNumber: tn,
        courierName: shippingInfo.courierName ?? row.courierName,
        estimatedDelivery: shippingInfo.estimatedDelivery ?? row.estimatedDelivery,
        trackingLocation: 'In transit — Algiers hub',
        shippedAt: now,
        updatedAt: now,
      );
      _replace(next);
      return MockConfig.simulate(next);
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderShipped(orderId),
        data: {
          'trackingNumber': shippingInfo.trackingNumber,
          'courierName': shippingInfo.courierName,
          'estimatedDelivery': shippingInfo.estimatedDelivery?.toIso8601String(),
        },
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty order response');
      return _orderFromApiMap(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to mark order shipped');
    }
  }

  @override
  Future<OrderModel> markDelivered(String orderId) async {
    if (MockConfig.useMock) {
      final row = await getOrderById(orderId);
      if (row == null) throw StateError('order');
      final now = DateTime.now();
      final next = row.copyWith(
        status: OrderStatus.delivered,
        deliveredAt: now,
        updatedAt: now,
      );
      _replace(next);
      return MockConfig.simulate(next);
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderDelivered(orderId),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty order response');
      return _orderFromApiMap(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to mark order delivered');
    }
  }

  @override
  Future<void> registerPlacedConsumerOrder(OrderModel order) async {
    if (MockConfig.useMock) {
      _consumerCache ??= _seedConsumerOrders();
      _consumerCache = [order, ..._consumerOrders];
      return;
    }
    try {
      await _dio.post<void>(
        ApiEndpoints.ordersConsumer(order.consumerId),
        data: _orderToApiMap(order),
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to register placed order');
    }
  }

  OrderModel _orderFromApiMap(Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final address =
        Map<String, dynamic>.from((data['deliveryAddress'] as Map?) ?? const {});
    final statusRaw = (data['status'] ?? '').toString().toLowerCase();
    final paymentRaw = (data['paymentMethod'] ?? '').toString().toLowerCase();
    return OrderModel(
      id: (data['id'] ?? '').toString(),
      consumerId: (data['consumerId'] ?? '').toString(),
      consumerName: (data['consumerName'] ?? '').toString(),
      consumerPhone: (data['consumerPhone'] ?? '').toString(),
      consumerAvatar: (data['consumerAvatar'] ?? '').toString(),
      vendorId: (data['vendorId'] ?? '').toString(),
      vendorName: (data['vendorName'] ?? '').toString(),
      vendorStoreName: (data['vendorStoreName'] ?? '').toString(),
      vendorAvatar: (data['vendorAvatar'] ?? '').toString(),
      vendorRating: (data['vendorRating'] as num?)?.toDouble() ?? 4.8,
      items: items
          .map(
            (e) => OrderItemModel(
              id: (e['id'] ?? '').toString(),
              listingId: (e['listingId'] ?? '').toString(),
              listingName: (e['listingName'] ?? '').toString(),
              listingImage: (e['listingImage'] ?? '').toString(),
              category: (e['category'] ?? '').toString(),
              condition: (e['condition'] ?? '').toString(),
              price: (e['price'] as num?)?.toDouble() ?? 0,
              quantity: (e['quantity'] as num?)?.toInt() ?? 1,
              total: (e['total'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList(),
      status: switch (statusRaw) {
        'confirmed' => OrderStatus.confirmed,
        'processing' => OrderStatus.processing,
        'shipped' => OrderStatus.shipped,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        'refunded' => OrderStatus.refunded,
        _ => OrderStatus.pending,
      },
      paymentMethod: switch (paymentRaw) {
        'cibcard' => PaymentMethod.cibCard,
        'dahabicard' => PaymentMethod.dahabiCard,
        'baridimob' => PaymentMethod.baridimob,
        _ => PaymentMethod.cashOnDelivery,
      },
      isPaid: data['isPaid'] == true,
      deliveryAddress: OrderAddressModel(
        fullName: (address['fullName'] ?? '').toString(),
        phone: (address['phone'] ?? '').toString(),
        street: (address['street'] ?? '').toString(),
        city: (address['city'] ?? '').toString(),
        wilaya: (address['wilaya'] ?? '').toString(),
        postalCode: address['postalCode'] as String?,
        isDefault: address['isDefault'] == true,
      ),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      trackingNumber: data['trackingNumber'] as String?,
      courierId: data['courierId']?.toString(),
      courierName: data['courierName'] as String?,
      trackingLocation: data['trackingLocation'] as String?,
      estimatedDelivery: DateTime.tryParse(
        (data['estimatedDelivery'] ?? '').toString(),
      ),
      cancelReason: data['cancelReason'] as String?,
      notes: data['notes'] as String?,
      createdAt:
          DateTime.tryParse((data['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse((data['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      confirmedAt:
          DateTime.tryParse((data['confirmedAt'] ?? '').toString()),
      shippedAt: DateTime.tryParse((data['shippedAt'] ?? '').toString()),
      deliveredAt: DateTime.tryParse((data['deliveredAt'] ?? '').toString()),
      cancelledAt: DateTime.tryParse((data['cancelledAt'] ?? '').toString()),
    );
  }

  Map<String, dynamic> _orderToApiMap(OrderModel order) => {
        'id': order.id,
        'consumerId': order.consumerId,
        'consumerName': order.consumerName,
        'consumerPhone': order.consumerPhone,
        'consumerAvatar': order.consumerAvatar,
        'vendorId': order.vendorId,
        'vendorName': order.vendorName,
        'vendorStoreName': order.vendorStoreName,
        'vendorAvatar': order.vendorAvatar,
        'vendorRating': order.vendorRating,
        'items': order.items
            .map(
              (e) => {
                'id': e.id,
                'listingId': e.listingId,
                'listingName': e.listingName,
                'listingImage': e.listingImage,
                'category': e.category,
                'condition': e.condition,
                'price': e.price,
                'quantity': e.quantity,
                'total': e.total,
              },
            )
            .toList(),
        'status': order.status.name,
        'paymentMethod': order.paymentMethod.name,
        'isPaid': order.isPaid,
        'deliveryAddress': {
          'fullName': order.deliveryAddress.fullName,
          'phone': order.deliveryAddress.phone,
          'street': order.deliveryAddress.street,
          'city': order.deliveryAddress.city,
          'wilaya': order.deliveryAddress.wilaya,
          'postalCode': order.deliveryAddress.postalCode,
          'isDefault': order.deliveryAddress.isDefault,
        },
        'subtotal': order.subtotal,
        'shippingCost': order.shippingCost,
        'discount': order.discount,
        'total': order.total,
        'trackingNumber': order.trackingNumber,
        'courierId': order.courierId,
        'courierName': order.courierName,
        'trackingLocation': order.trackingLocation,
        'estimatedDelivery': order.estimatedDelivery?.toIso8601String(),
        'cancelReason': order.cancelReason,
        'notes': order.notes,
        'createdAt': order.createdAt.toIso8601String(),
        'updatedAt': order.updatedAt.toIso8601String(),
        'confirmedAt': order.confirmedAt?.toIso8601String(),
        'shippedAt': order.shippedAt?.toIso8601String(),
        'deliveredAt': order.deliveredAt?.toIso8601String(),
        'cancelledAt': order.cancelledAt?.toIso8601String(),
      };
}
