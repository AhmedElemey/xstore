// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_hours_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StoreHoursEntity {
  String get vendorId => throw _privateConstructorUsedError;
  bool get isStoreOpen => throw _privateConstructorUsedError;
  String? get temporaryMessage => throw _privateConstructorUsedError;
  List<DayScheduleEntity> get schedule => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StoreHoursEntityCopyWith<StoreHoursEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreHoursEntityCopyWith<$Res> {
  factory $StoreHoursEntityCopyWith(
          StoreHoursEntity value, $Res Function(StoreHoursEntity) then) =
      _$StoreHoursEntityCopyWithImpl<$Res, StoreHoursEntity>;
  @useResult
  $Res call(
      {String vendorId,
      bool isStoreOpen,
      String? temporaryMessage,
      List<DayScheduleEntity> schedule,
      DateTime updatedAt});
}

/// @nodoc
class _$StoreHoursEntityCopyWithImpl<$Res, $Val extends StoreHoursEntity>
    implements $StoreHoursEntityCopyWith<$Res> {
  _$StoreHoursEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? isStoreOpen = null,
    Object? temporaryMessage = freezed,
    Object? schedule = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      vendorId: null == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String,
      isStoreOpen: null == isStoreOpen
          ? _value.isStoreOpen
          : isStoreOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      temporaryMessage: freezed == temporaryMessage
          ? _value.temporaryMessage
          : temporaryMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<DayScheduleEntity>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoreHoursEntityImplCopyWith<$Res>
    implements $StoreHoursEntityCopyWith<$Res> {
  factory _$$StoreHoursEntityImplCopyWith(_$StoreHoursEntityImpl value,
          $Res Function(_$StoreHoursEntityImpl) then) =
      __$$StoreHoursEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String vendorId,
      bool isStoreOpen,
      String? temporaryMessage,
      List<DayScheduleEntity> schedule,
      DateTime updatedAt});
}

