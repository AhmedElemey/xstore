import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
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

  /// Orders assigned to a platform courier ("Delivered by xStore"). No
  /// confirmed route exists for this on the xStoreEcommerce backend — see
  /// [ApiEndpoints.ordersCourier].
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

  Future<OrderModel> confirmOrder({
    required String orderId,
    required DeliveryMethod method,
  });

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

  /// Updates the delivery coordinates on an already-placed order. CONFIRMED
  /// (Postman collection) route + request body — response shape was never
  /// live-probed (no order survived long enough to reach this call), so
  /// treated as a bodyless-success signal rather than parsed.
  Future<void> updateDeliveryCoordinates({
    required String orderId,
    required double latitude,
    required double longitude,
  });

  /// Mock-mode-only: inserts a consumer order after checkout. Live mode has
  /// no equivalent call — [createOrder] already persists the order
  /// server-side, so this is a no-op there (see doc on the impl).
  Future<void> registerPlacedConsumerOrder(OrderModel order);

  /// Places a real single-listing order. CONFIRMED (Postman + live probe,
  /// 2026-08-14): `POST /api/orders` takes exactly `{listingId, quantity,
  /// latitude, longitude}` — there is no multi-item/cart endpoint. The
  /// fallback* fields are NOT sent on the wire; they're used to build a
  /// complete [OrderModel] for the UI from whatever the (unconfirmed-shape)
  /// response does or doesn't echo back.
  Future<OrderModel> createOrder({
    required String listingId,
    required int quantity,
    required double latitude,
    required double longitude,
    required OrderItemModel fallbackItem,
    required OrderAddressModel fallbackAddress,
    required PaymentMethod fallbackPayment,
    String? notes,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

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
      // CONFIRMED (live probe): bare array, 200 (empty on a fresh account).
      // page/pageSize aren't in the collection's example — sent
      // defensively, with a client-side slice as a safety net either way.
      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.ordersMe,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final list = response.data ?? const [];
      final all = list
          .whereType<Map>()
          .map((e) => _orderFromApiMap(Map<String, dynamic>.from(e)))
          .toList();
      return _page(all, page, pageSize);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// GET /vendor/orders envelope: `{orders, totalCount, pendingCount,
  /// confirmedCount, totalRevenue, warnThresholdEgp, pauseThresholdEgp,
  /// exceedsWarnThreshold, exceedsPauseThreshold, commissionValueOnOrder}`
  /// — CONFIRMED via live probe (2026-08-14). Shared by [getVendorOrders]
  /// and [getVendorOrderStats] so the stats-carrying fields aren't fetched
  /// twice.
  Future<Map<String, dynamic>> _fetchVendorOrdersEnvelope({
    String? status,
    int page = 1,
    int pageSize = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.vendorOrders,
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return response.data ?? const {};
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
      final envelope = await _fetchVendorOrdersEnvelope(
        page: page,
        pageSize: pageSize,
      );
      final list = envelope['orders'] as List<dynamic>? ?? const [];
      return list
          .whereType<Map>()
          .map((e) => _orderFromApiMap(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
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
    // No confirmed backend route — see ApiEndpoints.ordersCourier doc.
    // Treated as "no data" (404-tolerant) rather than a hard error so the
    // courier tab shows an empty state instead of error spam.
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
      if (e.response?.statusCode == 404) return const [];
      throw mapDioException(e);
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
      // CONFIRMED route: GET /orders/me/{id} (consumer-scoped). Vendor
      // order detail has no dedicated by-id route in the collection — it
      // reads from the list fetched via getVendorOrders instead (see
      // OrdersRepositoryImpl.getOrderDetail, which falls back to that path
      // for vendor sessions rather than calling this method).
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.orderMeById(orderId),
      );
      final data = response.data;
      if (data == null) return null;
      return _orderFromApiMap(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw mapDioException(e);
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
      // Small pageSize: the stats fields are present regardless of how
      // many order rows come back, so there's no need to fetch the full
      // list just to read them.
      final envelope = await _fetchVendorOrdersEnvelope(pageSize: 1);
      return OrderStatsEntity(
        pendingCount: (envelope['pendingCount'] as num?)?.toInt() ?? 0,
        // UNCONFIRMED: no separate "processing"/"shipped" counts in the
        // probed response — confirmedCount is the closest available proxy
        // for "active". Revisit once the backend confirms a fuller
        // breakdown.
        activeCount: (envelope['confirmedCount'] as num?)?.toInt() ?? 0,
        // UNCONFIRMED: no month-scoped count in the probed response.
        monthCount: 0,
        totalCount: (envelope['totalCount'] as num?)?.toInt() ?? 0,
        totalRevenue: (envelope['totalRevenue'] as num?)?.toDouble() ?? 0,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return _emptyVendorStats;
      throw mapDioException(e);
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
    if (isVendorSession) {
      // Vendor-side cancel goes through the same bulk status endpoint as
      // confirm/reject — there's no vendor-specific cancel route.
      return _setVendorOrderStatus(
        orderId: orderId,
        status: 'cancelled',
        localReason: reason,
      );
    }
    try {
      // CONFIRMED route: POST /orders/{id}/cancel. No documented request
      // body — the reason is applied locally for display only.
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderCancel(orderId),
      );
      final data = response.data;
      final parsed = data != null
          ? _orderFromApiMap(data)
          : (await getOrderById(orderId));
      if (parsed == null) throw const ServerException('Empty order response');
      return parsed.copyWith(
        status: OrderStatus.cancelled,
        cancelReason: parsed.cancelReason ?? reason,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> updateDeliveryCoordinates({
    required String orderId,
    required double latitude,
    required double longitude,
  }) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate<void>(null);
      return;
    }
    try {
      await _dio.put<void>(
        ApiEndpoints.orderCoordinates(orderId),
        data: {'latitude': latitude, 'longitude': longitude},
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Every vendor status transition (confirm/reject/processing/shipped/
  /// delivered/cancel) goes through this one bulk endpoint. UNCONFIRMED
  /// beyond `"confirmed"` (the only value shown in the collection's
  /// example body) — the other values below are the app's existing enum
  /// names lowercased, matching that one confirmed convention. Verify
  /// the full enum with the backend before this ships to production.
  Future<OrderModel> _setVendorOrderStatus({
    required String orderId,
    required String status,
    String? localReason,
    DeliveryMethod? localDeliveryMethod,
    ShippingInfo? localShippingInfo,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.vendorOrdersStatus,
        data: {
          'orderIds': [int.tryParse(orderId) ?? orderId],
          'status': status,
        },
      );
      final data = response.data;
      final parsedFromResponse =
          (data != null && data['orders'] == null && data['id'] != null)
              ? _orderFromApiMap(data)
              : null;
      final base = parsedFromResponse ?? await getOrderById(orderId);
      if (base == null) throw const ServerException('Empty order response');
      return base.copyWith(
        status: _statusFromWire(status) ?? base.status,
        cancelReason: localReason ?? base.cancelReason,
        deliveryMethod: localDeliveryMethod ?? base.deliveryMethod,
        trackingNumber:
            localShippingInfo?.trackingNumber ?? base.trackingNumber,
        courierName: localShippingInfo?.courierName ?? base.courierName,
        estimatedDelivery:
            localShippingInfo?.estimatedDelivery ?? base.estimatedDelivery,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<OrderModel> confirmOrder({
    required String orderId,
    required DeliveryMethod method,
  }) async {
    if (MockConfig.useMock) {
      final row = await getOrderById(orderId);
      if (row == null) throw StateError('order');
      final now = DateTime.now();
      final next = row.copyWith(
        status: OrderStatus.confirmed,
        deliveryMethod: method,
        confirmedAt: now,
        updatedAt: now,
      );
      _replace(next);
      return MockConfig.simulate(next);
    }
    // UNCONFIRMED: no wire field carries self-vs-platform delivery choice
    // on this endpoint — applied locally for display only. See the
    // "required for production" audit: this needs a backend field.
    return _setVendorOrderStatus(
      orderId: orderId,
      status: 'confirmed',
      localDeliveryMethod: method,
    );
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
    // UNCONFIRMED: no status value for "rejected" is documented — the
    // collection only shows "confirmed". Using "cancelled" (a value we
    // know the app itself sends) until the backend confirms a dedicated
    // rejected status; the reason is applied locally regardless, since no
    // rejection-reason field is documented on this endpoint either.
    return _setVendorOrderStatus(
      orderId: orderId,
      status: 'cancelled',
      localReason: reason,
    );
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
    return _setVendorOrderStatus(orderId: orderId, status: 'processing');
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
    // UNCONFIRMED: no wire fields for tracking number/courier/ETA on this
    // endpoint — applied locally for display only, same caveat as
    // confirmOrder's delivery method.
    return _setVendorOrderStatus(
      orderId: orderId,
      status: 'shipped',
      localShippingInfo: shippingInfo,
    );
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
    return _setVendorOrderStatus(orderId: orderId, status: 'delivered');
  }

  @override
  Future<void> registerPlacedConsumerOrder(OrderModel order) async {
    if (MockConfig.useMock) {
      _consumerCache ??= _seedConsumerOrders();
      _consumerCache = [order, ..._consumerOrders];
      return;
    }
    // No-op in live mode: CartRemoteDataSourceImpl.placeOrder already
    // persists the order via createOrder (POST /api/orders) — calling this
    // too would create a duplicate order. Kept only so the shared
    // CartRepositoryImpl.placeOrder call site doesn't need a mock/live
    // branch of its own.
  }

  @override
  Future<OrderModel> createOrder({
    required String listingId,
    required int quantity,
    required double latitude,
    required double longitude,
    required OrderItemModel fallbackItem,
    required OrderAddressModel fallbackAddress,
    required PaymentMethod fallbackPayment,
    String? notes,
  }) async {
    try {
      // CONFIRMED (Postman): flat body, listingId as the backend's numeric
      // id. Response shape is UNCONFIRMED (no example in the collection,
      // and the probe couldn't reach a real order — the test vendor
      // account needed admin approval before it could list a product) —
      // parsed tolerantly with the fallback* args covering anything the
      // response doesn't echo back.
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orders,
        data: {
          'listingId': int.tryParse(listingId) ?? listingId,
          'quantity': quantity,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty order response');
      return _orderFromApiMap(
        data,
        fallbackItems: [fallbackItem],
        fallbackAddress: fallbackAddress,
        fallbackPayment: fallbackPayment,
        fallbackNotes: notes,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  static const _statusWireValues = {
    'pending': OrderStatus.pending,
    'confirmed': OrderStatus.confirmed,
    'processing': OrderStatus.processing,
    'shipped': OrderStatus.shipped,
    'delivered': OrderStatus.delivered,
    'cancelled': OrderStatus.cancelled,
    'rejected': OrderStatus.cancelled,
    'refunded': OrderStatus.refunded,
  };

  OrderStatus? _statusFromWire(String raw) =>
      _statusWireValues[raw.toLowerCase()];

  /// Parses a single order object from the API. UNCONFIRMED field shape
  /// (see the doc on [ApiEndpoints.orders]) — tolerant of both a
  /// multi-item `items` array (in case a future contract adds one) and the
  /// CONFIRMED single-listing create shape (`listingId`/`quantity` at the
  /// top level), and falls back to locally-known context (the item/address/
  /// payment method the caller already has) for anything the response
  /// doesn't carry, rather than guessing wrong.
  OrderModel _orderFromApiMap(
    Map<String, dynamic> data, {
    List<OrderItemModel>? fallbackItems,
    OrderAddressModel? fallbackAddress,
    PaymentMethod? fallbackPayment,
    String? fallbackNotes,
  }) {
    final rawItems = data['items'] as List<dynamic>?;
    final items = rawItems != null
        ? rawItems
            .whereType<Map>()
            .map((e) => _itemFromApiMap(Map<String, dynamic>.from(e)))
            .toList()
        : _itemFromFlatOrder(data, fallbackItems);

    final statusRaw = (data['status'] ?? '').toString();
    final status = _statusFromWire(statusRaw) ?? OrderStatus.pending;

    final computedTotal = items.fold<double>(0, (a, b) => a + b.total);

    return OrderModel(
      id: (data['id'] ?? data['orderId'] ?? '').toString(),
      consumerId: (data['consumerId'] ?? data['userId'] ?? '').toString(),
      consumerName: (data['consumerName'] ?? '').toString(),
      consumerPhone: (data['consumerPhone'] ?? '').toString(),
      consumerAvatar: (data['consumerAvatar'] ?? '').toString(),
      vendorId: (data['vendorId'] ?? data['storeId'] ?? '').toString(),
      vendorName: (data['vendorName'] ?? '').toString(),
      vendorStoreName: (data['vendorStoreName'] ?? data['storeName'] ?? '').toString(),
      vendorAvatar: (data['vendorAvatar'] ?? '').toString(),
      vendorRating: (data['vendorRating'] as num?)?.toDouble() ?? 4.8,
      items: items,
      status: status,
      paymentMethod: fallbackPayment ?? PaymentMethod.cashOnDelivery,
      isPaid: data['isPaid'] == true,
      deliveryAddress: fallbackAddress ??
          OrderAddressModel(
            fullName: (data['consumerName'] ?? '').toString(),
            phone: (data['consumerPhone'] ?? '').toString(),
            street: '',
            city: '',
            wilaya: '',
          ),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? computedTotal,
      shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? computedTotal,
      trackingNumber: data['trackingNumber'] as String?,
      deliveryMethod: switch ((data['deliveryMethod'] ?? '').toString().toLowerCase()) {
        'self' => DeliveryMethod.self,
        'platform' => DeliveryMethod.platform,
        _ => null,
      },
      courierId: data['courierId']?.toString(),
      courierName: data['courierName'] as String?,
      trackingLocation: data['trackingLocation'] as String?,
      estimatedDelivery: DateTime.tryParse(
        (data['estimatedDelivery'] ?? '').toString(),
      ),
      cancelReason: data['cancelReason'] as String?,
      notes: (data['notes'] as String?) ?? fallbackNotes,
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

  OrderItemModel _itemFromApiMap(Map<String, dynamic> e) => OrderItemModel(
        id: (e['id'] ?? '').toString(),
        listingId: (e['listingId'] ?? '').toString(),
        listingName: (e['listingName'] ?? e['title'] ?? '').toString(),
        listingImage: (e['listingImage'] ?? e['imageUrl'] ?? '').toString(),
        category: (e['category'] ?? '').toString(),
        condition: (e['condition'] ?? '').toString(),
        price: (e['price'] as num?)?.toDouble() ?? 0,
        quantity: (e['quantity'] as num?)?.toInt() ?? 1,
        total: (e['total'] as num?)?.toDouble() ??
            (((e['price'] as num?)?.toDouble() ?? 0) *
                ((e['quantity'] as num?)?.toInt() ?? 1)),
      );

  /// Builds a single synthetic line item from a flat (non-`items`) order
  /// object — the CONFIRMED single-listing create shape only has
  /// `listingId`/`quantity` at the top level, not a nested list.
  List<OrderItemModel> _itemFromFlatOrder(
    Map<String, dynamic> data,
    List<OrderItemModel>? fallbackItems,
  ) {
    final listingId = data['listingId'];
    if (listingId == null) {
      return fallbackItems ?? const [];
    }
    final fallback = fallbackItems?.isNotEmpty == true ? fallbackItems!.first : null;
    final quantity = (data['quantity'] as num?)?.toInt() ?? fallback?.quantity ?? 1;
    final price = (data['price'] as num?)?.toDouble() ?? fallback?.price ?? 0;
    return [
      OrderItemModel(
        id: fallback?.id ?? 'line_${data['id'] ?? listingId}',
        listingId: listingId.toString(),
        listingName: (data['listingName'] ?? fallback?.listingName ?? '').toString(),
        listingImage: (data['listingImage'] ?? fallback?.listingImage ?? '').toString(),
        category: fallback?.category ?? '',
        condition: fallback?.condition ?? '',
        price: price,
        quantity: quantity,
        total: (data['total'] as num?)?.toDouble() ?? price * quantity,
      ),
    ];
  }
}
