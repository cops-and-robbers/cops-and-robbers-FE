// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_chat_room_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityChatLastMessageEntity {
  int get id => throw _privateConstructorUsedError;
  CommunityChatMessageBody get body => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get senderNickname => throw _privateConstructorUsedError;
  int? get senderProfileIcon => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatLastMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatLastMessageEntityCopyWith<CommunityChatLastMessageEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatLastMessageEntityCopyWith<$Res> {
  factory $CommunityChatLastMessageEntityCopyWith(
    CommunityChatLastMessageEntity value,
    $Res Function(CommunityChatLastMessageEntity) then,
  ) =
      _$CommunityChatLastMessageEntityCopyWithImpl<
        $Res,
        CommunityChatLastMessageEntity
      >;
  @useResult
  $Res call({
    int id,
    CommunityChatMessageBody body,
    DateTime createdAt,
    String? senderNickname,
    int? senderProfileIcon,
  });

  $CommunityChatMessageBodyCopyWith<$Res> get body;
}

/// @nodoc
class _$CommunityChatLastMessageEntityCopyWithImpl<
  $Res,
  $Val extends CommunityChatLastMessageEntity
>
    implements $CommunityChatLastMessageEntityCopyWith<$Res> {
  _$CommunityChatLastMessageEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatLastMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? createdAt = null,
    Object? senderNickname = freezed,
    Object? senderProfileIcon = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as CommunityChatMessageBody,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            senderNickname: freezed == senderNickname
                ? _value.senderNickname
                : senderNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderProfileIcon: freezed == senderProfileIcon
                ? _value.senderProfileIcon
                : senderProfileIcon // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of CommunityChatLastMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommunityChatMessageBodyCopyWith<$Res> get body {
    return $CommunityChatMessageBodyCopyWith<$Res>(_value.body, (value) {
      return _then(_value.copyWith(body: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommunityChatLastMessageEntityImplCopyWith<$Res>
    implements $CommunityChatLastMessageEntityCopyWith<$Res> {
  factory _$$CommunityChatLastMessageEntityImplCopyWith(
    _$CommunityChatLastMessageEntityImpl value,
    $Res Function(_$CommunityChatLastMessageEntityImpl) then,
  ) = __$$CommunityChatLastMessageEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    CommunityChatMessageBody body,
    DateTime createdAt,
    String? senderNickname,
    int? senderProfileIcon,
  });

  @override
  $CommunityChatMessageBodyCopyWith<$Res> get body;
}

/// @nodoc
class __$$CommunityChatLastMessageEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityChatLastMessageEntityCopyWithImpl<
          $Res,
          _$CommunityChatLastMessageEntityImpl
        >
    implements _$$CommunityChatLastMessageEntityImplCopyWith<$Res> {
  __$$CommunityChatLastMessageEntityImplCopyWithImpl(
    _$CommunityChatLastMessageEntityImpl _value,
    $Res Function(_$CommunityChatLastMessageEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatLastMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? createdAt = null,
    Object? senderNickname = freezed,
    Object? senderProfileIcon = freezed,
  }) {
    return _then(
      _$CommunityChatLastMessageEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as CommunityChatMessageBody,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        senderNickname: freezed == senderNickname
            ? _value.senderNickname
            : senderNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        senderProfileIcon: freezed == senderProfileIcon
            ? _value.senderProfileIcon
            : senderProfileIcon // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatLastMessageEntityImpl
    implements _CommunityChatLastMessageEntity {
  const _$CommunityChatLastMessageEntityImpl({
    required this.id,
    required this.body,
    required this.createdAt,
    this.senderNickname,
    this.senderProfileIcon,
  });

  @override
  final int id;
  @override
  final CommunityChatMessageBody body;
  @override
  final DateTime createdAt;
  @override
  final String? senderNickname;
  @override
  final int? senderProfileIcon;

  @override
  String toString() {
    return 'CommunityChatLastMessageEntity(id: $id, body: $body, createdAt: $createdAt, senderNickname: $senderNickname, senderProfileIcon: $senderProfileIcon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatLastMessageEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.senderNickname, senderNickname) ||
                other.senderNickname == senderNickname) &&
            (identical(other.senderProfileIcon, senderProfileIcon) ||
                other.senderProfileIcon == senderProfileIcon));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    body,
    createdAt,
    senderNickname,
    senderProfileIcon,
  );

  /// Create a copy of CommunityChatLastMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatLastMessageEntityImplCopyWith<
    _$CommunityChatLastMessageEntityImpl
  >
  get copyWith =>
      __$$CommunityChatLastMessageEntityImplCopyWithImpl<
        _$CommunityChatLastMessageEntityImpl
      >(this, _$identity);
}

abstract class _CommunityChatLastMessageEntity
    implements CommunityChatLastMessageEntity {
  const factory _CommunityChatLastMessageEntity({
    required final int id,
    required final CommunityChatMessageBody body,
    required final DateTime createdAt,
    final String? senderNickname,
    final int? senderProfileIcon,
  }) = _$CommunityChatLastMessageEntityImpl;

  @override
  int get id;
  @override
  CommunityChatMessageBody get body;
  @override
  DateTime get createdAt;
  @override
  String? get senderNickname;
  @override
  int? get senderProfileIcon;

  /// Create a copy of CommunityChatLastMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatLastMessageEntityImplCopyWith<
    _$CommunityChatLastMessageEntityImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommunityChatRoomEntity {
  int get postId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  CommunityPostStatus get status => throw _privateConstructorUsedError;
  DateTime get meetingAt => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  CommunityChatLastMessageEntity? get lastMessage =>
      throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatRoomEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatRoomEntityCopyWith<CommunityChatRoomEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatRoomEntityCopyWith<$Res> {
  factory $CommunityChatRoomEntityCopyWith(
    CommunityChatRoomEntity value,
    $Res Function(CommunityChatRoomEntity) then,
  ) = _$CommunityChatRoomEntityCopyWithImpl<$Res, CommunityChatRoomEntity>;
  @useResult
  $Res call({
    int postId,
    String title,
    CommunityPostStatus status,
    DateTime meetingAt,
    int memberCount,
    CommunityChatLastMessageEntity? lastMessage,
  });

  $CommunityChatLastMessageEntityCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$CommunityChatRoomEntityCopyWithImpl<
  $Res,
  $Val extends CommunityChatRoomEntity
>
    implements $CommunityChatRoomEntityCopyWith<$Res> {
  _$CommunityChatRoomEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatRoomEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? title = null,
    Object? status = null,
    Object? meetingAt = null,
    Object? memberCount = null,
    Object? lastMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            postId: null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CommunityPostStatus,
            meetingAt: null == meetingAt
                ? _value.meetingAt
                : meetingAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as CommunityChatLastMessageEntity?,
          )
          as $Val,
    );
  }

  /// Create a copy of CommunityChatRoomEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommunityChatLastMessageEntityCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $CommunityChatLastMessageEntityCopyWith<$Res>(_value.lastMessage!, (
      value,
    ) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommunityChatRoomEntityImplCopyWith<$Res>
    implements $CommunityChatRoomEntityCopyWith<$Res> {
  factory _$$CommunityChatRoomEntityImplCopyWith(
    _$CommunityChatRoomEntityImpl value,
    $Res Function(_$CommunityChatRoomEntityImpl) then,
  ) = __$$CommunityChatRoomEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int postId,
    String title,
    CommunityPostStatus status,
    DateTime meetingAt,
    int memberCount,
    CommunityChatLastMessageEntity? lastMessage,
  });

  @override
  $CommunityChatLastMessageEntityCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$CommunityChatRoomEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityChatRoomEntityCopyWithImpl<
          $Res,
          _$CommunityChatRoomEntityImpl
        >
    implements _$$CommunityChatRoomEntityImplCopyWith<$Res> {
  __$$CommunityChatRoomEntityImplCopyWithImpl(
    _$CommunityChatRoomEntityImpl _value,
    $Res Function(_$CommunityChatRoomEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatRoomEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? title = null,
    Object? status = null,
    Object? meetingAt = null,
    Object? memberCount = null,
    Object? lastMessage = freezed,
  }) {
    return _then(
      _$CommunityChatRoomEntityImpl(
        postId: null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CommunityPostStatus,
        meetingAt: null == meetingAt
            ? _value.meetingAt
            : meetingAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as CommunityChatLastMessageEntity?,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatRoomEntityImpl implements _CommunityChatRoomEntity {
  const _$CommunityChatRoomEntityImpl({
    required this.postId,
    required this.title,
    required this.status,
    required this.meetingAt,
    required this.memberCount,
    this.lastMessage,
  });

  @override
  final int postId;
  @override
  final String title;
  @override
  final CommunityPostStatus status;
  @override
  final DateTime meetingAt;
  @override
  final int memberCount;
  @override
  final CommunityChatLastMessageEntity? lastMessage;

  @override
  String toString() {
    return 'CommunityChatRoomEntity(postId: $postId, title: $title, status: $status, meetingAt: $meetingAt, memberCount: $memberCount, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatRoomEntityImpl &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.meetingAt, meetingAt) ||
                other.meetingAt == meetingAt) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    postId,
    title,
    status,
    meetingAt,
    memberCount,
    lastMessage,
  );

  /// Create a copy of CommunityChatRoomEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatRoomEntityImplCopyWith<_$CommunityChatRoomEntityImpl>
  get copyWith =>
      __$$CommunityChatRoomEntityImplCopyWithImpl<
        _$CommunityChatRoomEntityImpl
      >(this, _$identity);
}

abstract class _CommunityChatRoomEntity implements CommunityChatRoomEntity {
  const factory _CommunityChatRoomEntity({
    required final int postId,
    required final String title,
    required final CommunityPostStatus status,
    required final DateTime meetingAt,
    required final int memberCount,
    final CommunityChatLastMessageEntity? lastMessage,
  }) = _$CommunityChatRoomEntityImpl;

  @override
  int get postId;
  @override
  String get title;
  @override
  CommunityPostStatus get status;
  @override
  DateTime get meetingAt;
  @override
  int get memberCount;
  @override
  CommunityChatLastMessageEntity? get lastMessage;

  /// Create a copy of CommunityChatRoomEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatRoomEntityImplCopyWith<_$CommunityChatRoomEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
