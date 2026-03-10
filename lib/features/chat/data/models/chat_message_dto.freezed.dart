// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessageDto _$ChatMessageDtoFromJson(Map<String, dynamic> json) {
  return _ChatMessageDto.fromJson(json);
}

/// @nodoc
mixin _$ChatMessageDto {
  String get id => throw _privateConstructorUsedError;
  int get gameId => throw _privateConstructorUsedError;
  ChatSenderDto get sender => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;
  String get scope => throw _privateConstructorUsedError;

  /// Serializes this ChatMessageDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageDtoCopyWith<ChatMessageDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageDtoCopyWith<$Res> {
  factory $ChatMessageDtoCopyWith(
    ChatMessageDto value,
    $Res Function(ChatMessageDto) then,
  ) = _$ChatMessageDtoCopyWithImpl<$Res, ChatMessageDto>;
  @useResult
  $Res call({
    String id,
    int gameId,
    ChatSenderDto sender,
    String message,
    String timestamp,
    String scope,
  });

  $ChatSenderDtoCopyWith<$Res> get sender;
}

/// @nodoc
class _$ChatMessageDtoCopyWithImpl<$Res, $Val extends ChatMessageDto>
    implements $ChatMessageDtoCopyWith<$Res> {
  _$ChatMessageDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? sender = null,
    Object? message = null,
    Object? timestamp = null,
    Object? scope = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as int,
            sender: null == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                      as ChatSenderDto,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as String,
            scope: null == scope
                ? _value.scope
                : scope // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatSenderDtoCopyWith<$Res> get sender {
    return $ChatSenderDtoCopyWith<$Res>(_value.sender, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatMessageDtoImplCopyWith<$Res>
    implements $ChatMessageDtoCopyWith<$Res> {
  factory _$$ChatMessageDtoImplCopyWith(
    _$ChatMessageDtoImpl value,
    $Res Function(_$ChatMessageDtoImpl) then,
  ) = __$$ChatMessageDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int gameId,
    ChatSenderDto sender,
    String message,
    String timestamp,
    String scope,
  });

  @override
  $ChatSenderDtoCopyWith<$Res> get sender;
}

