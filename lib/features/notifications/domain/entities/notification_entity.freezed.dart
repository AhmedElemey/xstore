// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationEntity {
  String get id => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationPriority get priority => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get actionRoute => throw _privateConstructorUsedError;
  Map<String, dynamic>? get actionData => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get orderId => throw _privateConstructorUsedError;
  String? get listingId => throw _privateConstructorUsedError;
  String? get reviewId => throw _privateConstructorUsedError;
  String? get senderId => throw _privateConstructorUsedError;
  String? get senderName => throw _privateConstructorUsedError;
  String? get senderAvatar => throw _privateConstructorUsedError;
  int? get discountPercent => throw _privateConstructorUsedError;
  double? get priceDropAmount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotificationEntityCopyWith<NotificationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationEntityCopyWith<$Res> {
  factory $NotificationEntityCopyWith(
          NotificationEntity value, $Res Function(NotificationEntity) then) =
      _$NotificationEntityCopyWithImpl<$Res, NotificationEntity>;
  @useResult
  $Res call(
      {String id,
      NotificationType type,
      NotificationPriority priority,
      String title,
      String body,
      String? imageUrl,
      String? actionRoute,
      Map<String, dynamic>? actionData,
      bool isRead,
      DateTime createdAt,
      String? orderId,
      String? listingId,
      String? reviewId,
      String? senderId,
      String? senderName,
      String? senderAvatar,
      int? discountPercent,
      double? priceDropAmount});
}

/// @nodoc
class _$NotificationEntityCopyWithImpl<$Res, $Val extends NotificationEntity>
    implements $NotificationEntityCopyWith<$Res> {
  _$NotificationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? priority = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? actionRoute = freezed,
    Object? actionData = freezed,
    Object? isRead = null,
    Object? createdAt = null,
    Object? orderId = freezed,
    Object? listingId = freezed,
    Object? reviewId = freezed,
    Object? senderId = freezed,
    Object? senderName = freezed,
    Object? senderAvatar = freezed,
    Object? discountPercent = freezed,
    Object? priceDropAmount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      actionData: freezed == actionData
          ? _value.actionData
          : actionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewId: freezed == reviewId
          ? _value.reviewId
          : reviewId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAvatar: freezed == senderAvatar
          ? _value.senderAvatar
          : senderAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPercent: freezed == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      priceDropAmount: freezed == priceDropAmount
          ? _value.priceDropAmount
          : priceDropAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationEntityImplCopyWith<$Res>
    implements $NotificationEntityCopyWith<$Res> {
  factory _$$NotificationEntityImplCopyWith(_$NotificationEntityImpl value,
          $Res Function(_$NotificationEntityImpl) then) =
      __$$NotificationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      NotificationType type,
      NotificationPriority priority,
      String title,
      String body,
      String? imageUrl,
      String? actionRoute,
      Map<String, dynamic>? actionData,
      bool isRead,
      DateTime createdAt,
      String? orderId,
      String? listingId,
      String? reviewId,
      String? senderId,
      String? senderName,
      String? senderAvatar,
      int? discountPercent,
      double? priceDropAmount});
}

/// @nodoc
class __$$NotificationEntityImplCopyWithImpl<$Res>
    extends _$NotificationEntityCopyWithImpl<$Res, _$NotificationEntityImpl>
    implements _$$NotificationEntityImplCopyWith<$Res> {
  __$$NotificationEntityImplCopyWithImpl(_$NotificationEntityImpl _value,
      $Res Function(_$NotificationEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? priority = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? actionRoute = freezed,
    Object? actionData = freezed,
    Object? isRead = null,
    Object? createdAt = null,
    Object? orderId = freezed,
    Object? listingId = freezed,
    Object? reviewId = freezed,
    Object? senderId = freezed,
    Object? senderName = freezed,
    Object? senderAvatar = freezed,
    Object? discountPercent = freezed,
    Object? priceDropAmount = freezed,
  }) {
    return _then(_$NotificationEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      actionData: freezed == actionData
          ? _value._actionData
          : actionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewId: freezed == reviewId
          ? _value.reviewId
          : reviewId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAvatar: freezed == senderAvatar
          ? _value.senderAvatar
          : senderAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPercent: freezed == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      priceDropAmount: freezed == priceDropAmount
          ? _value.priceDropAmount
          : priceDropAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$NotificationEntityImpl implements _NotificationEntity {
  const _$NotificationEntityImpl(
      {required this.id,
      required this.type,
      this.priority = NotificationPriority.normal,
      required this.title,
      required this.body,
      this.imageUrl,
      this.actionRoute,
      final Map<String, dynamic>? actionData,
      this.isRead = false,
      required this.createdAt,
      this.orderId,
      this.listingId,
      this.reviewId,
      this.senderId,
      this.senderName,
      this.senderAvatar,
      this.discountPercent,
      this.priceDropAmount})
      : _actionData = actionData;

  @override
  final String id;
  @override
  final NotificationType type;
  @override
  @JsonKey()
  final NotificationPriority priority;
  @override
  final String title;
  @override
  final String body;
  @override
  final String? imageUrl;
  @override
  final String? actionRoute;
  final Map<String, dynamic>? _actionData;
  @override
  Map<String, dynamic>? get actionData {
    final value = _actionData;
    if (value == null) return null;
    if (_actionData is EqualUnmodifiableMapView) return _actionData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isRead;
  @override
  final DateTime createdAt;
  @override
  final String? orderId;
  @override
  final String? listingId;
  @override
  final String? reviewId;
  @override
  final String? senderId;
  @override
  final String? senderName;
  @override
  final String? senderAvatar;
  @override
  final int? discountPercent;
  @override
  final double? priceDropAmount;

  @override
  String toString() {
    return 'NotificationEntity(id: $id, type: $type, priority: $priority, title: $title, body: $body, imageUrl: $imageUrl, actionRoute: $actionRoute, actionData: $actionData, isRead: $isRead, createdAt: $createdAt, orderId: $orderId, listingId: $listingId, reviewId: $reviewId, senderId: $senderId, senderName: $senderName, senderAvatar: $senderAvatar, discountPercent: $discountPercent, priceDropAmount: $priceDropAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.actionRoute, actionRoute) ||
                other.actionRoute == actionRoute) &&
            const DeepCollectionEquality()
                .equals(other._actionData, _actionData) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.listingId, listingId) ||
                other.listingId == listingId) &&
            (identical(other.reviewId, reviewId) ||
                other.reviewId == reviewId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderAvatar, senderAvatar) ||
                other.senderAvatar == senderAvatar) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.priceDropAmount, priceDropAmount) ||
                other.priceDropAmount == priceDropAmount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      priority,
      title,
      body,
      imageUrl,
      actionRoute,
      const DeepCollectionEquality().hash(_actionData),
      isRead,
      createdAt,
      orderId,
      listingId,
      reviewId,
      senderId,
      senderName,
      senderAvatar,
      discountPercent,
      priceDropAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationEntityImplCopyWith<_$NotificationEntityImpl> get copyWith =>
      __$$NotificationEntityImplCopyWithImpl<_$NotificationEntityImpl>(
          this, _$identity);
}

