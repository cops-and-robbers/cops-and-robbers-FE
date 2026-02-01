// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_session_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateSessionRequest _$CreateSessionRequestFromJson(Map<String, dynamic> json) {
  return _CreateSessionRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateSessionRequest {
  /// 플레이그라운드 중심 위도
  double get playgroundLatitude => throw _privateConstructorUsedError;

  /// 플레이그라운드 중심 경도
  double get playgroundLongitude => throw _privateConstructorUsedError;

  /// 플레이그라운드 반경 (미터)
  double get playgroundRadiusInMeters => throw _privateConstructorUsedError;

  /// 감옥 중심 위도
  double get jailLatitude => throw _privateConstructorUsedError;

  /// 감옥 중심 경도
  double get jailLongitude => throw _privateConstructorUsedError;

  /// 감옥 반경 (미터)
  double get jailRadiusInMeters => throw _privateConstructorUsedError;

  /// 라운드 시간 (분)
  int get roundDurationMinutes => throw _privateConstructorUsedError;

  /// 위치 공유 간격 (분)
  int get locationShareMinutes => throw _privateConstructorUsedError;

  /// 경찰 대기 시간 (분)
  int get policeWaitMinutes => throw _privateConstructorUsedError;

  /// 최대 참가자 수
  int get maxParticipants => throw _privateConstructorUsedError;

  /// Serializes this CreateSessionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateSessionRequestCopyWith<CreateSessionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSessionRequestCopyWith<$Res> {
  factory $CreateSessionRequestCopyWith(
    CreateSessionRequest value,
    $Res Function(CreateSessionRequest) then,
  ) = _$CreateSessionRequestCopyWithImpl<$Res, CreateSessionRequest>;
  @useResult
  $Res call({
    double playgroundLatitude,
    double playgroundLongitude,
    double playgroundRadiusInMeters,
    double jailLatitude,
    double jailLongitude,
    double jailRadiusInMeters,
    int roundDurationMinutes,
    int locationShareMinutes,
    int policeWaitMinutes,
    int maxParticipants,
  });
}

/// @nodoc
class _$CreateSessionRequestCopyWithImpl<
  $Res,
  $Val extends CreateSessionRequest
