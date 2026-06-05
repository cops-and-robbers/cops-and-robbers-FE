// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ping_message_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PingMessageDto _$PingMessageDtoFromJson(Map<String, dynamic> json) {
  return _PingMessageDto.fromJson(json);
}

/// @nodoc
mixin _$PingMessageDto {
  String get id => throw _privateConstructorUsedError; // 서버 UUID
  int get gameId => throw _privateConstructorUsedError;
  String get pingType =>
      throw _privateConstructorUsedError; // "FOUND" | "SUSPECT" | "HELP" — String으로 받는다
  PingLocationDto get location => throw _privateConstructorUsedError;
  PingSenderDto get pingSender => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;

  /// Serializes this PingMessageDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PingMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PingMessageDtoCopyWith<PingMessageDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PingMessageDtoCopyWith<$Res> {
  factory $PingMessageDtoCopyWith(
    PingMessageDto value,
    $Res Function(PingMessageDto) then,
  ) = _$PingMessageDtoCopyWithImpl<$Res, PingMessageDto>;
  @useResult
  $Res call({
    String id,
    int gameId,
    String pingType,
    PingLocationDto location,
    PingSenderDto pingSender,
    String timestamp,
  });

  $PingLocationDtoCopyWith<$Res> get location;
  $PingSenderDtoCopyWith<$Res> get pingSender;
}