/// @nodoc
class __$$ChatMessageDtoImplCopyWithImpl<$Res>
    extends _$ChatMessageDtoCopyWithImpl<$Res, _$ChatMessageDtoImpl>
    implements _$$ChatMessageDtoImplCopyWith<$Res> {
  __$$ChatMessageDtoImplCopyWithImpl(
    _$ChatMessageDtoImpl _value,
    $Res Function(_$ChatMessageDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? sender = null,
    Object? message = null,
    Object? timestamp = null,
    Object? scope = null,
  }) {
    return _then(
      _$ChatMessageDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as int,
        sender: null == sender
            ? _value.sender
            : sender // ignore: cast_nullable_to_non_nullable
                  as ChatSenderDto,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as String,
        scope: null == scope
            ? _value.scope
            : scope // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageDtoImpl implements _ChatMessageDto {
  const _$ChatMessageDtoImpl({
    required this.id,
    required this.gameId,
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.scope,
  });

  factory _$ChatMessageDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageDtoImplFromJson(json);

  @override
  final String id;
  @override
  final int gameId;
  @override
  final ChatSenderDto sender;
  @override
  final String message;
  @override
  final String timestamp;
  @override
  final String scope;

  @override
  String toString() {
    return 'ChatMessageDto(id: $id, gameId: $gameId, sender: $sender, message: $message, timestamp: $timestamp, scope: $scope)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.scope, scope) || other.scope == scope));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, gameId, sender, message, timestamp, scope);

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageDtoImplCopyWith<_$ChatMessageDtoImpl> get copyWith =>
      __$$ChatMessageDtoImplCopyWithImpl<_$ChatMessageDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageDtoImplToJson(this);
  }
}

abstract class _ChatMessageDto implements ChatMessageDto {
  const factory _ChatMessageDto({
    required final String id,
    required final int gameId,
    required final ChatSenderDto sender,
    required final String message,
    required final String timestamp,
    required final String scope,
  }) = _$ChatMessageDtoImpl;

  factory _ChatMessageDto.fromJson(Map<String, dynamic> json) =
      _$ChatMessageDtoImpl.fromJson;

  @override
  String get id;
  @override
  int get gameId;
  @override
  ChatSenderDto get sender;
  @override
  String get message;
  @override
  String get timestamp;
  @override
  String get scope;

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageDtoImplCopyWith<_$ChatMessageDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatSenderDto _$ChatSenderDtoFromJson(Map<String, dynamic> json) {
  return _ChatSenderDto.fromJson(json);
}

/// @nodoc
mixin _$ChatSenderDto {
  int get participantId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get team => throw _privateConstructorUsedError;

  /// Serializes this ChatSenderDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatSenderDtoCopyWith<ChatSenderDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatSenderDtoCopyWith<$Res> {
  factory $ChatSenderDtoCopyWith(
    ChatSenderDto value,
    $Res Function(ChatSenderDto) then,
  ) = _$ChatSenderDtoCopyWithImpl<$Res, ChatSenderDto>;
  @useResult
  $Res call({int participantId, String nickname, String team});
}

/// @nodoc
class _$ChatSenderDtoCopyWithImpl<$Res, $Val extends ChatSenderDto>
    implements $ChatSenderDtoCopyWith<$Res> {
  _$ChatSenderDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? team = null,
  }) {
    return _then(
      _value.copyWith(
            participantId: null == participantId
                ? _value.participantId
                : participantId // ignore: cast_nullable_to_non_nullable
                      as int,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            team: null == team
                ? _value.team
                : team // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatSenderDtoImplCopyWith<$Res>
    implements $ChatSenderDtoCopyWith<$Res> {
  factory _$$ChatSenderDtoImplCopyWith(
    _$ChatSenderDtoImpl value,
    $Res Function(_$ChatSenderDtoImpl) then,
  ) = __$$ChatSenderDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int participantId, String nickname, String team});
}

/// @nodoc
class __$$ChatSenderDtoImplCopyWithImpl<$Res>
    extends _$ChatSenderDtoCopyWithImpl<$Res, _$ChatSenderDtoImpl>
    implements _$$ChatSenderDtoImplCopyWith<$Res> {
  __$$ChatSenderDtoImplCopyWithImpl(
    _$ChatSenderDtoImpl _value,
    $Res Function(_$ChatSenderDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? team = null,
  }) {
    return _then(
      _$ChatSenderDtoImpl(
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        team: null == team
            ? _value.team
            : team // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatSenderDtoImpl implements _ChatSenderDto {
  const _$ChatSenderDtoImpl({
    required this.participantId,
    required this.nickname,
    required this.team,
  });

  factory _$ChatSenderDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatSenderDtoImplFromJson(json);

  @override
  final int participantId;
  @override
  final String nickname;
  @override
  final String team;

  @override
  String toString() {
    return 'ChatSenderDto(participantId: $participantId, nickname: $nickname, team: $team)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatSenderDtoImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.team, team) || other.team == team));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, participantId, nickname, team);

  /// Create a copy of ChatSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatSenderDtoImplCopyWith<_$ChatSenderDtoImpl> get copyWith =>
      __$$ChatSenderDtoImplCopyWithImpl<_$ChatSenderDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatSenderDtoImplToJson(this);
  }
}

abstract class _ChatSenderDto implements ChatSenderDto {
  const factory _ChatSenderDto({
    required final int participantId,
    required final String nickname,
    required final String team,
  }) = _$ChatSenderDtoImpl;

  factory _ChatSenderDto.fromJson(Map<String, dynamic> json) =
      _$ChatSenderDtoImpl.fromJson;

  @override
  int get participantId;
  @override
  String get nickname;
  @override
  String get team;

  /// Create a copy of ChatSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatSenderDtoImplCopyWith<_$ChatSenderDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
