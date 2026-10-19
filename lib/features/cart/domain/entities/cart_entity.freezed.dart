// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CartVendorGroup {
  String get vendorId => throw _privateConstructorUsedError;
  String get vendorName => throw _privateConstructorUsedError;
  String get vendorStoreName => throw _privateConstructorUsedError;
  String get vendorAvatar => throw _privateConstructorUsedError;
  double? get vendorRating => throw _privateConstructorUsedError;
  bool get vendorVerified => throw _privateConstructorUsedError;
  List<CartItemEntity> get items => throw _privateConstructorUsedError;
  double get groupSubtotal => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CartVendorGroupCopyWith<CartVendorGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartVendorGroupCopyWith<$Res> {
  factory $CartVendorGroupCopyWith(
          CartVendorGroup value, $Res Function(CartVendorGroup) then) =
      _$CartVendorGroupCopyWithImpl<$Res, CartVendorGroup>;
  @useResult
  $Res call(
      {String vendorId,
      String vendorName,
      String vendorStoreName,
      String vendorAvatar,
      double? vendorRating,
      bool vendorVerified,
      List<CartItemEntity> items,
      double groupSubtotal});
}

/// @nodoc
class _$CartVendorGroupCopyWithImpl<$Res, $Val extends CartVendorGroup>
    implements $CartVendorGroupCopyWith<$Res> {
  _$CartVendorGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? vendorName = null,
    Object? vendorStoreName = null,
    Object? vendorAvatar = null,
    Object? vendorRating = freezed,
    Object? vendorVerified = null,
    Object? items = null,
    Object? groupSubtotal = null,
  }) {
    return _then(_value.copyWith(
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
      vendorRating: freezed == vendorRating
          ? _value.vendorRating
          : vendorRating // ignore: cast_nullable_to_non_nullable
              as double?,
      vendorVerified: null == vendorVerified
          ? _value.vendorVerified
          : vendorVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemEntity>,
      groupSubtotal: null == groupSubtotal
          ? _value.groupSubtotal
          : groupSubtotal // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartVendorGroupImplCopyWith<$Res>
    implements $CartVendorGroupCopyWith<$Res> {
  factory _$$CartVendorGroupImplCopyWith(_$CartVendorGroupImpl value,
          $Res Function(_$CartVendorGroupImpl) then) =
      __$$CartVendorGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String vendorId,
      String vendorName,
      String vendorStoreName,
      String vendorAvatar,
      double? vendorRating,
      bool vendorVerified,
      List<CartItemEntity> items,
      double groupSubtotal});
}

/// @nodoc
class __$$CartVendorGroupImplCopyWithImpl<$Res>
    extends _$CartVendorGroupCopyWithImpl<$Res, _$CartVendorGroupImpl>
    implements _$$CartVendorGroupImplCopyWith<$Res> {
  __$$CartVendorGroupImplCopyWithImpl(
      _$CartVendorGroupImpl _value, $Res Function(_$CartVendorGroupImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? vendorName = null,
    Object? vendorStoreName = null,
    Object? vendorAvatar = null,
    Object? vendorRating = freezed,
    Object? vendorVerified = null,
    Object? items = null,
    Object? groupSubtotal = null,
  }) {
    return _then(_$CartVendorGroupImpl(
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
      vendorRating: freezed == vendorRating
          ? _value.vendorRating
          : vendorRating // ignore: cast_nullable_to_non_nullable
              as double?,
      vendorVerified: null == vendorVerified
          ? _value.vendorVerified
          : vendorVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemEntity>,
      groupSubtotal: null == groupSubtotal
          ? _value.groupSubtotal
          : groupSubtotal // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$CartVendorGroupImpl implements _CartVendorGroup {
  const _$CartVendorGroupImpl(
      {required this.vendorId,
      required this.vendorName,
      required this.vendorStoreName,
      required this.vendorAvatar,
      this.vendorRating,
      this.vendorVerified = true,
      required final List<CartItemEntity> items,
      this.groupSubtotal = 0.0})
      : _items = items;

  @override
  final String vendorId;
  @override
  final String vendorName;
  @override
  final String vendorStoreName;
  @override
  final String vendorAvatar;
  @override
  final double? vendorRating;
  @override
  @JsonKey()
  final bool vendorVerified;
  final List<CartItemEntity> _items;
  @override
  List<CartItemEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final double groupSubtotal;

  @override
  String toString() {
    return 'CartVendorGroup(vendorId: $vendorId, vendorName: $vendorName, vendorStoreName: $vendorStoreName, vendorAvatar: $vendorAvatar, vendorRating: $vendorRating, vendorVerified: $vendorVerified, items: $items, groupSubtotal: $groupSubtotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartVendorGroupImpl &&
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
            (identical(other.vendorVerified, vendorVerified) ||
                other.vendorVerified == vendorVerified) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.groupSubtotal, groupSubtotal) ||
                other.groupSubtotal == groupSubtotal));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      vendorId,
      vendorName,
      vendorStoreName,
      vendorAvatar,
      vendorRating,
      vendorVerified,
      const DeepCollectionEquality().hash(_items),
      groupSubtotal);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CartVendorGroupImplCopyWith<_$CartVendorGroupImpl> get copyWith =>
      __$$CartVendorGroupImplCopyWithImpl<_$CartVendorGroupImpl>(
          this, _$identity);
}

abstract class _CartVendorGroup implements CartVendorGroup {
  const factory _CartVendorGroup(
      {required final String vendorId,
      required final String vendorName,
      required final String vendorStoreName,
      required final String vendorAvatar,
      final double? vendorRating,
      final bool vendorVerified,
      required final List<CartItemEntity> items,
      final double groupSubtotal}) = _$CartVendorGroupImpl;

  @override
  String get vendorId;
  @override
  String get vendorName;
  @override
  String get vendorStoreName;
  @override
  String get vendorAvatar;
  @override
  double? get vendorRating;
  @override
  bool get vendorVerified;
  @override
  List<CartItemEntity> get items;
  @override
  double get groupSubtotal;
  @override
  @JsonKey(ignore: true)
  _$$CartVendorGroupImplCopyWith<_$CartVendorGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CartEntity {
  String get id => throw _privateConstructorUsedError;
  String get consumerId => throw _privateConstructorUsedError;
  List<CartItemEntity> get items => throw _privateConstructorUsedError;
  Set<String> get selectedItemIds => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get shippingTotal => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  int get itemCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CartEntityCopyWith<CartEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartEntityCopyWith<$Res> {
  factory $CartEntityCopyWith(
          CartEntity value, $Res Function(CartEntity) then) =
      _$CartEntityCopyWithImpl<$Res, CartEntity>;
  @useResult
  $Res call(
      {String id,
      String consumerId,
      List<CartItemEntity> items,
      Set<String> selectedItemIds,
      double subtotal,
      double shippingTotal,
      double total,
      int itemCount});
}

/// @nodoc
class _$CartEntityCopyWithImpl<$Res, $Val extends CartEntity>
    implements $CartEntityCopyWith<$Res> {
  _$CartEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consumerId = null,
    Object? items = null,
    Object? selectedItemIds = null,
    Object? subtotal = null,
    Object? shippingTotal = null,
    Object? total = null,
    Object? itemCount = null,
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
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemEntity>,
      selectedItemIds: null == selectedItemIds
          ? _value.selectedItemIds
          : selectedItemIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
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
      itemCount: null == itemCount
          ? _value.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartEntityImplCopyWith<$Res>
    implements $CartEntityCopyWith<$Res> {
  factory _$$CartEntityImplCopyWith(
          _$CartEntityImpl value, $Res Function(_$CartEntityImpl) then) =
      __$$CartEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String consumerId,
      List<CartItemEntity> items,
      Set<String> selectedItemIds,
      double subtotal,
      double shippingTotal,
      double total,
      int itemCount});
}

/// @nodoc
class __$$CartEntityImplCopyWithImpl<$Res>
    extends _$CartEntityCopyWithImpl<$Res, _$CartEntityImpl>
    implements _$$CartEntityImplCopyWith<$Res> {
  __$$CartEntityImplCopyWithImpl(
      _$CartEntityImpl _value, $Res Function(_$CartEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consumerId = null,
    Object? items = null,
    Object? selectedItemIds = null,
    Object? subtotal = null,
    Object? shippingTotal = null,
    Object? total = null,
    Object? itemCount = null,
  }) {
    return _then(_$CartEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      consumerId: null == consumerId
          ? _value.consumerId
          : consumerId // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemEntity>,
      selectedItemIds: null == selectedItemIds
          ? _value._selectedItemIds
          : selectedItemIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
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
      itemCount: null == itemCount
          ? _value.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$CartEntityImpl implements _CartEntity {
  const _$CartEntityImpl(
      {required this.id,
      required this.consumerId,
      required final List<CartItemEntity> items,
      final Set<String> selectedItemIds = const <String>{},
      this.subtotal = 0.0,
      this.shippingTotal = 0.0,
      this.total = 0.0,
      this.itemCount = 0})
      : _items = items,
        _selectedItemIds = selectedItemIds;

  @override
  final String id;
  @override
  final String consumerId;
  final List<CartItemEntity> _items;
  @override
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
  final double subtotal;
  @override
  @JsonKey()
  final double shippingTotal;
  @override
  @JsonKey()
  final double total;
  @override
  @JsonKey()
  final int itemCount;

  @override
  String toString() {
    return 'CartEntity(id: $id, consumerId: $consumerId, items: $items, selectedItemIds: $selectedItemIds, subtotal: $subtotal, shippingTotal: $shippingTotal, total: $total, itemCount: $itemCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.consumerId, consumerId) ||
                other.consumerId == consumerId) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality()
                .equals(other._selectedItemIds, _selectedItemIds) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.shippingTotal, shippingTotal) ||
                other.shippingTotal == shippingTotal) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      consumerId,
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_selectedItemIds),
      subtotal,
      shippingTotal,
      total,
      itemCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CartEntityImplCopyWith<_$CartEntityImpl> get copyWith =>
      __$$CartEntityImplCopyWithImpl<_$CartEntityImpl>(this, _$identity);
}

abstract class _CartEntity implements CartEntity {
  const factory _CartEntity(
      {required final String id,
      required final String consumerId,
      required final List<CartItemEntity> items,
      final Set<String> selectedItemIds,
      final double subtotal,
      final double shippingTotal,
      final double total,
      final int itemCount}) = _$CartEntityImpl;

  @override
  String get id;
  @override
  String get consumerId;
  @override
  List<CartItemEntity> get items;
  @override
  Set<String> get selectedItemIds;
  @override
  double get subtotal;
  @override
  double get shippingTotal;
  @override
  double get total;
  @override
  int get itemCount;
  @override
  @JsonKey(ignore: true)
  _$$CartEntityImplCopyWith<_$CartEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
