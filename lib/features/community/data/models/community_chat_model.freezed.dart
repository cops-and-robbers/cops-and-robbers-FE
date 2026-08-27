// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommunityChatLastMessageResponseModel
_$CommunityChatLastMessageResponseModelFromJson(Map<String, dynamic> json) {
  return _CommunityChatLastMessageResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityChatLastMessageResponseModel {
  int get id => throw _privateConstructorUsedError;

  /// 본문. `SYSTEM`·`GAME_INVITE`는 JSON 문자열이다 —
  /// 해석은 `communityChatMessageBodyFromWire`가 한다.
  String? get message => throw _privateConstructorUsedError;
  String? get messageType => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get senderNickname => throw _privateConstructorUsedError;

  /// 프로필 아이콘 번호. 탈퇴자는 기본값이 채워져 온다 (DEC-0041).
  int? get senderProfileIcon => throw _privateConstructorUsedError;

  /// Serializes this CommunityChatLastMessageResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatLastMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatLastMessageResponseModelCopyWith<
    CommunityChatLastMessageResponseModel
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatLastMessageResponseModelCopyWith<$Res> {
  factory $CommunityChatLastMessageResponseModelCopyWith(
    CommunityChatLastMessageResponseModel value,
    $Res Function(CommunityChatLastMessageResponseModel) then,
  ) =
      _$CommunityChatLastMessageResponseModelCopyWithImpl<
        $Res,
        CommunityChatLastMessageResponseModel
      >;
  @useResult
  $Res call({
    int id,
    String? message,
    String? messageType,
    DateTime? createdAt,
    String? senderNickname,
    int? senderProfileIcon,
  });
}

/// @nodoc
class _$CommunityChatLastMessageResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityChatLastMessageResponseModel
>
    implements $CommunityChatLastMessageResponseModelCopyWith<$Res> {
  _$CommunityChatLastMessageResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatLastMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = freezed,
    Object? messageType = freezed,
    Object? createdAt = freezed,
    Object? senderNickname = freezed,
    Object? senderProfileIcon = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            messageType: freezed == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
}

/// @nodoc
abstract class _$$CommunityChatLastMessageResponseModelImplCopyWith<$Res>
    implements $CommunityChatLastMessageResponseModelCopyWith<$Res> {
  factory _$$CommunityChatLastMessageResponseModelImplCopyWith(
    _$CommunityChatLastMessageResponseModelImpl value,
    $Res Function(_$CommunityChatLastMessageResponseModelImpl) then,
  ) = __$$CommunityChatLastMessageResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String? message,
    String? messageType,
    DateTime? createdAt,
    String? senderNickname,
    int? senderProfileIcon,
  });
}