>
    implements $CreateSessionRequestCopyWith<$Res> {
  _$CreateSessionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playgroundLatitude = null,
    Object? playgroundLongitude = null,
    Object? playgroundRadiusInMeters = null,
    Object? jailLatitude = null,
    Object? jailLongitude = null,
    Object? jailRadiusInMeters = null,
    Object? roundDurationMinutes = null,
    Object? locationShareMinutes = null,
    Object? policeWaitMinutes = null,
    Object? maxParticipants = null,
  }) {
    return _then(
      _value.copyWith(
            playgroundLatitude: null == playgroundLatitude
                ? _value.playgroundLatitude
                : playgroundLatitude // ignore: cast_nullable_to_non_nullable
                      as double,
            playgroundLongitude: null == playgroundLongitude
                ? _value.playgroundLongitude
                : playgroundLongitude // ignore: cast_nullable_to_non_nullable
                      as double,
            playgroundRadiusInMeters: null == playgroundRadiusInMeters
                ? _value.playgroundRadiusInMeters
                : playgroundRadiusInMeters // ignore: cast_nullable_to_non_nullable
                      as double,
            jailLatitude: null == jailLatitude
                ? _value.jailLatitude
                : jailLatitude // ignore: cast_nullable_to_non_nullable
                      as double,
            jailLongitude: null == jailLongitude
                ? _value.jailLongitude
                : jailLongitude // ignore: cast_nullable_to_non_nullable
                      as double,
            jailRadiusInMeters: null == jailRadiusInMeters
                ? _value.jailRadiusInMeters
                : jailRadiusInMeters // ignore: cast_nullable_to_non_nullable
                      as double,
            roundDurationMinutes: null == roundDurationMinutes
                ? _value.roundDurationMinutes
                : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            locationShareMinutes: null == locationShareMinutes
                ? _value.locationShareMinutes
                : locationShareMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            policeWaitMinutes: null == policeWaitMinutes
                ? _value.policeWaitMinutes
                : policeWaitMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            maxParticipants: null == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateSessionRequestImplCopyWith<$Res>
    implements $CreateSessionRequestCopyWith<$Res> {
  factory _$$CreateSessionRequestImplCopyWith(
    _$CreateSessionRequestImpl value,
    $Res Function(_$CreateSessionRequestImpl) then,
  ) = __$$CreateSessionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double playgroundLatitude,
    double playgroundLongitude,
    double playgroundRadiusInMeters,
    double jailLatitude,
    double jailLongitude,
    double jailRadiusInMeters,
    int roundDurationMinutes,
    int locationShareMinutes,
    int policeWaitMinutes,
    int maxParticipants,
  });
}

/// @nodoc
class __$$CreateSessionRequestImplCopyWithImpl<$Res>
    extends _$CreateSessionRequestCopyWithImpl<$Res, _$CreateSessionRequestImpl>
    implements _$$CreateSessionRequestImplCopyWith<$Res> {
  __$$CreateSessionRequestImplCopyWithImpl(
    _$CreateSessionRequestImpl _value,
    $Res Function(_$CreateSessionRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playgroundLatitude = null,
    Object? playgroundLongitude = null,
    Object? playgroundRadiusInMeters = null,
    Object? jailLatitude = null,
    Object? jailLongitude = null,
    Object? jailRadiusInMeters = null,
    Object? roundDurationMinutes = null,
    Object? locationShareMinutes = null,
    Object? policeWaitMinutes = null,
    Object? maxParticipants = null,
  }) {
    return _then(
      _$CreateSessionRequestImpl(
        playgroundLatitude: null == playgroundLatitude
            ? _value.playgroundLatitude
            : playgroundLatitude // ignore: cast_nullable_to_non_nullable
                  as double,
        playgroundLongitude: null == playgroundLongitude
            ? _value.playgroundLongitude
            : playgroundLongitude // ignore: cast_nullable_to_non_nullable
                  as double,
        playgroundRadiusInMeters: null == playgroundRadiusInMeters
            ? _value.playgroundRadiusInMeters
            : playgroundRadiusInMeters // ignore: cast_nullable_to_non_nullable
                  as double,
        jailLatitude: null == jailLatitude
            ? _value.jailLatitude
            : jailLatitude // ignore: cast_nullable_to_non_nullable
                  as double,
        jailLongitude: null == jailLongitude
            ? _value.jailLongitude
            : jailLongitude // ignore: cast_nullable_to_non_nullable
                  as double,
        jailRadiusInMeters: null == jailRadiusInMeters
            ? _value.jailRadiusInMeters
            : jailRadiusInMeters // ignore: cast_nullable_to_non_nullable
                  as double,
        roundDurationMinutes: null == roundDurationMinutes
            ? _value.roundDurationMinutes
            : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        locationShareMinutes: null == locationShareMinutes
            ? _value.locationShareMinutes
            : locationShareMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        policeWaitMinutes: null == policeWaitMinutes
            ? _value.policeWaitMinutes
            : policeWaitMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        maxParticipants: null == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateSessionRequestImpl implements _CreateSessionRequest {
  const _$CreateSessionRequestImpl({
    required this.playgroundLatitude,
    required this.playgroundLongitude,
    required this.playgroundRadiusInMeters,
    required this.jailLatitude,
    required this.jailLongitude,
    required this.jailRadiusInMeters,
    required this.roundDurationMinutes,
    required this.locationShareMinutes,
    required this.policeWaitMinutes,
    required this.maxParticipants,
  });

  factory _$CreateSessionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateSessionRequestImplFromJson(json);

  /// 플레이그라운드 중심 위도
  @override
  final double playgroundLatitude;

  /// 플레이그라운드 중심 경도
  @override
  final double playgroundLongitude;

  /// 플레이그라운드 반경 (미터)
  @override
  final double playgroundRadiusInMeters;

  /// 감옥 중심 위도
  @override
  final double jailLatitude;

  /// 감옥 중심 경도
  @override
  final double jailLongitude;

  /// 감옥 반경 (미터)
  @override
  final double jailRadiusInMeters;

  /// 라운드 시간 (분)
  @override
  final int roundDurationMinutes;

  /// 위치 공유 간격 (분)
  @override
  final int locationShareMinutes;

  /// 경찰 대기 시간 (분)
  @override
  final int policeWaitMinutes;

  /// 최대 참가자 수
  @override
  final int maxParticipants;

  @override
  String toString() {
    return 'CreateSessionRequest(playgroundLatitude: $playgroundLatitude, playgroundLongitude: $playgroundLongitude, playgroundRadiusInMeters: $playgroundRadiusInMeters, jailLatitude: $jailLatitude, jailLongitude: $jailLongitude, jailRadiusInMeters: $jailRadiusInMeters, roundDurationMinutes: $roundDurationMinutes, locationShareMinutes: $locationShareMinutes, policeWaitMinutes: $policeWaitMinutes, maxParticipants: $maxParticipants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateSessionRequestImpl &&
            (identical(other.playgroundLatitude, playgroundLatitude) ||
                other.playgroundLatitude == playgroundLatitude) &&
            (identical(other.playgroundLongitude, playgroundLongitude) ||
                other.playgroundLongitude == playgroundLongitude) &&
            (identical(
                  other.playgroundRadiusInMeters,
                  playgroundRadiusInMeters,
                ) ||
                other.playgroundRadiusInMeters == playgroundRadiusInMeters) &&
            (identical(other.jailLatitude, jailLatitude) ||
                other.jailLatitude == jailLatitude) &&
            (identical(other.jailLongitude, jailLongitude) ||
                other.jailLongitude == jailLongitude) &&
            (identical(other.jailRadiusInMeters, jailRadiusInMeters) ||
                other.jailRadiusInMeters == jailRadiusInMeters) &&
            (identical(other.roundDurationMinutes, roundDurationMinutes) ||
                other.roundDurationMinutes == roundDurationMinutes) &&
            (identical(other.locationShareMinutes, locationShareMinutes) ||
                other.locationShareMinutes == locationShareMinutes) &&
            (identical(other.policeWaitMinutes, policeWaitMinutes) ||
                other.policeWaitMinutes == policeWaitMinutes) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    playgroundLatitude,
    playgroundLongitude,
    playgroundRadiusInMeters,
    jailLatitude,
    jailLongitude,
    jailRadiusInMeters,
    roundDurationMinutes,
    locationShareMinutes,
    policeWaitMinutes,
    maxParticipants,
  );

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateSessionRequestImplCopyWith<_$CreateSessionRequestImpl>
  get copyWith =>
      __$$CreateSessionRequestImplCopyWithImpl<_$CreateSessionRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateSessionRequestImplToJson(this);
  }
}

abstract class _CreateSessionRequest implements CreateSessionRequest {
  const factory _CreateSessionRequest({
    required final double playgroundLatitude,
    required final double playgroundLongitude,
    required final double playgroundRadiusInMeters,
    required final double jailLatitude,
    required final double jailLongitude,
    required final double jailRadiusInMeters,
    required final int roundDurationMinutes,
    required final int locationShareMinutes,
    required final int policeWaitMinutes,
    required final int maxParticipants,
  }) = _$CreateSessionRequestImpl;

  factory _CreateSessionRequest.fromJson(Map<String, dynamic> json) =
      _$CreateSessionRequestImpl.fromJson;

  /// 플레이그라운드 중심 위도
  @override
  double get playgroundLatitude;

  /// 플레이그라운드 중심 경도
  @override
  double get playgroundLongitude;

  /// 플레이그라운드 반경 (미터)
  @override
  double get playgroundRadiusInMeters;

  /// 감옥 중심 위도
  @override
  double get jailLatitude;

  /// 감옥 중심 경도
  @override
  double get jailLongitude;

  /// 감옥 반경 (미터)
  @override
  double get jailRadiusInMeters;

  /// 라운드 시간 (분)
  @override
  int get roundDurationMinutes;

  /// 위치 공유 간격 (분)
  @override
  int get locationShareMinutes;

  /// 경찰 대기 시간 (분)
  @override
  int get policeWaitMinutes;

  /// 최대 참가자 수
  @override
  int get maxParticipants;

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateSessionRequestImplCopyWith<_$CreateSessionRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
