// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_detail_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrderDetailState {
  String get orderId => throw _privateConstructorUsedError;
  OrderEntity? get order => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isActioning => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OrderDetailStateCopyWith<OrderDetailState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderDetailStateCopyWith<$Res> {
  factory $OrderDetailStateCopyWith(
          OrderDetailState value, $Res Function(OrderDetailState) then) =
      _$OrderDetailStateCopyWithImpl<$Res, OrderDetailState>;
  @useResult
  $Res call(
      {String orderId,
      OrderEntity? order,
      bool isLoading,
      bool isActioning,
      String? error});

  $OrderEntityCopyWith<$Res>? get order;
}

/// @nodoc
class _$OrderDetailStateCopyWithImpl<$Res, $Val extends OrderDetailState>
    implements $OrderDetailStateCopyWith<$Res> {
  _$OrderDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? order = freezed,
    Object? isLoading = null,
    Object? isActioning = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as OrderEntity?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isActioning: null == isActioning
          ? _value.isActioning
          : isActioning // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $OrderEntityCopyWith<$Res>? get order {
    if (_value.order == null) {
      return null;
    }

    return $OrderEntityCopyWith<$Res>(_value.order!, (value) {
      return _then(_value.copyWith(order: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderDetailStateImplCopyWith<$Res>
    implements $OrderDetailStateCopyWith<$Res> {
  factory _$$OrderDetailStateImplCopyWith(_$OrderDetailStateImpl value,
          $Res Function(_$OrderDetailStateImpl) then) =
      __$$OrderDetailStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String orderId,
      OrderEntity? order,
      bool isLoading,
      bool isActioning,
      String? error});

  @override
  $OrderEntityCopyWith<$Res>? get order;
}

/// @nodoc
class __$$OrderDetailStateImplCopyWithImpl<$Res>
    extends _$OrderDetailStateCopyWithImpl<$Res, _$OrderDetailStateImpl>
    implements _$$OrderDetailStateImplCopyWith<$Res> {
  __$$OrderDetailStateImplCopyWithImpl(_$OrderDetailStateImpl _value,
      $Res Function(_$OrderDetailStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? order = freezed,
    Object? isLoading = null,
    Object? isActioning = null,
    Object? error = freezed,
  }) {
    return _then(_$OrderDetailStateImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as OrderEntity?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isActioning: null == isActioning
          ? _value.isActioning
          : isActioning // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$OrderDetailStateImpl implements _OrderDetailState {
  const _$OrderDetailStateImpl(
      {required this.orderId,
      this.order,
      this.isLoading = false,
      this.isActioning = false,
      this.error});

  @override
  final String orderId;
  @override
  final OrderEntity? order;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isActioning;
  @override
  final String? error;

  @override
  String toString() {
    return 'OrderDetailState(orderId: $orderId, order: $order, isLoading: $isLoading, isActioning: $isActioning, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderDetailStateImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isActioning, isActioning) ||
                other.isActioning == isActioning) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, orderId, order, isLoading, isActioning, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderDetailStateImplCopyWith<_$OrderDetailStateImpl> get copyWith =>
      __$$OrderDetailStateImplCopyWithImpl<_$OrderDetailStateImpl>(
          this, _$identity);
}

abstract class _OrderDetailState implements OrderDetailState {
  const factory _OrderDetailState(
      {required final String orderId,
      final OrderEntity? order,
      final bool isLoading,
      final bool isActioning,
      final String? error}) = _$OrderDetailStateImpl;

  @override
  String get orderId;
  @override
  OrderEntity? get order;
  @override
  bool get isLoading;
  @override
  bool get isActioning;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$OrderDetailStateImplCopyWith<_$OrderDetailStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
