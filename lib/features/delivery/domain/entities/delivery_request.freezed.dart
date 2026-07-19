// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeliveryRequestEntity {
  String get id => throw _privateConstructorUsedError;
  String get consumerId => throw _privateConstructorUsedError;
  String get consumerName => throw _privateConstructorUsedError;
  String get consumerPhone => throw _privateConstructorUsedError;
  OrderAddress get pickup => throw _privateConstructorUsedError;
  OrderAddress get dropoff => throw _privateConstructorUsedError;
  String get packageNote => throw _privateConstructorUsedError;

  /// Null until the admin prices the request.
  double? get price => throw _privateConstructorUsedError;
  DeliveryRequestStatus get status => throw _privateConstructorUsedError;

  /// Assigned on confirmation (pilot: manual admin assignment).
  String? get courierId => throw _privateConstructorUsedError;
  String? get cancelReason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get pricedAt => throw _privateConstructorUsedError;
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  DateTime? get pickedUpAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DeliveryRequestEntityCopyWith<DeliveryRequestEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryRequestEntityCopyWith<$Res> {
  factory $DeliveryRequestEntityCopyWith(DeliveryRequestEntity value,
          $Res Function(DeliveryRequestEntity) then) =
      _$DeliveryRequestEntityCopyWithImpl<$Res, DeliveryRequestEntity>;
  @useResult
  $Res call(
      {String id,
      String consumerId,
      String consumerName,
      String consumerPhone,
      OrderAddress pickup,
      OrderAddress dropoff,
      String packageNote,
      double? price,
      DeliveryRequestStatus status,
      String? courierId,
      String? cancelReason,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? pricedAt,
      DateTime? confirmedAt,
      DateTime? pickedUpAt,
      DateTime? deliveredAt});

  $OrderAddressCopyWith<$Res> get pickup;
  $OrderAddressCopyWith<$Res> get dropoff;
}

