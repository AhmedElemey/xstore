// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AttributeEntry {
  String get key => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AttributeEntryCopyWith<AttributeEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttributeEntryCopyWith<$Res> {
  factory $AttributeEntryCopyWith(
          AttributeEntry value, $Res Function(AttributeEntry) then) =
      _$AttributeEntryCopyWithImpl<$Res, AttributeEntry>;
  @useResult
  $Res call({String key, String value});
}

/// @nodoc
class _$AttributeEntryCopyWithImpl<$Res, $Val extends AttributeEntry>
    implements $AttributeEntryCopyWith<$Res> {
  _$AttributeEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttributeEntryImplCopyWith<$Res>
    implements $AttributeEntryCopyWith<$Res> {
  factory _$$AttributeEntryImplCopyWith(_$AttributeEntryImpl value,
          $Res Function(_$AttributeEntryImpl) then) =
      __$$AttributeEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String value});
}

/// @nodoc
class __$$AttributeEntryImplCopyWithImpl<$Res>
    extends _$AttributeEntryCopyWithImpl<$Res, _$AttributeEntryImpl>
    implements _$$AttributeEntryImplCopyWith<$Res> {
  __$$AttributeEntryImplCopyWithImpl(
      _$AttributeEntryImpl _value, $Res Function(_$AttributeEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_$AttributeEntryImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AttributeEntryImpl implements _AttributeEntry {
  const _$AttributeEntryImpl({this.key = '', this.value = ''});

  @override
  @JsonKey()
  final String key;
  @override
  @JsonKey()
  final String value;

  @override
  String toString() {
    return 'AttributeEntry(key: $key, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttributeEntryImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AttributeEntryImplCopyWith<_$AttributeEntryImpl> get copyWith =>
      __$$AttributeEntryImplCopyWithImpl<_$AttributeEntryImpl>(
          this, _$identity);
}

abstract class _AttributeEntry implements AttributeEntry {
  const factory _AttributeEntry({final String key, final String value}) =
      _$AttributeEntryImpl;

  @override
  String get key;
  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$AttributeEntryImplCopyWith<_$AttributeEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ListingFormState {
  /// Persisted image paths (max 5). Use [ListingFormStateSpec.photos] for `List<File>`.
  List<String> get photoPaths => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get priceInput => throw _privateConstructorUsedError;
  String get compareAtPriceInput => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get subcategoryId => throw _privateConstructorUsedError;
  String get condition => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get shippingCostInput => throw _privateConstructorUsedError;
  bool get shippingAvailable => throw _privateConstructorUsedError;
  List<AttributeEntry> get attributes => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  Map<String, String> get errors => throw _privateConstructorUsedError;

  /// Incremented when a draft is loaded from storage (for controller sync).
  int get draftRevision => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ListingFormStateCopyWith<ListingFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingFormStateCopyWith<$Res> {
  factory $ListingFormStateCopyWith(
          ListingFormState value, $Res Function(ListingFormState) then) =
      _$ListingFormStateCopyWithImpl<$Res, ListingFormState>;
  @useResult
  $Res call(
      {List<String> photoPaths,
      String name,
      String priceInput,
      String compareAtPriceInput,
      String description,
      String categoryId,
      String subcategoryId,
      String condition,
      String brand,
      int quantity,
      String location,
      String shippingCostInput,
      bool shippingAvailable,
      List<AttributeEntry> attributes,
      bool isSubmitting,
      Map<String, String> errors,
      int draftRevision});
}

/// @nodoc
class _$ListingFormStateCopyWithImpl<$Res, $Val extends ListingFormState>
    implements $ListingFormStateCopyWith<$Res> {
  _$ListingFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoPaths = null,
    Object? name = null,
    Object? priceInput = null,
    Object? compareAtPriceInput = null,
    Object? description = null,
    Object? categoryId = null,
    Object? subcategoryId = null,
    Object? condition = null,
    Object? brand = null,
    Object? quantity = null,
    Object? location = null,
    Object? shippingCostInput = null,
    Object? shippingAvailable = null,
    Object? attributes = null,
    Object? isSubmitting = null,
    Object? errors = null,
    Object? draftRevision = null,
  }) {
    return _then(_value.copyWith(
      photoPaths: null == photoPaths
          ? _value.photoPaths
          : photoPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      priceInput: null == priceInput
          ? _value.priceInput
          : priceInput // ignore: cast_nullable_to_non_nullable
              as String,
      compareAtPriceInput: null == compareAtPriceInput
          ? _value.compareAtPriceInput
          : compareAtPriceInput // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      subcategoryId: null == subcategoryId
          ? _value.subcategoryId
          : subcategoryId // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      shippingCostInput: null == shippingCostInput
          ? _value.shippingCostInput
          : shippingCostInput // ignore: cast_nullable_to_non_nullable
              as String,
      shippingAvailable: null == shippingAvailable
          ? _value.shippingAvailable
          : shippingAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as List<AttributeEntry>,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      errors: null == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      draftRevision: null == draftRevision
          ? _value.draftRevision
          : draftRevision // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListingFormStateImplCopyWith<$Res>
    implements $ListingFormStateCopyWith<$Res> {
  factory _$$ListingFormStateImplCopyWith(_$ListingFormStateImpl value,
          $Res Function(_$ListingFormStateImpl) then) =
      __$$ListingFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> photoPaths,
      String name,
      String priceInput,
      String compareAtPriceInput,
      String description,
      String categoryId,
      String subcategoryId,
      String condition,
      String brand,
      int quantity,
      String location,
      String shippingCostInput,
      bool shippingAvailable,
      List<AttributeEntry> attributes,
      bool isSubmitting,
      Map<String, String> errors,
      int draftRevision});
}

/// @nodoc
class __$$ListingFormStateImplCopyWithImpl<$Res>
    extends _$ListingFormStateCopyWithImpl<$Res, _$ListingFormStateImpl>
    implements _$$ListingFormStateImplCopyWith<$Res> {
  __$$ListingFormStateImplCopyWithImpl(_$ListingFormStateImpl _value,
      $Res Function(_$ListingFormStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoPaths = null,
    Object? name = null,
    Object? priceInput = null,
    Object? compareAtPriceInput = null,
    Object? description = null,
    Object? categoryId = null,
    Object? subcategoryId = null,
    Object? condition = null,
    Object? brand = null,
    Object? quantity = null,
    Object? location = null,
    Object? shippingCostInput = null,
    Object? shippingAvailable = null,
    Object? attributes = null,
    Object? isSubmitting = null,
    Object? errors = null,
    Object? draftRevision = null,
  }) {
    return _then(_$ListingFormStateImpl(
      photoPaths: null == photoPaths
          ? _value._photoPaths
          : photoPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      priceInput: null == priceInput
          ? _value.priceInput
          : priceInput // ignore: cast_nullable_to_non_nullable
              as String,
      compareAtPriceInput: null == compareAtPriceInput
          ? _value.compareAtPriceInput
          : compareAtPriceInput // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      subcategoryId: null == subcategoryId
          ? _value.subcategoryId
          : subcategoryId // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      shippingCostInput: null == shippingCostInput
          ? _value.shippingCostInput
          : shippingCostInput // ignore: cast_nullable_to_non_nullable
              as String,
      shippingAvailable: null == shippingAvailable
          ? _value.shippingAvailable
          : shippingAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      attributes: null == attributes
          ? _value._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as List<AttributeEntry>,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      errors: null == errors
          ? _value._errors
          : errors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      draftRevision: null == draftRevision
          ? _value.draftRevision
          : draftRevision // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ListingFormStateImpl implements _ListingFormState {
  const _$ListingFormStateImpl(
      {final List<String> photoPaths = const <String>[],
      this.name = '',
      this.priceInput = '',
      this.compareAtPriceInput = '',
      this.description = '',
      this.categoryId = '',
      this.subcategoryId = '',
      this.condition = '',
      this.brand = '',
      this.quantity = 1,
      this.location = '',
      this.shippingCostInput = '',
      this.shippingAvailable = false,
      final List<AttributeEntry> attributes = const <AttributeEntry>[],
      this.isSubmitting = false,
      final Map<String, String> errors = const <String, String>{},
      this.draftRevision = 0})
      : _photoPaths = photoPaths,
        _attributes = attributes,
        _errors = errors;

  /// Persisted image paths (max 5). Use [ListingFormStateSpec.photos] for `List<File>`.
  final List<String> _photoPaths;

  /// Persisted image paths (max 5). Use [ListingFormStateSpec.photos] for `List<File>`.
  @override
  @JsonKey()
  List<String> get photoPaths {
    if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoPaths);
  }

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String priceInput;
  @override
  @JsonKey()
  final String compareAtPriceInput;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String categoryId;
  @override
  @JsonKey()
  final String subcategoryId;
  @override
  @JsonKey()
  final String condition;
  @override
  @JsonKey()
  final String brand;
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final String location;
  @override
  @JsonKey()
  final String shippingCostInput;
  @override
  @JsonKey()
  final bool shippingAvailable;
  final List<AttributeEntry> _attributes;
  @override
  @JsonKey()
  List<AttributeEntry> get attributes {
    if (_attributes is EqualUnmodifiableListView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attributes);
  }

  @override
  @JsonKey()
  final bool isSubmitting;
  final Map<String, String> _errors;
  @override
  @JsonKey()
  Map<String, String> get errors {
    if (_errors is EqualUnmodifiableMapView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_errors);
  }

  /// Incremented when a draft is loaded from storage (for controller sync).
  @override
  @JsonKey()
  final int draftRevision;

  @override
  String toString() {
    return 'ListingFormState(photoPaths: $photoPaths, name: $name, priceInput: $priceInput, compareAtPriceInput: $compareAtPriceInput, description: $description, categoryId: $categoryId, subcategoryId: $subcategoryId, condition: $condition, brand: $brand, quantity: $quantity, location: $location, shippingCostInput: $shippingCostInput, shippingAvailable: $shippingAvailable, attributes: $attributes, isSubmitting: $isSubmitting, errors: $errors, draftRevision: $draftRevision)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingFormStateImpl &&
            const DeepCollectionEquality()
                .equals(other._photoPaths, _photoPaths) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.priceInput, priceInput) ||
                other.priceInput == priceInput) &&
            (identical(other.compareAtPriceInput, compareAtPriceInput) ||
                other.compareAtPriceInput == compareAtPriceInput) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.subcategoryId, subcategoryId) ||
                other.subcategoryId == subcategoryId) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.shippingCostInput, shippingCostInput) ||
                other.shippingCostInput == shippingCostInput) &&
            (identical(other.shippingAvailable, shippingAvailable) ||
                other.shippingAvailable == shippingAvailable) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(other.draftRevision, draftRevision) ||
                other.draftRevision == draftRevision));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_photoPaths),
      name,
      priceInput,
      compareAtPriceInput,
      description,
      categoryId,
      subcategoryId,
      condition,
      brand,
      quantity,
      location,
      shippingCostInput,
      shippingAvailable,
      const DeepCollectionEquality().hash(_attributes),
      isSubmitting,
      const DeepCollectionEquality().hash(_errors),
      draftRevision);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingFormStateImplCopyWith<_$ListingFormStateImpl> get copyWith =>
      __$$ListingFormStateImplCopyWithImpl<_$ListingFormStateImpl>(
          this, _$identity);
}