/// @nodoc
class __$$CommunityChatLastMessageResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityChatLastMessageResponseModelCopyWithImpl<
          $Res,
          _$CommunityChatLastMessageResponseModelImpl
        >
    implements _$$CommunityChatLastMessageResponseModelImplCopyWith<$Res> {
  __$$CommunityChatLastMessageResponseModelImplCopyWithImpl(
    _$CommunityChatLastMessageResponseModelImpl _value,
    $Res Function(_$CommunityChatLastMessageResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatLastMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = freezed,
    Object? messageType = freezed,
    Object? createdAt = freezed,
    Object? senderNickname = freezed,
    Object? senderProfileIcon = freezed,
  }) {
    return _then(
      _$CommunityChatLastMessageResponseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        messageType: freezed == messageType
            ? _value.messageType
            : messageType // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
@JsonSerializable()
class _$CommunityChatLastMessageResponseModelImpl
    implements _CommunityChatLastMessageResponseModel {
  const _$CommunityChatLastMessageResponseModelImpl({
    required this.id,
    this.message,
    this.messageType,
    this.createdAt,
    this.senderNickname,
    this.senderProfileIcon,
  });

  factory _$CommunityChatLastMessageResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityChatLastMessageResponseModelImplFromJson(json);

  @override
  final int id;

  /// 본문. `SYSTEM`·`GAME_INVITE`는 JSON 문자열이다 —
  /// 해석은 `communityChatMessageBodyFromWire`가 한다.
  @override
  final String? message;
  @override
  final String? messageType;
  @override
  final DateTime? createdAt;
  @override
  final String? senderNickname;

  /// 프로필 아이콘 번호. 탈퇴자는 기본값이 채워져 온다 (DEC-0041).
  @override
  final int? senderProfileIcon;

  @override
  String toString() {
    return 'CommunityChatLastMessageResponseModel(id: $id, message: $message, messageType: $messageType, createdAt: $createdAt, senderNickname: $senderNickname, senderProfileIcon: $senderProfileIcon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatLastMessageResponseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.senderNickname, senderNickname) ||
                other.senderNickname == senderNickname) &&
            (identical(other.senderProfileIcon, senderProfileIcon) ||
                other.senderProfileIcon == senderProfileIcon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    message,
    messageType,
    createdAt,
    senderNickname,
    senderProfileIcon,
  );

  /// Create a copy of CommunityChatLastMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatLastMessageResponseModelImplCopyWith<
    _$CommunityChatLastMessageResponseModelImpl
  >
  get copyWith =>
      __$$CommunityChatLastMessageResponseModelImplCopyWithImpl<
        _$CommunityChatLastMessageResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityChatLastMessageResponseModelImplToJson(this);
  }
}

abstract class _CommunityChatLastMessageResponseModel
    implements CommunityChatLastMessageResponseModel {
  const factory _CommunityChatLastMessageResponseModel({
    required final int id,
    final String? message,
    final String? messageType,
    final DateTime? createdAt,
    final String? senderNickname,
    final int? senderProfileIcon,
  }) = _$CommunityChatLastMessageResponseModelImpl;

  factory _CommunityChatLastMessageResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityChatLastMessageResponseModelImpl.fromJson;

  @override
  int get id;

  /// 본문. `SYSTEM`·`GAME_INVITE`는 JSON 문자열이다 —
  /// 해석은 `communityChatMessageBodyFromWire`가 한다.
  @override
  String? get message;
  @override
  String? get messageType;
  @override
  DateTime? get createdAt;
  @override
  String? get senderNickname;

  /// 프로필 아이콘 번호. 탈퇴자는 기본값이 채워져 온다 (DEC-0041).
  @override
  int? get senderProfileIcon;

  /// Create a copy of CommunityChatLastMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatLastMessageResponseModelImplCopyWith<
    _$CommunityChatLastMessageResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityChatRoomResponseModel _$CommunityChatRoomResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityChatRoomResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityChatRoomResponseModel {
  int get postId => throw _privateConstructorUsedError;

  /// 게시글 제목. 스키마에 required가 없어 nullable로 받는다 — 제목 한 줄이
  /// 비는 편이 목록 전체가 파싱 실패로 날아가는 것보다 낫다 (LSN-0009).
  String? get title => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  DateTime? get meetingAt => throw _privateConstructorUsedError;
  int? get memberCount => throw _privateConstructorUsedError;

  /// 아직 대화가 없는 방은 null이다. 목록에서 맨 뒤로 밀린다.
  CommunityChatLastMessageResponseModel? get lastMessage =>
      throw _privateConstructorUsedError;

  /// Serializes this CommunityChatRoomResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatRoomResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatRoomResponseModelCopyWith<CommunityChatRoomResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatRoomResponseModelCopyWith<$Res> {
  factory $CommunityChatRoomResponseModelCopyWith(
    CommunityChatRoomResponseModel value,
    $Res Function(CommunityChatRoomResponseModel) then,
  ) =
      _$CommunityChatRoomResponseModelCopyWithImpl<
        $Res,
        CommunityChatRoomResponseModel
      >;
  @useResult
  $Res call({
    int postId,
    String? title,
    String? status,
    DateTime? meetingAt,
    int? memberCount,
    CommunityChatLastMessageResponseModel? lastMessage,
  });

  $CommunityChatLastMessageResponseModelCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$CommunityChatRoomResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityChatRoomResponseModel
>
    implements $CommunityChatRoomResponseModelCopyWith<$Res> {
  _$CommunityChatRoomResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatRoomResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? title = freezed,
    Object? status = freezed,
    Object? meetingAt = freezed,
    Object? memberCount = freezed,
    Object? lastMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            postId: null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            meetingAt: freezed == meetingAt
                ? _value.meetingAt
                : meetingAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            memberCount: freezed == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as CommunityChatLastMessageResponseModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of CommunityChatRoomResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommunityChatLastMessageResponseModelCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $CommunityChatLastMessageResponseModelCopyWith<$Res>(
      _value.lastMessage!,
      (value) {
        return _then(_value.copyWith(lastMessage: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatRoomResponseModelImplCopyWith<$Res>
    implements $CommunityChatRoomResponseModelCopyWith<$Res> {
  factory _$$CommunityChatRoomResponseModelImplCopyWith(
    _$CommunityChatRoomResponseModelImpl value,
    $Res Function(_$CommunityChatRoomResponseModelImpl) then,
  ) = __$$CommunityChatRoomResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int postId,
    String? title,
    String? status,
    DateTime? meetingAt,
    int? memberCount,
    CommunityChatLastMessageResponseModel? lastMessage,
  });

  @override
  $CommunityChatLastMessageResponseModelCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$CommunityChatRoomResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityChatRoomResponseModelCopyWithImpl<
          $Res,
          _$CommunityChatRoomResponseModelImpl
        >
    implements _$$CommunityChatRoomResponseModelImplCopyWith<$Res> {
  __$$CommunityChatRoomResponseModelImplCopyWithImpl(
    _$CommunityChatRoomResponseModelImpl _value,
    $Res Function(_$CommunityChatRoomResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatRoomResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? title = freezed,
    Object? status = freezed,
    Object? meetingAt = freezed,
    Object? memberCount = freezed,
    Object? lastMessage = freezed,
  }) {
    return _then(
      _$CommunityChatRoomResponseModelImpl(
        postId: null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        meetingAt: freezed == meetingAt
            ? _value.meetingAt
            : meetingAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        memberCount: freezed == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as CommunityChatLastMessageResponseModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityChatRoomResponseModelImpl
    implements _CommunityChatRoomResponseModel {
  const _$CommunityChatRoomResponseModelImpl({
    required this.postId,
    this.title,
    this.status,
    this.meetingAt,
    this.memberCount,
    this.lastMessage,
  });

  factory _$CommunityChatRoomResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityChatRoomResponseModelImplFromJson(json);

  @override
  final int postId;

  /// 게시글 제목. 스키마에 required가 없어 nullable로 받는다 — 제목 한 줄이
  /// 비는 편이 목록 전체가 파싱 실패로 날아가는 것보다 낫다 (LSN-0009).
  @override
  final String? title;
  @override
  final String? status;
  @override
  final DateTime? meetingAt;
  @override
  final int? memberCount;

  /// 아직 대화가 없는 방은 null이다. 목록에서 맨 뒤로 밀린다.
  @override
  final CommunityChatLastMessageResponseModel? lastMessage;

  @override
  String toString() {
    return 'CommunityChatRoomResponseModel(postId: $postId, title: $title, status: $status, meetingAt: $meetingAt, memberCount: $memberCount, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatRoomResponseModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of CommunityChatRoomResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatRoomResponseModelImplCopyWith<
    _$CommunityChatRoomResponseModelImpl
  >
  get copyWith =>
      __$$CommunityChatRoomResponseModelImplCopyWithImpl<
        _$CommunityChatRoomResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityChatRoomResponseModelImplToJson(this);
  }
}

abstract class _CommunityChatRoomResponseModel
    implements CommunityChatRoomResponseModel {
  const factory _CommunityChatRoomResponseModel({
    required final int postId,
    final String? title,
    final String? status,
    final DateTime? meetingAt,
    final int? memberCount,
    final CommunityChatLastMessageResponseModel? lastMessage,
  }) = _$CommunityChatRoomResponseModelImpl;

  factory _CommunityChatRoomResponseModel.fromJson(Map<String, dynamic> json) =
      _$CommunityChatRoomResponseModelImpl.fromJson;

  @override
  int get postId;

  /// 게시글 제목. 스키마에 required가 없어 nullable로 받는다 — 제목 한 줄이
  /// 비는 편이 목록 전체가 파싱 실패로 날아가는 것보다 낫다 (LSN-0009).
  @override
  String? get title;
  @override
  String? get status;
  @override
  DateTime? get meetingAt;
  @override
  int? get memberCount;

  /// 아직 대화가 없는 방은 null이다. 목록에서 맨 뒤로 밀린다.
  @override
  CommunityChatLastMessageResponseModel? get lastMessage;

  /// Create a copy of CommunityChatRoomResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatRoomResponseModelImplCopyWith<
    _$CommunityChatRoomResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityChatRoomListResponseModel _$CommunityChatRoomListResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityChatRoomListResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityChatRoomListResponseModel {
  List<CommunityChatRoomResponseModel> get chatRooms =>
      throw _privateConstructorUsedError;

  /// Serializes this CommunityChatRoomListResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatRoomListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatRoomListResponseModelCopyWith<
    CommunityChatRoomListResponseModel
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatRoomListResponseModelCopyWith<$Res> {
  factory $CommunityChatRoomListResponseModelCopyWith(
    CommunityChatRoomListResponseModel value,
    $Res Function(CommunityChatRoomListResponseModel) then,
  ) =
      _$CommunityChatRoomListResponseModelCopyWithImpl<
        $Res,
        CommunityChatRoomListResponseModel
      >;
  @useResult
  $Res call({List<CommunityChatRoomResponseModel> chatRooms});
}

/// @nodoc
class _$CommunityChatRoomListResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityChatRoomListResponseModel
>
    implements $CommunityChatRoomListResponseModelCopyWith<$Res> {
  _$CommunityChatRoomListResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatRoomListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? chatRooms = null}) {
    return _then(
      _value.copyWith(
            chatRooms: null == chatRooms
                ? _value.chatRooms
                : chatRooms // ignore: cast_nullable_to_non_nullable
                      as List<CommunityChatRoomResponseModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatRoomListResponseModelImplCopyWith<$Res>
    implements $CommunityChatRoomListResponseModelCopyWith<$Res> {
  factory _$$CommunityChatRoomListResponseModelImplCopyWith(
    _$CommunityChatRoomListResponseModelImpl value,
    $Res Function(_$CommunityChatRoomListResponseModelImpl) then,
  ) = __$$CommunityChatRoomListResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CommunityChatRoomResponseModel> chatRooms});
}

/// @nodoc
class __$$CommunityChatRoomListResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityChatRoomListResponseModelCopyWithImpl<
          $Res,
          _$CommunityChatRoomListResponseModelImpl
        >
    implements _$$CommunityChatRoomListResponseModelImplCopyWith<$Res> {
  __$$CommunityChatRoomListResponseModelImplCopyWithImpl(
    _$CommunityChatRoomListResponseModelImpl _value,
    $Res Function(_$CommunityChatRoomListResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatRoomListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? chatRooms = null}) {
    return _then(
      _$CommunityChatRoomListResponseModelImpl(
        chatRooms: null == chatRooms
            ? _value._chatRooms
            : chatRooms // ignore: cast_nullable_to_non_nullable
                  as List<CommunityChatRoomResponseModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityChatRoomListResponseModelImpl
    implements _CommunityChatRoomListResponseModel {
  const _$CommunityChatRoomListResponseModelImpl({
    final List<CommunityChatRoomResponseModel> chatRooms =
        const <CommunityChatRoomResponseModel>[],
  }) : _chatRooms = chatRooms;

  factory _$CommunityChatRoomListResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityChatRoomListResponseModelImplFromJson(json);

  final List<CommunityChatRoomResponseModel> _chatRooms;
  @override
  @JsonKey()
  List<CommunityChatRoomResponseModel> get chatRooms {
    if (_chatRooms is EqualUnmodifiableListView) return _chatRooms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chatRooms);
  }

  @override
  String toString() {
    return 'CommunityChatRoomListResponseModel(chatRooms: $chatRooms)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatRoomListResponseModelImpl &&
            const DeepCollectionEquality().equals(
              other._chatRooms,
              _chatRooms,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_chatRooms));

  /// Create a copy of CommunityChatRoomListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatRoomListResponseModelImplCopyWith<
    _$CommunityChatRoomListResponseModelImpl
  >
  get copyWith =>
      __$$CommunityChatRoomListResponseModelImplCopyWithImpl<
        _$CommunityChatRoomListResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityChatRoomListResponseModelImplToJson(this);
  }
}

abstract class _CommunityChatRoomListResponseModel
    implements CommunityChatRoomListResponseModel {
  const factory _CommunityChatRoomListResponseModel({
    final List<CommunityChatRoomResponseModel> chatRooms,
  }) = _$CommunityChatRoomListResponseModelImpl;

  factory _CommunityChatRoomListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityChatRoomListResponseModelImpl.fromJson;

  @override
  List<CommunityChatRoomResponseModel> get chatRooms;

  /// Create a copy of CommunityChatRoomListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatRoomListResponseModelImplCopyWith<
    _$CommunityChatRoomListResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityChatMessageResponseModel _$CommunityChatMessageResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityChatMessageResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityChatMessageResponseModel {
  int get id => throw _privateConstructorUsedError;

  /// 앱이 만든 UUID. 낙관적 말풍선을 에코와 맞추는 열쇠다.
  String? get messageKey => throw _privateConstructorUsedError;
  int? get senderId => throw _privateConstructorUsedError;
  String? get senderNickname => throw _privateConstructorUsedError;

  /// 프로필 아이콘 번호. **REST 내역에만 실린다** — 소켓 브로드캐스트
  /// (`CommunityChatPayload`)에는 아직 없어서 실시간 메시지는 null이다.
  /// 그때는 화면이 기본 아이콘으로 물러선다.
  int? get senderProfileIcon => throw _privateConstructorUsedError;

  /// 본문. `SYSTEM`·`GAME_INVITE`는 JSON 문자열이다.
  String? get message => throw _privateConstructorUsedError;
  String? get messageType => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CommunityChatMessageResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatMessageResponseModelCopyWith<CommunityChatMessageResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatMessageResponseModelCopyWith<$Res> {
  factory $CommunityChatMessageResponseModelCopyWith(
    CommunityChatMessageResponseModel value,
    $Res Function(CommunityChatMessageResponseModel) then,
  ) =
      _$CommunityChatMessageResponseModelCopyWithImpl<
        $Res,
        CommunityChatMessageResponseModel
      >;
  @useResult
  $Res call({
    int id,
    String? messageKey,
    int? senderId,
    String? senderNickname,
    int? senderProfileIcon,
    String? message,
    String? messageType,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CommunityChatMessageResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityChatMessageResponseModel
>
    implements $CommunityChatMessageResponseModelCopyWith<$Res> {
  _$CommunityChatMessageResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageKey = freezed,
    Object? senderId = freezed,
    Object? senderNickname = freezed,
    Object? senderProfileIcon = freezed,
    Object? message = freezed,
    Object? messageType = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            messageKey: freezed == messageKey
                ? _value.messageKey
                : messageKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderId: freezed == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as int?,
            senderNickname: freezed == senderNickname
                ? _value.senderNickname
                : senderNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderProfileIcon: freezed == senderProfileIcon
                ? _value.senderProfileIcon
                : senderProfileIcon // ignore: cast_nullable_to_non_nullable
                      as int?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            messageType: freezed == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatMessageResponseModelImplCopyWith<$Res>
    implements $CommunityChatMessageResponseModelCopyWith<$Res> {
  factory _$$CommunityChatMessageResponseModelImplCopyWith(
    _$CommunityChatMessageResponseModelImpl value,
    $Res Function(_$CommunityChatMessageResponseModelImpl) then,
  ) = __$$CommunityChatMessageResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String? messageKey,
    int? senderId,
    String? senderNickname,
    int? senderProfileIcon,
    String? message,
    String? messageType,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CommunityChatMessageResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMessageResponseModelCopyWithImpl<
          $Res,
          _$CommunityChatMessageResponseModelImpl
        >
    implements _$$CommunityChatMessageResponseModelImplCopyWith<$Res> {
  __$$CommunityChatMessageResponseModelImplCopyWithImpl(
    _$CommunityChatMessageResponseModelImpl _value,
    $Res Function(_$CommunityChatMessageResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageKey = freezed,
    Object? senderId = freezed,
    Object? senderNickname = freezed,
    Object? senderProfileIcon = freezed,
    Object? message = freezed,
    Object? messageType = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CommunityChatMessageResponseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        messageKey: freezed == messageKey
            ? _value.messageKey
            : messageKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        senderId: freezed == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as int?,
        senderNickname: freezed == senderNickname
            ? _value.senderNickname
            : senderNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        senderProfileIcon: freezed == senderProfileIcon
            ? _value.senderProfileIcon
            : senderProfileIcon // ignore: cast_nullable_to_non_nullable
                  as int?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        messageType: freezed == messageType
            ? _value.messageType
            : messageType // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityChatMessageResponseModelImpl
    implements _CommunityChatMessageResponseModel {
  const _$CommunityChatMessageResponseModelImpl({
    required this.id,
    this.messageKey,
    this.senderId,
    this.senderNickname,
    this.senderProfileIcon,
    this.message,
    this.messageType,
    this.createdAt,
  });

  factory _$CommunityChatMessageResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityChatMessageResponseModelImplFromJson(json);

  @override
  final int id;

  /// 앱이 만든 UUID. 낙관적 말풍선을 에코와 맞추는 열쇠다.
  @override
  final String? messageKey;
  @override
  final int? senderId;
  @override
  final String? senderNickname;

  /// 프로필 아이콘 번호. **REST 내역에만 실린다** — 소켓 브로드캐스트
  /// (`CommunityChatPayload`)에는 아직 없어서 실시간 메시지는 null이다.
  /// 그때는 화면이 기본 아이콘으로 물러선다.
  @override
  final int? senderProfileIcon;

  /// 본문. `SYSTEM`·`GAME_INVITE`는 JSON 문자열이다.
  @override
  final String? message;
  @override
  final String? messageType;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CommunityChatMessageResponseModel(id: $id, messageKey: $messageKey, senderId: $senderId, senderNickname: $senderNickname, senderProfileIcon: $senderProfileIcon, message: $message, messageType: $messageType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatMessageResponseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageKey, messageKey) ||
                other.messageKey == messageKey) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderNickname, senderNickname) ||
                other.senderNickname == senderNickname) &&
            (identical(other.senderProfileIcon, senderProfileIcon) ||
                other.senderProfileIcon == senderProfileIcon) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    messageKey,
    senderId,
    senderNickname,
    senderProfileIcon,
    message,
    messageType,
    createdAt,
  );

  /// Create a copy of CommunityChatMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatMessageResponseModelImplCopyWith<
    _$CommunityChatMessageResponseModelImpl
  >
  get copyWith =>
      __$$CommunityChatMessageResponseModelImplCopyWithImpl<
        _$CommunityChatMessageResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityChatMessageResponseModelImplToJson(this);
  }
}

abstract class _CommunityChatMessageResponseModel
    implements CommunityChatMessageResponseModel {
  const factory _CommunityChatMessageResponseModel({
    required final int id,
    final String? messageKey,
    final int? senderId,
    final String? senderNickname,
    final int? senderProfileIcon,
    final String? message,
    final String? messageType,
    final DateTime? createdAt,
  }) = _$CommunityChatMessageResponseModelImpl;

  factory _CommunityChatMessageResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityChatMessageResponseModelImpl.fromJson;

  @override
  int get id;

  /// 앱이 만든 UUID. 낙관적 말풍선을 에코와 맞추는 열쇠다.
  @override
  String? get messageKey;
  @override
  int? get senderId;
  @override
  String? get senderNickname;

  /// 프로필 아이콘 번호. **REST 내역에만 실린다** — 소켓 브로드캐스트
  /// (`CommunityChatPayload`)에는 아직 없어서 실시간 메시지는 null이다.
  /// 그때는 화면이 기본 아이콘으로 물러선다.
  @override
  int? get senderProfileIcon;

  /// 본문. `SYSTEM`·`GAME_INVITE`는 JSON 문자열이다.
  @override
  String? get message;
  @override
  String? get messageType;
  @override
  DateTime? get createdAt;

  /// Create a copy of CommunityChatMessageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatMessageResponseModelImplCopyWith<
    _$CommunityChatMessageResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityChatHistoryResponseModel _$CommunityChatHistoryResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityChatHistoryResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityChatHistoryResponseModel {
  List<CommunityChatMessageResponseModel> get messages =>
      throw _privateConstructorUsedError;
  int? get nextCursor => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;

  /// Serializes this CommunityChatHistoryResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatHistoryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatHistoryResponseModelCopyWith<CommunityChatHistoryResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatHistoryResponseModelCopyWith<$Res> {
  factory $CommunityChatHistoryResponseModelCopyWith(
    CommunityChatHistoryResponseModel value,
    $Res Function(CommunityChatHistoryResponseModel) then,
  ) =
      _$CommunityChatHistoryResponseModelCopyWithImpl<
        $Res,
        CommunityChatHistoryResponseModel
      >;
  @useResult
  $Res call({
    List<CommunityChatMessageResponseModel> messages,
    int? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class _$CommunityChatHistoryResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityChatHistoryResponseModel
>
    implements $CommunityChatHistoryResponseModelCopyWith<$Res> {
  _$CommunityChatHistoryResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatHistoryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? nextCursor = freezed,
    Object? hasNext = null,
  }) {
    return _then(
      _value.copyWith(
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<CommunityChatMessageResponseModel>,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as int?,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatHistoryResponseModelImplCopyWith<$Res>
    implements $CommunityChatHistoryResponseModelCopyWith<$Res> {
  factory _$$CommunityChatHistoryResponseModelImplCopyWith(
    _$CommunityChatHistoryResponseModelImpl value,
    $Res Function(_$CommunityChatHistoryResponseModelImpl) then,
  ) = __$$CommunityChatHistoryResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CommunityChatMessageResponseModel> messages,
    int? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class __$$CommunityChatHistoryResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityChatHistoryResponseModelCopyWithImpl<
          $Res,
          _$CommunityChatHistoryResponseModelImpl
        >
    implements _$$CommunityChatHistoryResponseModelImplCopyWith<$Res> {
  __$$CommunityChatHistoryResponseModelImplCopyWithImpl(
    _$CommunityChatHistoryResponseModelImpl _value,
    $Res Function(_$CommunityChatHistoryResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatHistoryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? nextCursor = freezed,
    Object? hasNext = null,
  }) {
    return _then(
      _$CommunityChatHistoryResponseModelImpl(
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<CommunityChatMessageResponseModel>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as int?,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityChatHistoryResponseModelImpl
    implements _CommunityChatHistoryResponseModel {
  const _$CommunityChatHistoryResponseModelImpl({
    final List<CommunityChatMessageResponseModel> messages =
        const <CommunityChatMessageResponseModel>[],
    this.nextCursor,
    this.hasNext = false,
  }) : _messages = messages;

  factory _$CommunityChatHistoryResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityChatHistoryResponseModelImplFromJson(json);

  final List<CommunityChatMessageResponseModel> _messages;
  @override
  @JsonKey()
  List<CommunityChatMessageResponseModel> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final int? nextCursor;
  @override
  @JsonKey()
  final bool hasNext;

  @override
  String toString() {
    return 'CommunityChatHistoryResponseModel(messages: $messages, nextCursor: $nextCursor, hasNext: $hasNext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatHistoryResponseModelImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_messages),
    nextCursor,
    hasNext,
  );

  /// Create a copy of CommunityChatHistoryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatHistoryResponseModelImplCopyWith<
    _$CommunityChatHistoryResponseModelImpl
  >
  get copyWith =>
      __$$CommunityChatHistoryResponseModelImplCopyWithImpl<
        _$CommunityChatHistoryResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityChatHistoryResponseModelImplToJson(this);
  }
}

abstract class _CommunityChatHistoryResponseModel
    implements CommunityChatHistoryResponseModel {
  const factory _CommunityChatHistoryResponseModel({
    final List<CommunityChatMessageResponseModel> messages,
    final int? nextCursor,
    final bool hasNext,
  }) = _$CommunityChatHistoryResponseModelImpl;

  factory _CommunityChatHistoryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityChatHistoryResponseModelImpl.fromJson;

  @override
  List<CommunityChatMessageResponseModel> get messages;
  @override
  int? get nextCursor;
  @override
  bool get hasNext;

  /// Create a copy of CommunityChatHistoryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatHistoryResponseModelImplCopyWith<
    _$CommunityChatHistoryResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityChatMemberResponseModel _$CommunityChatMemberResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityChatMemberResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityChatMemberResponseModel {
  int get userId => throw _privateConstructorUsedError;

  /// 탈퇴한 유저면 `"알수없음"`이 채워져 온다 (DEC-0041 — 자리를 비우지 않는다).
  String? get nickname => throw _privateConstructorUsedError;
  int? get profileIcon => throw _privateConstructorUsedError;
  bool get isAuthor => throw _privateConstructorUsedError;

  /// Serializes this CommunityChatMemberResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatMemberResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatMemberResponseModelCopyWith<CommunityChatMemberResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatMemberResponseModelCopyWith<$Res> {
  factory $CommunityChatMemberResponseModelCopyWith(
    CommunityChatMemberResponseModel value,
    $Res Function(CommunityChatMemberResponseModel) then,
  ) =
      _$CommunityChatMemberResponseModelCopyWithImpl<
        $Res,
        CommunityChatMemberResponseModel
      >;
  @useResult
  $Res call({int userId, String? nickname, int? profileIcon, bool isAuthor});
}

/// @nodoc
class _$CommunityChatMemberResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityChatMemberResponseModel
>
    implements $CommunityChatMemberResponseModelCopyWith<$Res> {
  _$CommunityChatMemberResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatMemberResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = freezed,
    Object? profileIcon = freezed,
    Object? isAuthor = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            nickname: freezed == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileIcon: freezed == profileIcon
                ? _value.profileIcon
                : profileIcon // ignore: cast_nullable_to_non_nullable
                      as int?,
            isAuthor: null == isAuthor
                ? _value.isAuthor
                : isAuthor // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatMemberResponseModelImplCopyWith<$Res>
    implements $CommunityChatMemberResponseModelCopyWith<$Res> {
  factory _$$CommunityChatMemberResponseModelImplCopyWith(
    _$CommunityChatMemberResponseModelImpl value,
    $Res Function(_$CommunityChatMemberResponseModelImpl) then,
  ) = __$$CommunityChatMemberResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, String? nickname, int? profileIcon, bool isAuthor});
}

/// @nodoc
class __$$CommunityChatMemberResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMemberResponseModelCopyWithImpl<
          $Res,
          _$CommunityChatMemberResponseModelImpl
        >
    implements _$$CommunityChatMemberResponseModelImplCopyWith<$Res> {
  __$$CommunityChatMemberResponseModelImplCopyWithImpl(
    _$CommunityChatMemberResponseModelImpl _value,
    $Res Function(_$CommunityChatMemberResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMemberResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = freezed,
    Object? profileIcon = freezed,
    Object? isAuthor = null,
  }) {
    return _then(
      _$CommunityChatMemberResponseModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: freezed == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileIcon: freezed == profileIcon
            ? _value.profileIcon
            : profileIcon // ignore: cast_nullable_to_non_nullable
                  as int?,
        isAuthor: null == isAuthor
            ? _value.isAuthor
            : isAuthor // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityChatMemberResponseModelImpl
    implements _CommunityChatMemberResponseModel {
  const _$CommunityChatMemberResponseModelImpl({
    required this.userId,
    this.nickname,
    this.profileIcon,
    this.isAuthor = false,
  });

  factory _$CommunityChatMemberResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityChatMemberResponseModelImplFromJson(json);

  @override
  final int userId;

  /// 탈퇴한 유저면 `"알수없음"`이 채워져 온다 (DEC-0041 — 자리를 비우지 않는다).
  @override
  final String? nickname;
  @override
  final int? profileIcon;
  @override
  @JsonKey()
  final bool isAuthor;

  @override
  String toString() {
    return 'CommunityChatMemberResponseModel(userId: $userId, nickname: $nickname, profileIcon: $profileIcon, isAuthor: $isAuthor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatMemberResponseModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileIcon, profileIcon) ||
                other.profileIcon == profileIcon) &&
            (identical(other.isAuthor, isAuthor) ||
                other.isAuthor == isAuthor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, nickname, profileIcon, isAuthor);

  /// Create a copy of CommunityChatMemberResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatMemberResponseModelImplCopyWith<
    _$CommunityChatMemberResponseModelImpl
  >
  get copyWith =>
      __$$CommunityChatMemberResponseModelImplCopyWithImpl<
        _$CommunityChatMemberResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityChatMemberResponseModelImplToJson(this);
  }
}

abstract class _CommunityChatMemberResponseModel
    implements CommunityChatMemberResponseModel {
  const factory _CommunityChatMemberResponseModel({
    required final int userId,
    final String? nickname,
    final int? profileIcon,
    final bool isAuthor,
  }) = _$CommunityChatMemberResponseModelImpl;

  factory _CommunityChatMemberResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityChatMemberResponseModelImpl.fromJson;

  @override
  int get userId;

  /// 탈퇴한 유저면 `"알수없음"`이 채워져 온다 (DEC-0041 — 자리를 비우지 않는다).
  @override
  String? get nickname;
  @override
  int? get profileIcon;
  @override
  bool get isAuthor;

  /// Create a copy of CommunityChatMemberResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatMemberResponseModelImplCopyWith<
    _$CommunityChatMemberResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityChatMemberListResponseModel
_$CommunityChatMemberListResponseModelFromJson(Map<String, dynamic> json) {
  return _CommunityChatMemberListResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityChatMemberListResponseModel {
  List<CommunityChatMemberResponseModel> get members =>
      throw _privateConstructorUsedError;

  /// Serializes this CommunityChatMemberListResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatMemberListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatMemberListResponseModelCopyWith<
    CommunityChatMemberListResponseModel
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatMemberListResponseModelCopyWith<$Res> {
  factory $CommunityChatMemberListResponseModelCopyWith(
    CommunityChatMemberListResponseModel value,
    $Res Function(CommunityChatMemberListResponseModel) then,
  ) =
      _$CommunityChatMemberListResponseModelCopyWithImpl<
        $Res,
        CommunityChatMemberListResponseModel
      >;
  @useResult
  $Res call({List<CommunityChatMemberResponseModel> members});
}

/// @nodoc
class _$CommunityChatMemberListResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityChatMemberListResponseModel
>
    implements $CommunityChatMemberListResponseModelCopyWith<$Res> {
  _$CommunityChatMemberListResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatMemberListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? members = null}) {
    return _then(
      _value.copyWith(
            members: null == members
                ? _value.members
                : members // ignore: cast_nullable_to_non_nullable
                      as List<CommunityChatMemberResponseModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatMemberListResponseModelImplCopyWith<$Res>
    implements $CommunityChatMemberListResponseModelCopyWith<$Res> {
  factory _$$CommunityChatMemberListResponseModelImplCopyWith(
    _$CommunityChatMemberListResponseModelImpl value,
    $Res Function(_$CommunityChatMemberListResponseModelImpl) then,
  ) = __$$CommunityChatMemberListResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CommunityChatMemberResponseModel> members});
}

/// @nodoc
class __$$CommunityChatMemberListResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMemberListResponseModelCopyWithImpl<
          $Res,
          _$CommunityChatMemberListResponseModelImpl
        >
    implements _$$CommunityChatMemberListResponseModelImplCopyWith<$Res> {
  __$$CommunityChatMemberListResponseModelImplCopyWithImpl(
    _$CommunityChatMemberListResponseModelImpl _value,
    $Res Function(_$CommunityChatMemberListResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMemberListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? members = null}) {
    return _then(
      _$CommunityChatMemberListResponseModelImpl(
        members: null == members
            ? _value._members
            : members // ignore: cast_nullable_to_non_nullable
                  as List<CommunityChatMemberResponseModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityChatMemberListResponseModelImpl
    implements _CommunityChatMemberListResponseModel {
  const _$CommunityChatMemberListResponseModelImpl({
    final List<CommunityChatMemberResponseModel> members =
        const <CommunityChatMemberResponseModel>[],
  }) : _members = members;

  factory _$CommunityChatMemberListResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityChatMemberListResponseModelImplFromJson(json);

  final List<CommunityChatMemberResponseModel> _members;
  @override
  @JsonKey()
  List<CommunityChatMemberResponseModel> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  String toString() {
    return 'CommunityChatMemberListResponseModel(members: $members)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatMemberListResponseModelImpl &&
            const DeepCollectionEquality().equals(other._members, _members));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_members));

  /// Create a copy of CommunityChatMemberListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatMemberListResponseModelImplCopyWith<
    _$CommunityChatMemberListResponseModelImpl
  >
  get copyWith =>
      __$$CommunityChatMemberListResponseModelImplCopyWithImpl<
        _$CommunityChatMemberListResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityChatMemberListResponseModelImplToJson(this);
  }
}

abstract class _CommunityChatMemberListResponseModel
    implements CommunityChatMemberListResponseModel {
  const factory _CommunityChatMemberListResponseModel({
    final List<CommunityChatMemberResponseModel> members,
  }) = _$CommunityChatMemberListResponseModelImpl;

  factory _CommunityChatMemberListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityChatMemberListResponseModelImpl.fromJson;

  @override
  List<CommunityChatMemberResponseModel> get members;

  /// Create a copy of CommunityChatMemberListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatMemberListResponseModelImplCopyWith<
    _$CommunityChatMemberListResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
