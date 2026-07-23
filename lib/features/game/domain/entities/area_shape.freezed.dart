// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'area_shape.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GeoPoint {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeoPointCopyWith<GeoPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeoPointCopyWith<$Res> {
  factory $GeoPointCopyWith(GeoPoint value, $Res Function(GeoPoint) then) =
      _$GeoPointCopyWithImpl<$Res, GeoPoint>;
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class _$GeoPointCopyWithImpl<$Res, $Val extends GeoPoint>
    implements $GeoPointCopyWith<$Res> {
  _$GeoPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeoPoint
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
abstract class _$$GeoPointImplCopyWith<$Res>
    implements $GeoPointCopyWith<$Res> {
  factory _$$GeoPointImplCopyWith(
    _$GeoPointImpl value,
    $Res Function(_$GeoPointImpl) then,
  ) = __$$GeoPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class __$$GeoPointImplCopyWithImpl<$Res>
    extends _$GeoPointCopyWithImpl<$Res, _$GeoPointImpl>
    implements _$$GeoPointImplCopyWith<$Res> {
  __$$GeoPointImplCopyWithImpl(
    _$GeoPointImpl _value,
    $Res Function(_$GeoPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = null, Object? longitude = null}) {
    return _then(
      _$GeoPointImpl(
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

class _$GeoPointImpl implements _GeoPoint {
  const _$GeoPointImpl({required this.latitude, required this.longitude});

  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'GeoPoint(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeoPointImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeoPointImplCopyWith<_$GeoPointImpl> get copyWith =>
      __$$GeoPointImplCopyWithImpl<_$GeoPointImpl>(this, _$identity);
}

abstract class _GeoPoint implements GeoPoint {
  const factory _GeoPoint({
    required final double latitude,
    required final double longitude,
  }) = _$GeoPointImpl;

  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeoPointImplCopyWith<_$GeoPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AreaShape {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GeoPoint center, double radiusInMeters) circle,
    required TResult Function(List<GeoPoint> points) polygon,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GeoPoint center, double radiusInMeters)? circle,
    TResult? Function(List<GeoPoint> points)? polygon,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GeoPoint center, double radiusInMeters)? circle,
    TResult Function(List<GeoPoint> points)? polygon,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CircleShape value) circle,
    required TResult Function(PolygonShape value) polygon,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CircleShape value)? circle,
    TResult? Function(PolygonShape value)? polygon,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CircleShape value)? circle,
    TResult Function(PolygonShape value)? polygon,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AreaShapeCopyWith<$Res> {
  factory $AreaShapeCopyWith(AreaShape value, $Res Function(AreaShape) then) =
      _$AreaShapeCopyWithImpl<$Res, AreaShape>;
}

/// @nodoc
class _$AreaShapeCopyWithImpl<$Res, $Val extends AreaShape>
    implements $AreaShapeCopyWith<$Res> {
  _$AreaShapeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AreaShape
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CircleShapeImplCopyWith<$Res> {
  factory _$$CircleShapeImplCopyWith(
    _$CircleShapeImpl value,
    $Res Function(_$CircleShapeImpl) then,
  ) = __$$CircleShapeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GeoPoint center, double radiusInMeters});

  $GeoPointCopyWith<$Res> get center;
}

/// @nodoc
class __$$CircleShapeImplCopyWithImpl<$Res>
    extends _$AreaShapeCopyWithImpl<$Res, _$CircleShapeImpl>
    implements _$$CircleShapeImplCopyWith<$Res> {
  __$$CircleShapeImplCopyWithImpl(
    _$CircleShapeImpl _value,
    $Res Function(_$CircleShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AreaShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? center = null, Object? radiusInMeters = null}) {
    return _then(
      _$CircleShapeImpl(
        center: null == center
            ? _value.center
            : center // ignore: cast_nullable_to_non_nullable
                  as GeoPoint,
        radiusInMeters: null == radiusInMeters
            ? _value.radiusInMeters
            : radiusInMeters // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }

  /// Create a copy of AreaShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeoPointCopyWith<$Res> get center {
    return $GeoPointCopyWith<$Res>(_value.center, (value) {
      return _then(_value.copyWith(center: value));
    });
  }
}

/// @nodoc

class _$CircleShapeImpl extends CircleShape {
  const _$CircleShapeImpl({required this.center, required this.radiusInMeters})
    : super._();

  @override
  final GeoPoint center;
  @override
  final double radiusInMeters;

  @override
  String toString() {
    return 'AreaShape.circle(center: $center, radiusInMeters: $radiusInMeters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircleShapeImpl &&
            (identical(other.center, center) || other.center == center) &&
            (identical(other.radiusInMeters, radiusInMeters) ||
                other.radiusInMeters == radiusInMeters));
  }

  @override
  int get hashCode => Object.hash(runtimeType, center, radiusInMeters);

  /// Create a copy of AreaShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircleShapeImplCopyWith<_$CircleShapeImpl> get copyWith =>
      __$$CircleShapeImplCopyWithImpl<_$CircleShapeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GeoPoint center, double radiusInMeters) circle,
    required TResult Function(List<GeoPoint> points) polygon,
  }) {
    return circle(center, radiusInMeters);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GeoPoint center, double radiusInMeters)? circle,
    TResult? Function(List<GeoPoint> points)? polygon,
  }) {
    return circle?.call(center, radiusInMeters);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GeoPoint center, double radiusInMeters)? circle,
    TResult Function(List<GeoPoint> points)? polygon,
    required TResult orElse(),
  }) {
    if (circle != null) {
      return circle(center, radiusInMeters);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CircleShape value) circle,
    required TResult Function(PolygonShape value) polygon,
  }) {
    return circle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CircleShape value)? circle,
    TResult? Function(PolygonShape value)? polygon,
  }) {
    return circle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CircleShape value)? circle,
    TResult Function(PolygonShape value)? polygon,
    required TResult orElse(),
  }) {
    if (circle != null) {
      return circle(this);
    }
    return orElse();
  }
}

