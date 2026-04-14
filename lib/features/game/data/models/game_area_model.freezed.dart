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

RobberLocationModel _$RobberLocationModelFromJson(Map<String, dynamic> json) {
  return _RobberLocationModel.fromJson(json);
}

/// @nodoc
mixin _$RobberLocationModel {
  int get participantId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this RobberLocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RobberLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RobberLocationModelCopyWith<RobberLocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RobberLocationModelCopyWith<$Res> {
  factory $RobberLocationModelCopyWith(
    RobberLocationModel value,
    $Res Function(RobberLocationModel) then,
  ) = _$RobberLocationModelCopyWithImpl<$Res, RobberLocationModel>;
  @useResult
  $Res call({
    int participantId,
    String nickname,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class _$RobberLocationModelCopyWithImpl<$Res, $Val extends RobberLocationModel>
    implements $RobberLocationModelCopyWith<$Res> {
  _$RobberLocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RobberLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? latitude = null,
    Object? longitude = null,
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
abstract class _$$RobberLocationModelImplCopyWith<$Res>
    implements $RobberLocationModelCopyWith<$Res> {
  factory _$$RobberLocationModelImplCopyWith(
    _$RobberLocationModelImpl value,
    $Res Function(_$RobberLocationModelImpl) then,
  ) = __$$RobberLocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int participantId,
    String nickname,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class __$$RobberLocationModelImplCopyWithImpl<$Res>
    extends _$RobberLocationModelCopyWithImpl<$Res, _$RobberLocationModelImpl>
    implements _$$RobberLocationModelImplCopyWith<$Res> {
  __$$RobberLocationModelImplCopyWithImpl(
    _$RobberLocationModelImpl _value,
    $Res Function(_$RobberLocationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RobberLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(
      _$RobberLocationModelImpl(
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$RobberLocationModelImpl implements _RobberLocationModel {
  const _$RobberLocationModelImpl({
    required this.participantId,
    required this.nickname,
    required this.latitude,
    required this.longitude,
  });

  factory _$RobberLocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RobberLocationModelImplFromJson(json);

  @override
  final int participantId;
  @override
  final String nickname;
  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'RobberLocationModel(participantId: $participantId, nickname: $nickname, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RobberLocationModelImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, participantId, nickname, latitude, longitude);

  /// Create a copy of RobberLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RobberLocationModelImplCopyWith<_$RobberLocationModelImpl> get copyWith =>
      __$$RobberLocationModelImplCopyWithImpl<_$RobberLocationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RobberLocationModelImplToJson(this);
  }
}

abstract class _RobberLocationModel implements RobberLocationModel {
  const factory _RobberLocationModel({
    required final int participantId,
    required final String nickname,
    required final double latitude,
    required final double longitude,
  }) = _$RobberLocationModelImpl;

  factory _RobberLocationModel.fromJson(Map<String, dynamic> json) =
      _$RobberLocationModelImpl.fromJson;

  @override
  int get participantId;
  @override
  String get nickname;
  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of RobberLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RobberLocationModelImplCopyWith<_$RobberLocationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameAreaModel _$GameAreaModelFromJson(Map<String, dynamic> json) {
  return _GameAreaModel.fromJson(json);
}

/// @nodoc
mixin _$GameAreaModel {
  LatLngModel get playgroundCenter => throw _privateConstructorUsedError;
  double get playgroundRadiusInMeters => throw _privateConstructorUsedError;
  LatLngModel get jailCenter => throw _privateConstructorUsedError;
  double get jailRadiusInMeters => throw _privateConstructorUsedError;

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
    LatLngModel playgroundCenter,
    double playgroundRadiusInMeters,
    LatLngModel jailCenter,
    double jailRadiusInMeters,
  });

  $LatLngModelCopyWith<$Res> get playgroundCenter;
  $LatLngModelCopyWith<$Res> get jailCenter;
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

  /// Create a copy of GameAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LatLngModelCopyWith<$Res> get playgroundCenter {
    return $LatLngModelCopyWith<$Res>(_value.playgroundCenter, (value) {
      return _then(_value.copyWith(playgroundCenter: value) as $Val);
    });
  }

  /// Create a copy of GameAreaModel
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
abstract class _$$GameAreaModelImplCopyWith<$Res>
    implements $GameAreaModelCopyWith<$Res> {
  factory _$$GameAreaModelImplCopyWith(
    _$GameAreaModelImpl value,
    $Res Function(_$GameAreaModelImpl) then,
  ) = __$$GameAreaModelImplCopyWithImpl<$Res>;
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
    Object? playgroundCenter = null,
    Object? playgroundRadiusInMeters = null,
    Object? jailCenter = null,
    Object? jailRadiusInMeters = null,
  }) {
    return _then(
      _$GameAreaModelImpl(
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
class _$GameAreaModelImpl implements _GameAreaModel {
  const _$GameAreaModelImpl({
    required this.playgroundCenter,
    required this.playgroundRadiusInMeters,
    required this.jailCenter,
    required this.jailRadiusInMeters,
  });

  factory _$GameAreaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameAreaModelImplFromJson(json);

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
    return 'GameAreaModel(playgroundCenter: $playgroundCenter, playgroundRadiusInMeters: $playgroundRadiusInMeters, jailCenter: $jailCenter, jailRadiusInMeters: $jailRadiusInMeters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameAreaModelImpl &&
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
    required final LatLngModel playgroundCenter,
    required final double playgroundRadiusInMeters,
    required final LatLngModel jailCenter,
    required final double jailRadiusInMeters,
  }) = _$GameAreaModelImpl;

  factory _GameAreaModel.fromJson(Map<String, dynamic> json) =
      _$GameAreaModelImpl.fromJson;

  @override
  LatLngModel get playgroundCenter;
  @override
  double get playgroundRadiusInMeters;
  @override
  LatLngModel get jailCenter;
  @override
  double get jailRadiusInMeters;

  /// Create a copy of GameAreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameAreaModelImplCopyWith<_$GameAreaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
