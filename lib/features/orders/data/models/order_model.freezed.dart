// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrderAddressModel {
  String get fullName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get street => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get wilaya => throw _privateConstructorUsedError;
  String? get postalCode => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OrderAddressModelCopyWith<OrderAddressModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderAddressModelCopyWith<$Res> {
  factory $OrderAddressModelCopyWith(
          OrderAddressModel value, $Res Function(OrderAddressModel) then) =
      _$OrderAddressModelCopyWithImpl<$Res, OrderAddressModel>;
  @useResult
  $Res call(
      {String fullName,
      String phone,
      String street,
      String city,
      String wilaya,
      String? postalCode,
      bool isDefault});
}

/// @nodoc
class _$OrderAddressModelCopyWithImpl<$Res, $Val extends OrderAddressModel>
    implements $OrderAddressModelCopyWith<$Res> {
  _$OrderAddressModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? phone = null,
    Object? street = null,
    Object? city = null,
    Object? wilaya = null,
    Object? postalCode = freezed,
    Object? isDefault = null,
  }) {
    return _then(_value.copyWith(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      wilaya: null == wilaya
          ? _value.wilaya
          : wilaya // ignore: cast_nullable_to_non_nullable
              as String,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderAddressModelImplCopyWith<$Res>
    implements $OrderAddressModelCopyWith<$Res> {
  factory _$$OrderAddressModelImplCopyWith(_$OrderAddressModelImpl value,
          $Res Function(_$OrderAddressModelImpl) then) =
      __$$OrderAddressModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fullName,
      String phone,
      String street,
      String city,
      String wilaya,
      String? postalCode,
      bool isDefault});
}

/// @nodoc
class __$$OrderAddressModelImplCopyWithImpl<$Res>
    extends _$OrderAddressModelCopyWithImpl<$Res, _$OrderAddressModelImpl>
    implements _$$OrderAddressModelImplCopyWith<$Res> {
  __$$OrderAddressModelImplCopyWithImpl(_$OrderAddressModelImpl _value,
      $Res Function(_$OrderAddressModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? phone = null,
    Object? street = null,
    Object? city = null,
    Object? wilaya = null,
    Object? postalCode = freezed,
    Object? isDefault = null,
  }) {
    return _then(_$OrderAddressModelImpl(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      wilaya: null == wilaya
          ? _value.wilaya
          : wilaya // ignore: cast_nullable_to_non_nullable
              as String,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$OrderAddressModelImpl implements _OrderAddressModel {
  const _$OrderAddressModelImpl(
      {required this.fullName,
      required this.phone,
      required this.street,
      required this.city,
      required this.wilaya,
      this.postalCode,
      this.isDefault = false});

  @override
  final String fullName;
  @override
  final String phone;
  @override
  final String street;
  @override
  final String city;
  @override
  final String wilaya;
  @override
  final String? postalCode;
  @override
  @JsonKey()
  final bool isDefault;

  @override
  String toString() {
    return 'OrderAddressModel(fullName: $fullName, phone: $phone, street: $street, city: $city, wilaya: $wilaya, postalCode: $postalCode, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderAddressModelImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.wilaya, wilaya) || other.wilaya == wilaya) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fullName, phone, street, city,
      wilaya, postalCode, isDefault);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderAddressModelImplCopyWith<_$OrderAddressModelImpl> get copyWith =>
      __$$OrderAddressModelImplCopyWithImpl<_$OrderAddressModelImpl>(
          this, _$identity);
}

abstract class _OrderAddressModel implements OrderAddressModel {
  const factory _OrderAddressModel(
      {required final String fullName,
      required final String phone,
      required final String street,
      required final String city,
      required final String wilaya,
      final String? postalCode,
      final bool isDefault}) = _$OrderAddressModelImpl;

  @override
  String get fullName;
  @override
  String get phone;
  @override
  String get street;
  @override
  String get city;
  @override
  String get wilaya;
  @override
  String? get postalCode;
  @override
  bool get isDefault;
  @override
  @JsonKey(ignore: true)
  _$$OrderAddressModelImplCopyWith<_$OrderAddressModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  String get consumerId => throw _privateConstructorUsedError;
  String get consumerName => throw _privateConstructorUsedError;
  String get consumerPhone => throw _privateConstructorUsedError;
  String get consumerAvatar => throw _privateConstructorUsedError;
  String get vendorId => throw _privateConstructorUsedError;
  String get vendorName => throw _privateConstructorUsedError;
  String get vendorStoreName => throw _privateConstructorUsedError;
  String get vendorAvatar => throw _privateConstructorUsedError;
  double get vendorRating => throw _privateConstructorUsedError;
  List<OrderItemModel> get items => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  bool get isPaid => throw _privateConstructorUsedError;
  OrderAddressModel get deliveryAddress => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get shippingCost => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  String? get trackingNumber => throw _privateConstructorUsedError;
  String? get courierId => throw _privateConstructorUsedError;
  String? get courierName => throw _privateConstructorUsedError;
  String? get trackingLocation => throw _privateConstructorUsedError;
  DateTime? get estimatedDelivery => throw _privateConstructorUsedError;
  String? get cancelReason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  DateTime? get shippedAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
          OrderModel value, $Res Function(OrderModel) then) =
      _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call(
      {String id,
      String consumerId,
      String consumerName,
      String consumerPhone,
      String consumerAvatar,
      String vendorId,
      String vendorName,
      String vendorStoreName,
      String vendorAvatar,
      double vendorRating,
      List<OrderItemModel> items,
      OrderStatus status,
      PaymentMethod paymentMethod,
      bool isPaid,
      OrderAddressModel deliveryAddress,
      double subtotal,
      double shippingCost,
      double discount,
      double total,
      String? trackingNumber,
      String? courierId,
      String? courierName,
      String? trackingLocation,
      DateTime? estimatedDelivery,
      String? cancelReason,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? confirmedAt,
      DateTime? shippedAt,
      DateTime? deliveredAt,
      DateTime? cancelledAt});

  $OrderAddressModelCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consumerId = null,
    Object? consumerName = null,
    Object? consumerPhone = null,
    Object? consumerAvatar = null,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? vendorStoreName = null,
    Object? vendorAvatar = null,
    Object? vendorRating = null,
    Object? items = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? isPaid = null,
    Object? deliveryAddress = null,
    Object? subtotal = null,
    Object? shippingCost = null,
    Object? discount = null,
    Object? total = null,
    Object? trackingNumber = freezed,
    Object? courierId = freezed,
    Object? courierName = freezed,
    Object? trackingLocation = freezed,
    Object? estimatedDelivery = freezed,
    Object? cancelReason = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? confirmedAt = freezed,
    Object? shippedAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      consumerId: null == consumerId
          ? _value.consumerId
          : consumerId // ignore: cast_nullable_to_non_nullable
              as String,
      consumerName: null == consumerName
          ? _value.consumerName
          : consumerName // ignore: cast_nullable_to_non_nullable
              as String,
      consumerPhone: null == consumerPhone
          ? _value.consumerPhone
          : consumerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      consumerAvatar: null == consumerAvatar
          ? _value.consumerAvatar
          : consumerAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      vendorId: null == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String,
      vendorName: null == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String,
      vendorStoreName: null == vendorStoreName
          ? _value.vendorStoreName
          : vendorStoreName // ignore: cast_nullable_to_non_nullable
              as String,
      vendorAvatar: null == vendorAvatar
          ? _value.vendorAvatar
          : vendorAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      vendorRating: null == vendorRating
          ? _value.vendorRating
          : vendorRating // ignore: cast_nullable_to_non_nullable
              as double,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItemModel>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as OrderAddressModel,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      shippingCost: null == shippingCost
          ? _value.shippingCost
          : shippingCost // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      trackingNumber: freezed == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      courierId: freezed == courierId
          ? _value.courierId
          : courierId // ignore: cast_nullable_to_non_nullable
              as String?,
      courierName: freezed == courierName
          ? _value.courierName
          : courierName // ignore: cast_nullable_to_non_nullable
              as String?,
      trackingLocation: freezed == trackingLocation
          ? _value.trackingLocation
          : trackingLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDelivery: freezed == estimatedDelivery
          ? _value.estimatedDelivery
          : estimatedDelivery // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      shippedAt: freezed == shippedAt
          ? _value.shippedAt
          : shippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $OrderAddressModelCopyWith<$Res> get deliveryAddress {
    return $OrderAddressModelCopyWith<$Res>(_value.deliveryAddress, (value) {
      return _then(_value.copyWith(deliveryAddress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
          _$OrderModelImpl value, $Res Function(_$OrderModelImpl) then) =
      __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String consumerId,
      String consumerName,
      String consumerPhone,
      String consumerAvatar,
      String vendorId,
      String vendorName,
      String vendorStoreName,
      String vendorAvatar,
      double vendorRating,
      List<OrderItemModel> items,
      OrderStatus status,
      PaymentMethod paymentMethod,
      bool isPaid,
      OrderAddressModel deliveryAddress,
      double subtotal,
      double shippingCost,
      double discount,
      double total,
      String? trackingNumber,
      String? courierId,
      String? courierName,
      String? trackingLocation,
      DateTime? estimatedDelivery,
      String? cancelReason,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? confirmedAt,
      DateTime? shippedAt,
      DateTime? deliveredAt,
      DateTime? cancelledAt});

  @override
  $OrderAddressModelCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
      _$OrderModelImpl _value, $Res Function(_$OrderModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consumerId = null,
    Object? consumerName = null,
    Object? consumerPhone = null,
    Object? consumerAvatar = null,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? vendorStoreName = null,
    Object? vendorAvatar = null,
    Object? vendorRating = null,
    Object? items = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? isPaid = null,
    Object? deliveryAddress = null,
    Object? subtotal = null,
    Object? shippingCost = null,
    Object? discount = null,
    Object? total = null,
    Object? trackingNumber = freezed,
    Object? courierId = freezed,
    Object? courierName = freezed,
    Object? trackingLocation = freezed,
    Object? estimatedDelivery = freezed,
    Object? cancelReason = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? confirmedAt = freezed,
    Object? shippedAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
  }) {
    return _then(_$OrderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      consumerId: null == consumerId
          ? _value.consumerId
          : consumerId // ignore: cast_nullable_to_non_nullable
              as String,
      consumerName: null == consumerName
          ? _value.consumerName
          : consumerName // ignore: cast_nullable_to_non_nullable
              as String,
      consumerPhone: null == consumerPhone
          ? _value.consumerPhone
          : consumerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      consumerAvatar: null == consumerAvatar
          ? _value.consumerAvatar
          : consumerAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      vendorId: null == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String,
      vendorName: null == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String,
      vendorStoreName: null == vendorStoreName
          ? _value.vendorStoreName
          : vendorStoreName // ignore: cast_nullable_to_non_nullable
              as String,
      vendorAvatar: null == vendorAvatar
          ? _value.vendorAvatar
          : vendorAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      vendorRating: null == vendorRating
          ? _value.vendorRating
          : vendorRating // ignore: cast_nullable_to_non_nullable
              as double,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItemModel>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as OrderAddressModel,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      shippingCost: null == shippingCost
          ? _value.shippingCost
          : shippingCost // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      trackingNumber: freezed == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      courierId: freezed == courierId
          ? _value.courierId
          : courierId // ignore: cast_nullable_to_non_nullable
              as String?,
      courierName: freezed == courierName
          ? _value.courierName
          : courierName // ignore: cast_nullable_to_non_nullable
              as String?,
      trackingLocation: freezed == trackingLocation
          ? _value.trackingLocation
          : trackingLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDelivery: freezed == estimatedDelivery
          ? _value.estimatedDelivery
          : estimatedDelivery // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      shippedAt: freezed == shippedAt
          ? _value.shippedAt
          : shippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$OrderModelImpl implements _OrderModel {
  const _$OrderModelImpl(
      {required this.id,
      required this.consumerId,
      required this.consumerName,
      required this.consumerPhone,
      this.consumerAvatar = '',
      required this.vendorId,
      required this.vendorName,
      required this.vendorStoreName,
      this.vendorAvatar = '',
      this.vendorRating = 4.8,
      required final List<OrderItemModel> items,
      required this.status,
      required this.paymentMethod,
      this.isPaid = false,
      required this.deliveryAddress,
      required this.subtotal,
      required this.shippingCost,
      required this.discount,
      required this.total,
      this.trackingNumber,
      this.courierId,
      this.courierName,
      this.trackingLocation,
      this.estimatedDelivery,
      this.cancelReason,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.confirmedAt,
      this.shippedAt,
      this.deliveredAt,
      this.cancelledAt})
      : _items = items;

  @override
  final String id;
  @override
  final String consumerId;
  @override
  final String consumerName;
  @override
  final String consumerPhone;
  @override
  @JsonKey()
  final String consumerAvatar;
  @override
  final String vendorId;
  @override
  final String vendorName;
  @override
  final String vendorStoreName;
  @override
  @JsonKey()
  final String vendorAvatar;
  @override
  @JsonKey()
  final double vendorRating;
  final List<OrderItemModel> _items;
  @override
  List<OrderItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final OrderStatus status;
  @override
  final PaymentMethod paymentMethod;
  @override
  @JsonKey()
  final bool isPaid;
  @override
  final OrderAddressModel deliveryAddress;
  @override
  final double subtotal;
  @override
  final double shippingCost;
  @override
  final double discount;
  @override
  final double total;
  @override
  final String? trackingNumber;
  @override
  final String? courierId;
  @override
  final String? courierName;
  @override
  final String? trackingLocation;
  @override
  final DateTime? estimatedDelivery;
  @override
  final String? cancelReason;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? confirmedAt;
  @override
  final DateTime? shippedAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? cancelledAt;

  @override
  String toString() {
    return 'OrderModel(id: $id, consumerId: $consumerId, consumerName: $consumerName, consumerPhone: $consumerPhone, consumerAvatar: $consumerAvatar, vendorId: $vendorId, vendorName: $vendorName, vendorStoreName: $vendorStoreName, vendorAvatar: $vendorAvatar, vendorRating: $vendorRating, items: $items, status: $status, paymentMethod: $paymentMethod, isPaid: $isPaid, deliveryAddress: $deliveryAddress, subtotal: $subtotal, shippingCost: $shippingCost, discount: $discount, total: $total, trackingNumber: $trackingNumber, courierId: $courierId, courierName: $courierName, trackingLocation: $trackingLocation, estimatedDelivery: $estimatedDelivery, cancelReason: $cancelReason, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, confirmedAt: $confirmedAt, shippedAt: $shippedAt, deliveredAt: $deliveredAt, cancelledAt: $cancelledAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.consumerId, consumerId) ||
                other.consumerId == consumerId) &&
            (identical(other.consumerName, consumerName) ||
                other.consumerName == consumerName) &&
            (identical(other.consumerPhone, consumerPhone) ||
                other.consumerPhone == consumerPhone) &&
            (identical(other.consumerAvatar, consumerAvatar) ||
                other.consumerAvatar == consumerAvatar) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            (identical(other.vendorStoreName, vendorStoreName) ||
                other.vendorStoreName == vendorStoreName) &&
            (identical(other.vendorAvatar, vendorAvatar) ||
                other.vendorAvatar == vendorAvatar) &&
            (identical(other.vendorRating, vendorRating) ||
                other.vendorRating == vendorRating) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.shippingCost, shippingCost) ||
                other.shippingCost == shippingCost) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.trackingNumber, trackingNumber) ||
                other.trackingNumber == trackingNumber) &&
            (identical(other.courierId, courierId) ||
                other.courierId == courierId) &&
            (identical(other.courierName, courierName) ||
                other.courierName == courierName) &&
            (identical(other.trackingLocation, trackingLocation) ||
                other.trackingLocation == trackingLocation) &&
            (identical(other.estimatedDelivery, estimatedDelivery) ||
                other.estimatedDelivery == estimatedDelivery) &&
            (identical(other.cancelReason, cancelReason) ||
                other.cancelReason == cancelReason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.shippedAt, shippedAt) ||
                other.shippedAt == shippedAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        consumerId,
        consumerName,
        consumerPhone,
        consumerAvatar,
        vendorId,
        vendorName,
        vendorStoreName,
        vendorAvatar,
        vendorRating,
        const DeepCollectionEquality().hash(_items),
        status,
        paymentMethod,
        isPaid,
        deliveryAddress,
        subtotal,
        shippingCost,
        discount,
        total,
        trackingNumber,
        courierId,
        courierName,
        trackingLocation,
        estimatedDelivery,
        cancelReason,
        notes,
        createdAt,
        updatedAt,
        confirmedAt,
        shippedAt,
        deliveredAt,
        cancelledAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);
}

abstract class _OrderModel implements OrderModel {
  const factory _OrderModel(
      {required final String id,
      required final String consumerId,
      required final String consumerName,
      required final String consumerPhone,
      final String consumerAvatar,
      required final String vendorId,
      required final String vendorName,
      required final String vendorStoreName,
      final String vendorAvatar,
      final double vendorRating,
      required final List<OrderItemModel> items,
      required final OrderStatus status,
      required final PaymentMethod paymentMethod,
      final bool isPaid,
      required final OrderAddressModel deliveryAddress,
      required final double subtotal,
      required final double shippingCost,
      required final double discount,
      required final double total,
      final String? trackingNumber,
      final String? courierId,
      final String? courierName,
      final String? trackingLocation,
      final DateTime? estimatedDelivery,
      final String? cancelReason,
      final String? notes,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? confirmedAt,
      final DateTime? shippedAt,
      final DateTime? deliveredAt,
      final DateTime? cancelledAt}) = _$OrderModelImpl;

  @override
  String get id;
  @override
  String get consumerId;
  @override
  String get consumerName;
  @override
  String get consumerPhone;
  @override
  String get consumerAvatar;
  @override
  String get vendorId;
  @override
  String get vendorName;
  @override
  String get vendorStoreName;
  @override
  String get vendorAvatar;
  @override
  double get vendorRating;
  @override
  List<OrderItemModel> get items;
  @override
  OrderStatus get status;
  @override
  PaymentMethod get paymentMethod;
  @override
  bool get isPaid;
  @override
  OrderAddressModel get deliveryAddress;
  @override
  double get subtotal;
  @override
  double get shippingCost;
  @override
  double get discount;
  @override
  double get total;
  @override
  String? get trackingNumber;
  @override
  String? get courierId;
  @override
  String? get courierName;
  @override
  String? get trackingLocation;
  @override
  DateTime? get estimatedDelivery;
  @override
  String? get cancelReason;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get confirmedAt;
  @override
  DateTime? get shippedAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get cancelledAt;
  @override
  @JsonKey(ignore: true)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
