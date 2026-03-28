// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_order_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlaceOrderParams {
  String get consumerId => throw _privateConstructorUsedError;
  List<CartItemEntity> get items => throw _privateConstructorUsedError;
  OrderAddress get deliveryAddress => throw _privateConstructorUsedError;
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  String? get deliveryNote => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get shippingTotal => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  String? get cardNumber => throw _privateConstructorUsedError;
  String? get cardExpiry => throw _privateConstructorUsedError;
  String? get cardCvv => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PlaceOrderParamsCopyWith<PlaceOrderParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceOrderParamsCopyWith<$Res> {
  factory $PlaceOrderParamsCopyWith(
          PlaceOrderParams value, $Res Function(PlaceOrderParams) then) =
      _$PlaceOrderParamsCopyWithImpl<$Res, PlaceOrderParams>;
  @useResult
  $Res call(
      {String consumerId,
      List<CartItemEntity> items,
      OrderAddress deliveryAddress,
      PaymentMethod paymentMethod,
      String? deliveryNote,
      double subtotal,
      double shippingTotal,
      double discount,
      double total,
      String? cardNumber,
      String? cardExpiry,
      String? cardCvv});

  $OrderAddressCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class _$PlaceOrderParamsCopyWithImpl<$Res, $Val extends PlaceOrderParams>
    implements $PlaceOrderParamsCopyWith<$Res> {
  _$PlaceOrderParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consumerId = null,
    Object? items = null,
    Object? deliveryAddress = null,
    Object? paymentMethod = null,
    Object? deliveryNote = freezed,
    Object? subtotal = null,
    Object? shippingTotal = null,
    Object? discount = null,
    Object? total = null,
    Object? cardNumber = freezed,
    Object? cardExpiry = freezed,
    Object? cardCvv = freezed,
  }) {
    return _then(_value.copyWith(
      consumerId: null == consumerId
          ? _value.consumerId
          : consumerId // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemEntity>,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as OrderAddress,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      deliveryNote: freezed == deliveryNote
          ? _value.deliveryNote
          : deliveryNote // ignore: cast_nullable_to_non_nullable
              as String?,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      shippingTotal: null == shippingTotal
          ? _value.shippingTotal
          : shippingTotal // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      cardNumber: freezed == cardNumber
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      cardExpiry: freezed == cardExpiry
          ? _value.cardExpiry
          : cardExpiry // ignore: cast_nullable_to_non_nullable
              as String?,
      cardCvv: freezed == cardCvv
          ? _value.cardCvv
          : cardCvv // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $OrderAddressCopyWith<$Res> get deliveryAddress {
    return $OrderAddressCopyWith<$Res>(_value.deliveryAddress, (value) {
      return _then(_value.copyWith(deliveryAddress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlaceOrderParamsImplCopyWith<$Res>
    implements $PlaceOrderParamsCopyWith<$Res> {
  factory _$$PlaceOrderParamsImplCopyWith(_$PlaceOrderParamsImpl value,
          $Res Function(_$PlaceOrderParamsImpl) then) =
      __$$PlaceOrderParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String consumerId,
      List<CartItemEntity> items,
      OrderAddress deliveryAddress,
      PaymentMethod paymentMethod,
      String? deliveryNote,
      double subtotal,
      double shippingTotal,
      double discount,
      double total,
      String? cardNumber,
      String? cardExpiry,
      String? cardCvv});

  @override
  $OrderAddressCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class __$$PlaceOrderParamsImplCopyWithImpl<$Res>
    extends _$PlaceOrderParamsCopyWithImpl<$Res, _$PlaceOrderParamsImpl>
    implements _$$PlaceOrderParamsImplCopyWith<$Res> {
  __$$PlaceOrderParamsImplCopyWithImpl(_$PlaceOrderParamsImpl _value,
      $Res Function(_$PlaceOrderParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consumerId = null,
    Object? items = null,
    Object? deliveryAddress = null,
    Object? paymentMethod = null,
    Object? deliveryNote = freezed,
    Object? subtotal = null,
    Object? shippingTotal = null,
    Object? discount = null,
    Object? total = null,
    Object? cardNumber = freezed,
    Object? cardExpiry = freezed,
    Object? cardCvv = freezed,
  }) {
    return _then(_$PlaceOrderParamsImpl(
      consumerId: null == consumerId
          ? _value.consumerId
          : consumerId // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemEntity>,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as OrderAddress,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      deliveryNote: freezed == deliveryNote
          ? _value.deliveryNote
          : deliveryNote // ignore: cast_nullable_to_non_nullable
              as String?,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      shippingTotal: null == shippingTotal
          ? _value.shippingTotal
          : shippingTotal // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      cardNumber: freezed == cardNumber
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      cardExpiry: freezed == cardExpiry
          ? _value.cardExpiry
          : cardExpiry // ignore: cast_nullable_to_non_nullable
              as String?,
      cardCvv: freezed == cardCvv
          ? _value.cardCvv
          : cardCvv // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PlaceOrderParamsImpl implements _PlaceOrderParams {
  const _$PlaceOrderParamsImpl(
      {required this.consumerId,
      required final List<CartItemEntity> items,
      required this.deliveryAddress,
      required this.paymentMethod,
      this.deliveryNote,
      required this.subtotal,
      required this.shippingTotal,
      required this.discount,
      required this.total,
      this.cardNumber,
      this.cardExpiry,
      this.cardCvv})
      : _items = items;

  @override
  final String consumerId;
  final List<CartItemEntity> _items;
  @override
  List<CartItemEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final OrderAddress deliveryAddress;
  @override
  final PaymentMethod paymentMethod;
  @override
  final String? deliveryNote;
  @override
  final double subtotal;
  @override
  final double shippingTotal;
  @override
  final double discount;
  @override
  final double total;
  @override
  final String? cardNumber;
  @override
  final String? cardExpiry;
  @override
  final String? cardCvv;

  @override
  String toString() {
    return 'PlaceOrderParams(consumerId: $consumerId, items: $items, deliveryAddress: $deliveryAddress, paymentMethod: $paymentMethod, deliveryNote: $deliveryNote, subtotal: $subtotal, shippingTotal: $shippingTotal, discount: $discount, total: $total, cardNumber: $cardNumber, cardExpiry: $cardExpiry, cardCvv: $cardCvv)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceOrderParamsImpl &&
            (identical(other.consumerId, consumerId) ||
                other.consumerId == consumerId) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.deliveryNote, deliveryNote) ||
                other.deliveryNote == deliveryNote) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.shippingTotal, shippingTotal) ||
                other.shippingTotal == shippingTotal) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.cardNumber, cardNumber) ||
                other.cardNumber == cardNumber) &&
            (identical(other.cardExpiry, cardExpiry) ||
                other.cardExpiry == cardExpiry) &&
            (identical(other.cardCvv, cardCvv) || other.cardCvv == cardCvv));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      consumerId,
      const DeepCollectionEquality().hash(_items),
      deliveryAddress,
      paymentMethod,
      deliveryNote,
      subtotal,
      shippingTotal,
      discount,
      total,
      cardNumber,
      cardExpiry,
      cardCvv);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceOrderParamsImplCopyWith<_$PlaceOrderParamsImpl> get copyWith =>
      __$$PlaceOrderParamsImplCopyWithImpl<_$PlaceOrderParamsImpl>(
          this, _$identity);
}

abstract class _PlaceOrderParams implements PlaceOrderParams {
  const factory _PlaceOrderParams(
      {required final String consumerId,
      required final List<CartItemEntity> items,
      required final OrderAddress deliveryAddress,
      required final PaymentMethod paymentMethod,
      final String? deliveryNote,
      required final double subtotal,
      required final double shippingTotal,
      required final double discount,
      required final double total,
      final String? cardNumber,
      final String? cardExpiry,
      final String? cardCvv}) = _$PlaceOrderParamsImpl;

  @override
  String get consumerId;
  @override
  List<CartItemEntity> get items;
  @override
  OrderAddress get deliveryAddress;
  @override
  PaymentMethod get paymentMethod;
  @override
  String? get deliveryNote;
  @override
  double get subtotal;
  @override
  double get shippingTotal;
  @override
  double get discount;
  @override
  double get total;
  @override
  String? get cardNumber;
  @override
  String? get cardExpiry;
  @override
  String? get cardCvv;
  @override
  @JsonKey(ignore: true)
  _$$PlaceOrderParamsImplCopyWith<_$PlaceOrderParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
