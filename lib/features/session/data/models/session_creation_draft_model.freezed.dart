// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_creation_draft_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SessionCreationDraftModel _$SessionCreationDraftModelFromJson(
  Map<String, dynamic> json,
) {
  return _SessionCreationDraftModel.fromJson(json);
}

/// @nodoc
mixin _$SessionCreationDraftModel {
  // ============================================
  // 구역 정보 (1단계: 구역 설정)
  // ============================================
  /// 플레이그라운드 중심 좌표
  @LatLngConverter()
  LatLng? get playgroundCenter => throw _privateConstructorUsedError;

  /// 플레이그라운드 반경 (미터)
  double? get playgroundRadiusInMeters => throw _privateConstructorUsedError;

  /// 감옥 중심 좌표
  @LatLngConverter()
  LatLng? get jailCenter => throw _privateConstructorUsedError;

  /// 감옥 반경 (미터)
  double? get jailRadiusInMeters =>
      throw _privateConstructorUsedError; // ============================================
  // 게임 설정 (2단계: 인원 설정, 3단계: 기본정보 설정)
  // ============================================
  /// 라운드 시간 (분)
  int? get roundDurationMinutes => throw _privateConstructorUsedError;

  /// 위치 공개 주기 (분)
  int? get locationRevealIntervalMinutes => throw _privateConstructorUsedError;

  /// 경찰 대기 시간 (분)
  int? get policeWaitMinutes => throw _privateConstructorUsedError;

  /// 최대 참가자 수
  int? get maxParticipants => throw _privateConstructorUsedError;

  /// Serializes this SessionCreationDraftModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionCreationDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionCreationDraftModelCopyWith<SessionCreationDraftModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionCreationDraftModelCopyWith<$Res> {
  factory $SessionCreationDraftModelCopyWith(
    SessionCreationDraftModel value,
    $Res Function(SessionCreationDraftModel) then,
  ) = _$SessionCreationDraftModelCopyWithImpl<$Res, SessionCreationDraftModel>;
  @useResult
  $Res call({
    @LatLngConverter() LatLng? playgroundCenter,
    double? playgroundRadiusInMeters,
    @LatLngConverter() LatLng? jailCenter,
    double? jailRadiusInMeters,
    int? roundDurationMinutes,
    int? locationRevealIntervalMinutes,
    int? policeWaitMinutes,
    int? maxParticipants,
  });
}

/// @nodoc
class _$SessionCreationDraftModelCopyWithImpl<
  $Res,
  $Val extends SessionCreationDraftModel
