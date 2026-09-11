import 'package:xstore/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:xstore/features/orders/data/models/order_item_model.dart';
import 'package:xstore/features/orders/data/models/order_model.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

/// Fake [OrdersRemoteDataSource] for [CartRemoteDataSourceImpl.placeOrder]
/// tests — only [createOrder] is ever exercised by that call path, so
/// every other method throws if reached, same convention as
/// [StubWishlistRemoteDataSource].
class StubOrdersRemoteDataSource implements OrdersRemoteDataSource {
  StubOrdersRemoteDataSource({
    Future<OrderModel> Function({
      required String listingId,
      required int quantity,
      required double latitude,
      required double longitude,
      required OrderItemModel fallbackItem,
      required OrderAddressModel fallbackAddress,
      required PaymentMethod fallbackPayment,
      String? notes,
    })? onCreateOrder,
    Future<OrderModel?> Function(String orderId)? getOrderByIdResult,
    Future<List<OrderModel>> Function({
      required String consumerId,
      required int page,
      required int pageSize,
    })? getConsumerOrdersResult,
  })  : _onCreateOrder = onCreateOrder,
        _getOrderById = getOrderByIdResult,
        _getConsumerOrders = getConsumerOrdersResult;

  final Future<OrderModel> Function({
    required String listingId,
    required int quantity,
    required double latitude,
    required double longitude,
    required OrderItemModel fallbackItem,
    required OrderAddressModel fallbackAddress,
    required PaymentMethod fallbackPayment,
    String? notes,
  })? _onCreateOrder;

  final Future<OrderModel?> Function(String orderId)? _getOrderById;
  final Future<List<OrderModel>> Function({
    required String consumerId,
    required int page,
    required int pageSize,
  })? _getConsumerOrders;

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
  }) {
    final cb = _onCreateOrder;
    if (cb == null) throw UnimplementedError('createOrder not stubbed');
    return cb(
      listingId: listingId,
      quantity: quantity,
      latitude: latitude,
      longitude: longitude,
      fallbackItem: fallbackItem,
      fallbackAddress: fallbackAddress,
      fallbackPayment: fallbackPayment,
      notes: notes,
    );
  }

  @override
  Future<List<OrderModel>> getConsumerOrders({
    required String consumerId,
    required int page,
    required int pageSize,
  }) {
    final cb = _getConsumerOrders;
    if (cb == null) throw UnimplementedError();
    return cb(consumerId: consumerId, page: page, pageSize: pageSize);
  }

  @override
  Future<List<OrderModel>> getVendorOrders({
    required String vendorId,
    required int page,
    required int pageSize,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<OrderModel>> getCourierOrders({
    required String courierId,
    required int page,
    required int pageSize,
  }) =>
      throw UnimplementedError();

  @override
  Future<OrderModel?> getOrderById(String orderId) {
    final cb = _getOrderById;
    if (cb == null) throw UnimplementedError();
    return cb(orderId);
  }

  @override
  Future<OrderStatsEntity> getVendorOrderStats({required String vendorId}) =>
      throw UnimplementedError();

  @override
  Future<OrderModel> cancelOrder({
    required String orderId,
    required String reason,
    required bool isVendorSession,
  }) =>
      throw UnimplementedError();

  @override
  Future<OrderModel> confirmOrder({
    required String orderId,
    required DeliveryMethod method,
    String? vendorId,
  }) =>
      throw UnimplementedError();

  @override
  Future<OrderModel> rejectOrder({
    required String orderId,
    required String reason,
    String? vendorId,
  }) =>
      throw UnimplementedError();

  @override
  Future<OrderModel> markProcessing(String orderId, {String? vendorId}) =>
      throw UnimplementedError();

  @override
  Future<OrderModel> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
    String? vendorId,
  }) =>
      throw UnimplementedError();

  @override
  Future<OrderModel> markDelivered(String orderId) => throw UnimplementedError();

  @override
  Future<void> updateDeliveryCoordinates({
    required String orderId,
    required double latitude,
    required double longitude,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> registerPlacedConsumerOrder(OrderModel order) =>
      throw UnimplementedError();
}
