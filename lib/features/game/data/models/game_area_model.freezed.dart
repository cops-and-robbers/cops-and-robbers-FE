// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_area_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LatLngModel _$LatLngModelFromJson(Map<String, dynamic> json) {
  return _LatLngModel.fromJson(json);
}

/// @nodoc
mixin _$LatLngModel {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this LatLngModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LatLngModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LatLngModelCopyWith<LatLngModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LatLngModelCopyWith<$Res> {
  factory $LatLngModelCopyWith(
    LatLngModel value,
    $Res Function(LatLngModel) then,
  ) = _$LatLngModelCopyWithImpl<$Res, LatLngModel>;
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class _$LatLngModelCopyWithImpl<$Res, $Val extends LatLngModel>
    implements $LatLngModelCopyWith<$Res> {
  _$LatLngModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LatLngModel
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
abstract class _$$LatLngModelImplCopyWith<$Res>
    implements $LatLngModelCopyWith<$Res> {
  factory _$$LatLngModelImplCopyWith(
    _$LatLngModelImpl value,
    $Res Function(_$LatLngModelImpl) then,
  ) = __$$LatLngModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class __$$LatLngModelImplCopyWithImpl<$Res>
    extends _$LatLngModelCopyWithImpl<$Res, _$LatLngModelImpl>
    implements _$$LatLngModelImplCopyWith<$Res> {
  __$$LatLngModelImplCopyWithImpl(
    _$LatLngModelImpl _value,
    $Res Function(_$LatLngModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LatLngModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = null, Object? longitude = null}) {
    return _then(
      _$LatLngModelImpl(
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
class _$LatLngModelImpl implements _LatLngModel {
  const _$LatLngModelImpl({required this.latitude, required this.longitude});

  factory _$LatLngModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LatLngModelImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'LatLngModel(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LatLngModelImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of LatLngModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LatLngModelImplCopyWith<_$LatLngModelImpl> get copyWith =>
      __$$LatLngModelImplCopyWithImpl<_$LatLngModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LatLngModelImplToJson(this);
  }
}

abstract class _LatLngModel implements LatLngModel {
  const factory _LatLngModel({
    required final double latitude,
    required final double longitude,
  }) = _$LatLngModelImpl;

  factory _LatLngModel.fromJson(Map<String, dynamic> json) =
      _$LatLngModelImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of LatLngModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LatLngModelImplCopyWith<_$LatLngModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CircleAreaModel _$CircleAreaModelFromJson(Map<String, dynamic> json) {
  return _CircleAreaModel.fromJson(json);
}

/// @nodoc
mixin _$CircleAreaModel {
  LatLngModel get playgroundCenter => throw _privateConstructorUsedError;
  double get playgroundRadiusInMeters => throw _privateConstructorUsedError;
  LatLngModel get jailCenter => throw _privateConstructorUsedError;
  double get jailRadiusInMeters => throw _privateConstructorUsedError;

  /// Serializes this CircleAreaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CircleAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CircleAreaModelCopyWith<CircleAreaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircleAreaModelCopyWith<$Res> {
  factory $CircleAreaModelCopyWith(
    CircleAreaModel value,
    $Res Function(CircleAreaModel) then,
  ) = _$CircleAreaModelCopyWithImpl<$Res, CircleAreaModel>;
  @useResult
  $Res call({
    LatLngModel playgroundCenter,
    double playgroundRadiusInMeters,
    LatLngModel jailCenter,
    double jailRadiusInMeters,
  });

  $LatLngModelCopyWith<$Res> get playgroundCenter;
  $LatLngModelCopyWith<$Res> get jailCenter;
}

/// @nodoc
class _$CircleAreaModelCopyWithImpl<$Res, $Val extends CircleAreaModel>
    implements $CircleAreaModelCopyWith<$Res> {
  _$CircleAreaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CircleAreaModel
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
                      as LatLngModel,
            playgroundRadiusInMeters: null == playgroundRadiusInMeters
                ? _value.playgroundRadiusInMeters
                : playgroundRadiusInMeters // ignore: cast_nullable_to_non_nullable
                      as double,
            jailCenter: null == jailCenter
                ? _value.jailCenter
                : jailCenter // ignore: cast_nullable_to_non_nullable
                      as LatLngModel,
            jailRadiusInMeters: null == jailRadiusInMeters
                ? _value.jailRadiusInMeters
                : jailRadiusInMeters // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }

  /// Create a copy of CircleAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LatLngModelCopyWith<$Res> get playgroundCenter {
    return $LatLngModelCopyWith<$Res>(_value.playgroundCenter, (value) {
      return _then(_value.copyWith(playgroundCenter: value) as $Val);
    });
  }

  /// Create a copy of CircleAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LatLngModelCopyWith<$Res> get jailCenter {
    return $LatLngModelCopyWith<$Res>(_value.jailCenter, (value) {
      return _then(_value.copyWith(jailCenter: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CircleAreaModelImplCopyWith<$Res>
    implements $CircleAreaModelCopyWith<$Res> {
  factory _$$CircleAreaModelImplCopyWith(
    _$CircleAreaModelImpl value,
    $Res Function(_$CircleAreaModelImpl) then,
  ) = __$$CircleAreaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    LatLngModel playgroundCenter,
    double playgroundRadiusInMeters,
    LatLngModel jailCenter,
    double jailRadiusInMeters,
  });

  @override
  $LatLngModelCopyWith<$Res> get playgroundCenter;
  @override
  $LatLngModelCopyWith<$Res> get jailCenter;
}

/// @nodoc
class __$$CircleAreaModelImplCopyWithImpl<$Res>
    extends _$CircleAreaModelCopyWithImpl<$Res, _$CircleAreaModelImpl>
    implements _$$CircleAreaModelImplCopyWith<$Res> {
  __$$CircleAreaModelImplCopyWithImpl(
    _$CircleAreaModelImpl _value,
    $Res Function(_$CircleAreaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CircleAreaModel
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
      _$CircleAreaModelImpl(
        playgroundCenter: null == playgroundCenter
            ? _value.playgroundCenter
            : playgroundCenter // ignore: cast_nullable_to_non_nullable
                  as LatLngModel,
        playgroundRadiusInMeters: null == playgroundRadiusInMeters
            ? _value.playgroundRadiusInMeters
            : playgroundRadiusInMeters // ignore: cast_nullable_to_non_nullable
                  as double,
        jailCenter: null == jailCenter
            ? _value.jailCenter
            : jailCenter // ignore: cast_nullable_to_non_nullable
                  as LatLngModel,
        jailRadiusInMeters: null == jailRadiusInMeters
            ? _value.jailRadiusInMeters
            : jailRadiusInMeters // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CircleAreaModelImpl implements _CircleAreaModel {
  const _$CircleAreaModelImpl({
    required this.playgroundCenter,
    required this.playgroundRadiusInMeters,
    required this.jailCenter,
    required this.jailRadiusInMeters,
  });

  factory _$CircleAreaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircleAreaModelImplFromJson(json);

  @override
  final LatLngModel playgroundCenter;
  @override
  final double playgroundRadiusInMeters;
  @override
  final LatLngModel jailCenter;
  @override
  final double jailRadiusInMeters;

  @override
  String toString() {
    return 'CircleAreaModel(playgroundCenter: $playgroundCenter, playgroundRadiusInMeters: $playgroundRadiusInMeters, jailCenter: $jailCenter, jailRadiusInMeters: $jailRadiusInMeters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircleAreaModelImpl &&
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

  /// Create a copy of CircleAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircleAreaModelImplCopyWith<_$CircleAreaModelImpl> get copyWith =>
      __$$CircleAreaModelImplCopyWithImpl<_$CircleAreaModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CircleAreaModelImplToJson(this);
  }
}

abstract class _CircleAreaModel implements CircleAreaModel {
  const factory _CircleAreaModel({
    required final LatLngModel playgroundCenter,
    required final double playgroundRadiusInMeters,
    required final LatLngModel jailCenter,
    required final double jailRadiusInMeters,
  }) = _$CircleAreaModelImpl;

  factory _CircleAreaModel.fromJson(Map<String, dynamic> json) =
      _$CircleAreaModelImpl.fromJson;

  @override
  LatLngModel get playgroundCenter;
  @override
  double get playgroundRadiusInMeters;
  @override
  LatLngModel get jailCenter;
  @override
  double get jailRadiusInMeters;

  /// Create a copy of CircleAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircleAreaModelImplCopyWith<_$CircleAreaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PolygonAreaModel _$PolygonAreaModelFromJson(Map<String, dynamic> json) {
  return _PolygonAreaModel.fromJson(json);
}

/// @nodoc
mixin _$PolygonAreaModel {
  List<LatLngModel> get playgroundPolygon => throw _privateConstructorUsedError;
  List<LatLngModel> get jailPolygon => throw _privateConstructorUsedError;

  /// Serializes this PolygonAreaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PolygonAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PolygonAreaModelCopyWith<PolygonAreaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PolygonAreaModelCopyWith<$Res> {
  factory $PolygonAreaModelCopyWith(
    PolygonAreaModel value,
    $Res Function(PolygonAreaModel) then,
  ) = _$PolygonAreaModelCopyWithImpl<$Res, PolygonAreaModel>;
  @useResult
  $Res call({
    List<LatLngModel> playgroundPolygon,
    List<LatLngModel> jailPolygon,
  });
}

/// @nodoc
class _$PolygonAreaModelCopyWithImpl<$Res, $Val extends PolygonAreaModel>
    implements $PolygonAreaModelCopyWith<$Res> {
  _$PolygonAreaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PolygonAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? playgroundPolygon = null, Object? jailPolygon = null}) {
    return _then(
      _value.copyWith(
            playgroundPolygon: null == playgroundPolygon
                ? _value.playgroundPolygon
                : playgroundPolygon // ignore: cast_nullable_to_non_nullable
                      as List<LatLngModel>,
            jailPolygon: null == jailPolygon
                ? _value.jailPolygon
                : jailPolygon // ignore: cast_nullable_to_non_nullable
                      as List<LatLngModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PolygonAreaModelImplCopyWith<$Res>
    implements $PolygonAreaModelCopyWith<$Res> {
  factory _$$PolygonAreaModelImplCopyWith(
    _$PolygonAreaModelImpl value,
    $Res Function(_$PolygonAreaModelImpl) then,
  ) = __$$PolygonAreaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<LatLngModel> playgroundPolygon,
    List<LatLngModel> jailPolygon,
  });
}

/// @nodoc
class __$$PolygonAreaModelImplCopyWithImpl<$Res>
    extends _$PolygonAreaModelCopyWithImpl<$Res, _$PolygonAreaModelImpl>
    implements _$$PolygonAreaModelImplCopyWith<$Res> {
  __$$PolygonAreaModelImplCopyWithImpl(
    _$PolygonAreaModelImpl _value,
    $Res Function(_$PolygonAreaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PolygonAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? playgroundPolygon = null, Object? jailPolygon = null}) {
    return _then(
      _$PolygonAreaModelImpl(
        playgroundPolygon: null == playgroundPolygon
            ? _value._playgroundPolygon
            : playgroundPolygon // ignore: cast_nullable_to_non_nullable
                  as List<LatLngModel>,
        jailPolygon: null == jailPolygon
            ? _value._jailPolygon
            : jailPolygon // ignore: cast_nullable_to_non_nullable
                  as List<LatLngModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PolygonAreaModelImpl implements _PolygonAreaModel {
  const _$PolygonAreaModelImpl({
    required final List<LatLngModel> playgroundPolygon,
    required final List<LatLngModel> jailPolygon,
  }) : _playgroundPolygon = playgroundPolygon,
       _jailPolygon = jailPolygon;

  factory _$PolygonAreaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PolygonAreaModelImplFromJson(json);

  final List<LatLngModel> _playgroundPolygon;
  @override
  List<LatLngModel> get playgroundPolygon {
    if (_playgroundPolygon is EqualUnmodifiableListView)
      return _playgroundPolygon;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playgroundPolygon);
  }

  final List<LatLngModel> _jailPolygon;
  @override
  List<LatLngModel> get jailPolygon {
    if (_jailPolygon is EqualUnmodifiableListView) return _jailPolygon;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jailPolygon);
  }

  @override
  String toString() {
    return 'PolygonAreaModel(playgroundPolygon: $playgroundPolygon, jailPolygon: $jailPolygon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PolygonAreaModelImpl &&
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

  /// Create a copy of PolygonAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PolygonAreaModelImplCopyWith<_$PolygonAreaModelImpl> get copyWith =>
      __$$PolygonAreaModelImplCopyWithImpl<_$PolygonAreaModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PolygonAreaModelImplToJson(this);
  }
}

abstract class _PolygonAreaModel implements PolygonAreaModel {
  const factory _PolygonAreaModel({
    required final List<LatLngModel> playgroundPolygon,
    required final List<LatLngModel> jailPolygon,
  }) = _$PolygonAreaModelImpl;

  factory _PolygonAreaModel.fromJson(Map<String, dynamic> json) =
      _$PolygonAreaModelImpl.fromJson;

  @override
  List<LatLngModel> get playgroundPolygon;
  @override
  List<LatLngModel> get jailPolygon;

  /// Create a copy of PolygonAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PolygonAreaModelImplCopyWith<_$PolygonAreaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameAreaModel _$GameAreaModelFromJson(Map<String, dynamic> json) {
  return _GameAreaModel.fromJson(json);
}

/// @nodoc
mixin _$GameAreaModel {
  GameAreaType get areaType => throw _privateConstructorUsedError;
  CircleAreaModel? get circle => throw _privateConstructorUsedError;
  PolygonAreaModel? get polygon => throw _privateConstructorUsedError;

  /// Serializes this GameAreaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameAreaModelCopyWith<GameAreaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameAreaModelCopyWith<$Res> {
  factory $GameAreaModelCopyWith(
    GameAreaModel value,
    $Res Function(GameAreaModel) then,
  ) = _$GameAreaModelCopyWithImpl<$Res, GameAreaModel>;
  @useResult
  $Res call({
    GameAreaType areaType,
    CircleAreaModel? circle,
    PolygonAreaModel? polygon,
  });

  $CircleAreaModelCopyWith<$Res>? get circle;
  $PolygonAreaModelCopyWith<$Res>? get polygon;
}

/// @nodoc
class _$GameAreaModelCopyWithImpl<$Res, $Val extends GameAreaModel>
    implements $GameAreaModelCopyWith<$Res> {
  _$GameAreaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameAreaModel
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
                      as CircleAreaModel?,
            polygon: freezed == polygon
                ? _value.polygon
                : polygon // ignore: cast_nullable_to_non_nullable
                      as PolygonAreaModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CircleAreaModelCopyWith<$Res>? get circle {
    if (_value.circle == null) {
      return null;
    }

    return $CircleAreaModelCopyWith<$Res>(_value.circle!, (value) {
      return _then(_value.copyWith(circle: value) as $Val);
    });
  }

  /// Create a copy of GameAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PolygonAreaModelCopyWith<$Res>? get polygon {
    if (_value.polygon == null) {
      return null;
    }

    return $PolygonAreaModelCopyWith<$Res>(_value.polygon!, (value) {
      return _then(_value.copyWith(polygon: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameAreaModelImplCopyWith<$Res>
    implements $GameAreaModelCopyWith<$Res> {
  factory _$$GameAreaModelImplCopyWith(
    _$GameAreaModelImpl value,
    $Res Function(_$GameAreaModelImpl) then,
  ) = __$$GameAreaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    GameAreaType areaType,
    CircleAreaModel? circle,
    PolygonAreaModel? polygon,
  });

  @override
  $CircleAreaModelCopyWith<$Res>? get circle;
  @override
  $PolygonAreaModelCopyWith<$Res>? get polygon;
}

/// @nodoc
class __$$GameAreaModelImplCopyWithImpl<$Res>
    extends _$GameAreaModelCopyWithImpl<$Res, _$GameAreaModelImpl>
    implements _$$GameAreaModelImplCopyWith<$Res> {
  __$$GameAreaModelImplCopyWithImpl(
    _$GameAreaModelImpl _value,
    $Res Function(_$GameAreaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? areaType = null,
    Object? circle = freezed,
    Object? polygon = freezed,
  }) {
    return _then(
      _$GameAreaModelImpl(
        areaType: null == areaType
            ? _value.areaType
            : areaType // ignore: cast_nullable_to_non_nullable
                  as GameAreaType,
        circle: freezed == circle
            ? _value.circle
            : circle // ignore: cast_nullable_to_non_nullable
                  as CircleAreaModel?,
        polygon: freezed == polygon
            ? _value.polygon
            : polygon // ignore: cast_nullable_to_non_nullable
                  as PolygonAreaModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameAreaModelImpl implements _GameAreaModel {
  const _$GameAreaModelImpl({
    required this.areaType,
    this.circle,
    this.polygon,
  });

  factory _$GameAreaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameAreaModelImplFromJson(json);

  @override
  final GameAreaType areaType;
  @override
  final CircleAreaModel? circle;
  @override
  final PolygonAreaModel? polygon;

  @override
  String toString() {
    return 'GameAreaModel(areaType: $areaType, circle: $circle, polygon: $polygon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameAreaModelImpl &&
            (identical(other.areaType, areaType) ||
                other.areaType == areaType) &&
            (identical(other.circle, circle) || other.circle == circle) &&
            (identical(other.polygon, polygon) || other.polygon == polygon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, areaType, circle, polygon);

  /// Create a copy of GameAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameAreaModelImplCopyWith<_$GameAreaModelImpl> get copyWith =>
      __$$GameAreaModelImplCopyWithImpl<_$GameAreaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameAreaModelImplToJson(this);
  }
}

abstract class _GameAreaModel implements GameAreaModel {
  const factory _GameAreaModel({
    required final GameAreaType areaType,
    final CircleAreaModel? circle,
    final PolygonAreaModel? polygon,
  }) = _$GameAreaModelImpl;

  factory _GameAreaModel.fromJson(Map<String, dynamic> json) =
      _$GameAreaModelImpl.fromJson;

  @override
  GameAreaType get areaType;
  @override
  CircleAreaModel? get circle;
  @override
  PolygonAreaModel? get polygon;

  /// Create a copy of GameAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameAreaModelImplCopyWith<_$GameAreaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