>
    implements $SessionCreationDraftModelCopyWith<$Res> {
  _$SessionCreationDraftModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionCreationDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playgroundCenter = freezed,
    Object? playgroundRadiusInMeters = freezed,
    Object? jailCenter = freezed,
    Object? jailRadiusInMeters = freezed,
    Object? roundDurationMinutes = freezed,
    Object? locationRevealIntervalMinutes = freezed,
    Object? policeWaitMinutes = freezed,
    Object? maxParticipants = freezed,
  }) {
    return _then(
      _value.copyWith(
            playgroundCenter: freezed == playgroundCenter
                ? _value.playgroundCenter
                : playgroundCenter // ignore: cast_nullable_to_non_nullable
                      as LatLng?,
            playgroundRadiusInMeters: freezed == playgroundRadiusInMeters
                ? _value.playgroundRadiusInMeters
                : playgroundRadiusInMeters // ignore: cast_nullable_to_non_nullable
                      as double?,
            jailCenter: freezed == jailCenter
                ? _value.jailCenter
                : jailCenter // ignore: cast_nullable_to_non_nullable
                      as LatLng?,
            jailRadiusInMeters: freezed == jailRadiusInMeters
                ? _value.jailRadiusInMeters
                : jailRadiusInMeters // ignore: cast_nullable_to_non_nullable
                      as double?,
            roundDurationMinutes: freezed == roundDurationMinutes
                ? _value.roundDurationMinutes
                : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            locationRevealIntervalMinutes:
                freezed == locationRevealIntervalMinutes
                ? _value.locationRevealIntervalMinutes
                : locationRevealIntervalMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            policeWaitMinutes: freezed == policeWaitMinutes
                ? _value.policeWaitMinutes
                : policeWaitMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxParticipants: freezed == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionCreationDraftModelImplCopyWith<$Res>
    implements $SessionCreationDraftModelCopyWith<$Res> {
  factory _$$SessionCreationDraftModelImplCopyWith(
    _$SessionCreationDraftModelImpl value,
    $Res Function(_$SessionCreationDraftModelImpl) then,
  ) = __$$SessionCreationDraftModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @LatLngConverter() LatLng? playgroundCenter,
    double? playgroundRadiusInMeters,
    @LatLngConverter() LatLng? jailCenter,
    double? jailRadiusInMeters,
    int? roundDurationMinutes,
    int? locationRevealIntervalMinutes,
    int? policeWaitMinutes,
    int? maxParticipants,
  });
}

/// @nodoc
class __$$SessionCreationDraftModelImplCopyWithImpl<$Res>
    extends
        _$SessionCreationDraftModelCopyWithImpl<
          $Res,
          _$SessionCreationDraftModelImpl
        >
    implements _$$SessionCreationDraftModelImplCopyWith<$Res> {
  __$$SessionCreationDraftModelImplCopyWithImpl(
    _$SessionCreationDraftModelImpl _value,
    $Res Function(_$SessionCreationDraftModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionCreationDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playgroundCenter = freezed,
    Object? playgroundRadiusInMeters = freezed,
    Object? jailCenter = freezed,
    Object? jailRadiusInMeters = freezed,
    Object? roundDurationMinutes = freezed,
    Object? locationRevealIntervalMinutes = freezed,
    Object? policeWaitMinutes = freezed,
    Object? maxParticipants = freezed,
  }) {
    return _then(
      _$SessionCreationDraftModelImpl(
        playgroundCenter: freezed == playgroundCenter
            ? _value.playgroundCenter
            : playgroundCenter // ignore: cast_nullable_to_non_nullable
                  as LatLng?,
        playgroundRadiusInMeters: freezed == playgroundRadiusInMeters
            ? _value.playgroundRadiusInMeters
            : playgroundRadiusInMeters // ignore: cast_nullable_to_non_nullable
                  as double?,
        jailCenter: freezed == jailCenter
            ? _value.jailCenter
            : jailCenter // ignore: cast_nullable_to_non_nullable
                  as LatLng?,
        jailRadiusInMeters: freezed == jailRadiusInMeters
            ? _value.jailRadiusInMeters
            : jailRadiusInMeters // ignore: cast_nullable_to_non_nullable
                  as double?,
        roundDurationMinutes: freezed == roundDurationMinutes
            ? _value.roundDurationMinutes
            : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        locationRevealIntervalMinutes: freezed == locationRevealIntervalMinutes
            ? _value.locationRevealIntervalMinutes
            : locationRevealIntervalMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        policeWaitMinutes: freezed == policeWaitMinutes
            ? _value.policeWaitMinutes
            : policeWaitMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxParticipants: freezed == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionCreationDraftModelImpl implements _SessionCreationDraftModel {
  const _$SessionCreationDraftModelImpl({
    @LatLngConverter() this.playgroundCenter,
    this.playgroundRadiusInMeters,
    @LatLngConverter() this.jailCenter,
    this.jailRadiusInMeters,
    this.roundDurationMinutes,
    this.locationRevealIntervalMinutes,
    this.policeWaitMinutes,
    this.maxParticipants,
  });

  factory _$SessionCreationDraftModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionCreationDraftModelImplFromJson(json);

  // ============================================
  // 구역 정보 (1단계: 구역 설정)
  // ============================================
  /// 플레이그라운드 중심 좌표
  @override
  @LatLngConverter()
  final LatLng? playgroundCenter;

  /// 플레이그라운드 반경 (미터)
  @override
  final double? playgroundRadiusInMeters;

  /// 감옥 중심 좌표
  @override
  @LatLngConverter()
  final LatLng? jailCenter;

  /// 감옥 반경 (미터)
  @override
  final double? jailRadiusInMeters;
  // ============================================
  // 게임 설정 (2단계: 인원 설정, 3단계: 기본정보 설정)
  // ============================================
  /// 라운드 시간 (분)
  @override
  final int? roundDurationMinutes;

  /// 위치 공개 주기 (분)
  @override
  final int? locationRevealIntervalMinutes;

  /// 경찰 대기 시간 (분)
  @override
  final int? policeWaitMinutes;

  /// 최대 참가자 수
  @override
  final int? maxParticipants;

  @override
  String toString() {
    return 'SessionCreationDraftModel(playgroundCenter: $playgroundCenter, playgroundRadiusInMeters: $playgroundRadiusInMeters, jailCenter: $jailCenter, jailRadiusInMeters: $jailRadiusInMeters, roundDurationMinutes: $roundDurationMinutes, locationRevealIntervalMinutes: $locationRevealIntervalMinutes, policeWaitMinutes: $policeWaitMinutes, maxParticipants: $maxParticipants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionCreationDraftModelImpl &&
            (identical(other.playgroundCenter, playgroundCenter) ||
                other.playgroundCenter == playgroundCenter) &&
            (identical(
                  other.playgroundRadiusInMeters,
                  playgroundRadiusInMeters,
                ) ||
                other.playgroundRadiusInMeters == playgroundRadiusInMeters) &&
            (identical(other.jailCenter, jailCenter) ||
                other.jailCenter == jailCenter) &&
            (identical(other.jailRadiusInMeters, jailRadiusInMeters) ||
                other.jailRadiusInMeters == jailRadiusInMeters) &&
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
                other.maxParticipants == maxParticipants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    playgroundCenter,
    playgroundRadiusInMeters,
    jailCenter,
    jailRadiusInMeters,
    roundDurationMinutes,
    locationRevealIntervalMinutes,
    policeWaitMinutes,
    maxParticipants,
  );

  /// Create a copy of SessionCreationDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionCreationDraftModelImplCopyWith<_$SessionCreationDraftModelImpl>
  get copyWith =>
      __$$SessionCreationDraftModelImplCopyWithImpl<
        _$SessionCreationDraftModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionCreationDraftModelImplToJson(this);
  }
}

abstract class _SessionCreationDraftModel implements SessionCreationDraftModel {
  const factory _SessionCreationDraftModel({
    @LatLngConverter() final LatLng? playgroundCenter,
    final double? playgroundRadiusInMeters,
    @LatLngConverter() final LatLng? jailCenter,
    final double? jailRadiusInMeters,
    final int? roundDurationMinutes,
    final int? locationRevealIntervalMinutes,
    final int? policeWaitMinutes,
    final int? maxParticipants,
  }) = _$SessionCreationDraftModelImpl;

  factory _SessionCreationDraftModel.fromJson(Map<String, dynamic> json) =
      _$SessionCreationDraftModelImpl.fromJson;

  // ============================================
  // 구역 정보 (1단계: 구역 설정)
  // ============================================
  /// 플레이그라운드 중심 좌표
  @override
  @LatLngConverter()
  LatLng? get playgroundCenter;

  /// 플레이그라운드 반경 (미터)
  @override
  double? get playgroundRadiusInMeters;

  /// 감옥 중심 좌표
  @override
  @LatLngConverter()
  LatLng? get jailCenter;

  /// 감옥 반경 (미터)
  @override
  double? get jailRadiusInMeters; // ============================================
  // 게임 설정 (2단계: 인원 설정, 3단계: 기본정보 설정)
  // ============================================
  /// 라운드 시간 (분)
  @override
  int? get roundDurationMinutes;

  /// 위치 공개 주기 (분)
  @override
  int? get locationRevealIntervalMinutes;

  /// 경찰 대기 시간 (분)
  @override
  int? get policeWaitMinutes;

  /// 최대 참가자 수
  @override
  int? get maxParticipants;

  /// Create a copy of SessionCreationDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionCreationDraftModelImplCopyWith<_$SessionCreationDraftModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
