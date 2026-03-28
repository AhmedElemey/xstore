import '../../features/listing/data/models/listing_model.dart';
import 'mock_listings.dart';

/// Order status for mock orders screen / future persistence.
enum MockOrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
}

/// Snapshot-style order row (no domain entity exists in-app yet).
class MockOrderEntity {
  const MockOrderEntity({
    required this.id,
    required this.consumerId,
    required this.vendorId,
    required this.vendorName,
    required this.listingSnapshot,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.createdAt,
    required this.updatedAt,
    this.trackingNumber,
    this.estimatedDelivery,
    this.cancelReason,
  });

  final String id;
  final String consumerId;
  final String vendorId;
  final String vendorName;
  final ListingModel listingSnapshot;
  final int quantity;
  final double totalPrice;
  final MockOrderStatus status;
  final String paymentMethod;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;
  final String? cancelReason;
}

ListingModel _listing(String id) =>
    mockListingModels.firstWhere((e) => e.id == id);

final mockOrders = <MockOrderEntity>[
  MockOrderEntity(
    id: 'order_001',
    consumerId: 'consumer_001',
    vendorId: 'vendor_001',
    vendorName: 'Ahmed Bensalem',
    listingSnapshot: _listing('listing_001'),
    quantity: 1,
    totalPrice: 185000,
    status: MockOrderStatus.delivered,
    paymentMethod: 'Cash on Delivery',
    deliveryAddress: '12 Rue Didouche Mourad, Algiers',
    trackingNumber: 'XS-2024-001',
    estimatedDelivery: null,
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  MockOrderEntity(
    id: 'order_002',
    consumerId: 'consumer_001',
    vendorId: 'vendor_001',
    vendorName: 'Ahmed Bensalem',
    listingSnapshot: _listing('listing_013'),
    quantity: 1,
    totalPrice: 32000,
    status: MockOrderStatus.shipped,
    paymentMethod: 'CIB Card',
    deliveryAddress: '8 Blvd de la Soummam, Oran',
    trackingNumber: 'XS-2024-002',
    estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  MockOrderEntity(
    id: 'order_003',
    consumerId: 'consumer_001',
    vendorId: 'vendor_001',
    vendorName: 'Ahmed Bensalem',
    listingSnapshot: _listing('listing_003'),
    quantity: 2,
    totalPrice: 25000,
    status: MockOrderStatus.confirmed,
    paymentMethod: 'Cash on Delivery',
    deliveryAddress: '3 Cours de la Révolution, Constantine',
    trackingNumber: null,
    estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  MockOrderEntity(
    id: 'order_004',
    consumerId: 'consumer_001',
    vendorId: 'vendor_001',
    vendorName: 'Ahmed Bensalem',
    listingSnapshot: _listing('listing_017'),
    quantity: 1,
    totalPrice: 1200,
    status: MockOrderStatus.pending,
    paymentMethod: 'Cash on Delivery',
    deliveryAddress: '21 Blvd du 1er Novembre, Annaba',
    trackingNumber: null,
    estimatedDelivery: null,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  MockOrderEntity(
    id: 'order_005',
    consumerId: 'consumer_001',
    vendorId: 'vendor_001',
    vendorName: 'Ahmed Bensalem',
    listingSnapshot: _listing('listing_012'),
    quantity: 1,
    totalPrice: 3200,
    status: MockOrderStatus.cancelled,
    paymentMethod: 'Cash on Delivery',
    deliveryAddress: '5 Rue Colonel Amirouche, Setif',
    trackingNumber: null,
    estimatedDelivery: null,
    cancelReason: 'Item out of stock',
    createdAt: DateTime.now().subtract(const Duration(days: 9)),
    updatedAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
  MockOrderEntity(
    id: 'order_006',
    consumerId: 'consumer_001',
    vendorId: 'vendor_001',
    vendorName: 'Ahmed Bensalem',
    listingSnapshot: _listing('listing_019'),
    quantity: 1,
    totalPrice: 78000,
    status: MockOrderStatus.shipped,
    paymentMethod: 'CIB Card',
    deliveryAddress: '2 Rue Larbi Ben Mhidi, Algiers',
    trackingNumber: 'XS-2024-006',
    estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
  ),
];
