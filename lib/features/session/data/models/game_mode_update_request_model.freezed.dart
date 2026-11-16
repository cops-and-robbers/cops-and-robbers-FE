// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_mode_update_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameModeUpdateRequestModel _$GameModeUpdateRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _GameModeUpdateRequestModel.fromJson(json);
}

/// @nodoc
mixin _$GameModeUpdateRequestModel {
  @JsonKey(fromJson: GameMode.fromJson, toJson: gameModeToJson)
  GameMode get gameMode => throw _privateConstructorUsedError;
  GameAreaRequestModel get area => throw _privateConstructorUsedError;

  /// Serializes this GameModeUpdateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameModeUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameModeUpdateRequestModelCopyWith<GameModeUpdateRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameModeUpdateRequestModelCopyWith<$Res> {
  factory $GameModeUpdateRequestModelCopyWith(
    GameModeUpdateRequestModel value,
    $Res Function(GameModeUpdateRequestModel) then,
  ) =
      _$GameModeUpdateRequestModelCopyWithImpl<
        $Res,
        GameModeUpdateRequestModel
      >;
  @useResult
  $Res call({
    @JsonKey(fromJson: GameMode.fromJson, toJson: gameModeToJson)
    GameMode gameMode,
    GameAreaRequestModel area,
  });

  $GameAreaRequestModelCopyWith<$Res> get area;
}

/// @nodoc
class _$GameModeUpdateRequestModelCopyWithImpl<
  $Res,
  $Val extends GameModeUpdateRequestModel
>
    implements $GameModeUpdateRequestModelCopyWith<$Res> {
  _$GameModeUpdateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameModeUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? gameMode = null, Object? area = null}) {
    return _then(
      _value.copyWith(
            gameMode: null == gameMode
                ? _value.gameMode
                : gameMode // ignore: cast_nullable_to_non_nullable
                      as GameMode,
            area: null == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as GameAreaRequestModel,
          )
          as $Val,
    );
  }

  /// Create a copy of GameModeUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameAreaRequestModelCopyWith<$Res> get area {
    return $GameAreaRequestModelCopyWith<$Res>(_value.area, (value) {
      return _then(_value.copyWith(area: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameModeUpdateRequestModelImplCopyWith<$Res>
    implements $GameModeUpdateRequestModelCopyWith<$Res> {
  factory _$$GameModeUpdateRequestModelImplCopyWith(
    _$GameModeUpdateRequestModelImpl value,
    $Res Function(_$GameModeUpdateRequestModelImpl) then,
  ) = __$$GameModeUpdateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: GameMode.fromJson, toJson: gameModeToJson)
    GameMode gameMode,
    GameAreaRequestModel area,
  });

  @override
  $GameAreaRequestModelCopyWith<$Res> get area;
}

/// @nodoc
class __$$GameModeUpdateRequestModelImplCopyWithImpl<$Res>
    extends
        _$GameModeUpdateRequestModelCopyWithImpl<
          $Res,
          _$GameModeUpdateRequestModelImpl
        >
    implements _$$GameModeUpdateRequestModelImplCopyWith<$Res> {
  __$$GameModeUpdateRequestModelImplCopyWithImpl(
    _$GameModeUpdateRequestModelImpl _value,
    $Res Function(_$GameModeUpdateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameModeUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? gameMode = null, Object? area = null}) {
    return _then(
      _$GameModeUpdateRequestModelImpl(
        gameMode: null == gameMode
            ? _value.gameMode
            : gameMode // ignore: cast_nullable_to_non_nullable
                  as GameMode,
        area: null == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as GameAreaRequestModel,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameModeUpdateRequestModelImpl implements _GameModeUpdateRequestModel {
  const _$GameModeUpdateRequestModelImpl({
    @JsonKey(fromJson: GameMode.fromJson, toJson: gameModeToJson)
    required this.gameMode,
    required this.area,
  });

  factory _$GameModeUpdateRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$GameModeUpdateRequestModelImplFromJson(json);

  @override
  @JsonKey(fromJson: GameMode.fromJson, toJson: gameModeToJson)
  final GameMode gameMode;
  @override
  final GameAreaRequestModel area;

  @override
  String toString() {
    return 'GameModeUpdateRequestModel(gameMode: $gameMode, area: $area)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameModeUpdateRequestModelImpl &&
            (identical(other.gameMode, gameMode) ||
                other.gameMode == gameMode) &&
            (identical(other.area, area) || other.area == area));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gameMode, area);

  /// Create a copy of GameModeUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameModeUpdateRequestModelImplCopyWith<_$GameModeUpdateRequestModelImpl>
  get copyWith =>
      __$$GameModeUpdateRequestModelImplCopyWithImpl<
        _$GameModeUpdateRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameModeUpdateRequestModelImplToJson(this);
  }
}

abstract class _GameModeUpdateRequestModel
    implements GameModeUpdateRequestModel {
  const factory _GameModeUpdateRequestModel({
    @JsonKey(fromJson: GameMode.fromJson, toJson: gameModeToJson)
    required final GameMode gameMode,
    required final GameAreaRequestModel area,
  }) = _$GameModeUpdateRequestModelImpl;

  factory _GameModeUpdateRequestModel.fromJson(Map<String, dynamic> json) =
      _$GameModeUpdateRequestModelImpl.fromJson;

  @override
  @JsonKey(fromJson: GameMode.fromJson, toJson: gameModeToJson)
  GameMode get gameMode;
  @override
  GameAreaRequestModel get area;

  /// Create a copy of GameModeUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameModeUpdateRequestModelImplCopyWith<_$GameModeUpdateRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
