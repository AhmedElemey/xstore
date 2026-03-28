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
mixin _$ListingFormState {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  List<String> get photoPaths => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

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
      {String title,
      String description,
      double price,
      List<String> photoPaths,
      bool isSubmitting,
      String? errorMessage});
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
    Object? title = null,
    Object? description = null,
    Object? price = null,
    Object? photoPaths = null,
    Object? isSubmitting = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      photoPaths: null == photoPaths
          ? _value.photoPaths
          : photoPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
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
      {String title,
      String description,
      double price,
      List<String> photoPaths,
      bool isSubmitting,
      String? errorMessage});
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
    Object? title = null,
    Object? description = null,
    Object? price = null,
    Object? photoPaths = null,
    Object? isSubmitting = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$ListingFormStateImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      photoPaths: null == photoPaths
          ? _value._photoPaths
          : photoPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ListingFormStateImpl implements _ListingFormState {
  const _$ListingFormStateImpl(
      {this.title = '',
      this.description = '',
      this.price = 0.0,
      final List<String> photoPaths = const <String>[],
      this.isSubmitting = false,
      this.errorMessage})
      : _photoPaths = photoPaths;

  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final double price;
  final List<String> _photoPaths;
  @override
  @JsonKey()
  List<String> get photoPaths {
    if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoPaths);
  }

  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ListingFormState(title: $title, description: $description, price: $price, photoPaths: $photoPaths, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingFormStateImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            const DeepCollectionEquality()
                .equals(other._photoPaths, _photoPaths) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      description,
      price,
      const DeepCollectionEquality().hash(_photoPaths),
      isSubmitting,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingFormStateImplCopyWith<_$ListingFormStateImpl> get copyWith =>
      __$$ListingFormStateImplCopyWithImpl<_$ListingFormStateImpl>(
          this, _$identity);
}

abstract class _ListingFormState implements ListingFormState {
  const factory _ListingFormState(
      {final String title,
      final String description,
      final double price,
      final List<String> photoPaths,
      final bool isSubmitting,
      final String? errorMessage}) = _$ListingFormStateImpl;

  @override
  String get title;
  @override
  String get description;
  @override
  double get price;
  @override
  List<String> get photoPaths;
  @override
  bool get isSubmitting;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$ListingFormStateImplCopyWith<_$ListingFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
