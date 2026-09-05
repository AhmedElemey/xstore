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
import '../../../listing/data/models/listing_model.dart';
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
    String? vendorId,
  });

  Future<OrderModel> rejectOrder({
    required String orderId,
    required String reason,
    String? vendorId,
  });

  Future<OrderModel> markProcessing(String orderId, {String? vendorId});

  Future<OrderModel> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
    String? vendorId,
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

  /// Public listing JSON keyed by id — fills item/store fields the order
  /// DTO doesn't snapshot. Capped so a long session cannot grow forever.
  final Map<String, Map<String, dynamic>> _listingSnapCache = {};
  static const _listingSnapCacheCap = 40;

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
        city: rest.isNotEmpty ? rest : mockConsumerUser.location ?? 'Cairo',
        wilaya: rest.isNotEmpty ? rest : 'Cairo',
      ),
      subtotal: sub,
      shippingCost: ship,
      discount: 0,
      total: m.totalPrice,
      trackingNumber: m.trackingNumber,
      courierName: m.trackingNumber != null ? 'xStore Logistics' : null,
      trackingLocation: m.status == MockOrderStatus.shipped
          ? 'In transit — Cairo hub'
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
        city: city ?? 'Cairo',
        wilaya: wilaya ?? city ?? 'Cairo',
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
          ? 'In transit — Cairo hub'
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
        city: 'Cairo',
        wilaya: 'Cairo',
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
        city: 'Cairo',
        wilaya: 'Cairo',
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
        city: 'Alexandria',
        wilaya: 'Alexandria',
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
        city: 'Mansoura',
        wilaya: 'Mansoura',
        courierId: mockCourierUser.id,
        courierName: mockCourierUser.name,
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V005',
        consumerName: 'Amira Hassan',
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
        city: 'Tanta',
        wilaya: 'Tanta',
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
        city: 'Cairo',
        wilaya: 'Cairo',
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
        city: 'Cairo',
        wilaya: 'Cairo',
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
        city: 'Aswan',
        wilaya: 'Aswan',
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
      return _hydrateOrders(_page(all, page, pageSize));
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
    return _asVendorOrdersEnvelope(response.data);
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
      final list = _envelopeList(envelope, 'orders');
      final rows = list
          .whereType<Map>()
          .map((e) => _orderFromApiMap(Map<String, dynamic>.from(e)))
          .toList();
      return _hydrateOrders(rows);
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
      // CONFIRMED route: GET /orders/me/{id} (consumer-scoped). The
      // payload shape was never live-probed — unwrap `{data|Data}` and
      // tolerate 404 so the repository can fall back to GET /orders/me.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.orderMeById(orderId),
      );
      final map = _asOrderMap(response.data);
      if (map == null) return null;
      final parsed = _orderFromApiMap(map);
      final hydrated = await _hydrateOrders([parsed]);
      return hydrated.first;
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
        pendingCount: _envelopeInt(envelope, 'pendingCount') ?? 0,
        // UNCONFIRMED: no separate "processing"/"shipped" counts in the
        // probed response — confirmedCount is the closest available proxy
        // for "active". Revisit once the backend confirms a fuller
        // breakdown.
        activeCount: _envelopeInt(envelope, 'confirmedCount') ?? 0,
        // UNCONFIRMED: no month-scoped count in the probed response.
        monthCount: 0,
        totalCount: _envelopeInt(envelope, 'totalCount') ?? 0,
        totalRevenue: _envelopeDouble(envelope, 'totalRevenue') ?? 0,
        // CONFIRMED against backend source (GetVendorOrdersQueryHandler,
        // 2026-08-15): commissionValueOnOrder/warnThresholdEgp/
        // pauseThresholdEgp come from the admin-configured SystemSetting
        // row; exceedsWarnThreshold/exceedsPauseThreshold come from the
        // vendor's own VendorCommissionWallet row (its raw OutstandingEgp
        // is admin-only, never sent to the vendor app — these booleans are
        // the only wallet signal a vendor session can read).
        commissionValueOnOrder:
            _envelopeDouble(envelope, 'commissionValueOnOrder'),
        warnThresholdEgp: _envelopeDouble(envelope, 'warnThresholdEgp'),
        pauseThresholdEgp: _envelopeDouble(envelope, 'pauseThresholdEgp'),
        exceedsWarnThreshold:
            _envelopeBool(envelope, 'exceedsWarnThreshold'),
        exceedsPauseThreshold:
            _envelopeBool(envelope, 'exceedsPauseThreshold'),
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
      // body — the reason is applied locally for display only. Response
      // shape was never live-probed either, so unwrap a possible
      // `{data|Data: {...}}` Result envelope the same way getOrderById
      // does on this same resource, and accept a non-Map body (a bare
      // success string, or no body at all) instead of throwing.
      final response = await _dio.post<dynamic>(
        ApiEndpoints.orderCancel(orderId),
      );
      final map = _asOrderMap(response.data);
      final parsed =
          map != null ? _orderFromApiMap(map) : (await getOrderById(orderId));
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
    String? vendorId,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.vendorOrdersStatus,
        data: {
          'orderIds': [int.tryParse(orderId) ?? orderId],
          'status': status,
        },
      );
      // Same Result-envelope risk as cancelOrder: unwrap a possible
      // `{data|Data: {...}}` wrap via _asOrderMap instead of assuming the
      // order fields sit at the response's top level.
      final data = response.data;
      final unwrapped =
          (data != null && data['orders'] == null) ? _asOrderMap(data) : null;
      final parsedFromResponse =
          unwrapped != null ? _orderFromApiMap(unwrapped) : null;
      // Fallback hydration: GET /orders/me/{id} is consumer-scoped, so it's
      // the wrong lookup for a vendor session — search the vendor's own
      // order list instead when we know who the vendor is (mirrors
      // OrdersRepositoryImpl.getOrderDetail's vendor branch). Callers that
      // don't pass vendorId (courier's markShipped/markDelivered, the
      // unreachable vendor branch of cancelOrder) keep the old fallback.
      final base = parsedFromResponse ??
          (vendorId != null
              ? (await getVendorOrders(vendorId: vendorId, page: 1, pageSize: 100))
                  .where((o) => o.id == orderId)
                  .firstOrNull
              : await getOrderById(orderId));
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
    String? vendorId,
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
      vendorId: vendorId,
    );
  }

  @override
  Future<OrderModel> rejectOrder({
    required String orderId,
    required String reason,
    String? vendorId,
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
      vendorId: vendorId,
    );
  }

  @override
  Future<OrderModel> markProcessing(String orderId, {String? vendorId}) async {
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
    return _setVendorOrderStatus(
      orderId: orderId,
      status: 'processing',
      vendorId: vendorId,
    );
  }

  @override
  Future<OrderModel> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
    String? vendorId,
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
        trackingLocation: 'In transit — Cairo hub',
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
      vendorId: vendorId,
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
    final listing = _asMap(_envelopeValue(data, 'listing')) ??
        _asMap(_envelopeValue(data, 'product'));
    final vendorNode = _asMap(_envelopeValue(data, 'vendor')) ??
        _asMap(_envelopeValue(data, 'seller')) ??
        _asMap(_envelopeValue(data, 'store')) ??
        _asMap(_envelopeValue(listing ?? const {}, 'seller')) ??
        _asMap(_envelopeValue(listing ?? const {}, 'vendor'));

    final rawItems = _envelopeValue(data, 'items') ??
        _envelopeValue(data, 'orderItems');
    var items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => _itemFromApiMap(Map<String, dynamic>.from(e)))
            .toList()
        : <OrderItemModel>[];
    if (items.isEmpty) {
      items = _itemFromFlatOrder(data, fallbackItems, listing: listing);
    }

    final statusRaw = _optString(data, 'status') ?? '';
    final status = _statusFromWire(statusRaw) ?? OrderStatus.pending;

    final computedTotal = items.fold<double>(0, (a, b) => a + b.total);

    final vendorRatingRaw = _envelopeDouble(data, 'vendorRating') ??
        _envelopeDouble(vendorNode ?? const {}, 'rating') ??
        _envelopeDouble(data, 'rating');
    final vendorRating =
        (vendorRatingRaw != null && vendorRatingRaw > 0) ? vendorRatingRaw : null;

    final vendorName = _optString(data, 'vendorName') ??
        _optString(data, 'userName') ??
        _optString(listing ?? const {}, 'userName') ??
        _optString(vendorNode ?? const {}, 'name') ??
        _optString(vendorNode ?? const {}, 'displayName') ??
        '';
    final vendorStoreName = _optString(data, 'vendorStoreName') ??
        _optString(data, 'storeName') ??
        _optString(listing ?? const {}, 'storeName') ??
        _optString(vendorNode ?? const {}, 'storeName') ??
        vendorName;
    final vendorId = _optString(data, 'vendorId') ??
        _optString(data, 'storeId') ??
        _optString(listing ?? const {}, 'userId') ??
        _optString(listing ?? const {}, 'vendorId') ??
        _optString(vendorNode ?? const {}, 'id') ??
        '';
    final vendorAvatar = _optString(data, 'vendorAvatar') ??
        _optString(data, 'userAvatar') ??
        _optString(listing ?? const {}, 'userAvatar') ??
        _optString(vendorNode ?? const {}, 'avatarUrl') ??
        _optString(vendorNode ?? const {}, 'storeImageUrl') ??
        '';

    return OrderModel(
      id: _optString(data, 'id') ?? _optString(data, 'orderId') ?? '',
      consumerId: _optString(data, 'consumerId') ??
          _optString(data, 'buyerId') ??
          '',
      consumerName: _optString(data, 'consumerName') ?? '',
      consumerPhone: _optString(data, 'consumerPhone') ??
          _optString(data, 'phoneNumber') ??
          '',
      consumerAvatar: _optString(data, 'consumerAvatar') ?? '',
      vendorId: vendorId,
      vendorName: vendorName,
      vendorStoreName: vendorStoreName,
      vendorAvatar: vendorAvatar,
      vendorRating: vendorRating,
      items: items,
      status: status,
      paymentMethod: fallbackPayment ?? PaymentMethod.cashOnDelivery,
      isPaid: _envelopeBool(data, 'isPaid'),
      deliveryAddress: _addressFromApi(data, fallbackAddress),
      subtotal: _envelopeDouble(data, 'subtotal') ?? computedTotal,
      shippingCost: _envelopeDouble(data, 'shippingCost') ?? 0,
      discount: _envelopeDouble(data, 'discount') ?? 0,
      total: _envelopeDouble(data, 'total') ?? computedTotal,
      trackingNumber: _optString(data, 'trackingNumber'),
      deliveryMethod:
          switch ((_optString(data, 'deliveryMethod') ?? '').toLowerCase()) {
        'self' => DeliveryMethod.self,
        'platform' => DeliveryMethod.platform,
        _ => null,
      },
      courierId: _optString(data, 'courierId'),
      courierName: _optString(data, 'courierName'),
      trackingLocation: _optString(data, 'trackingLocation'),
      estimatedDelivery: DateTime.tryParse(
        _optString(data, 'estimatedDelivery') ?? '',
      ),
      cancelReason: _optString(data, 'cancelReason'),
      notes: _optString(data, 'notes') ?? fallbackNotes,
      createdAt:
          DateTime.tryParse(_optString(data, 'createdAt') ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(_optString(data, 'updatedAt') ?? '') ?? DateTime.now(),
      confirmedAt: DateTime.tryParse(_optString(data, 'confirmedAt') ?? ''),
      shippedAt: DateTime.tryParse(_optString(data, 'shippedAt') ?? ''),
      deliveredAt: DateTime.tryParse(_optString(data, 'deliveredAt') ?? ''),
      cancelledAt: DateTime.tryParse(_optString(data, 'cancelledAt') ?? ''),
    );
  }

  OrderAddressModel _addressFromApi(
    Map<String, dynamic> data,
    OrderAddressModel? fallback,
  ) {
    final nested = _asMap(_envelopeValue(data, 'deliveryAddress')) ??
        _asMap(_envelopeValue(data, 'shippingAddress')) ??
        _asMap(_envelopeValue(data, 'address'));
    final src = nested ?? data;
    final fullName = _optString(src, 'fullName') ??
        _optString(src, 'name') ??
        _optString(data, 'consumerName') ??
        fallback?.fullName ??
        '';
    final phone = _optString(src, 'phone') ??
        _optString(src, 'phoneNumber') ??
        _optString(data, 'consumerPhone') ??
        fallback?.phone ??
        '';
    final street = _optString(src, 'street') ??
        _optString(src, 'detailedAddressByGoogleMaps') ??
        _optString(src, 'detailedAddressByUser') ??
        _optString(src, 'detailAddress') ??
        _optString(src, 'addressLine') ??
        _optString(data, 'detailedAddressByGoogleMaps') ??
        _optString(data, 'detailedAddressByUser') ??
        fallback?.street ??
        '';
    final city = _optString(src, 'city') ??
        _optString(src, 'cityByGoogleMaps') ??
        _optString(src, 'town') ??
        _optString(data, 'cityByGoogleMaps') ??
        fallback?.city ??
        '';
    final wilaya = _optString(src, 'wilaya') ??
        _optString(src, 'government') ??
        _optString(src, 'governorate') ??
        _optString(src, 'governmentByGoogleMaps') ??
        _optString(data, 'governmentByGoogleMaps') ??
        fallback?.wilaya ??
        '';
    return OrderAddressModel(
      fullName: fullName,
      phone: phone,
      street: street,
      city: city,
      wilaya: wilaya,
      postalCode: _optString(src, 'postalCode') ?? fallback?.postalCode,
      isDefault: fallback?.isDefault ?? false,
    );
  }

  OrderItemModel _itemFromApiMap(Map<String, dynamic> e) {
    final nested = _asMap(_envelopeValue(e, 'listing')) ?? e;
    final quantity = _envelopeInt(e, 'quantity') ?? 1;
    final price = _envelopeDouble(e, 'price') ??
        _envelopeDouble(nested, 'price') ??
        0;
    return OrderItemModel(
      id: _optString(e, 'id') ?? '',
      listingId: _optString(e, 'listingId') ??
          _optString(nested, 'id') ??
          '',
      listingName: _listingTitle(nested) ?? _listingTitle(e) ?? '',
      listingImage: _firstImageUrl(nested) ?? _firstImageUrl(e) ?? '',
      category: _listingCategory(nested),
      condition: listingConditionLabelFromRaw(
        _envelopeValue(nested, 'conditionLabel') ??
            _envelopeValue(nested, 'condition'),
      ),
      price: price,
      quantity: quantity,
      total: _envelopeDouble(e, 'total') ?? price * quantity,
    );
  }

  /// Builds a single synthetic line item from a flat (non-`items`) order
  /// object — the CONFIRMED single-listing create shape only has
  /// `listingId`/`quantity` at the top level, not a nested list.
  List<OrderItemModel> _itemFromFlatOrder(
    Map<String, dynamic> data,
    List<OrderItemModel>? fallbackItems, {
    Map<String, dynamic>? listing,
  }) {
    final listingId = _envelopeValue(listing ?? const {}, 'id') ??
        _envelopeValue(data, 'listingId');
    if (listingId == null) {
      return fallbackItems ?? const [];
    }
    final fallback =
        fallbackItems?.isNotEmpty == true ? fallbackItems!.first : null;
    final src = listing ?? data;
    final quantity = _envelopeInt(data, 'quantity') ?? fallback?.quantity ?? 1;
    final price = _envelopeDouble(src, 'price') ??
        _envelopeDouble(data, 'price') ??
        fallback?.price ??
        0;
    final condition = listingConditionLabelFromRaw(
      _envelopeValue(src, 'conditionLabel') ?? _envelopeValue(src, 'condition'),
    );
    return [
      OrderItemModel(
        id: fallback?.id ?? 'line_${_optString(data, 'id') ?? listingId}',
        listingId: listingId.toString(),
        listingName: _listingTitle(src) ?? fallback?.listingName ?? '',
        listingImage: _firstImageUrl(src) ?? fallback?.listingImage ?? '',
        category: _listingCategory(src).isNotEmpty
            ? _listingCategory(src)
            : fallback?.category ?? '',
        condition: condition.isNotEmpty ? condition : fallback?.condition ?? '',
        price: price,
        quantity: quantity,
        total: _envelopeDouble(data, 'total') ?? price * quantity,
      ),
    ];
  }

  String? _listingTitle(Map<String, dynamic> m) =>
      _optString(m, 'titleEn') ??
      _optString(m, 'title') ??
      _optString(m, 'titleAr') ??
      _optString(m, 'name') ??
      _optString(m, 'listingName');

  String _listingCategory(Map<String, dynamic> m) {
    final raw = _envelopeValue(m, 'categoryLabel') ??
        _envelopeValue(m, 'categoryNameEn') ??
        _envelopeValue(m, 'category');
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    if (raw is Map) {
      return _optString(Map<String, dynamic>.from(raw), 'nameEn') ??
          _optString(Map<String, dynamic>.from(raw), 'name') ??
          '';
    }
    return '';
  }

  String? _firstImageUrl(Map<String, dynamic> m) {
    final urls =
        _envelopeValue(m, 'imageUrls') ?? _envelopeValue(m, 'images');
    if (urls is List && urls.isNotEmpty) {
      final first = urls.first;
      if (first is String && first.trim().isNotEmpty) return first.trim();
      if (first is Map) {
        final map = Map<String, dynamic>.from(first);
        return _optString(map, 'url') ??
            _optString(map, 'imageUrl') ??
            _optString(map, 'path');
      }
    }
    return _optString(m, 'imageUrl') ??
        _optString(m, 'listingImage') ??
        _optString(m, 'thumbnailUrl');
  }

  Future<List<OrderModel>> _hydrateOrders(List<OrderModel> rows) async {
    final ids = <String>{};
    for (final o in rows) {
      if (!_needsListingSnap(o)) continue;
      for (final i in o.items) {
        if (i.listingId.isNotEmpty) ids.add(i.listingId);
      }
    }
    await Future.wait(ids.map(_ensureListingSnap));
    return rows.map(_applyListingSnap).toList();
  }

  bool _needsListingSnap(OrderModel o) {
    final needsVendor = o.vendorId.isEmpty &&
        o.vendorName.isEmpty &&
        o.vendorStoreName.isEmpty;
    final needsItem = o.items.isEmpty ||
        o.items.any(
          (i) =>
              i.listingName.isEmpty || i.listingImage.isEmpty || i.price <= 0,
        );
    final needsAddress = o.deliveryAddress.street.isEmpty &&
        o.deliveryAddress.city.isEmpty &&
        o.deliveryAddress.wilaya.isEmpty;
    return needsVendor || needsItem || needsAddress;
  }

  Future<void> _ensureListingSnap(String listingId) async {
    if (_listingSnapCache.containsKey(listingId)) return;
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.apiListingDetail(listingId),
      );
      final map = _asOrderMap(response.data) ?? _asMap(response.data);
      if (map == null) return;
      if (_listingSnapCache.length >= _listingSnapCacheCap) {
        _listingSnapCache.remove(_listingSnapCache.keys.first);
      }
      _listingSnapCache[listingId] = map;
    } on DioException {
      // Order still renders with whatever the order payload had.
    }
  }

  OrderModel _applyListingSnap(OrderModel o) {
    if (o.items.isEmpty) return o;
    final snaps = [
      for (final i in o.items) _listingSnapCache[i.listingId],
    ];
    final items = <OrderItemModel>[];
    for (var i = 0; i < o.items.length; i++) {
      final item = o.items[i];
      final snap = snaps[i];
      if (snap == null) {
        items.add(item);
        continue;
      }
      final price = item.price > 0
          ? item.price
          : (_envelopeDouble(snap, 'price') ?? 0);
      items.add(
        item.copyWith(
          listingName: item.listingName.isNotEmpty
              ? item.listingName
              : (_listingTitle(snap) ?? ''),
          listingImage: item.listingImage.isNotEmpty
              ? item.listingImage
              : (_firstImageUrl(snap) ?? ''),
          category: item.category.isNotEmpty
              ? item.category
              : _listingCategory(snap),
          condition: item.condition.isNotEmpty
              ? item.condition
              : listingConditionLabelFromRaw(
                  _envelopeValue(snap, 'conditionLabel') ??
                      _envelopeValue(snap, 'condition'),
                ),
          price: price,
          total: item.total > 0 ? item.total : price * item.quantity,
        ),
      );
    }
    final firstSnap = snaps.whereType<Map<String, dynamic>>().firstOrNull;
    var next = o.copyWith(items: items);
    if (firstSnap != null) {
      next = next.copyWith(
        vendorId: o.vendorId.isNotEmpty
            ? o.vendorId
            : (_optString(firstSnap, 'userId') ??
                _optString(firstSnap, 'vendorId') ??
                o.vendorId),
        vendorName: o.vendorName.isNotEmpty
            ? o.vendorName
            : (_optString(firstSnap, 'userName') ?? o.vendorName),
        vendorStoreName: o.vendorStoreName.isNotEmpty
            ? o.vendorStoreName
            : (_optString(firstSnap, 'storeName') ??
                _optString(firstSnap, 'userName') ??
                o.vendorStoreName),
        vendorAvatar: o.vendorAvatar.isNotEmpty
            ? o.vendorAvatar
            : (_optString(firstSnap, 'userAvatar') ?? o.vendorAvatar),
      );
      final loc = _optString(firstSnap, 'location');
      if (loc != null &&
          next.deliveryAddress.street.isEmpty &&
          next.deliveryAddress.city.isEmpty) {
        next = next.copyWith(
          deliveryAddress: next.deliveryAddress.copyWith(street: loc),
        );
      }
    }
    return next;
  }

  Map<String, dynamic>? _asMap(Object? raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  /// Single-order success may be the order map itself or a Result wrap
  /// `{data|Data: {...}}`. Same unwrap as vendor-orders stats.
  Map<String, dynamic>? _asOrderMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    if (_optString(map, 'id') != null ||
        _optString(map, 'orderId') != null ||
        _envelopeValue(map, 'listingId') != null ||
        _envelopeValue(map, 'items') != null ||
        _envelopeValue(map, 'status') != null) {
      return map;
    }
    final nested = map['data'] ?? map['Data'];
    if (nested is Map) return _asOrderMap(nested);
    if (map.isEmpty) return null;
    return map;
  }

  String? _optString(Map<String, dynamic> m, String camel) {
    final v = _envelopeValue(m, camel);
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Vendor-orders success is `Ok(result.Data)` (flat map). Also accept a
  /// `{data|Data: {...}}` wrap so a Result-envelope flip doesn't drop
  /// `commissionValueOnOrder` / `orders`.
  Map<String, dynamic> _asVendorOrdersEnvelope(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) return const {};
    if (_envelopeHas(raw, 'orders') ||
        _envelopeHas(raw, 'commissionValueOnOrder') ||
        _envelopeHas(raw, 'totalCount')) {
      return raw;
    }
    final nested = raw['data'] ?? raw['Data'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return raw;
  }

  bool _envelopeHas(Map<String, dynamic> m, String camel) =>
      _envelopeValue(m, camel) != null;

  Object? _envelopeValue(Map<String, dynamic> m, String camel) {
    if (m.containsKey(camel)) return m[camel];
    if (camel.isEmpty) return null;
    return m['${camel[0].toUpperCase()}${camel.substring(1)}'];
  }

  List<dynamic> _envelopeList(Map<String, dynamic> m, String camel) {
    final v = _envelopeValue(m, camel);
    return v is List ? v : const [];
  }

  int? _envelopeInt(Map<String, dynamic> m, String camel) {
    final v = _envelopeValue(m, camel);
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  double? _envelopeDouble(Map<String, dynamic> m, String camel) {
    final v = _envelopeValue(m, camel);
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  bool _envelopeBool(Map<String, dynamic> m, String camel) {
    final v = _envelopeValue(m, camel);
    if (v is bool) return v;
    return false;
  }
}