abstract class _NotificationEntity implements NotificationEntity {
  const factory _NotificationEntity(
      {required final String id,
      required final NotificationType type,
      final NotificationPriority priority,
      required final String title,
      required final String body,
      final String? imageUrl,
      final String? actionRoute,
      final Map<String, dynamic>? actionData,
      final bool isRead,
      required final DateTime createdAt,
      final String? orderId,
      final String? listingId,
      final String? reviewId,
      final String? senderId,
      final String? senderName,
      final String? senderAvatar,
      final int? discountPercent,
      final double? priceDropAmount}) = _$NotificationEntityImpl;

  @override
  String get id;
  @override
  NotificationType get type;
  @override
  NotificationPriority get priority;
  @override
  String get title;
  @override
  String get body;
  @override
  String? get imageUrl;
  @override
  String? get actionRoute;
  @override
  Map<String, dynamic>? get actionData;
  @override
  bool get isRead;
  @override
  DateTime get createdAt;
  @override
  String? get orderId;
  @override
  String? get listingId;
  @override
  String? get reviewId;
  @override
  String? get senderId;
  @override
  String? get senderName;
  @override
  String? get senderAvatar;
  @override
  int? get discountPercent;
  @override
  double? get priceDropAmount;
  @override
  @JsonKey(ignore: true)
  _$$NotificationEntityImplCopyWith<_$NotificationEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NotificationGroup {
  String get label => throw _privateConstructorUsedError;
  List<NotificationEntity> get notifications =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotificationGroupCopyWith<NotificationGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationGroupCopyWith<$Res> {
  factory $NotificationGroupCopyWith(
          NotificationGroup value, $Res Function(NotificationGroup) then) =
      _$NotificationGroupCopyWithImpl<$Res, NotificationGroup>;
  @useResult
  $Res call({String label, List<NotificationEntity> notifications});
}

/// @nodoc
class _$NotificationGroupCopyWithImpl<$Res, $Val extends NotificationGroup>
    implements $NotificationGroupCopyWith<$Res> {
  _$NotificationGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? notifications = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationEntity>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationGroupImplCopyWith<$Res>
    implements $NotificationGroupCopyWith<$Res> {
  factory _$$NotificationGroupImplCopyWith(_$NotificationGroupImpl value,
          $Res Function(_$NotificationGroupImpl) then) =
      __$$NotificationGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, List<NotificationEntity> notifications});
}

/// @nodoc
class __$$NotificationGroupImplCopyWithImpl<$Res>
    extends _$NotificationGroupCopyWithImpl<$Res, _$NotificationGroupImpl>
    implements _$$NotificationGroupImplCopyWith<$Res> {
  __$$NotificationGroupImplCopyWithImpl(_$NotificationGroupImpl _value,
      $Res Function(_$NotificationGroupImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? notifications = null,
  }) {
    return _then(_$NotificationGroupImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      notifications: null == notifications
          ? _value._notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationEntity>,
    ));
  }
}

/// @nodoc

class _$NotificationGroupImpl implements _NotificationGroup {
  const _$NotificationGroupImpl(
      {required this.label,
      required final List<NotificationEntity> notifications})
      : _notifications = notifications;

  @override
  final String label;
  final List<NotificationEntity> _notifications;
  @override
  List<NotificationEntity> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @override
  String toString() {
    return 'NotificationGroup(label: $label, notifications: $notifications)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationGroupImpl &&
            (identical(other.label, label) || other.label == label) &&
            const DeepCollectionEquality()
                .equals(other._notifications, _notifications));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, label, const DeepCollectionEquality().hash(_notifications));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationGroupImplCopyWith<_$NotificationGroupImpl> get copyWith =>
      __$$NotificationGroupImplCopyWithImpl<_$NotificationGroupImpl>(
          this, _$identity);
}

abstract class _NotificationGroup implements NotificationGroup {
  const factory _NotificationGroup(
          {required final String label,
          required final List<NotificationEntity> notifications}) =
      _$NotificationGroupImpl;

  @override
  String get label;
  @override
  List<NotificationEntity> get notifications;
  @override
  @JsonKey(ignore: true)
  _$$NotificationGroupImplCopyWith<_$NotificationGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
