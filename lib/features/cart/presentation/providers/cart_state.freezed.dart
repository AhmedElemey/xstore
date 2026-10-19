// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CartState {
  List<CartItemEntity> get items => throw _privateConstructorUsedError;
  Set<String> get selectedItemIds => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isUpdating => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String get consumerId => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get shippingTotal => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  CartItemEntity? get lastRemovedItem => throw _privateConstructorUsedError;
  int? get lastRemovedIndex => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CartStateCopyWith<CartState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartStateCopyWith<$Res> {
  factory $CartStateCopyWith(CartState value, $Res Function(CartState) then) =
      _$CartStateCopyWithImpl<$Res, CartState>;
  @useResult
  $Res call(
      {List<CartItemEntity> items,
      Set<String> selectedItemIds,
      bool isLoading,
      bool isUpdating,
      String? error,
      String consumerId,
      double subtotal,
      double shippingTotal,
      double total,
      CartItemEntity? lastRemovedItem,
      int? lastRemovedIndex});

  $CartItemEntityCopyWith<$Res>? get lastRemovedItem;
}

/// @nodoc
class _$CartStateCopyWithImpl<$Res, $Val extends CartState>
    implements $CartStateCopyWith<$Res> {
  _$CartStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? selectedItemIds = null,
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
    Object? consumerId = null,
    Object? subtotal = null,
    Object? shippingTotal = null,
    Object? total = null,
    Object? lastRemovedItem = freezed,
    Object? lastRemovedIndex = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemEntity>,
      selectedItemIds: null == selectedItemIds
          ? _value.selectedItemIds
          : selectedItemIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      consumerId: null == consumerId
          ? _value.consumerId
          : consumerId // ignore: cast_nullable_to_non_nullable
              as String,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      shippingTotal: null == shippingTotal
          ? _value.shippingTotal
          : shippingTotal // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      lastRemovedItem: freezed == lastRemovedItem
          ? _value.lastRemovedItem
          : lastRemovedItem // ignore: cast_nullable_to_non_nullable
              as CartItemEntity?,
      lastRemovedIndex: freezed == lastRemovedIndex
          ? _value.lastRemovedIndex
          : lastRemovedIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CartItemEntityCopyWith<$Res>? get lastRemovedItem {
    if (_value.lastRemovedItem == null) {
      return null;
    }

    return $CartItemEntityCopyWith<$Res>(_value.lastRemovedItem!, (value) {
      return _then(_value.copyWith(lastRemovedItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartStateImplCopyWith<$Res>
    implements $CartStateCopyWith<$Res> {
  factory _$$CartStateImplCopyWith(
          _$CartStateImpl value, $Res Function(_$CartStateImpl) then) =
      __$$CartStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CartItemEntity> items,
      Set<String> selectedItemIds,
      bool isLoading,
      bool isUpdating,
      String? error,
      String consumerId,
      double subtotal,
      double shippingTotal,
      double total,
      CartItemEntity? lastRemovedItem,
      int? lastRemovedIndex});

  @override
  $CartItemEntityCopyWith<$Res>? get lastRemovedItem;
}

/// @nodoc
class __$$CartStateImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$CartStateImpl>
    implements _$$CartStateImplCopyWith<$Res> {
  __$$CartStateImplCopyWithImpl(
      _$CartStateImpl _value, $Res Function(_$CartStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? selectedItemIds = null,
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
    Object? consumerId = null,
    Object? subtotal = null,
    Object? shippingTotal = null,
    Object? total = null,
    Object? lastRemovedItem = freezed,
    Object? lastRemovedIndex = freezed,
  }) {
    return _then(_$CartStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemEntity>,
      selectedItemIds: null == selectedItemIds
          ? _value._selectedItemIds
          : selectedItemIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      consumerId: null == consumerId
          ? _value.consumerId
          : consumerId // ignore: cast_nullable_to_non_nullable
              as String,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      shippingTotal: null == shippingTotal
          ? _value.shippingTotal
          : shippingTotal // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      lastRemovedItem: freezed == lastRemovedItem
          ? _value.lastRemovedItem
          : lastRemovedItem // ignore: cast_nullable_to_non_nullable
              as CartItemEntity?,
      lastRemovedIndex: freezed == lastRemovedIndex
          ? _value.lastRemovedIndex
          : lastRemovedIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$CartStateImpl implements _CartState {
  const _$CartStateImpl(
      {final List<CartItemEntity> items = const [],
      final Set<String> selectedItemIds = const {},
      this.isLoading = false,
      this.isUpdating = false,
      this.error,
      this.consumerId = '',
      this.subtotal = 0.0,
      this.shippingTotal = 0.0,
      this.total = 0.0,
      this.lastRemovedItem,
      this.lastRemovedIndex})
      : _items = items,
        _selectedItemIds = selectedItemIds;

  final List<CartItemEntity> _items;
  @override
  @JsonKey()
  List<CartItemEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final Set<String> _selectedItemIds;
  @override
  @JsonKey()
  Set<String> get selectedItemIds {
    if (_selectedItemIds is EqualUnmodifiableSetView) return _selectedItemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedItemIds);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  final String? error;
  @override
  @JsonKey()
  final String consumerId;
  @override
  @JsonKey()
  final double subtotal;
  @override
  @JsonKey()
  final double shippingTotal;
  @override
  @JsonKey()
  final double total;
  @override
  final CartItemEntity? lastRemovedItem;
  @override
  final int? lastRemovedIndex;

  @override
  String toString() {
    return 'CartState(items: $items, selectedItemIds: $selectedItemIds, isLoading: $isLoading, isUpdating: $isUpdating, error: $error, consumerId: $consumerId, subtotal: $subtotal, shippingTotal: $shippingTotal, total: $total, lastRemovedItem: $lastRemovedItem, lastRemovedIndex: $lastRemovedIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality()
                .equals(other._selectedItemIds, _selectedItemIds) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.consumerId, consumerId) ||
                other.consumerId == consumerId) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.shippingTotal, shippingTotal) ||
                other.shippingTotal == shippingTotal) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.lastRemovedItem, lastRemovedItem) ||
                other.lastRemovedItem == lastRemovedItem) &&
            (identical(other.lastRemovedIndex, lastRemovedIndex) ||
                other.lastRemovedIndex == lastRemovedIndex));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_selectedItemIds),
      isLoading,
      isUpdating,
      error,
      consumerId,
      subtotal,
      shippingTotal,
      total,
      lastRemovedItem,
      lastRemovedIndex);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CartStateImplCopyWith<_$CartStateImpl> get copyWith =>
      __$$CartStateImplCopyWithImpl<_$CartStateImpl>(this, _$identity);
}

abstract class _CartState implements CartState {
  const factory _CartState(
      {final List<CartItemEntity> items,
      final Set<String> selectedItemIds,
      final bool isLoading,
      final bool isUpdating,
      final String? error,
      final String consumerId,
      final double subtotal,
      final double shippingTotal,
      final double total,
      final CartItemEntity? lastRemovedItem,
      final int? lastRemovedIndex}) = _$CartStateImpl;

  @override
  List<CartItemEntity> get items;
  @override
  Set<String> get selectedItemIds;
  @override
  bool get isLoading;
  @override
  bool get isUpdating;
  @override
  String? get error;
  @override
  String get consumerId;
  @override
  double get subtotal;
  @override
  double get shippingTotal;
  @override
  double get total;
  @override
  CartItemEntity? get lastRemovedItem;
  @override
  int? get lastRemovedIndex;
  @override
  @JsonKey(ignore: true)
  _$$CartStateImplCopyWith<_$CartStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