/// @nodoc
class _$PingMessageDtoCopyWithImpl<$Res, $Val extends PingMessageDto>
    implements $PingMessageDtoCopyWith<$Res> {
  _$PingMessageDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PingMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? pingType = null,
    Object? location = null,
    Object? pingSender = null,
    Object? timestamp = null,
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
            pingType: null == pingType
                ? _value.pingType
                : pingType // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as PingLocationDto,
            pingSender: null == pingSender
                ? _value.pingSender
                : pingSender // ignore: cast_nullable_to_non_nullable
                      as PingSenderDto,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of PingMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PingLocationDtoCopyWith<$Res> get location {
    return $PingLocationDtoCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of PingMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PingSenderDtoCopyWith<$Res> get pingSender {
    return $PingSenderDtoCopyWith<$Res>(_value.pingSender, (value) {
      return _then(_value.copyWith(pingSender: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PingMessageDtoImplCopyWith<$Res>
    implements $PingMessageDtoCopyWith<$Res> {
  factory _$$PingMessageDtoImplCopyWith(
    _$PingMessageDtoImpl value,
    $Res Function(_$PingMessageDtoImpl) then,
  ) = __$$PingMessageDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int gameId,
    String pingType,
    PingLocationDto location,
    PingSenderDto pingSender,
    String timestamp,
  });

  @override
  $PingLocationDtoCopyWith<$Res> get location;
  @override
  $PingSenderDtoCopyWith<$Res> get pingSender;
}

/// @nodoc
class __$$PingMessageDtoImplCopyWithImpl<$Res>
    extends _$PingMessageDtoCopyWithImpl<$Res, _$PingMessageDtoImpl>
    implements _$$PingMessageDtoImplCopyWith<$Res> {
  __$$PingMessageDtoImplCopyWithImpl(
    _$PingMessageDtoImpl _value,
    $Res Function(_$PingMessageDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PingMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? pingType = null,
    Object? location = null,
    Object? pingSender = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$PingMessageDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as int,
        pingType: null == pingType
            ? _value.pingType
            : pingType // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as PingLocationDto,
        pingSender: null == pingSender
            ? _value.pingSender
            : pingSender // ignore: cast_nullable_to_non_nullable
                  as PingSenderDto,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PingMessageDtoImpl implements _PingMessageDto {
  const _$PingMessageDtoImpl({
    required this.id,
    required this.gameId,
    required this.pingType,
    required this.location,
    required this.pingSender,
    required this.timestamp,
  });

  factory _$PingMessageDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PingMessageDtoImplFromJson(json);

  @override
  final String id;
  // 서버 UUID
  @override
  final int gameId;
  @override
  final String pingType;
  // "FOUND" | "SUSPECT" | "HELP" — String으로 받는다
  @override
  final PingLocationDto location;
  @override
  final PingSenderDto pingSender;
  @override
  final String timestamp;

  @override
  String toString() {
    return 'PingMessageDto(id: $id, gameId: $gameId, pingType: $pingType, location: $location, pingSender: $pingSender, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PingMessageDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.pingType, pingType) ||
                other.pingType == pingType) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.pingSender, pingSender) ||
                other.pingSender == pingSender) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    gameId,
    pingType,
    location,
    pingSender,
    timestamp,
  );

  /// Create a copy of PingMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PingMessageDtoImplCopyWith<_$PingMessageDtoImpl> get copyWith =>
      __$$PingMessageDtoImplCopyWithImpl<_$PingMessageDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PingMessageDtoImplToJson(this);
  }
}

abstract class _PingMessageDto implements PingMessageDto {
  const factory _PingMessageDto({
    required final String id,
    required final int gameId,
    required final String pingType,
    required final PingLocationDto location,
    required final PingSenderDto pingSender,
    required final String timestamp,
  }) = _$PingMessageDtoImpl;

  factory _PingMessageDto.fromJson(Map<String, dynamic> json) =
      _$PingMessageDtoImpl.fromJson;

  @override
  String get id; // 서버 UUID
  @override
  int get gameId;
  @override
  String get pingType; // "FOUND" | "SUSPECT" | "HELP" — String으로 받는다
  @override
  PingLocationDto get location;
  @override
  PingSenderDto get pingSender;
  @override
  String get timestamp;

  /// Create a copy of PingMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PingMessageDtoImplCopyWith<_$PingMessageDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PingLocationDto _$PingLocationDtoFromJson(Map<String, dynamic> json) {
  return _PingLocationDto.fromJson(json);
}

/// @nodoc
mixin _$PingLocationDto {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this PingLocationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PingLocationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PingLocationDtoCopyWith<PingLocationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PingLocationDtoCopyWith<$Res> {
  factory $PingLocationDtoCopyWith(
    PingLocationDto value,
    $Res Function(PingLocationDto) then,
  ) = _$PingLocationDtoCopyWithImpl<$Res, PingLocationDto>;
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class _$PingLocationDtoCopyWithImpl<$Res, $Val extends PingLocationDto>
    implements $PingLocationDtoCopyWith<$Res> {
  _$PingLocationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PingLocationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = null, Object? longitude = null}) {
    return _then(
      _value.copyWith(
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PingLocationDtoImplCopyWith<$Res>
    implements $PingLocationDtoCopyWith<$Res> {
  factory _$$PingLocationDtoImplCopyWith(
    _$PingLocationDtoImpl value,
    $Res Function(_$PingLocationDtoImpl) then,
  ) = __$$PingLocationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class __$$PingLocationDtoImplCopyWithImpl<$Res>
    extends _$PingLocationDtoCopyWithImpl<$Res, _$PingLocationDtoImpl>
    implements _$$PingLocationDtoImplCopyWith<$Res> {
  __$$PingLocationDtoImplCopyWithImpl(
    _$PingLocationDtoImpl _value,
    $Res Function(_$PingLocationDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PingLocationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = null, Object? longitude = null}) {
    return _then(
      _$PingLocationDtoImpl(
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PingLocationDtoImpl implements _PingLocationDto {
  const _$PingLocationDtoImpl({
    required this.latitude,
    required this.longitude,
  });

  factory _$PingLocationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PingLocationDtoImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'PingLocationDto(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PingLocationDtoImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of PingLocationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PingLocationDtoImplCopyWith<_$PingLocationDtoImpl> get copyWith =>
      __$$PingLocationDtoImplCopyWithImpl<_$PingLocationDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PingLocationDtoImplToJson(this);
  }
}

abstract class _PingLocationDto implements PingLocationDto {
  const factory _PingLocationDto({
    required final double latitude,
    required final double longitude,
  }) = _$PingLocationDtoImpl;

  factory _PingLocationDto.fromJson(Map<String, dynamic> json) =
      _$PingLocationDtoImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of PingLocationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PingLocationDtoImplCopyWith<_$PingLocationDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PingSenderDto _$PingSenderDtoFromJson(Map<String, dynamic> json) {
  return _PingSenderDto.fromJson(json);
}

/// @nodoc
mixin _$PingSenderDto {
  int get participantId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;

  /// Serializes this PingSenderDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PingSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PingSenderDtoCopyWith<PingSenderDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PingSenderDtoCopyWith<$Res> {
  factory $PingSenderDtoCopyWith(
    PingSenderDto value,
    $Res Function(PingSenderDto) then,
  ) = _$PingSenderDtoCopyWithImpl<$Res, PingSenderDto>;
  @useResult
  $Res call({int participantId, String nickname});
}

/// @nodoc
class _$PingSenderDtoCopyWithImpl<$Res, $Val extends PingSenderDto>
    implements $PingSenderDtoCopyWith<$Res> {
  _$PingSenderDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PingSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? participantId = null, Object? nickname = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PingSenderDtoImplCopyWith<$Res>
    implements $PingSenderDtoCopyWith<$Res> {
  factory _$$PingSenderDtoImplCopyWith(
    _$PingSenderDtoImpl value,
    $Res Function(_$PingSenderDtoImpl) then,
  ) = __$$PingSenderDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int participantId, String nickname});
}

/// @nodoc
class __$$PingSenderDtoImplCopyWithImpl<$Res>
    extends _$PingSenderDtoCopyWithImpl<$Res, _$PingSenderDtoImpl>
    implements _$$PingSenderDtoImplCopyWith<$Res> {
  __$$PingSenderDtoImplCopyWithImpl(
    _$PingSenderDtoImpl _value,
    $Res Function(_$PingSenderDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PingSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? participantId = null, Object? nickname = null}) {
    return _then(
      _$PingSenderDtoImpl(
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PingSenderDtoImpl implements _PingSenderDto {
  const _$PingSenderDtoImpl({
    required this.participantId,
    required this.nickname,
  });

  factory _$PingSenderDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PingSenderDtoImplFromJson(json);

  @override
  final int participantId;
  @override
  final String nickname;

  @override
  String toString() {
    return 'PingSenderDto(participantId: $participantId, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PingSenderDtoImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, participantId, nickname);

  /// Create a copy of PingSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PingSenderDtoImplCopyWith<_$PingSenderDtoImpl> get copyWith =>
      __$$PingSenderDtoImplCopyWithImpl<_$PingSenderDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PingSenderDtoImplToJson(this);
  }
}

abstract class _PingSenderDto implements PingSenderDto {
  const factory _PingSenderDto({
    required final int participantId,
    required final String nickname,
  }) = _$PingSenderDtoImpl;

  factory _PingSenderDto.fromJson(Map<String, dynamic> json) =
      _$PingSenderDtoImpl.fromJson;

  @override
  int get participantId;
  @override
  String get nickname;

  /// Create a copy of PingSenderDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PingSenderDtoImplCopyWith<_$PingSenderDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
