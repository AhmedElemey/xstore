import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/delivery_api_endpoints.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/delivery_request.dart';
import 'delivery_request_datasource.dart';

/// Real delivery-backend calls for package delivery requests (Flow B —
/// consumer standalone packages and vendor order-linked custom requests).
/// The requester/courier scoping ("mine") comes from the caller's JWT
/// identity on the backend, not the id parameters on this interface — they
/// exist only to satisfy [DeliveryRequestDataSource]'s shared shape with the
/// mock datasource.
class DeliveryRequestRemoteDataSource implements DeliveryRequestDataSource {
  DeliveryRequestRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<DeliveryRequestEntity>> getMyRequests(
    String requesterId,
  ) async {
    final list = await _getList(DeliveryApiEndpoints.deliveryRequestsMine);
    return list.map(_requestFromApiMap).toList();
  }

  @override
  Future<DeliveryRequestEntity> createRequest({
    required String requesterId,
    required String requesterName,
    required String requesterPhone,
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
    String? orderId,
  }) async {
    final data = await _post(
      DeliveryApiEndpoints.deliveryRequests,
      {
        'pickup': _addressToApiMap(pickup),
        'dropoff': _addressToApiMap(dropoff),
        'packageNote': packageNote,
        if (orderId != null) 'orderId': orderId,
      },
    );
    return _requestFromApiMap(data);
  }

  @override
  Future<DeliveryRequestEntity> confirmRequest(String id) async {
    final data =
        await _post(DeliveryApiEndpoints.deliveryRequestConfirm(id), const {});
    return _requestFromApiMap(data);
  }

  @override
  Future<DeliveryRequestEntity> cancelRequest(String id, String reason) async {
    final data = await _post(
      DeliveryApiEndpoints.deliveryRequestCancel(id),
      {'reason': reason},
    );
    return _requestFromApiMap(data);
  }

  @override
  Future<List<DeliveryRequestEntity>> getCourierPackages(
    String courierId,
  ) async {
    final list =
        await _getList(DeliveryApiEndpoints.deliveryRequestsCourierMine);
    return list.map(_requestFromApiMap).toList();
  }

  @override
  Future<DeliveryRequestEntity> markPickedUp(String id) async {
    final data =
        await _post(DeliveryApiEndpoints.deliveryRequestPickup(id), const {});
    return _requestFromApiMap(data);
  }

  @override
  Future<DeliveryRequestEntity> markDelivered(String id) async {
    final data =
        await _post(DeliveryApiEndpoints.deliveryRequestDeliver(id), const {});
    return _requestFromApiMap(data);
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    try {
      final response = await _dio.get<List<dynamic>>(path);
      final list = response.data ?? const [];
      return list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_errorMessage(e));
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return data;
    } on DioException catch (e) {
      throw ServerException(_errorMessage(e));
    }
  }

  String _errorMessage(DioException e) {
    final body = e.response?.data;
    if (body is Map && body['title'] is String) return body['title'] as String;
    return e.message ?? 'Delivery request failed';
  }

  Map<String, dynamic> _addressToApiMap(OrderAddress a) => {
        'fullName': a.fullName,
        'phone': a.phone,
        'street': a.street,
        'city': a.city,
        'wilaya': a.wilaya,
        'postalCode': a.postalCode,
      };

  OrderAddress _addressFromApiMap(Map<String, dynamic> data) => OrderAddress(
        fullName: (data['fullName'] ?? '').toString(),
        phone: (data['phone'] ?? '').toString(),
        street: (data['street'] ?? '').toString(),
        city: (data['city'] ?? '').toString(),
        wilaya: (data['wilaya'] ?? '').toString(),
        postalCode: data['postalCode'] as String?,
      );

  DeliveryRequestEntity _requestFromApiMap(Map<String, dynamic> data) {
    final pickup = Map<String, dynamic>.from((data['pickup'] as Map?) ?? const {});
    final dropoff =
        Map<String, dynamic>.from((data['dropoff'] as Map?) ?? const {});
    return DeliveryRequestEntity(
      id: (data['id'] ?? '').toString(),
      requesterId: (data['consumerId'] ?? '').toString(),
      requesterName: (data['consumerName'] ?? '').toString(),
      requesterPhone: (data['consumerPhone'] ?? '').toString(),
      pickup: _addressFromApiMap(pickup),
      dropoff: _addressFromApiMap(dropoff),
      packageNote: (data['packageNote'] ?? '').toString(),
      orderId: data['orderId'] as String?,
      price: (data['price'] as num?)?.toDouble(),
      status: switch ((data['status'] ?? '').toString()) {
        'priced' => DeliveryRequestStatus.priced,
        'confirmed' => DeliveryRequestStatus.confirmed,
        'pickedUp' => DeliveryRequestStatus.pickedUp,
        'delivered' => DeliveryRequestStatus.delivered,
        'cancelled' => DeliveryRequestStatus.cancelled,
        _ => DeliveryRequestStatus.submitted,
      },
      courierId: data['courierId'] as String?,
      cancelReason: data['cancelReason'] as String?,
      createdAt:
          DateTime.tryParse((data['createdAt'] ?? '').toString()) ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse((data['updatedAt'] ?? '').toString()) ??
              DateTime.now(),
      pricedAt: DateTime.tryParse((data['pricedAt'] ?? '').toString()),
      confirmedAt: DateTime.tryParse((data['confirmedAt'] ?? '').toString()),
      pickedUpAt: DateTime.tryParse((data['pickedUpAt'] ?? '').toString()),
      deliveredAt: DateTime.tryParse((data['deliveredAt'] ?? '').toString()),
    );
  }
}