abstract class _ListingFormState implements ListingFormState {
  const factory _ListingFormState(
      {final List<String> photoPaths,
      final String name,
      final String priceInput,
      final String compareAtPriceInput,
      final String description,
      final String categoryId,
      final String subcategoryId,
      final String condition,
      final String brand,
      final int quantity,
      final String location,
      final String shippingCostInput,
      final bool shippingAvailable,
      final List<AttributeEntry> attributes,
      final bool isSubmitting,
      final Map<String, String> errors,
      final int draftRevision}) = _$ListingFormStateImpl;

  @override

  /// Persisted image paths (max 5). Use [ListingFormStateSpec.photos] for `List<File>`.
  List<String> get photoPaths;
  @override
  String get name;
  @override
  String get priceInput;
  @override
  String get compareAtPriceInput;
  @override
  String get description;
  @override
  String get categoryId;
  @override
  String get subcategoryId;
  @override
  String get condition;
  @override
  String get brand;
  @override
  int get quantity;
  @override
  String get location;
  @override
  String get shippingCostInput;
  @override
  bool get shippingAvailable;
  @override
  List<AttributeEntry> get attributes;
  @override
  bool get isSubmitting;
  @override
  Map<String, String> get errors;
  @override

  /// Incremented when a draft is loaded from storage (for controller sync).
  int get draftRevision;
  @override
  @JsonKey(ignore: true)
  _$$ListingFormStateImplCopyWith<_$ListingFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