abstract class CircleShape extends AreaShape {
  const factory CircleShape({
    required final GeoPoint center,
    required final double radiusInMeters,
  }) = _$CircleShapeImpl;
  const CircleShape._() : super._();

  GeoPoint get center;
  double get radiusInMeters;

  /// Create a copy of AreaShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircleShapeImplCopyWith<_$CircleShapeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PolygonShapeImplCopyWith<$Res> {
  factory _$$PolygonShapeImplCopyWith(
    _$PolygonShapeImpl value,
    $Res Function(_$PolygonShapeImpl) then,
  ) = __$$PolygonShapeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<GeoPoint> points});
}

/// @nodoc
class __$$PolygonShapeImplCopyWithImpl<$Res>
    extends _$AreaShapeCopyWithImpl<$Res, _$PolygonShapeImpl>
    implements _$$PolygonShapeImplCopyWith<$Res> {
  __$$PolygonShapeImplCopyWithImpl(
    _$PolygonShapeImpl _value,
    $Res Function(_$PolygonShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AreaShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? points = null}) {
    return _then(
      _$PolygonShapeImpl(
        points: null == points
            ? _value._points
            : points // ignore: cast_nullable_to_non_nullable
                  as List<GeoPoint>,
      ),
    );
  }
}

/// @nodoc

class _$PolygonShapeImpl extends PolygonShape {
  const _$PolygonShapeImpl({required final List<GeoPoint> points})
    : _points = points,
      super._();

  final List<GeoPoint> _points;
  @override
  List<GeoPoint> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  String toString() {
    return 'AreaShape.polygon(points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PolygonShapeImpl &&
            const DeepCollectionEquality().equals(other._points, _points));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_points));

  /// Create a copy of AreaShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PolygonShapeImplCopyWith<_$PolygonShapeImpl> get copyWith =>
      __$$PolygonShapeImplCopyWithImpl<_$PolygonShapeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GeoPoint center, double radiusInMeters) circle,
    required TResult Function(List<GeoPoint> points) polygon,
  }) {
    return polygon(points);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GeoPoint center, double radiusInMeters)? circle,
    TResult? Function(List<GeoPoint> points)? polygon,
  }) {
    return polygon?.call(points);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GeoPoint center, double radiusInMeters)? circle,
    TResult Function(List<GeoPoint> points)? polygon,
    required TResult orElse(),
  }) {
    if (polygon != null) {
      return polygon(points);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CircleShape value) circle,
    required TResult Function(PolygonShape value) polygon,
  }) {
    return polygon(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CircleShape value)? circle,
    TResult? Function(PolygonShape value)? polygon,
  }) {
    return polygon?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CircleShape value)? circle,
    TResult Function(PolygonShape value)? polygon,
    required TResult orElse(),
  }) {
    if (polygon != null) {
      return polygon(this);
    }
    return orElse();
  }
}

