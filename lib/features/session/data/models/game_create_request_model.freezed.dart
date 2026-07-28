// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_create_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameCreateRequestModel _$GameCreateRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _GameCreateRequestModel.fromJson(json);
}

/// @nodoc
mixin _$GameCreateRequestModel {
  /// 영역 설정 (areaType + circle/polygon)
  GameAreaRequestModel get area => throw _privateConstructorUsedError;

  /// 게임 규칙 설정
  GameSettingsRequestModel get settings => throw _privateConstructorUsedError;

  /// Serializes this GameCreateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCreateRequestModelCopyWith<GameCreateRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCreateRequestModelCopyWith<$Res> {
  factory $GameCreateRequestModelCopyWith(
    GameCreateRequestModel value,
    $Res Function(GameCreateRequestModel) then,
  ) = _$GameCreateRequestModelCopyWithImpl<$Res, GameCreateRequestModel>;
  @useResult
  $Res call({GameAreaRequestModel area, GameSettingsRequestModel settings});

  $GameAreaRequestModelCopyWith<$Res> get area;
  $GameSettingsRequestModelCopyWith<$Res> get settings;
}

/// @nodoc
class _$GameCreateRequestModelCopyWithImpl<
  $Res,
  $Val extends GameCreateRequestModel
>
    implements $GameCreateRequestModelCopyWith<$Res> {
  _$GameCreateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? area = null, Object? settings = null}) {
    return _then(
      _value.copyWith(
            area: null == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as GameAreaRequestModel,
            settings: null == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as GameSettingsRequestModel,
          )
          as $Val,
    );
  }

  /// Create a copy of GameCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameAreaRequestModelCopyWith<$Res> get area {
    return $GameAreaRequestModelCopyWith<$Res>(_value.area, (value) {
      return _then(_value.copyWith(area: value) as $Val);
    });
  }

  /// Create a copy of GameCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameSettingsRequestModelCopyWith<$Res> get settings {
    return $GameSettingsRequestModelCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameCreateRequestModelImplCopyWith<$Res>
    implements $GameCreateRequestModelCopyWith<$Res> {
  factory _$$GameCreateRequestModelImplCopyWith(
    _$GameCreateRequestModelImpl value,
    $Res Function(_$GameCreateRequestModelImpl) then,
  ) = __$$GameCreateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({GameAreaRequestModel area, GameSettingsRequestModel settings});

  @override
  $GameAreaRequestModelCopyWith<$Res> get area;
  @override
  $GameSettingsRequestModelCopyWith<$Res> get settings;
}

