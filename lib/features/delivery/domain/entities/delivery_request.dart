import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../orders/domain/entities/order_entity.dart';

part 'delivery_request.freezed.dart';

/// Lifecycle of a point-to-point package delivery request (requester is a
/// consumer or a vendor).
///
/// submitted → (admin prices) priced → (requester confirms) confirmed →
/// (courier collects cash + parcel) pickedUp → delivered.
/// cancelled is reachable from submitted/priced only — once confirmed the
/// request is a courier task and follows the courier flow.
enum DeliveryRequestStatus {
  submitted,
  priced,
  confirmed,
  pickedUp,
  delivered,
  cancelled,
}

/// A consumer's or vendor's request to move a package from [pickup] to
/// [dropoff].
///
/// The app never holds money: the courier collects [price] in cash from the
/// sender at pickup (COD-at-pickup, mirroring the marketplace COD pilot).
/// [pickup]'s fullName/phone identify the sender; [dropoff]'s identify the
/// recipient. [requesterId]/[requesterName]/[requesterPhone] identify the
/// signed-in account that submitted the request (consumer or vendor) — not
/// necessarily the same person as the sender named in [pickup].
@freezed
class DeliveryRequestEntity with _$DeliveryRequestEntity {
  const factory DeliveryRequestEntity({
    required String id,
    required String requesterId,
    required String requesterName,
    required String requesterPhone,
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
    /// Null until the admin prices the request.
    double? price,
    required DeliveryRequestStatus status,
    /// Assigned on confirmation (pilot: manual admin assignment).
    String? courierId,
    String? cancelReason,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? pricedAt,
    DateTime? confirmedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) = _DeliveryRequestEntity;
}