abstract class PolygonShape extends AreaShape {
  const factory PolygonShape({required final List<GeoPoint> points}) =
      _$PolygonShapeImpl;
  const PolygonShape._() : super._();

  List<GeoPoint> get points;

  /// Create a copy of AreaShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PolygonShapeImplCopyWith<_$PolygonShapeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GameAreaEntity {
  AreaShape get playground => throw _privateConstructorUsedError;
  AreaShape get jail => throw _privateConstructorUsedError;

  /// Create a copy of GameAreaEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameAreaEntityCopyWith<GameAreaEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameAreaEntityCopyWith<$Res> {
  factory $GameAreaEntityCopyWith(
    GameAreaEntity value,
    $Res Function(GameAreaEntity) then,
  ) = _$GameAreaEntityCopyWithImpl<$Res, GameAreaEntity>;
  @useResult
  $Res call({AreaShape playground, AreaShape jail});

  $AreaShapeCopyWith<$Res> get playground;
  $AreaShapeCopyWith<$Res> get jail;
}

/// @nodoc
class _$GameAreaEntityCopyWithImpl<$Res, $Val extends GameAreaEntity>
    implements $GameAreaEntityCopyWith<$Res> {
  _$GameAreaEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameAreaEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? playground = null, Object? jail = null}) {
    return _then(
      _value.copyWith(
            playground: null == playground
                ? _value.playground
                : playground // ignore: cast_nullable_to_non_nullable
                      as AreaShape,
            jail: null == jail
                ? _value.jail
                : jail // ignore: cast_nullable_to_non_nullable
                      as AreaShape,
          )
          as $Val,
    );
  }

  /// Create a copy of GameAreaEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AreaShapeCopyWith<$Res> get playground {
    return $AreaShapeCopyWith<$Res>(_value.playground, (value) {
      return _then(_value.copyWith(playground: value) as $Val);
    });
  }

  /// Create a copy of GameAreaEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AreaShapeCopyWith<$Res> get jail {
    return $AreaShapeCopyWith<$Res>(_value.jail, (value) {
      return _then(_value.copyWith(jail: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameAreaEntityImplCopyWith<$Res>
    implements $GameAreaEntityCopyWith<$Res> {
  factory _$$GameAreaEntityImplCopyWith(
    _$GameAreaEntityImpl value,
    $Res Function(_$GameAreaEntityImpl) then,
  ) = __$$GameAreaEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AreaShape playground, AreaShape jail});

  @override
  $AreaShapeCopyWith<$Res> get playground;
  @override
  $AreaShapeCopyWith<$Res> get jail;
}

/// @nodoc
class __$$GameAreaEntityImplCopyWithImpl<$Res>
    extends _$GameAreaEntityCopyWithImpl<$Res, _$GameAreaEntityImpl>
    implements _$$GameAreaEntityImplCopyWith<$Res> {
  __$$GameAreaEntityImplCopyWithImpl(
    _$GameAreaEntityImpl _value,
    $Res Function(_$GameAreaEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameAreaEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? playground = null, Object? jail = null}) {
    return _then(
      _$GameAreaEntityImpl(
        playground: null == playground
            ? _value.playground
            : playground // ignore: cast_nullable_to_non_nullable
                  as AreaShape,
        jail: null == jail
            ? _value.jail
            : jail // ignore: cast_nullable_to_non_nullable
                  as AreaShape,
      ),
    );
  }
}

/// @nodoc

class _$GameAreaEntityImpl implements _GameAreaEntity {
  const _$GameAreaEntityImpl({required this.playground, required this.jail});

  @override
  final AreaShape playground;
  @override
  final AreaShape jail;

  @override
  String toString() {
    return 'GameAreaEntity(playground: $playground, jail: $jail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameAreaEntityImpl &&
            (identical(other.playground, playground) ||
                other.playground == playground) &&
            (identical(other.jail, jail) || other.jail == jail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, playground, jail);

  /// Create a copy of GameAreaEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameAreaEntityImplCopyWith<_$GameAreaEntityImpl> get copyWith =>
      __$$GameAreaEntityImplCopyWithImpl<_$GameAreaEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _GameAreaEntity implements GameAreaEntity {
  const factory _GameAreaEntity({
    required final AreaShape playground,
    required final AreaShape jail,
  }) = _$GameAreaEntityImpl;

  @override
  AreaShape get playground;
  @override
  AreaShape get jail;

  /// Create a copy of GameAreaEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameAreaEntityImplCopyWith<_$GameAreaEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
