// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_write_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReviewWriteParams {
  double get rating => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ReviewWriteParamsCopyWith<ReviewWriteParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewWriteParamsCopyWith<$Res> {
  factory $ReviewWriteParamsCopyWith(
          ReviewWriteParams value, $Res Function(ReviewWriteParams) then) =
      _$ReviewWriteParamsCopyWithImpl<$Res, ReviewWriteParams>;
  @useResult
  $Res call({double rating, String comment});
}

/// @nodoc
class _$ReviewWriteParamsCopyWithImpl<$Res, $Val extends ReviewWriteParams>
    implements $ReviewWriteParamsCopyWith<$Res> {
  _$ReviewWriteParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? comment = null,
  }) {
    return _then(_value.copyWith(
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewWriteParamsImplCopyWith<$Res>
    implements $ReviewWriteParamsCopyWith<$Res> {
  factory _$$ReviewWriteParamsImplCopyWith(_$ReviewWriteParamsImpl value,
          $Res Function(_$ReviewWriteParamsImpl) then) =
      __$$ReviewWriteParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double rating, String comment});
}

/// @nodoc
class __$$ReviewWriteParamsImplCopyWithImpl<$Res>
    extends _$ReviewWriteParamsCopyWithImpl<$Res, _$ReviewWriteParamsImpl>
    implements _$$ReviewWriteParamsImplCopyWith<$Res> {
  __$$ReviewWriteParamsImplCopyWithImpl(_$ReviewWriteParamsImpl _value,
      $Res Function(_$ReviewWriteParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? comment = null,
  }) {
    return _then(_$ReviewWriteParamsImpl(
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ReviewWriteParamsImpl implements _ReviewWriteParams {
  const _$ReviewWriteParamsImpl({required this.rating, required this.comment});

  @override
  final double rating;
  @override
  final String comment;

  @override
  String toString() {
    return 'ReviewWriteParams(rating: $rating, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewWriteParamsImpl &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rating, comment);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewWriteParamsImplCopyWith<_$ReviewWriteParamsImpl> get copyWith =>
      __$$ReviewWriteParamsImplCopyWithImpl<_$ReviewWriteParamsImpl>(
          this, _$identity);
}

abstract class _ReviewWriteParams implements ReviewWriteParams {
  const factory _ReviewWriteParams(
      {required final double rating,
      required final String comment}) = _$ReviewWriteParamsImpl;

  @override
  double get rating;
  @override
  String get comment;
  @override
  @JsonKey(ignore: true)
  _$$ReviewWriteParamsImplCopyWith<_$ReviewWriteParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
