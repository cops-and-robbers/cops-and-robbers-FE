// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_session_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateSessionResponse _$CreateSessionResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CreateSessionResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateSessionResponse {
  /// 게임 세션 ID
  int get gameId => throw _privateConstructorUsedError;

  /// 초대 코드 (예: "ABC123")
  String get inviteCode => throw _privateConstructorUsedError;

  /// 세션 상태 (예: "WAITING")
  String get status => throw _privateConstructorUsedError;

  /// 라운드 시간 (분)
  int get roundDurationMinutes => throw _privateConstructorUsedError;

  /// 위치 공개 주기 (분)
  int get locationRevealIntervalMinutes => throw _privateConstructorUsedError;

  /// 경찰 대기 시간 (분)
  int get policeWaitMinutes => throw _privateConstructorUsedError;

  /// 최대 참가자 수
  int get maxParticipants => throw _privateConstructorUsedError;

  /// 생성 시각 (v2.7.0부터 `+09:00` timezone suffix 포함 ISO 8601)
  ///
  /// `fromJson`은 json_serializable 기본 동작으로 String → DateTime 파싱.
  /// `toJson`은 UTC로 강제 변환하여 ISO 8601 + `Z` suffix를 보장
  /// (로컬 DateTime 직렬화 시 timezone 정보가 누락되는 문제 방지).
  @JsonKey(toJson: _dateTimeToIso)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CreateSessionResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateSessionResponseCopyWith<CreateSessionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSessionResponseCopyWith<$Res> {
  factory $CreateSessionResponseCopyWith(
    CreateSessionResponse value,
    $Res Function(CreateSessionResponse) then,
  ) = _$CreateSessionResponseCopyWithImpl<$Res, CreateSessionResponse>;
  @useResult
  $Res call({
    int gameId,
    String inviteCode,
    String status,
    int roundDurationMinutes,
    int locationRevealIntervalMinutes,
    int policeWaitMinutes,
    int maxParticipants,
    @JsonKey(toJson: _dateTimeToIso) DateTime createdAt,
  });
}

/// @nodoc
class _$CreateSessionResponseCopyWithImpl<
  $Res,
  $Val extends CreateSessionResponse
>
    implements $CreateSessionResponseCopyWith<$Res> {
  _$CreateSessionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? inviteCode = null,
    Object? status = null,
    Object? roundDurationMinutes = null,
    Object? locationRevealIntervalMinutes = null,
    Object? policeWaitMinutes = null,
    Object? maxParticipants = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as int,
            inviteCode: null == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            roundDurationMinutes: null == roundDurationMinutes
                ? _value.roundDurationMinutes
                : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            locationRevealIntervalMinutes: null == locationRevealIntervalMinutes
                ? _value.locationRevealIntervalMinutes
                : locationRevealIntervalMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            policeWaitMinutes: null == policeWaitMinutes
                ? _value.policeWaitMinutes
                : policeWaitMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            maxParticipants: null == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateSessionResponseImplCopyWith<$Res>
    implements $CreateSessionResponseCopyWith<$Res> {
  factory _$$CreateSessionResponseImplCopyWith(
    _$CreateSessionResponseImpl value,
    $Res Function(_$CreateSessionResponseImpl) then,
  ) = __$$CreateSessionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int gameId,
    String inviteCode,
    String status,
    int roundDurationMinutes,
    int locationRevealIntervalMinutes,
    int policeWaitMinutes,
    int maxParticipants,
    @JsonKey(toJson: _dateTimeToIso) DateTime createdAt,
  });
}