/// @nodoc
class __$$StoreHoursEntityImplCopyWithImpl<$Res>
    extends _$StoreHoursEntityCopyWithImpl<$Res, _$StoreHoursEntityImpl>
    implements _$$StoreHoursEntityImplCopyWith<$Res> {
  __$$StoreHoursEntityImplCopyWithImpl(_$StoreHoursEntityImpl _value,
      $Res Function(_$StoreHoursEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? isStoreOpen = null,
    Object? temporaryMessage = freezed,
    Object? schedule = null,
    Object? updatedAt = null,
  }) {
    return _then(_$StoreHoursEntityImpl(
      vendorId: null == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String,
      isStoreOpen: null == isStoreOpen
          ? _value.isStoreOpen
          : isStoreOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      temporaryMessage: freezed == temporaryMessage
          ? _value.temporaryMessage
          : temporaryMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      schedule: null == schedule
          ? _value._schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<DayScheduleEntity>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$StoreHoursEntityImpl implements _StoreHoursEntity {
  const _$StoreHoursEntityImpl(
      {required this.vendorId,
      required this.isStoreOpen,
      required this.temporaryMessage,
      required final List<DayScheduleEntity> schedule,
      required this.updatedAt})
      : _schedule = schedule;

  @override
  final String vendorId;
  @override
  final bool isStoreOpen;
  @override
  final String? temporaryMessage;
  final List<DayScheduleEntity> _schedule;
  @override
  List<DayScheduleEntity> get schedule {
    if (_schedule is EqualUnmodifiableListView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedule);
  }

  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'StoreHoursEntity(vendorId: $vendorId, isStoreOpen: $isStoreOpen, temporaryMessage: $temporaryMessage, schedule: $schedule, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreHoursEntityImpl &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.isStoreOpen, isStoreOpen) ||
                other.isStoreOpen == isStoreOpen) &&
            (identical(other.temporaryMessage, temporaryMessage) ||
                other.temporaryMessage == temporaryMessage) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      vendorId,
      isStoreOpen,
      temporaryMessage,
      const DeepCollectionEquality().hash(_schedule),
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreHoursEntityImplCopyWith<_$StoreHoursEntityImpl> get copyWith =>
      __$$StoreHoursEntityImplCopyWithImpl<_$StoreHoursEntityImpl>(
          this, _$identity);
}

abstract class _StoreHoursEntity implements StoreHoursEntity {
  const factory _StoreHoursEntity(
      {required final String vendorId,
      required final bool isStoreOpen,
      required final String? temporaryMessage,
      required final List<DayScheduleEntity> schedule,
      required final DateTime updatedAt}) = _$StoreHoursEntityImpl;

  @override
  String get vendorId;
  @override
  bool get isStoreOpen;
  @override
  String? get temporaryMessage;
  @override
  List<DayScheduleEntity> get schedule;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$StoreHoursEntityImplCopyWith<_$StoreHoursEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$StoreStatusEntity {
  bool get isOpen => throw _privateConstructorUsedError;
  DayScheduleEntity? get currentDayHours => throw _privateConstructorUsedError;
  DayScheduleEntity? get nextOpenDay => throw _privateConstructorUsedError;
  String get statusLabel => throw _privateConstructorUsedError;
  String? get nextOpenLabel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StoreStatusEntityCopyWith<StoreStatusEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreStatusEntityCopyWith<$Res> {
  factory $StoreStatusEntityCopyWith(
          StoreStatusEntity value, $Res Function(StoreStatusEntity) then) =
      _$StoreStatusEntityCopyWithImpl<$Res, StoreStatusEntity>;
  @useResult
  $Res call(
      {bool isOpen,
      DayScheduleEntity? currentDayHours,
      DayScheduleEntity? nextOpenDay,
      String statusLabel,
      String? nextOpenLabel});

  $DayScheduleEntityCopyWith<$Res>? get currentDayHours;
  $DayScheduleEntityCopyWith<$Res>? get nextOpenDay;
}

/// @nodoc
class _$StoreStatusEntityCopyWithImpl<$Res, $Val extends StoreStatusEntity>
    implements $StoreStatusEntityCopyWith<$Res> {
  _$StoreStatusEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isOpen = null,
    Object? currentDayHours = freezed,
    Object? nextOpenDay = freezed,
    Object? statusLabel = null,
    Object? nextOpenLabel = freezed,
  }) {
    return _then(_value.copyWith(
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      currentDayHours: freezed == currentDayHours
          ? _value.currentDayHours
          : currentDayHours // ignore: cast_nullable_to_non_nullable
              as DayScheduleEntity?,
      nextOpenDay: freezed == nextOpenDay
          ? _value.nextOpenDay
          : nextOpenDay // ignore: cast_nullable_to_non_nullable
              as DayScheduleEntity?,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      nextOpenLabel: freezed == nextOpenLabel
          ? _value.nextOpenLabel
          : nextOpenLabel // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DayScheduleEntityCopyWith<$Res>? get currentDayHours {
    if (_value.currentDayHours == null) {
      return null;
    }

    return $DayScheduleEntityCopyWith<$Res>(_value.currentDayHours!, (value) {
      return _then(_value.copyWith(currentDayHours: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DayScheduleEntityCopyWith<$Res>? get nextOpenDay {
    if (_value.nextOpenDay == null) {
      return null;
    }

    return $DayScheduleEntityCopyWith<$Res>(_value.nextOpenDay!, (value) {
      return _then(_value.copyWith(nextOpenDay: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StoreStatusEntityImplCopyWith<$Res>
    implements $StoreStatusEntityCopyWith<$Res> {
  factory _$$StoreStatusEntityImplCopyWith(_$StoreStatusEntityImpl value,
          $Res Function(_$StoreStatusEntityImpl) then) =
      __$$StoreStatusEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isOpen,
      DayScheduleEntity? currentDayHours,
      DayScheduleEntity? nextOpenDay,
      String statusLabel,
      String? nextOpenLabel});

  @override
  $DayScheduleEntityCopyWith<$Res>? get currentDayHours;
  @override
  $DayScheduleEntityCopyWith<$Res>? get nextOpenDay;
}

/// @nodoc
class __$$StoreStatusEntityImplCopyWithImpl<$Res>
    extends _$StoreStatusEntityCopyWithImpl<$Res, _$StoreStatusEntityImpl>
    implements _$$StoreStatusEntityImplCopyWith<$Res> {
  __$$StoreStatusEntityImplCopyWithImpl(_$StoreStatusEntityImpl _value,
      $Res Function(_$StoreStatusEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isOpen = null,
    Object? currentDayHours = freezed,
    Object? nextOpenDay = freezed,
    Object? statusLabel = null,
    Object? nextOpenLabel = freezed,
  }) {
    return _then(_$StoreStatusEntityImpl(
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      currentDayHours: freezed == currentDayHours
          ? _value.currentDayHours
          : currentDayHours // ignore: cast_nullable_to_non_nullable
              as DayScheduleEntity?,
      nextOpenDay: freezed == nextOpenDay
          ? _value.nextOpenDay
          : nextOpenDay // ignore: cast_nullable_to_non_nullable
              as DayScheduleEntity?,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      nextOpenLabel: freezed == nextOpenLabel
          ? _value.nextOpenLabel
          : nextOpenLabel // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$StoreStatusEntityImpl implements _StoreStatusEntity {
  const _$StoreStatusEntityImpl(
      {required this.isOpen,
      required this.currentDayHours,
      required this.nextOpenDay,
      required this.statusLabel,
      required this.nextOpenLabel});

  @override
  final bool isOpen;
  @override
  final DayScheduleEntity? currentDayHours;
  @override
  final DayScheduleEntity? nextOpenDay;
  @override
  final String statusLabel;
  @override
  final String? nextOpenLabel;

  @override
  String toString() {
    return 'StoreStatusEntity(isOpen: $isOpen, currentDayHours: $currentDayHours, nextOpenDay: $nextOpenDay, statusLabel: $statusLabel, nextOpenLabel: $nextOpenLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreStatusEntityImpl &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            (identical(other.currentDayHours, currentDayHours) ||
                other.currentDayHours == currentDayHours) &&
            (identical(other.nextOpenDay, nextOpenDay) ||
                other.nextOpenDay == nextOpenDay) &&
            (identical(other.statusLabel, statusLabel) ||
                other.statusLabel == statusLabel) &&
            (identical(other.nextOpenLabel, nextOpenLabel) ||
                other.nextOpenLabel == nextOpenLabel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isOpen, currentDayHours,
      nextOpenDay, statusLabel, nextOpenLabel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreStatusEntityImplCopyWith<_$StoreStatusEntityImpl> get copyWith =>
      __$$StoreStatusEntityImplCopyWithImpl<_$StoreStatusEntityImpl>(
          this, _$identity);
}

abstract class _StoreStatusEntity implements StoreStatusEntity {
  const factory _StoreStatusEntity(
      {required final bool isOpen,
      required final DayScheduleEntity? currentDayHours,
      required final DayScheduleEntity? nextOpenDay,
      required final String statusLabel,
      required final String? nextOpenLabel}) = _$StoreStatusEntityImpl;

  @override
  bool get isOpen;
  @override
  DayScheduleEntity? get currentDayHours;
  @override
  DayScheduleEntity? get nextOpenDay;
  @override
  String get statusLabel;
  @override
  String? get nextOpenLabel;
  @override
  @JsonKey(ignore: true)
  _$$StoreStatusEntityImplCopyWith<_$StoreStatusEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
