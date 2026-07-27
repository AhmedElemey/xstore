import 'package:dio/dio.dart';

import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/delivery_request.dart';

/// The package-delivery data contract, shared by the live remote datasource and
/// the in-memory mock ([DeliveryRequestMockDataSource]). The repository depends
/// on this interface; the dependencies provider picks the implementation from
/// `MockConfig.useMock`.
///
/// Method signatures mirror [DeliveryRequestRepository] minus the `Either`
/// wrapping — implementations throw on failure and the repository maps to
/// [Failure].
abstract interface class DeliveryRequestDataSource {
  Future<List<DeliveryRequestEntity>> getMyRequests(String consumerId);

  Future<DeliveryRequestEntity> createRequest({
    required String consumerId,
    required String consumerName,
    required String consumerPhone,
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
  });

  Future<DeliveryRequestEntity> confirmRequest(String id);

  Future<DeliveryRequestEntity> cancelRequest(String id, String reason);

  Future<List<DeliveryRequestEntity>> getCourierPackages(String courierId);

  Future<DeliveryRequestEntity> markPickedUp(String id);

  Future<DeliveryRequestEntity> markDelivered(String id);
}

/// Talks to the xStore delivery backend (`/api/delivery-requests`). The caller
/// identity (consumer / courier) comes from the auth token injected centrally
/// by `dioProvider`, so `consumerId` / `courierId` arguments are not sent on the
/// wire — the token-scoped `/mine` and `/courier/mine` routes are used instead.
class DeliveryRequestRemoteDataSource implements DeliveryRequestDataSource {
  DeliveryRequestRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<DeliveryRequestEntity>> getMyRequests(String consumerId) =>
      _getList(ApiEndpoints.deliveryRequestsMine);

  @override
  Future<List<DeliveryRequestEntity>> getCourierPackages(String courierId) =>
      _getList(ApiEndpoints.deliveryRequestsCourierMine);

  @override
  Future<DeliveryRequestEntity> createRequest({
    required String consumerId,
    required String consumerName,
    required String consumerPhone,
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
  }) =>
      _postOne(
        ApiEndpoints.deliveryRequests,
        data: {
          'pickup': _addressToJson(pickup),
          'dropoff': _addressToJson(dropoff),
          'packageNote': packageNote,
        },
      );

  @override
  Future<DeliveryRequestEntity> confirmRequest(String id) =>
      _postOne(ApiEndpoints.deliveryRequestConfirm(id));

  @override
  Future<DeliveryRequestEntity> cancelRequest(String id, String reason) =>
      _postOne(
        ApiEndpoints.deliveryRequestCancel(id),
        data: {'reason': reason},
      );

  @override
  Future<DeliveryRequestEntity> markPickedUp(String id) =>
      _postOne(ApiEndpoints.deliveryRequestPickup(id));

  @override
  Future<DeliveryRequestEntity> markDelivered(String id) =>
      _postOne(ApiEndpoints.deliveryRequestDeliver(id));

  // ---- HTTP helpers ----

  Future<List<DeliveryRequestEntity>> _getList(String path) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        options: ApiAuthHeaders.authenticated(),
      );
      return (response.data ?? const [])
          .whereType<Map>()
          .map((e) => _fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<DeliveryRequestEntity> _postOne(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: ApiAuthHeaders.authenticated(),
      );
      return _fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ---- Parsing ----

  static Map<String, dynamic> _addressToJson(OrderAddress a) => {
        'fullName': a.fullName,
        'phone': a.phone,
        'street': a.street,
        'city': a.city,
        'wilaya': a.wilaya,
        'postalCode': a.postalCode,
      };

  static OrderAddress _addressFromJson(Map<String, dynamic> j) => OrderAddress(
        fullName: j['fullName'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        street: j['street'] as String? ?? '',
        city: j['city'] as String? ?? '',
        wilaya: j['wilaya'] as String? ?? '',
        postalCode: j['postalCode'] as String?,
      );

  /// Enum values arrive as camelCase strings matching the Dart names
  /// (`submitted`, `pickedUp`, ...). An unknown value falls back to
  /// `submitted` rather than throwing, so one renamed backend member can't
  /// blank the whole list.
  static DeliveryRequestStatus _statusFromJson(Object? raw) {
    final name = raw?.toString() ?? '';
    for (final s in DeliveryRequestStatus.values) {
      if (s.name == name) return s;
    }
    return DeliveryRequestStatus.submitted;
  }

  static DateTime? _dateOrNull(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  static DeliveryRequestEntity _fromJson(Map<String, dynamic> j) {
    final price = j['price'];
    return DeliveryRequestEntity(
      id: j['id'] as String? ?? '',
      consumerId: j['consumerId'] as String? ?? '',
      consumerName: j['consumerName'] as String? ?? '',
      consumerPhone: j['consumerPhone'] as String? ?? '',
      pickup: _addressFromJson(
        Map<String, dynamic>.from(j['pickup'] as Map? ?? const {}),
      ),
      dropoff: _addressFromJson(
        Map<String, dynamic>.from(j['dropoff'] as Map? ?? const {}),
      ),
      packageNote: j['packageNote'] as String? ?? '',
      price: price is num ? price.toDouble() : null,
      status: _statusFromJson(j['status']),
      courierId: j['courierId'] as String?,
      cancelReason: j['cancelReason'] as String?,
      createdAt: _dateOrNull(j['createdAt']) ?? DateTime.now(),
      updatedAt: _dateOrNull(j['updatedAt']) ?? DateTime.now(),
      pricedAt: _dateOrNull(j['pricedAt']),
      confirmedAt: _dateOrNull(j['confirmedAt']),
      pickedUpAt: _dateOrNull(j['pickedUpAt']),
      deliveredAt: _dateOrNull(j['deliveredAt']),
    );
  }
}
