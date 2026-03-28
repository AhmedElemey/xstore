// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CheckoutState {
  int get currentStep => throw _privateConstructorUsedError;
  List<OrderAddress> get savedAddresses => throw _privateConstructorUsedError;
  int? get selectedAddressIndex => throw _privateConstructorUsedError;
  PaymentMethod? get selectedPayment => throw _privateConstructorUsedError;
  String get deliveryNote => throw _privateConstructorUsedError;
  String get cardNumber => throw _privateConstructorUsedError;
  String get cardExpiry => throw _privateConstructorUsedError;
  String get cardCvv => throw _privateConstructorUsedError;
  bool get isPlacingOrder => throw _privateConstructorUsedError;
  String? get placedOrderId => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CheckoutStateCopyWith<CheckoutState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckoutStateCopyWith<$Res> {
  factory $CheckoutStateCopyWith(
          CheckoutState value, $Res Function(CheckoutState) then) =
      _$CheckoutStateCopyWithImpl<$Res, CheckoutState>;
  @useResult
  $Res call(
      {int currentStep,
      List<OrderAddress> savedAddresses,
      int? selectedAddressIndex,
      PaymentMethod? selectedPayment,
      String deliveryNote,
      String cardNumber,
      String cardExpiry,
      String cardCvv,
      bool isPlacingOrder,
      String? placedOrderId,
      String? error});
}

/// @nodoc
class _$CheckoutStateCopyWithImpl<$Res, $Val extends CheckoutState>
    implements $CheckoutStateCopyWith<$Res> {
  _$CheckoutStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? savedAddresses = null,
    Object? selectedAddressIndex = freezed,
    Object? selectedPayment = freezed,
    Object? deliveryNote = null,
    Object? cardNumber = null,
    Object? cardExpiry = null,
    Object? cardCvv = null,
    Object? isPlacingOrder = null,
    Object? placedOrderId = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      savedAddresses: null == savedAddresses
          ? _value.savedAddresses
          : savedAddresses // ignore: cast_nullable_to_non_nullable
              as List<OrderAddress>,
      selectedAddressIndex: freezed == selectedAddressIndex
          ? _value.selectedAddressIndex
          : selectedAddressIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedPayment: freezed == selectedPayment
          ? _value.selectedPayment
          : selectedPayment // ignore: cast_nullable_to_non_nullable
              as PaymentMethod?,
      deliveryNote: null == deliveryNote
          ? _value.deliveryNote
          : deliveryNote // ignore: cast_nullable_to_non_nullable
              as String,
      cardNumber: null == cardNumber
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String,
      cardExpiry: null == cardExpiry
          ? _value.cardExpiry
          : cardExpiry // ignore: cast_nullable_to_non_nullable
              as String,
      cardCvv: null == cardCvv
          ? _value.cardCvv
          : cardCvv // ignore: cast_nullable_to_non_nullable
              as String,
      isPlacingOrder: null == isPlacingOrder
          ? _value.isPlacingOrder
          : isPlacingOrder // ignore: cast_nullable_to_non_nullable
              as bool,
      placedOrderId: freezed == placedOrderId
          ? _value.placedOrderId
          : placedOrderId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckoutStateImplCopyWith<$Res>
    implements $CheckoutStateCopyWith<$Res> {
  factory _$$CheckoutStateImplCopyWith(
          _$CheckoutStateImpl value, $Res Function(_$CheckoutStateImpl) then) =
      __$$CheckoutStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStep,
      List<OrderAddress> savedAddresses,
      int? selectedAddressIndex,
      PaymentMethod? selectedPayment,
      String deliveryNote,
      String cardNumber,
      String cardExpiry,
      String cardCvv,
      bool isPlacingOrder,
      String? placedOrderId,
      String? error});
}

