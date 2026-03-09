// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lobby_event_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LobbyEventDto _$LobbyEventDtoFromJson(Map<String, dynamic> json) {
  return _LobbyEventDto.fromJson(json);
}

/// @nodoc
mixin _$LobbyEventDto {
  String get eventId => throw _privateConstructorUsedError;
  int get gameId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;

  /// Serializes this LobbyEventDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LobbyEventDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LobbyEventDtoCopyWith<LobbyEventDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LobbyEventDtoCopyWith<$Res> {
  factory $LobbyEventDtoCopyWith(
    LobbyEventDto value,
    $Res Function(LobbyEventDto) then,
  ) = _$LobbyEventDtoCopyWithImpl<$Res, LobbyEventDto>;
  @useResult
  $Res call({
    String eventId,
    int gameId,
    String type,
    String timestamp,
    Map<String, dynamic> data,
  });
}

/// @nodoc
class _$LobbyEventDtoCopyWithImpl<$Res, $Val extends LobbyEventDto>
    implements $LobbyEventDtoCopyWith<$Res> {
  _$LobbyEventDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LobbyEventDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? gameId = null,
    Object? type = null,
    Object? timestamp = null,
    Object? data = null,
  }) {
    return _then(
      _value.copyWith(
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as int,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LobbyEventDtoImplCopyWith<$Res>
    implements $LobbyEventDtoCopyWith<$Res> {
  factory _$$LobbyEventDtoImplCopyWith(
    _$LobbyEventDtoImpl value,
    $Res Function(_$LobbyEventDtoImpl) then,
  ) = __$$LobbyEventDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String eventId,
    int gameId,
    String type,
    String timestamp,
    Map<String, dynamic> data,
  });
}

/// @nodoc
class __$$LobbyEventDtoImplCopyWithImpl<$Res>
    extends _$LobbyEventDtoCopyWithImpl<$Res, _$LobbyEventDtoImpl>
    implements _$$LobbyEventDtoImplCopyWith<$Res> {
  __$$LobbyEventDtoImplCopyWithImpl(
    _$LobbyEventDtoImpl _value,
    $Res Function(_$LobbyEventDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LobbyEventDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? gameId = null,
    Object? type = null,
    Object? timestamp = null,
    Object? data = null,
  }) {
    return _then(
      _$LobbyEventDtoImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LobbyEventDtoImpl implements _LobbyEventDto {
  const _$LobbyEventDtoImpl({
    required this.eventId,
    required this.gameId,
    required this.type,
    required this.timestamp,
    final Map<String, dynamic> data = const {},
  }) : _data = data;

  factory _$LobbyEventDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LobbyEventDtoImplFromJson(json);

  @override
  final String eventId;
  @override
  final int gameId;
  @override
  final String type;
  @override
  final String timestamp;
  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  String toString() {
    return 'LobbyEventDto(eventId: $eventId, gameId: $gameId, type: $type, timestamp: $timestamp, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LobbyEventDtoImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventId,
    gameId,
    type,
    timestamp,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of LobbyEventDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LobbyEventDtoImplCopyWith<_$LobbyEventDtoImpl> get copyWith =>
      __$$LobbyEventDtoImplCopyWithImpl<_$LobbyEventDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LobbyEventDtoImplToJson(this);
  }
}

abstract class _LobbyEventDto implements LobbyEventDto {
  const factory _LobbyEventDto({
    required final String eventId,
    required final int gameId,
    required final String type,
    required final String timestamp,
    final Map<String, dynamic> data,
  }) = _$LobbyEventDtoImpl;

  factory _LobbyEventDto.fromJson(Map<String, dynamic> json) =
      _$LobbyEventDtoImpl.fromJson;

  @override
  String get eventId;
  @override
  int get gameId;
  @override
  String get type;
  @override
  String get timestamp;
  @override
  Map<String, dynamic> get data;

  /// Create a copy of LobbyEventDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LobbyEventDtoImplCopyWith<_$LobbyEventDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameStartData _$GameStartDataFromJson(Map<String, dynamic> json) {
  return _GameStartData.fromJson(json);
}

/// @nodoc
mixin _$GameStartData {
  String get message => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;

  /// Serializes this GameStartData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameStartData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStartDataCopyWith<GameStartData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStartDataCopyWith<$Res> {
  factory $GameStartDataCopyWith(
    GameStartData value,
    $Res Function(GameStartData) then,
  ) = _$GameStartDataCopyWithImpl<$Res, GameStartData>;
  @useResult
  $Res call({String message, String startTime});
}

/// @nodoc
class _$GameStartDataCopyWithImpl<$Res, $Val extends GameStartData>
    implements $GameStartDataCopyWith<$Res> {
  _$GameStartDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameStartData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? startTime = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameStartDataImplCopyWith<$Res>
    implements $GameStartDataCopyWith<$Res> {
  factory _$$GameStartDataImplCopyWith(
    _$GameStartDataImpl value,
    $Res Function(_$GameStartDataImpl) then,
  ) = __$$GameStartDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String startTime});
}

/// @nodoc
class __$$GameStartDataImplCopyWithImpl<$Res>
    extends _$GameStartDataCopyWithImpl<$Res, _$GameStartDataImpl>
    implements _$$GameStartDataImplCopyWith<$Res> {
  __$$GameStartDataImplCopyWithImpl(
    _$GameStartDataImpl _value,
    $Res Function(_$GameStartDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameStartData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? startTime = null}) {
    return _then(
      _$GameStartDataImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStartDataImpl implements _GameStartData {
  const _$GameStartDataImpl({required this.message, required this.startTime});

  factory _$GameStartDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStartDataImplFromJson(json);

  @override
  final String message;
  @override
  final String startTime;

  @override
  String toString() {
    return 'GameStartData(message: $message, startTime: $startTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStartDataImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, startTime);

  /// Create a copy of GameStartData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStartDataImplCopyWith<_$GameStartDataImpl> get copyWith =>
      __$$GameStartDataImplCopyWithImpl<_$GameStartDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStartDataImplToJson(this);
  }
}

abstract class _GameStartData implements GameStartData {
  const factory _GameStartData({
    required final String message,
    required final String startTime,
  }) = _$GameStartDataImpl;

  factory _GameStartData.fromJson(Map<String, dynamic> json) =
      _$GameStartDataImpl.fromJson;

  @override
  String get message;
  @override
  String get startTime;

  /// Create a copy of GameStartData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStartDataImplCopyWith<_$GameStartDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LobbyParticipantInfo _$LobbyParticipantInfoFromJson(Map<String, dynamic> json) {
  return _LobbyParticipantInfo.fromJson(json);
}

/// @nodoc
mixin _$LobbyParticipantInfo {
  int get participantId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get team => throw _privateConstructorUsedError;
  bool get isReady => throw _privateConstructorUsedError;

  /// Serializes this LobbyParticipantInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LobbyParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LobbyParticipantInfoCopyWith<LobbyParticipantInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LobbyParticipantInfoCopyWith<$Res> {
  factory $LobbyParticipantInfoCopyWith(
    LobbyParticipantInfo value,
    $Res Function(LobbyParticipantInfo) then,
  ) = _$LobbyParticipantInfoCopyWithImpl<$Res, LobbyParticipantInfo>;
  @useResult
  $Res call({int participantId, String nickname, String team, bool isReady});
}

/// @nodoc
class _$LobbyParticipantInfoCopyWithImpl<
  $Res,
  $Val extends LobbyParticipantInfo
>
    implements $LobbyParticipantInfoCopyWith<$Res> {
  _$LobbyParticipantInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LobbyParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? team = null,
    Object? isReady = null,
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
            isReady: null == isReady
                ? _value.isReady
                : isReady // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LobbyParticipantInfoImplCopyWith<$Res>
    implements $LobbyParticipantInfoCopyWith<$Res> {
  factory _$$LobbyParticipantInfoImplCopyWith(
    _$LobbyParticipantInfoImpl value,
    $Res Function(_$LobbyParticipantInfoImpl) then,
  ) = __$$LobbyParticipantInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int participantId, String nickname, String team, bool isReady});
}

/// @nodoc
class __$$LobbyParticipantInfoImplCopyWithImpl<$Res>
    extends _$LobbyParticipantInfoCopyWithImpl<$Res, _$LobbyParticipantInfoImpl>
    implements _$$LobbyParticipantInfoImplCopyWith<$Res> {
  __$$LobbyParticipantInfoImplCopyWithImpl(
    _$LobbyParticipantInfoImpl _value,
    $Res Function(_$LobbyParticipantInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LobbyParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? team = null,
    Object? isReady = null,
  }) {
    return _then(
      _$LobbyParticipantInfoImpl(
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
        isReady: null == isReady
            ? _value.isReady
            : isReady // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LobbyParticipantInfoImpl implements _LobbyParticipantInfo {
  const _$LobbyParticipantInfoImpl({
    required this.participantId,
    required this.nickname,
    required this.team,
    required this.isReady,
  });

  factory _$LobbyParticipantInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LobbyParticipantInfoImplFromJson(json);

  @override
  final int participantId;
  @override
  final String nickname;
  @override
  final String team;
  @override
  final bool isReady;

  @override
  String toString() {
    return 'LobbyParticipantInfo(participantId: $participantId, nickname: $nickname, team: $team, isReady: $isReady)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LobbyParticipantInfoImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.team, team) || other.team == team) &&
            (identical(other.isReady, isReady) || other.isReady == isReady));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, participantId, nickname, team, isReady);

  /// Create a copy of LobbyParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LobbyParticipantInfoImplCopyWith<_$LobbyParticipantInfoImpl>
  get copyWith =>
      __$$LobbyParticipantInfoImplCopyWithImpl<_$LobbyParticipantInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LobbyParticipantInfoImplToJson(this);
  }
}

abstract class _LobbyParticipantInfo implements LobbyParticipantInfo {
  const factory _LobbyParticipantInfo({
    required final int participantId,
    required final String nickname,
    required final String team,
    required final bool isReady,
  }) = _$LobbyParticipantInfoImpl;

  factory _LobbyParticipantInfo.fromJson(Map<String, dynamic> json) =
      _$LobbyParticipantInfoImpl.fromJson;

  @override
  int get participantId;
  @override
  String get nickname;
  @override
  String get team;
  @override
  bool get isReady;

  /// Create a copy of LobbyParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LobbyParticipantInfoImplCopyWith<_$LobbyParticipantInfoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
