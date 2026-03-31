import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
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

  static List<OrderModel>? _consumerCache;
  static List<OrderModel>? _vendorCache;

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
      courierName: trackingNumber != null ? (courierName ?? 'xStore Logistics') : null,
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
        consumerPhone: '+213 555 987 654',
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
        consumerPhone: '+213 555 123 789',
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
        consumerPhone: '+213 555 444 222',
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
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V004',
        consumerName: 'Youcef Tlemceni',
        consumerPhone: '+213 555 888 111',
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
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V005',
        consumerName: 'Amira Setifienne',
        consumerPhone: '+213 555 333 999',
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
        consumerPhone: '+213 555 610 610',
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
      ),
      _vendorOrderTemplate(
        id: 'XS-2024-V007',
        consumerName: 'Meriem Hadj',
        consumerPhone: '+213 555 700 001',
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
        consumerPhone: '+213 555 730 730',
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
    final _ = _dio;
    throw UnimplementedError();
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
    final _ = _dio;
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  Future<void> registerPlacedConsumerOrder(OrderModel order) async {
    if (MockConfig.useMock) {
      _consumerCache ??= _seedConsumerOrders();
      _consumerCache = [order, ..._consumerOrders];
      return;
    }
    throw UnimplementedError();
  }
}
