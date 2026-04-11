// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_schedule_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DayScheduleEntity {
  DayOfWeek get day => throw _privateConstructorUsedError;
  bool get isOpen => throw _privateConstructorUsedError;
  TimeOfDay get openTime => throw _privateConstructorUsedError;
  TimeOfDay get closeTime => throw _privateConstructorUsedError;
  bool get is24Hours => throw _privateConstructorUsedError;
  bool get isClosed => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DayScheduleEntityCopyWith<DayScheduleEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayScheduleEntityCopyWith<$Res> {
  factory $DayScheduleEntityCopyWith(
          DayScheduleEntity value, $Res Function(DayScheduleEntity) then) =
      _$DayScheduleEntityCopyWithImpl<$Res, DayScheduleEntity>;
  @useResult
  $Res call(
      {DayOfWeek day,
      bool isOpen,
      TimeOfDay openTime,
      TimeOfDay closeTime,
      bool is24Hours,
      bool isClosed});
}

/// @nodoc
class _$DayScheduleEntityCopyWithImpl<$Res, $Val extends DayScheduleEntity>
    implements $DayScheduleEntityCopyWith<$Res> {
  _$DayScheduleEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? isOpen = null,
    Object? openTime = null,
    Object? closeTime = null,
    Object? is24Hours = null,
    Object? isClosed = null,
  }) {
    return _then(_value.copyWith(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as DayOfWeek,
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      openTime: null == openTime
          ? _value.openTime
          : openTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      closeTime: null == closeTime
          ? _value.closeTime
          : closeTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      is24Hours: null == is24Hours
          ? _value.is24Hours
          : is24Hours // ignore: cast_nullable_to_non_nullable
              as bool,
      isClosed: null == isClosed
          ? _value.isClosed
          : isClosed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DayScheduleEntityImplCopyWith<$Res>
    implements $DayScheduleEntityCopyWith<$Res> {
  factory _$$DayScheduleEntityImplCopyWith(_$DayScheduleEntityImpl value,
          $Res Function(_$DayScheduleEntityImpl) then) =
      __$$DayScheduleEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DayOfWeek day,
      bool isOpen,
      TimeOfDay openTime,
      TimeOfDay closeTime,
      bool is24Hours,
      bool isClosed});
}

/// @nodoc
class __$$DayScheduleEntityImplCopyWithImpl<$Res>
    extends _$DayScheduleEntityCopyWithImpl<$Res, _$DayScheduleEntityImpl>
    implements _$$DayScheduleEntityImplCopyWith<$Res> {
  __$$DayScheduleEntityImplCopyWithImpl(_$DayScheduleEntityImpl _value,
      $Res Function(_$DayScheduleEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? isOpen = null,
    Object? openTime = null,
    Object? closeTime = null,
    Object? is24Hours = null,
    Object? isClosed = null,
  }) {
    return _then(_$DayScheduleEntityImpl(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as DayOfWeek,
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      openTime: null == openTime
          ? _value.openTime
          : openTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      closeTime: null == closeTime
          ? _value.closeTime
          : closeTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      is24Hours: null == is24Hours
          ? _value.is24Hours
          : is24Hours // ignore: cast_nullable_to_non_nullable
              as bool,
      isClosed: null == isClosed
          ? _value.isClosed
          : isClosed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$DayScheduleEntityImpl implements _DayScheduleEntity {
  const _$DayScheduleEntityImpl(
      {required this.day,
      required this.isOpen,
      required this.openTime,
      required this.closeTime,
      required this.is24Hours,
      required this.isClosed});

  @override
  final DayOfWeek day;
  @override
  final bool isOpen;
  @override
  final TimeOfDay openTime;
  @override
  final TimeOfDay closeTime;
  @override
  final bool is24Hours;
  @override
  final bool isClosed;

  @override
  String toString() {
    return 'DayScheduleEntity(day: $day, isOpen: $isOpen, openTime: $openTime, closeTime: $closeTime, is24Hours: $is24Hours, isClosed: $isClosed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayScheduleEntityImpl &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            (identical(other.openTime, openTime) ||
                other.openTime == openTime) &&
            (identical(other.closeTime, closeTime) ||
                other.closeTime == closeTime) &&
            (identical(other.is24Hours, is24Hours) ||
                other.is24Hours == is24Hours) &&
            (identical(other.isClosed, isClosed) ||
                other.isClosed == isClosed));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, day, isOpen, openTime, closeTime, is24Hours, isClosed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DayScheduleEntityImplCopyWith<_$DayScheduleEntityImpl> get copyWith =>
      __$$DayScheduleEntityImplCopyWithImpl<_$DayScheduleEntityImpl>(
          this, _$identity);
}

abstract class _DayScheduleEntity implements DayScheduleEntity {
  const factory _DayScheduleEntity(
      {required final DayOfWeek day,
      required final bool isOpen,
      required final TimeOfDay openTime,
      required final TimeOfDay closeTime,
      required final bool is24Hours,
      required final bool isClosed}) = _$DayScheduleEntityImpl;

  @override
  DayOfWeek get day;
  @override
  bool get isOpen;
  @override
  TimeOfDay get openTime;
  @override
  TimeOfDay get closeTime;
  @override
  bool get is24Hours;
  @override
  bool get isClosed;
  @override
  @JsonKey(ignore: true)
  _$$DayScheduleEntityImplCopyWith<_$DayScheduleEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
