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
  double? get jailRadiusInMeters => throw _privateConstructorUsedError;

  /// 구역 타입 (거리로 설정 = circle / 핀으로 설정 = polygon)
  GameAreaType get areaType => throw _privateConstructorUsedError;

  /// 플레이그라운드 핀 목록 (찍은 순서 그대로 — 정렬은 표시·전송 시점에)
  @LatLngListConverter()
  List<LatLng>? get playgroundPinPoints => throw _privateConstructorUsedError;

  /// 감옥 핀 목록 (찍은 순서 그대로)
  @LatLngListConverter()
  List<LatLng>? get jailPinPoints => throw _privateConstructorUsedError; // ============================================
  // 게임 설정 (2단계: 인원 설정, 3단계: 기본정보 설정)
  // ============================================
  /// 라운드 시간 (분)
  int? get roundDurationMinutes => throw _privateConstructorUsedError;

  /// 위치 공유 간격 (분)
  int? get locationShareMinutes => throw _privateConstructorUsedError;

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
    GameAreaType areaType,
    @LatLngListConverter() List<LatLng>? playgroundPinPoints,
    @LatLngListConverter() List<LatLng>? jailPinPoints,
    int? roundDurationMinutes,
    int? locationShareMinutes,
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
    Object? areaType = null,
    Object? playgroundPinPoints = freezed,
    Object? jailPinPoints = freezed,
    Object? roundDurationMinutes = freezed,
    Object? locationShareMinutes = freezed,
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
            areaType: null == areaType
                ? _value.areaType
                : areaType // ignore: cast_nullable_to_non_nullable
                      as GameAreaType,
            playgroundPinPoints: freezed == playgroundPinPoints
                ? _value.playgroundPinPoints
                : playgroundPinPoints // ignore: cast_nullable_to_non_nullable
                      as List<LatLng>?,
            jailPinPoints: freezed == jailPinPoints
                ? _value.jailPinPoints
                : jailPinPoints // ignore: cast_nullable_to_non_nullable
                      as List<LatLng>?,
            roundDurationMinutes: freezed == roundDurationMinutes
                ? _value.roundDurationMinutes
                : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            locationShareMinutes: freezed == locationShareMinutes
                ? _value.locationShareMinutes
                : locationShareMinutes // ignore: cast_nullable_to_non_nullable
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
    GameAreaType areaType,
    @LatLngListConverter() List<LatLng>? playgroundPinPoints,
    @LatLngListConverter() List<LatLng>? jailPinPoints,
    int? roundDurationMinutes,
    int? locationShareMinutes,
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
    Object? areaType = null,
    Object? playgroundPinPoints = freezed,
    Object? jailPinPoints = freezed,
    Object? roundDurationMinutes = freezed,
    Object? locationShareMinutes = freezed,
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
        areaType: null == areaType
            ? _value.areaType
            : areaType // ignore: cast_nullable_to_non_nullable
                  as GameAreaType,
        playgroundPinPoints: freezed == playgroundPinPoints
            ? _value._playgroundPinPoints
            : playgroundPinPoints // ignore: cast_nullable_to_non_nullable
                  as List<LatLng>?,
        jailPinPoints: freezed == jailPinPoints
            ? _value._jailPinPoints
            : jailPinPoints // ignore: cast_nullable_to_non_nullable
                  as List<LatLng>?,
        roundDurationMinutes: freezed == roundDurationMinutes
            ? _value.roundDurationMinutes
            : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        locationShareMinutes: freezed == locationShareMinutes
            ? _value.locationShareMinutes
            : locationShareMinutes // ignore: cast_nullable_to_non_nullable
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
    this.areaType = GameAreaType.circle,
    @LatLngListConverter() final List<LatLng>? playgroundPinPoints,
    @LatLngListConverter() final List<LatLng>? jailPinPoints,
    this.roundDurationMinutes,
    this.locationShareMinutes,
    this.policeWaitMinutes,
    this.maxParticipants,
  }) : _playgroundPinPoints = playgroundPinPoints,
       _jailPinPoints = jailPinPoints;

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

  /// 구역 타입 (거리로 설정 = circle / 핀으로 설정 = polygon)
  @override
  @JsonKey()
  final GameAreaType areaType;

  /// 플레이그라운드 핀 목록 (찍은 순서 그대로 — 정렬은 표시·전송 시점에)
  final List<LatLng>? _playgroundPinPoints;

  /// 플레이그라운드 핀 목록 (찍은 순서 그대로 — 정렬은 표시·전송 시점에)
  @override
  @LatLngListConverter()
  List<LatLng>? get playgroundPinPoints {
    final value = _playgroundPinPoints;
    if (value == null) return null;
    if (_playgroundPinPoints is EqualUnmodifiableListView)
      return _playgroundPinPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// 감옥 핀 목록 (찍은 순서 그대로)
  final List<LatLng>? _jailPinPoints;

  /// 감옥 핀 목록 (찍은 순서 그대로)
  @override
  @LatLngListConverter()
  List<LatLng>? get jailPinPoints {
    final value = _jailPinPoints;
    if (value == null) return null;
    if (_jailPinPoints is EqualUnmodifiableListView) return _jailPinPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // ============================================
  // 게임 설정 (2단계: 인원 설정, 3단계: 기본정보 설정)
  // ============================================
  /// 라운드 시간 (분)
  @override
  final int? roundDurationMinutes;

  /// 위치 공유 간격 (분)
  @override
  final int? locationShareMinutes;

  /// 경찰 대기 시간 (분)
  @override
  final int? policeWaitMinutes;

  /// 최대 참가자 수
  @override
  final int? maxParticipants;

  @override
  String toString() {
    return 'SessionCreationDraftModel(playgroundCenter: $playgroundCenter, playgroundRadiusInMeters: $playgroundRadiusInMeters, jailCenter: $jailCenter, jailRadiusInMeters: $jailRadiusInMeters, areaType: $areaType, playgroundPinPoints: $playgroundPinPoints, jailPinPoints: $jailPinPoints, roundDurationMinutes: $roundDurationMinutes, locationShareMinutes: $locationShareMinutes, policeWaitMinutes: $policeWaitMinutes, maxParticipants: $maxParticipants)';
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
            (identical(other.areaType, areaType) ||
                other.areaType == areaType) &&
            const DeepCollectionEquality().equals(
              other._playgroundPinPoints,
              _playgroundPinPoints,
            ) &&
            const DeepCollectionEquality().equals(
              other._jailPinPoints,
              _jailPinPoints,
            ) &&
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
    playgroundCenter,
    playgroundRadiusInMeters,
    jailCenter,
    jailRadiusInMeters,
    areaType,
    const DeepCollectionEquality().hash(_playgroundPinPoints),
    const DeepCollectionEquality().hash(_jailPinPoints),
    roundDurationMinutes,
    locationShareMinutes,
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
    final GameAreaType areaType,
    @LatLngListConverter() final List<LatLng>? playgroundPinPoints,
    @LatLngListConverter() final List<LatLng>? jailPinPoints,
    final int? roundDurationMinutes,
    final int? locationShareMinutes,
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
  double? get jailRadiusInMeters;

  /// 구역 타입 (거리로 설정 = circle / 핀으로 설정 = polygon)
  @override
  GameAreaType get areaType;

  /// 플레이그라운드 핀 목록 (찍은 순서 그대로 — 정렬은 표시·전송 시점에)
  @override
  @LatLngListConverter()
  List<LatLng>? get playgroundPinPoints;

  /// 감옥 핀 목록 (찍은 순서 그대로)
  @override
  @LatLngListConverter()
  List<LatLng>? get jailPinPoints; // ============================================
  // 게임 설정 (2단계: 인원 설정, 3단계: 기본정보 설정)
  // ============================================
  /// 라운드 시간 (분)
  @override
  int? get roundDurationMinutes;

  /// 위치 공유 간격 (분)
  @override
  int? get locationShareMinutes;

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