/// @nodoc
class __$$CreateSessionResponseImplCopyWithImpl<$Res>
    extends
        _$CreateSessionResponseCopyWithImpl<$Res, _$CreateSessionResponseImpl>
    implements _$$CreateSessionResponseImplCopyWith<$Res> {
  __$$CreateSessionResponseImplCopyWithImpl(
    _$CreateSessionResponseImpl _value,
    $Res Function(_$CreateSessionResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? inviteCode = null,
    Object? status = null,
    Object? roundDurationMinutes = null,
    Object? locationRevealIntervalMinutes = null,
    Object? policeWaitMinutes = null,
    Object? maxParticipants = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$CreateSessionResponseImpl(
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as int,
        inviteCode: null == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        roundDurationMinutes: null == roundDurationMinutes
            ? _value.roundDurationMinutes
            : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        locationRevealIntervalMinutes: null == locationRevealIntervalMinutes
            ? _value.locationRevealIntervalMinutes
            : locationRevealIntervalMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        policeWaitMinutes: null == policeWaitMinutes
            ? _value.policeWaitMinutes
            : policeWaitMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        maxParticipants: null == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateSessionResponseImpl implements _CreateSessionResponse {
  const _$CreateSessionResponseImpl({
    required this.gameId,
    required this.inviteCode,
    required this.status,
    required this.roundDurationMinutes,
    required this.locationRevealIntervalMinutes,
    required this.policeWaitMinutes,
    required this.maxParticipants,
    @JsonKey(toJson: _dateTimeToIso) required this.createdAt,
  });

  factory _$CreateSessionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateSessionResponseImplFromJson(json);

  /// 게임 세션 ID
  @override
  final int gameId;

  /// 초대 코드 (예: "ABC123")
  @override
  final String inviteCode;

  /// 세션 상태 (예: "WAITING")
  @override
  final String status;

  /// 라운드 시간 (분)
  @override
  final int roundDurationMinutes;

  /// 위치 공개 주기 (분)
  @override
  final int locationRevealIntervalMinutes;

  /// 경찰 대기 시간 (분)
  @override
  final int policeWaitMinutes;

  /// 최대 참가자 수
  @override
  final int maxParticipants;

  /// 생성 시각 (v2.7.0부터 `+09:00` timezone suffix 포함 ISO 8601)
  ///
  /// `fromJson`은 json_serializable 기본 동작으로 String → DateTime 파싱.
  /// `toJson`은 UTC로 강제 변환하여 ISO 8601 + `Z` suffix를 보장
  /// (로컬 DateTime 직렬화 시 timezone 정보가 누락되는 문제 방지).
  @override
  @JsonKey(toJson: _dateTimeToIso)
  final DateTime createdAt;

  @override
  String toString() {
    return 'CreateSessionResponse(gameId: $gameId, inviteCode: $inviteCode, status: $status, roundDurationMinutes: $roundDurationMinutes, locationRevealIntervalMinutes: $locationRevealIntervalMinutes, policeWaitMinutes: $policeWaitMinutes, maxParticipants: $maxParticipants, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateSessionResponseImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.roundDurationMinutes, roundDurationMinutes) ||
                other.roundDurationMinutes == roundDurationMinutes) &&
            (identical(
                  other.locationRevealIntervalMinutes,
                  locationRevealIntervalMinutes,
                ) ||
                other.locationRevealIntervalMinutes ==
                    locationRevealIntervalMinutes) &&
            (identical(other.policeWaitMinutes, policeWaitMinutes) ||
                other.policeWaitMinutes == policeWaitMinutes) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gameId,
    inviteCode,
    status,
    roundDurationMinutes,
    locationRevealIntervalMinutes,
    policeWaitMinutes,
    maxParticipants,
    createdAt,
  );

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateSessionResponseImplCopyWith<_$CreateSessionResponseImpl>
  get copyWith =>
      __$$CreateSessionResponseImplCopyWithImpl<_$CreateSessionResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateSessionResponseImplToJson(this);
  }
}

abstract class _CreateSessionResponse implements CreateSessionResponse {
  const factory _CreateSessionResponse({
    required final int gameId,
    required final String inviteCode,
    required final String status,
    required final int roundDurationMinutes,
    required final int locationRevealIntervalMinutes,
    required final int policeWaitMinutes,
    required final int maxParticipants,
    @JsonKey(toJson: _dateTimeToIso) required final DateTime createdAt,
  }) = _$CreateSessionResponseImpl;

  factory _CreateSessionResponse.fromJson(Map<String, dynamic> json) =
      _$CreateSessionResponseImpl.fromJson;

  /// 게임 세션 ID
  @override
  int get gameId;

  /// 초대 코드 (예: "ABC123")
  @override
  String get inviteCode;

  /// 세션 상태 (예: "WAITING")
  @override
  String get status;

  /// 라운드 시간 (분)
  @override
  int get roundDurationMinutes;

  /// 위치 공개 주기 (분)
  @override
  int get locationRevealIntervalMinutes;

  /// 경찰 대기 시간 (분)
  @override
  int get policeWaitMinutes;

  /// 최대 참가자 수
  @override
  int get maxParticipants;

  /// 생성 시각 (v2.7.0부터 `+09:00` timezone suffix 포함 ISO 8601)
  ///
  /// `fromJson`은 json_serializable 기본 동작으로 String → DateTime 파싱.
  /// `toJson`은 UTC로 강제 변환하여 ISO 8601 + `Z` suffix를 보장
  /// (로컬 DateTime 직렬화 시 timezone 정보가 누락되는 문제 방지).
  @override
  @JsonKey(toJson: _dateTimeToIso)
  DateTime get createdAt;

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateSessionResponseImplCopyWith<_$CreateSessionResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