/// @nodoc
class _$DeliveryRequestEntityCopyWithImpl<$Res,
        $Val extends DeliveryRequestEntity>
    implements $DeliveryRequestEntityCopyWith<$Res> {
  _$DeliveryRequestEntityCopyWithImpl(this._value, this._then);

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
    Object? pickup = null,
    Object? dropoff = null,
    Object? packageNote = null,
    Object? price = freezed,
    Object? status = null,
    Object? courierId = freezed,
    Object? cancelReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? pricedAt = freezed,
    Object? confirmedAt = freezed,
    Object? pickedUpAt = freezed,
    Object? deliveredAt = freezed,
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
      pickup: null == pickup
          ? _value.pickup
          : pickup // ignore: cast_nullable_to_non_nullable
              as OrderAddress,
      dropoff: null == dropoff
          ? _value.dropoff
          : dropoff // ignore: cast_nullable_to_non_nullable
              as OrderAddress,
      packageNote: null == packageNote
          ? _value.packageNote
          : packageNote // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DeliveryRequestStatus,
      courierId: freezed == courierId
          ? _value.courierId
          : courierId // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pricedAt: freezed == pricedAt
          ? _value.pricedAt
          : pricedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pickedUpAt: freezed == pickedUpAt
          ? _value.pickedUpAt
          : pickedUpAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $OrderAddressCopyWith<$Res> get pickup {
    return $OrderAddressCopyWith<$Res>(_value.pickup, (value) {
      return _then(_value.copyWith(pickup: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $OrderAddressCopyWith<$Res> get dropoff {
    return $OrderAddressCopyWith<$Res>(_value.dropoff, (value) {
      return _then(_value.copyWith(dropoff: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeliveryRequestEntityImplCopyWith<$Res>
    implements $DeliveryRequestEntityCopyWith<$Res> {
  factory _$$DeliveryRequestEntityImplCopyWith(
          _$DeliveryRequestEntityImpl value,
          $Res Function(_$DeliveryRequestEntityImpl) then) =
      __$$DeliveryRequestEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String consumerId,
      String consumerName,
      String consumerPhone,
      OrderAddress pickup,
      OrderAddress dropoff,
      String packageNote,
      double? price,
      DeliveryRequestStatus status,
      String? courierId,
      String? cancelReason,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? pricedAt,
      DateTime? confirmedAt,
      DateTime? pickedUpAt,
      DateTime? deliveredAt});

  @override
  $OrderAddressCopyWith<$Res> get pickup;
  @override
  $OrderAddressCopyWith<$Res> get dropoff;
}

/// @nodoc
class __$$DeliveryRequestEntityImplCopyWithImpl<$Res>
    extends _$DeliveryRequestEntityCopyWithImpl<$Res,
        _$DeliveryRequestEntityImpl>
    implements _$$DeliveryRequestEntityImplCopyWith<$Res> {
  __$$DeliveryRequestEntityImplCopyWithImpl(_$DeliveryRequestEntityImpl _value,
      $Res Function(_$DeliveryRequestEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consumerId = null,
    Object? consumerName = null,
    Object? consumerPhone = null,
    Object? pickup = null,
    Object? dropoff = null,
    Object? packageNote = null,
    Object? price = freezed,
    Object? status = null,
    Object? courierId = freezed,
    Object? cancelReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? pricedAt = freezed,
    Object? confirmedAt = freezed,
    Object? pickedUpAt = freezed,
    Object? deliveredAt = freezed,
  }) {
    return _then(_$DeliveryRequestEntityImpl(
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
      pickup: null == pickup
          ? _value.pickup
          : pickup // ignore: cast_nullable_to_non_nullable
              as OrderAddress,
      dropoff: null == dropoff
          ? _value.dropoff
          : dropoff // ignore: cast_nullable_to_non_nullable
              as OrderAddress,
      packageNote: null == packageNote
          ? _value.packageNote
          : packageNote // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DeliveryRequestStatus,
      courierId: freezed == courierId
          ? _value.courierId
          : courierId // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pricedAt: freezed == pricedAt
          ? _value.pricedAt
          : pricedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pickedUpAt: freezed == pickedUpAt
          ? _value.pickedUpAt
          : pickedUpAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$DeliveryRequestEntityImpl implements _DeliveryRequestEntity {
  const _$DeliveryRequestEntityImpl(
      {required this.id,
      required this.consumerId,
      required this.consumerName,
      required this.consumerPhone,
      required this.pickup,
      required this.dropoff,
      required this.packageNote,
      this.price,
      required this.status,
      this.courierId,
      this.cancelReason,
      required this.createdAt,
      required this.updatedAt,
      this.pricedAt,
      this.confirmedAt,
      this.pickedUpAt,
      this.deliveredAt});

  @override
  final String id;
  @override
  final String consumerId;
  @override
  final String consumerName;
  @override
  final String consumerPhone;
  @override
  final OrderAddress pickup;
  @override
  final OrderAddress dropoff;
  @override
  final String packageNote;

  /// Null until the admin prices the request.
  @override
  final double? price;
  @override
  final DeliveryRequestStatus status;

  /// Assigned on confirmation (pilot: manual admin assignment).
  @override
  final String? courierId;
  @override
  final String? cancelReason;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? pricedAt;
  @override
  final DateTime? confirmedAt;
  @override
  final DateTime? pickedUpAt;
  @override
  final DateTime? deliveredAt;

  @override
  String toString() {
    return 'DeliveryRequestEntity(id: $id, consumerId: $consumerId, consumerName: $consumerName, consumerPhone: $consumerPhone, pickup: $pickup, dropoff: $dropoff, packageNote: $packageNote, price: $price, status: $status, courierId: $courierId, cancelReason: $cancelReason, createdAt: $createdAt, updatedAt: $updatedAt, pricedAt: $pricedAt, confirmedAt: $confirmedAt, pickedUpAt: $pickedUpAt, deliveredAt: $deliveredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryRequestEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.consumerId, consumerId) ||
                other.consumerId == consumerId) &&
            (identical(other.consumerName, consumerName) ||
                other.consumerName == consumerName) &&
            (identical(other.consumerPhone, consumerPhone) ||
                other.consumerPhone == consumerPhone) &&
            (identical(other.pickup, pickup) || other.pickup == pickup) &&
            (identical(other.dropoff, dropoff) || other.dropoff == dropoff) &&
            (identical(other.packageNote, packageNote) ||
                other.packageNote == packageNote) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.courierId, courierId) ||
                other.courierId == courierId) &&
            (identical(other.cancelReason, cancelReason) ||
                other.cancelReason == cancelReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.pricedAt, pricedAt) ||
                other.pricedAt == pricedAt) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.pickedUpAt, pickedUpAt) ||
                other.pickedUpAt == pickedUpAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      consumerId,
      consumerName,
      consumerPhone,
      pickup,
      dropoff,
      packageNote,
      price,
      status,
      courierId,
      cancelReason,
      createdAt,
      updatedAt,
      pricedAt,
      confirmedAt,
      pickedUpAt,
      deliveredAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryRequestEntityImplCopyWith<_$DeliveryRequestEntityImpl>
      get copyWith => __$$DeliveryRequestEntityImplCopyWithImpl<
          _$DeliveryRequestEntityImpl>(this, _$identity);
}

abstract class _DeliveryRequestEntity implements DeliveryRequestEntity {
  const factory _DeliveryRequestEntity(
      {required final String id,
      required final String consumerId,
      required final String consumerName,
      required final String consumerPhone,
      required final OrderAddress pickup,
      required final OrderAddress dropoff,
      required final String packageNote,
      final double? price,
      required final DeliveryRequestStatus status,
      final String? courierId,
      final String? cancelReason,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? pricedAt,
      final DateTime? confirmedAt,
      final DateTime? pickedUpAt,
      final DateTime? deliveredAt}) = _$DeliveryRequestEntityImpl;

  @override
  String get id;
  @override
  String get consumerId;
  @override
  String get consumerName;
  @override
  String get consumerPhone;
  @override
  OrderAddress get pickup;
  @override
  OrderAddress get dropoff;
  @override
  String get packageNote;
  @override

  /// Null until the admin prices the request.
  double? get price;
  @override
  DeliveryRequestStatus get status;
  @override

  /// Assigned on confirmation (pilot: manual admin assignment).
  String? get courierId;
  @override
  String? get cancelReason;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get pricedAt;
  @override
  DateTime? get confirmedAt;
  @override
  DateTime? get pickedUpAt;
  @override
  DateTime? get deliveredAt;
  @override
  @JsonKey(ignore: true)
  _$$DeliveryRequestEntityImplCopyWith<_$DeliveryRequestEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