/// @nodoc
class __$$GameCreateRequestModelImplCopyWithImpl<$Res>
    extends
        _$GameCreateRequestModelCopyWithImpl<$Res, _$GameCreateRequestModelImpl>
    implements _$$GameCreateRequestModelImplCopyWith<$Res> {
  __$$GameCreateRequestModelImplCopyWithImpl(
    _$GameCreateRequestModelImpl _value,
    $Res Function(_$GameCreateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? area = null, Object? settings = null}) {
    return _then(
      _$GameCreateRequestModelImpl(
        area: null == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as GameAreaRequestModel,
        settings: null == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as GameSettingsRequestModel,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameCreateRequestModelImpl implements _GameCreateRequestModel {
  const _$GameCreateRequestModelImpl({
    required this.area,
    required this.settings,
  });

  factory _$GameCreateRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameCreateRequestModelImplFromJson(json);

  /// 영역 설정 (areaType + circle/polygon)
  @override
  final GameAreaRequestModel area;

  /// 게임 규칙 설정
  @override
  final GameSettingsRequestModel settings;

  @override
  String toString() {
    return 'GameCreateRequestModel(area: $area, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameCreateRequestModelImpl &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.settings, settings) ||
                other.settings == settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, area, settings);

  /// Create a copy of GameCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameCreateRequestModelImplCopyWith<_$GameCreateRequestModelImpl>
  get copyWith =>
      __$$GameCreateRequestModelImplCopyWithImpl<_$GameCreateRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameCreateRequestModelImplToJson(this);
  }
}

abstract class _GameCreateRequestModel implements GameCreateRequestModel {
  const factory _GameCreateRequestModel({
    required final GameAreaRequestModel area,
    required final GameSettingsRequestModel settings,
  }) = _$GameCreateRequestModelImpl;

  factory _GameCreateRequestModel.fromJson(Map<String, dynamic> json) =
      _$GameCreateRequestModelImpl.fromJson;

  /// 영역 설정 (areaType + circle/polygon)
  @override
  GameAreaRequestModel get area;

  /// 게임 규칙 설정
  @override
  GameSettingsRequestModel get settings;

  /// Create a copy of GameCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameCreateRequestModelImplCopyWith<_$GameCreateRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GameAreaRequestModel _$GameAreaRequestModelFromJson(Map<String, dynamic> json) {
  return _GameAreaRequestModel.fromJson(json);
}

/// @nodoc
mixin _$GameAreaRequestModel {
  GameAreaType get areaType => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  CircleAreaRequestModel? get circle => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  PolygonAreaRequestModel? get polygon => throw _privateConstructorUsedError;

  /// Serializes this GameAreaRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameAreaRequestModelCopyWith<GameAreaRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameAreaRequestModelCopyWith<$Res> {
  factory $GameAreaRequestModelCopyWith(
    GameAreaRequestModel value,
    $Res Function(GameAreaRequestModel) then,
  ) = _$GameAreaRequestModelCopyWithImpl<$Res, GameAreaRequestModel>;
  @useResult
  $Res call({
    GameAreaType areaType,
    @JsonKey(includeIfNull: false) CircleAreaRequestModel? circle,
    @JsonKey(includeIfNull: false) PolygonAreaRequestModel? polygon,
  });

  $CircleAreaRequestModelCopyWith<$Res>? get circle;
  $PolygonAreaRequestModelCopyWith<$Res>? get polygon;
}

/// @nodoc
class _$GameAreaRequestModelCopyWithImpl<
  $Res,
  $Val extends GameAreaRequestModel
>
    implements $GameAreaRequestModelCopyWith<$Res> {
  _$GameAreaRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? areaType = null,
    Object? circle = freezed,
    Object? polygon = freezed,
  }) {
    return _then(
      _value.copyWith(
            areaType: null == areaType
                ? _value.areaType
                : areaType // ignore: cast_nullable_to_non_nullable
                      as GameAreaType,
            circle: freezed == circle
                ? _value.circle
                : circle // ignore: cast_nullable_to_non_nullable
                      as CircleAreaRequestModel?,
            polygon: freezed == polygon
                ? _value.polygon
                : polygon // ignore: cast_nullable_to_non_nullable
                      as PolygonAreaRequestModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CircleAreaRequestModelCopyWith<$Res>? get circle {
    if (_value.circle == null) {
      return null;
    }

    return $CircleAreaRequestModelCopyWith<$Res>(_value.circle!, (value) {
      return _then(_value.copyWith(circle: value) as $Val);
    });
  }

  /// Create a copy of GameAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PolygonAreaRequestModelCopyWith<$Res>? get polygon {
    if (_value.polygon == null) {
      return null;
    }

    return $PolygonAreaRequestModelCopyWith<$Res>(_value.polygon!, (value) {
      return _then(_value.copyWith(polygon: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameAreaRequestModelImplCopyWith<$Res>
    implements $GameAreaRequestModelCopyWith<$Res> {
  factory _$$GameAreaRequestModelImplCopyWith(
    _$GameAreaRequestModelImpl value,
    $Res Function(_$GameAreaRequestModelImpl) then,
  ) = __$$GameAreaRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    GameAreaType areaType,
    @JsonKey(includeIfNull: false) CircleAreaRequestModel? circle,
    @JsonKey(includeIfNull: false) PolygonAreaRequestModel? polygon,
  });

  @override
  $CircleAreaRequestModelCopyWith<$Res>? get circle;
  @override
  $PolygonAreaRequestModelCopyWith<$Res>? get polygon;
}

/// @nodoc
class __$$GameAreaRequestModelImplCopyWithImpl<$Res>
    extends _$GameAreaRequestModelCopyWithImpl<$Res, _$GameAreaRequestModelImpl>
    implements _$$GameAreaRequestModelImplCopyWith<$Res> {
  __$$GameAreaRequestModelImplCopyWithImpl(
    _$GameAreaRequestModelImpl _value,
    $Res Function(_$GameAreaRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? areaType = null,
    Object? circle = freezed,
    Object? polygon = freezed,
  }) {
    return _then(
      _$GameAreaRequestModelImpl(
        areaType: null == areaType
            ? _value.areaType
            : areaType // ignore: cast_nullable_to_non_nullable
                  as GameAreaType,
        circle: freezed == circle
            ? _value.circle
            : circle // ignore: cast_nullable_to_non_nullable
                  as CircleAreaRequestModel?,
        polygon: freezed == polygon
            ? _value.polygon
            : polygon // ignore: cast_nullable_to_non_nullable
                  as PolygonAreaRequestModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameAreaRequestModelImpl implements _GameAreaRequestModel {
  const _$GameAreaRequestModelImpl({
    required this.areaType,
    @JsonKey(includeIfNull: false) this.circle,
    @JsonKey(includeIfNull: false) this.polygon,
  });

  factory _$GameAreaRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameAreaRequestModelImplFromJson(json);

  @override
  final GameAreaType areaType;
  @override
  @JsonKey(includeIfNull: false)
  final CircleAreaRequestModel? circle;
  @override
  @JsonKey(includeIfNull: false)
  final PolygonAreaRequestModel? polygon;

  @override
  String toString() {
    return 'GameAreaRequestModel(areaType: $areaType, circle: $circle, polygon: $polygon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameAreaRequestModelImpl &&
            (identical(other.areaType, areaType) ||
                other.areaType == areaType) &&
            (identical(other.circle, circle) || other.circle == circle) &&
            (identical(other.polygon, polygon) || other.polygon == polygon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, areaType, circle, polygon);

  /// Create a copy of GameAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameAreaRequestModelImplCopyWith<_$GameAreaRequestModelImpl>
  get copyWith =>
      __$$GameAreaRequestModelImplCopyWithImpl<_$GameAreaRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameAreaRequestModelImplToJson(this);
  }
}

abstract class _GameAreaRequestModel implements GameAreaRequestModel {
  const factory _GameAreaRequestModel({
    required final GameAreaType areaType,
    @JsonKey(includeIfNull: false) final CircleAreaRequestModel? circle,
    @JsonKey(includeIfNull: false) final PolygonAreaRequestModel? polygon,
  }) = _$GameAreaRequestModelImpl;

  factory _GameAreaRequestModel.fromJson(Map<String, dynamic> json) =
      _$GameAreaRequestModelImpl.fromJson;

  @override
  GameAreaType get areaType;
  @override
  @JsonKey(includeIfNull: false)
  CircleAreaRequestModel? get circle;
  @override
  @JsonKey(includeIfNull: false)
  PolygonAreaRequestModel? get polygon;

  /// Create a copy of GameAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameAreaRequestModelImplCopyWith<_$GameAreaRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CircleAreaRequestModel _$CircleAreaRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _CircleAreaRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CircleAreaRequestModel {
  /// 플레이그라운드 중심 좌표
  CoordinatesRequestModel get playgroundCenter =>
      throw _privateConstructorUsedError;

  /// 플레이그라운드 반경 (미터, 최소 10m, 정수)
  int get playgroundRadiusInMeters => throw _privateConstructorUsedError;

  /// 감옥 중심 좌표
  CoordinatesRequestModel get jailCenter => throw _privateConstructorUsedError;

  /// 감옥 반경 (미터, 최소 5m, 정수)
  int get jailRadiusInMeters => throw _privateConstructorUsedError;

  /// Serializes this CircleAreaRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CircleAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CircleAreaRequestModelCopyWith<CircleAreaRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircleAreaRequestModelCopyWith<$Res> {
  factory $CircleAreaRequestModelCopyWith(
    CircleAreaRequestModel value,
    $Res Function(CircleAreaRequestModel) then,
  ) = _$CircleAreaRequestModelCopyWithImpl<$Res, CircleAreaRequestModel>;
  @useResult
  $Res call({
    CoordinatesRequestModel playgroundCenter,
    int playgroundRadiusInMeters,
    CoordinatesRequestModel jailCenter,
    int jailRadiusInMeters,
  });

  $CoordinatesRequestModelCopyWith<$Res> get playgroundCenter;
  $CoordinatesRequestModelCopyWith<$Res> get jailCenter;
}

/// @nodoc
class _$CircleAreaRequestModelCopyWithImpl<
  $Res,
  $Val extends CircleAreaRequestModel
>
    implements $CircleAreaRequestModelCopyWith<$Res> {
  _$CircleAreaRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CircleAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playgroundCenter = null,
    Object? playgroundRadiusInMeters = null,
    Object? jailCenter = null,
    Object? jailRadiusInMeters = null,
  }) {
    return _then(
      _value.copyWith(
            playgroundCenter: null == playgroundCenter
                ? _value.playgroundCenter
                : playgroundCenter // ignore: cast_nullable_to_non_nullable
                      as CoordinatesRequestModel,
            playgroundRadiusInMeters: null == playgroundRadiusInMeters
                ? _value.playgroundRadiusInMeters
                : playgroundRadiusInMeters // ignore: cast_nullable_to_non_nullable
                      as int,
            jailCenter: null == jailCenter
                ? _value.jailCenter
                : jailCenter // ignore: cast_nullable_to_non_nullable
                      as CoordinatesRequestModel,
            jailRadiusInMeters: null == jailRadiusInMeters
                ? _value.jailRadiusInMeters
                : jailRadiusInMeters // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of CircleAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CoordinatesRequestModelCopyWith<$Res> get playgroundCenter {
    return $CoordinatesRequestModelCopyWith<$Res>(_value.playgroundCenter, (
      value,
    ) {
      return _then(_value.copyWith(playgroundCenter: value) as $Val);
    });
  }

  /// Create a copy of CircleAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CoordinatesRequestModelCopyWith<$Res> get jailCenter {
    return $CoordinatesRequestModelCopyWith<$Res>(_value.jailCenter, (value) {
      return _then(_value.copyWith(jailCenter: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CircleAreaRequestModelImplCopyWith<$Res>
    implements $CircleAreaRequestModelCopyWith<$Res> {
  factory _$$CircleAreaRequestModelImplCopyWith(
    _$CircleAreaRequestModelImpl value,
    $Res Function(_$CircleAreaRequestModelImpl) then,
  ) = __$$CircleAreaRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CoordinatesRequestModel playgroundCenter,
    int playgroundRadiusInMeters,
    CoordinatesRequestModel jailCenter,
    int jailRadiusInMeters,
  });

  @override
  $CoordinatesRequestModelCopyWith<$Res> get playgroundCenter;
  @override
  $CoordinatesRequestModelCopyWith<$Res> get jailCenter;
}

/// @nodoc
class __$$CircleAreaRequestModelImplCopyWithImpl<$Res>
    extends
        _$CircleAreaRequestModelCopyWithImpl<$Res, _$CircleAreaRequestModelImpl>
    implements _$$CircleAreaRequestModelImplCopyWith<$Res> {
  __$$CircleAreaRequestModelImplCopyWithImpl(
    _$CircleAreaRequestModelImpl _value,
    $Res Function(_$CircleAreaRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CircleAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playgroundCenter = null,
    Object? playgroundRadiusInMeters = null,
    Object? jailCenter = null,
    Object? jailRadiusInMeters = null,
  }) {
    return _then(
      _$CircleAreaRequestModelImpl(
        playgroundCenter: null == playgroundCenter
            ? _value.playgroundCenter
            : playgroundCenter // ignore: cast_nullable_to_non_nullable
                  as CoordinatesRequestModel,
        playgroundRadiusInMeters: null == playgroundRadiusInMeters
            ? _value.playgroundRadiusInMeters
            : playgroundRadiusInMeters // ignore: cast_nullable_to_non_nullable
                  as int,
        jailCenter: null == jailCenter
            ? _value.jailCenter
            : jailCenter // ignore: cast_nullable_to_non_nullable
                  as CoordinatesRequestModel,
        jailRadiusInMeters: null == jailRadiusInMeters
            ? _value.jailRadiusInMeters
            : jailRadiusInMeters // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CircleAreaRequestModelImpl implements _CircleAreaRequestModel {
  const _$CircleAreaRequestModelImpl({
    required this.playgroundCenter,
    required this.playgroundRadiusInMeters,
    required this.jailCenter,
    required this.jailRadiusInMeters,
  });

  factory _$CircleAreaRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircleAreaRequestModelImplFromJson(json);

  /// 플레이그라운드 중심 좌표
  @override
  final CoordinatesRequestModel playgroundCenter;

  /// 플레이그라운드 반경 (미터, 최소 10m, 정수)
  @override
  final int playgroundRadiusInMeters;

  /// 감옥 중심 좌표
  @override
  final CoordinatesRequestModel jailCenter;

  /// 감옥 반경 (미터, 최소 5m, 정수)
  @override
  final int jailRadiusInMeters;

  @override
  String toString() {
    return 'CircleAreaRequestModel(playgroundCenter: $playgroundCenter, playgroundRadiusInMeters: $playgroundRadiusInMeters, jailCenter: $jailCenter, jailRadiusInMeters: $jailRadiusInMeters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircleAreaRequestModelImpl &&
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
                other.jailRadiusInMeters == jailRadiusInMeters));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    playgroundCenter,
    playgroundRadiusInMeters,
    jailCenter,
    jailRadiusInMeters,
  );

  /// Create a copy of CircleAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircleAreaRequestModelImplCopyWith<_$CircleAreaRequestModelImpl>
  get copyWith =>
      __$$CircleAreaRequestModelImplCopyWithImpl<_$CircleAreaRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CircleAreaRequestModelImplToJson(this);
  }
}

abstract class _CircleAreaRequestModel implements CircleAreaRequestModel {
  const factory _CircleAreaRequestModel({
    required final CoordinatesRequestModel playgroundCenter,
    required final int playgroundRadiusInMeters,
    required final CoordinatesRequestModel jailCenter,
    required final int jailRadiusInMeters,
  }) = _$CircleAreaRequestModelImpl;

  factory _CircleAreaRequestModel.fromJson(Map<String, dynamic> json) =
      _$CircleAreaRequestModelImpl.fromJson;

  /// 플레이그라운드 중심 좌표
  @override
  CoordinatesRequestModel get playgroundCenter;

  /// 플레이그라운드 반경 (미터, 최소 10m, 정수)
  @override
  int get playgroundRadiusInMeters;

  /// 감옥 중심 좌표
  @override
  CoordinatesRequestModel get jailCenter;

  /// 감옥 반경 (미터, 최소 5m, 정수)
  @override
  int get jailRadiusInMeters;

  /// Create a copy of CircleAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircleAreaRequestModelImplCopyWith<_$CircleAreaRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PolygonAreaRequestModel _$PolygonAreaRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _PolygonAreaRequestModel.fromJson(json);
}

/// @nodoc
mixin _$PolygonAreaRequestModel {
  /// 플레이그라운드 꼭짓점 좌표 목록
  List<CoordinatesRequestModel> get playgroundPolygon =>
      throw _privateConstructorUsedError;

  /// 감옥 꼭짓점 좌표 목록
  List<CoordinatesRequestModel> get jailPolygon =>
      throw _privateConstructorUsedError;

  /// Serializes this PolygonAreaRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PolygonAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PolygonAreaRequestModelCopyWith<PolygonAreaRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PolygonAreaRequestModelCopyWith<$Res> {
  factory $PolygonAreaRequestModelCopyWith(
    PolygonAreaRequestModel value,
    $Res Function(PolygonAreaRequestModel) then,
  ) = _$PolygonAreaRequestModelCopyWithImpl<$Res, PolygonAreaRequestModel>;
  @useResult
  $Res call({
    List<CoordinatesRequestModel> playgroundPolygon,
    List<CoordinatesRequestModel> jailPolygon,
  });
}

/// @nodoc
class _$PolygonAreaRequestModelCopyWithImpl<
  $Res,
  $Val extends PolygonAreaRequestModel
>
    implements $PolygonAreaRequestModelCopyWith<$Res> {
  _$PolygonAreaRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PolygonAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? playgroundPolygon = null, Object? jailPolygon = null}) {
    return _then(
      _value.copyWith(
            playgroundPolygon: null == playgroundPolygon
                ? _value.playgroundPolygon
                : playgroundPolygon // ignore: cast_nullable_to_non_nullable
                      as List<CoordinatesRequestModel>,
            jailPolygon: null == jailPolygon
                ? _value.jailPolygon
                : jailPolygon // ignore: cast_nullable_to_non_nullable
                      as List<CoordinatesRequestModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PolygonAreaRequestModelImplCopyWith<$Res>
    implements $PolygonAreaRequestModelCopyWith<$Res> {
  factory _$$PolygonAreaRequestModelImplCopyWith(
    _$PolygonAreaRequestModelImpl value,
    $Res Function(_$PolygonAreaRequestModelImpl) then,
  ) = __$$PolygonAreaRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CoordinatesRequestModel> playgroundPolygon,
    List<CoordinatesRequestModel> jailPolygon,
  });
}

/// @nodoc
class __$$PolygonAreaRequestModelImplCopyWithImpl<$Res>
    extends
        _$PolygonAreaRequestModelCopyWithImpl<
          $Res,
          _$PolygonAreaRequestModelImpl
        >
    implements _$$PolygonAreaRequestModelImplCopyWith<$Res> {
  __$$PolygonAreaRequestModelImplCopyWithImpl(
    _$PolygonAreaRequestModelImpl _value,
    $Res Function(_$PolygonAreaRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PolygonAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? playgroundPolygon = null, Object? jailPolygon = null}) {
    return _then(
      _$PolygonAreaRequestModelImpl(
        playgroundPolygon: null == playgroundPolygon
            ? _value._playgroundPolygon
            : playgroundPolygon // ignore: cast_nullable_to_non_nullable
                  as List<CoordinatesRequestModel>,
        jailPolygon: null == jailPolygon
            ? _value._jailPolygon
            : jailPolygon // ignore: cast_nullable_to_non_nullable
                  as List<CoordinatesRequestModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PolygonAreaRequestModelImpl implements _PolygonAreaRequestModel {
  const _$PolygonAreaRequestModelImpl({
    required final List<CoordinatesRequestModel> playgroundPolygon,
    required final List<CoordinatesRequestModel> jailPolygon,
  }) : _playgroundPolygon = playgroundPolygon,
       _jailPolygon = jailPolygon;

  factory _$PolygonAreaRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PolygonAreaRequestModelImplFromJson(json);

  /// 플레이그라운드 꼭짓점 좌표 목록
  final List<CoordinatesRequestModel> _playgroundPolygon;

  /// 플레이그라운드 꼭짓점 좌표 목록
  @override
  List<CoordinatesRequestModel> get playgroundPolygon {
    if (_playgroundPolygon is EqualUnmodifiableListView)
      return _playgroundPolygon;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playgroundPolygon);
  }

  /// 감옥 꼭짓점 좌표 목록
  final List<CoordinatesRequestModel> _jailPolygon;

  /// 감옥 꼭짓점 좌표 목록
  @override
  List<CoordinatesRequestModel> get jailPolygon {
    if (_jailPolygon is EqualUnmodifiableListView) return _jailPolygon;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jailPolygon);
  }

  @override
  String toString() {
    return 'PolygonAreaRequestModel(playgroundPolygon: $playgroundPolygon, jailPolygon: $jailPolygon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PolygonAreaRequestModelImpl &&
            const DeepCollectionEquality().equals(
              other._playgroundPolygon,
              _playgroundPolygon,
            ) &&
            const DeepCollectionEquality().equals(
              other._jailPolygon,
              _jailPolygon,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_playgroundPolygon),
    const DeepCollectionEquality().hash(_jailPolygon),
  );

  /// Create a copy of PolygonAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PolygonAreaRequestModelImplCopyWith<_$PolygonAreaRequestModelImpl>
  get copyWith =>
      __$$PolygonAreaRequestModelImplCopyWithImpl<
        _$PolygonAreaRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PolygonAreaRequestModelImplToJson(this);
  }
}

abstract class _PolygonAreaRequestModel implements PolygonAreaRequestModel {
  const factory _PolygonAreaRequestModel({
    required final List<CoordinatesRequestModel> playgroundPolygon,
    required final List<CoordinatesRequestModel> jailPolygon,
  }) = _$PolygonAreaRequestModelImpl;

  factory _PolygonAreaRequestModel.fromJson(Map<String, dynamic> json) =
      _$PolygonAreaRequestModelImpl.fromJson;

  /// 플레이그라운드 꼭짓점 좌표 목록
  @override
  List<CoordinatesRequestModel> get playgroundPolygon;

  /// 감옥 꼭짓점 좌표 목록
  @override
  List<CoordinatesRequestModel> get jailPolygon;

  /// Create a copy of PolygonAreaRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PolygonAreaRequestModelImplCopyWith<_$PolygonAreaRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CoordinatesRequestModel _$CoordinatesRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _CoordinatesRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CoordinatesRequestModel {
  /// 위도
  double get latitude => throw _privateConstructorUsedError;

  /// 경도
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this CoordinatesRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoordinatesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoordinatesRequestModelCopyWith<CoordinatesRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoordinatesRequestModelCopyWith<$Res> {
  factory $CoordinatesRequestModelCopyWith(
    CoordinatesRequestModel value,
    $Res Function(CoordinatesRequestModel) then,
  ) = _$CoordinatesRequestModelCopyWithImpl<$Res, CoordinatesRequestModel>;
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class _$CoordinatesRequestModelCopyWithImpl<
  $Res,
  $Val extends CoordinatesRequestModel
>
    implements $CoordinatesRequestModelCopyWith<$Res> {
  _$CoordinatesRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoordinatesRequestModel
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
abstract class _$$CoordinatesRequestModelImplCopyWith<$Res>
    implements $CoordinatesRequestModelCopyWith<$Res> {
  factory _$$CoordinatesRequestModelImplCopyWith(
    _$CoordinatesRequestModelImpl value,
    $Res Function(_$CoordinatesRequestModelImpl) then,
  ) = __$$CoordinatesRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class __$$CoordinatesRequestModelImplCopyWithImpl<$Res>
    extends
        _$CoordinatesRequestModelCopyWithImpl<
          $Res,
          _$CoordinatesRequestModelImpl
        >
    implements _$$CoordinatesRequestModelImplCopyWith<$Res> {
  __$$CoordinatesRequestModelImplCopyWithImpl(
    _$CoordinatesRequestModelImpl _value,
    $Res Function(_$CoordinatesRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CoordinatesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = null, Object? longitude = null}) {
    return _then(
      _$CoordinatesRequestModelImpl(
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
class _$CoordinatesRequestModelImpl implements _CoordinatesRequestModel {
  const _$CoordinatesRequestModelImpl({
    required this.latitude,
    required this.longitude,
  });

  factory _$CoordinatesRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoordinatesRequestModelImplFromJson(json);

  /// 위도
  @override
  final double latitude;

  /// 경도
  @override
  final double longitude;

  @override
  String toString() {
    return 'CoordinatesRequestModel(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoordinatesRequestModelImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of CoordinatesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoordinatesRequestModelImplCopyWith<_$CoordinatesRequestModelImpl>
  get copyWith =>
      __$$CoordinatesRequestModelImplCopyWithImpl<
        _$CoordinatesRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoordinatesRequestModelImplToJson(this);
  }
}

abstract class _CoordinatesRequestModel implements CoordinatesRequestModel {
  const factory _CoordinatesRequestModel({
    required final double latitude,
    required final double longitude,
  }) = _$CoordinatesRequestModelImpl;

  factory _CoordinatesRequestModel.fromJson(Map<String, dynamic> json) =
      _$CoordinatesRequestModelImpl.fromJson;

  /// 위도
  @override
  double get latitude;

  /// 경도
  @override
  double get longitude;

  /// Create a copy of CoordinatesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoordinatesRequestModelImplCopyWith<_$CoordinatesRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GameSettingsRequestModel _$GameSettingsRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _GameSettingsRequestModel.fromJson(json);
}

/// @nodoc
mixin _$GameSettingsRequestModel {
  /// 라운드 시간 (10~180분)
  int get roundDurationMinutes => throw _privateConstructorUsedError;

  /// 위치 공개 주기 (최소 1분)
  int get locationRevealIntervalMinutes => throw _privateConstructorUsedError;

  /// 경찰 대기 시간 (최소 0분)
  int get policeWaitMinutes => throw _privateConstructorUsedError;

  /// 최대 참여 인원 (2~50명)
  int get maxParticipants => throw _privateConstructorUsedError;

  /// Serializes this GameSettingsRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSettingsRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSettingsRequestModelCopyWith<GameSettingsRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSettingsRequestModelCopyWith<$Res> {
  factory $GameSettingsRequestModelCopyWith(
    GameSettingsRequestModel value,
    $Res Function(GameSettingsRequestModel) then,
  ) = _$GameSettingsRequestModelCopyWithImpl<$Res, GameSettingsRequestModel>;
  @useResult
  $Res call({
    int roundDurationMinutes,
    int locationRevealIntervalMinutes,
    int policeWaitMinutes,
    int maxParticipants,
  });
}

/// @nodoc
class _$GameSettingsRequestModelCopyWithImpl<
  $Res,
  $Val extends GameSettingsRequestModel
>
    implements $GameSettingsRequestModelCopyWith<$Res> {
  _$GameSettingsRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSettingsRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roundDurationMinutes = null,
    Object? locationRevealIntervalMinutes = null,
    Object? policeWaitMinutes = null,
    Object? maxParticipants = null,
  }) {
    return _then(
      _value.copyWith(
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameSettingsRequestModelImplCopyWith<$Res>
    implements $GameSettingsRequestModelCopyWith<$Res> {
  factory _$$GameSettingsRequestModelImplCopyWith(
    _$GameSettingsRequestModelImpl value,
    $Res Function(_$GameSettingsRequestModelImpl) then,
  ) = __$$GameSettingsRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int roundDurationMinutes,
    int locationRevealIntervalMinutes,
    int policeWaitMinutes,
    int maxParticipants,
  });
}

/// @nodoc
class __$$GameSettingsRequestModelImplCopyWithImpl<$Res>
    extends
        _$GameSettingsRequestModelCopyWithImpl<
          $Res,
          _$GameSettingsRequestModelImpl
        >
    implements _$$GameSettingsRequestModelImplCopyWith<$Res> {
  __$$GameSettingsRequestModelImplCopyWithImpl(
    _$GameSettingsRequestModelImpl _value,
    $Res Function(_$GameSettingsRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSettingsRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roundDurationMinutes = null,
    Object? locationRevealIntervalMinutes = null,
    Object? policeWaitMinutes = null,
    Object? maxParticipants = null,
  }) {
    return _then(
      _$GameSettingsRequestModelImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSettingsRequestModelImpl implements _GameSettingsRequestModel {
  const _$GameSettingsRequestModelImpl({
    required this.roundDurationMinutes,
    required this.locationRevealIntervalMinutes,
    required this.policeWaitMinutes,
    required this.maxParticipants,
  });

  factory _$GameSettingsRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSettingsRequestModelImplFromJson(json);

  /// 라운드 시간 (10~180분)
  @override
  final int roundDurationMinutes;

  /// 위치 공개 주기 (최소 1분)
  @override
  final int locationRevealIntervalMinutes;

  /// 경찰 대기 시간 (최소 0분)
  @override
  final int policeWaitMinutes;

  /// 최대 참여 인원 (2~50명)
  @override
  final int maxParticipants;

  @override
  String toString() {
    return 'GameSettingsRequestModel(roundDurationMinutes: $roundDurationMinutes, locationRevealIntervalMinutes: $locationRevealIntervalMinutes, policeWaitMinutes: $policeWaitMinutes, maxParticipants: $maxParticipants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSettingsRequestModelImpl &&
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
    roundDurationMinutes,
    locationRevealIntervalMinutes,
    policeWaitMinutes,
    maxParticipants,
  );

  /// Create a copy of GameSettingsRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSettingsRequestModelImplCopyWith<_$GameSettingsRequestModelImpl>
  get copyWith =>
      __$$GameSettingsRequestModelImplCopyWithImpl<
        _$GameSettingsRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSettingsRequestModelImplToJson(this);
  }
}

abstract class _GameSettingsRequestModel implements GameSettingsRequestModel {
  const factory _GameSettingsRequestModel({
    required final int roundDurationMinutes,
    required final int locationRevealIntervalMinutes,
    required final int policeWaitMinutes,
    required final int maxParticipants,
  }) = _$GameSettingsRequestModelImpl;

  factory _GameSettingsRequestModel.fromJson(Map<String, dynamic> json) =
      _$GameSettingsRequestModelImpl.fromJson;

  /// 라운드 시간 (10~180분)
  @override
  int get roundDurationMinutes;

  /// 위치 공개 주기 (최소 1분)
  @override
  int get locationRevealIntervalMinutes;

  /// 경찰 대기 시간 (최소 0분)
  @override
  int get policeWaitMinutes;

  /// 최대 참여 인원 (2~50명)
  @override
  int get maxParticipants;

  /// Create a copy of GameSettingsRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSettingsRequestModelImplCopyWith<_$GameSettingsRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