/// @nodoc
class __$$CheckoutStateImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$CheckoutStateImpl>
    implements _$$CheckoutStateImplCopyWith<$Res> {
  __$$CheckoutStateImplCopyWithImpl(
      _$CheckoutStateImpl _value, $Res Function(_$CheckoutStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? savedAddresses = null,
    Object? selectedAddressIndex = freezed,
    Object? selectedPayment = freezed,
    Object? deliveryNote = null,
    Object? cardNumber = null,
    Object? cardExpiry = null,
    Object? cardCvv = null,
    Object? isPlacingOrder = null,
    Object? placedOrderId = freezed,
    Object? error = freezed,
  }) {
    return _then(_$CheckoutStateImpl(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      savedAddresses: null == savedAddresses
          ? _value._savedAddresses
          : savedAddresses // ignore: cast_nullable_to_non_nullable
              as List<OrderAddress>,
      selectedAddressIndex: freezed == selectedAddressIndex
          ? _value.selectedAddressIndex
          : selectedAddressIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedPayment: freezed == selectedPayment
          ? _value.selectedPayment
          : selectedPayment // ignore: cast_nullable_to_non_nullable
              as PaymentMethod?,
      deliveryNote: null == deliveryNote
          ? _value.deliveryNote
          : deliveryNote // ignore: cast_nullable_to_non_nullable
              as String,
      cardNumber: null == cardNumber
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String,
      cardExpiry: null == cardExpiry
          ? _value.cardExpiry
          : cardExpiry // ignore: cast_nullable_to_non_nullable
              as String,
      cardCvv: null == cardCvv
          ? _value.cardCvv
          : cardCvv // ignore: cast_nullable_to_non_nullable
              as String,
      isPlacingOrder: null == isPlacingOrder
          ? _value.isPlacingOrder
          : isPlacingOrder // ignore: cast_nullable_to_non_nullable
              as bool,
      placedOrderId: freezed == placedOrderId
          ? _value.placedOrderId
          : placedOrderId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CheckoutStateImpl implements _CheckoutState {
  const _$CheckoutStateImpl(
      {this.currentStep = 1,
      final List<OrderAddress> savedAddresses = const <OrderAddress>[],
      this.selectedAddressIndex,
      this.selectedPayment,
      this.deliveryNote = '',
      this.cardNumber = '',
      this.cardExpiry = '',
      this.cardCvv = '',
      this.isPlacingOrder = false,
      this.placedOrderId,
      this.error})
      : _savedAddresses = savedAddresses;

  @override
  @JsonKey()
  final int currentStep;
  final List<OrderAddress> _savedAddresses;
  @override
  @JsonKey()
  List<OrderAddress> get savedAddresses {
    if (_savedAddresses is EqualUnmodifiableListView) return _savedAddresses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_savedAddresses);
  }

  @override
  final int? selectedAddressIndex;
  @override
  final PaymentMethod? selectedPayment;
  @override
  @JsonKey()
  final String deliveryNote;
  @override
  @JsonKey()
  final String cardNumber;
  @override
  @JsonKey()
  final String cardExpiry;
  @override
  @JsonKey()
  final String cardCvv;
  @override
  @JsonKey()
  final bool isPlacingOrder;
  @override
  final String? placedOrderId;
  @override
  final String? error;

  @override
  String toString() {
    return 'CheckoutState(currentStep: $currentStep, savedAddresses: $savedAddresses, selectedAddressIndex: $selectedAddressIndex, selectedPayment: $selectedPayment, deliveryNote: $deliveryNote, cardNumber: $cardNumber, cardExpiry: $cardExpiry, cardCvv: $cardCvv, isPlacingOrder: $isPlacingOrder, placedOrderId: $placedOrderId, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckoutStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            const DeepCollectionEquality()
                .equals(other._savedAddresses, _savedAddresses) &&
            (identical(other.selectedAddressIndex, selectedAddressIndex) ||
                other.selectedAddressIndex == selectedAddressIndex) &&
            (identical(other.selectedPayment, selectedPayment) ||
                other.selectedPayment == selectedPayment) &&
            (identical(other.deliveryNote, deliveryNote) ||
                other.deliveryNote == deliveryNote) &&
            (identical(other.cardNumber, cardNumber) ||
                other.cardNumber == cardNumber) &&
            (identical(other.cardExpiry, cardExpiry) ||
                other.cardExpiry == cardExpiry) &&
            (identical(other.cardCvv, cardCvv) || other.cardCvv == cardCvv) &&
            (identical(other.isPlacingOrder, isPlacingOrder) ||
                other.isPlacingOrder == isPlacingOrder) &&
            (identical(other.placedOrderId, placedOrderId) ||
                other.placedOrderId == placedOrderId) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStep,
      const DeepCollectionEquality().hash(_savedAddresses),
      selectedAddressIndex,
      selectedPayment,
      deliveryNote,
      cardNumber,
      cardExpiry,
      cardCvv,
      isPlacingOrder,
      placedOrderId,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckoutStateImplCopyWith<_$CheckoutStateImpl> get copyWith =>
      __$$CheckoutStateImplCopyWithImpl<_$CheckoutStateImpl>(this, _$identity);
}

abstract class _CheckoutState implements CheckoutState {
  const factory _CheckoutState(
      {final int currentStep,
      final List<OrderAddress> savedAddresses,
      final int? selectedAddressIndex,
      final PaymentMethod? selectedPayment,
      final String deliveryNote,
      final String cardNumber,
      final String cardExpiry,
      final String cardCvv,
      final bool isPlacingOrder,
      final String? placedOrderId,
      final String? error}) = _$CheckoutStateImpl;

  @override
  int get currentStep;
  @override
  List<OrderAddress> get savedAddresses;
  @override
  int? get selectedAddressIndex;
  @override
  PaymentMethod? get selectedPayment;
  @override
  String get deliveryNote;
  @override
  String get cardNumber;
  @override
  String get cardExpiry;
  @override
  String get cardCvv;
  @override
  bool get isPlacingOrder;
  @override
  String? get placedOrderId;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$CheckoutStateImplCopyWith<_$CheckoutStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
