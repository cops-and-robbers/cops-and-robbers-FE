// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_game_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserGameStatusModel _$UserGameStatusModelFromJson(Map<String, dynamic> json) {
  return _UserGameStatusModel.fromJson(json);
}

/// @nodoc
mixin _$UserGameStatusModel {
  bool get isParticipating => throw _privateConstructorUsedError;
  UserGameParticipationModel? get participationInfo =>
      throw _privateConstructorUsedError;

  /// Serializes this UserGameStatusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserGameStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserGameStatusModelCopyWith<UserGameStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserGameStatusModelCopyWith<$Res> {
  factory $UserGameStatusModelCopyWith(
    UserGameStatusModel value,
    $Res Function(UserGameStatusModel) then,
  ) = _$UserGameStatusModelCopyWithImpl<$Res, UserGameStatusModel>;
  @useResult
  $Res call({
    bool isParticipating,
    UserGameParticipationModel? participationInfo,
  });

  $UserGameParticipationModelCopyWith<$Res>? get participationInfo;
}

/// @nodoc
class _$UserGameStatusModelCopyWithImpl<$Res, $Val extends UserGameStatusModel>
    implements $UserGameStatusModelCopyWith<$Res> {
  _$UserGameStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserGameStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isParticipating = null,
    Object? participationInfo = freezed,
  }) {
    return _then(
      _value.copyWith(
            isParticipating: null == isParticipating
                ? _value.isParticipating
                : isParticipating // ignore: cast_nullable_to_non_nullable
                      as bool,
            participationInfo: freezed == participationInfo
                ? _value.participationInfo
                : participationInfo // ignore: cast_nullable_to_non_nullable
                      as UserGameParticipationModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserGameStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserGameParticipationModelCopyWith<$Res>? get participationInfo {
    if (_value.participationInfo == null) {
      return null;
    }

    return $UserGameParticipationModelCopyWith<$Res>(
      _value.participationInfo!,
      (value) {
        return _then(_value.copyWith(participationInfo: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$UserGameStatusModelImplCopyWith<$Res>
    implements $UserGameStatusModelCopyWith<$Res> {
  factory _$$UserGameStatusModelImplCopyWith(
    _$UserGameStatusModelImpl value,
    $Res Function(_$UserGameStatusModelImpl) then,
  ) = __$$UserGameStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isParticipating,
    UserGameParticipationModel? participationInfo,
  });

  @override
  $UserGameParticipationModelCopyWith<$Res>? get participationInfo;
}

/// @nodoc
class __$$UserGameStatusModelImplCopyWithImpl<$Res>
    extends _$UserGameStatusModelCopyWithImpl<$Res, _$UserGameStatusModelImpl>
    implements _$$UserGameStatusModelImplCopyWith<$Res> {
  __$$UserGameStatusModelImplCopyWithImpl(
    _$UserGameStatusModelImpl _value,
    $Res Function(_$UserGameStatusModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserGameStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isParticipating = null,
    Object? participationInfo = freezed,
  }) {
    return _then(
      _$UserGameStatusModelImpl(
        isParticipating: null == isParticipating
            ? _value.isParticipating
            : isParticipating // ignore: cast_nullable_to_non_nullable
                  as bool,
        participationInfo: freezed == participationInfo
            ? _value.participationInfo
            : participationInfo // ignore: cast_nullable_to_non_nullable
                  as UserGameParticipationModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserGameStatusModelImpl implements _UserGameStatusModel {
  const _$UserGameStatusModelImpl({
    required this.isParticipating,
    this.participationInfo,
  });

  factory _$UserGameStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserGameStatusModelImplFromJson(json);

  @override
  final bool isParticipating;
  @override
  final UserGameParticipationModel? participationInfo;

  @override
  String toString() {
    return 'UserGameStatusModel(isParticipating: $isParticipating, participationInfo: $participationInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGameStatusModelImpl &&
            (identical(other.isParticipating, isParticipating) ||
                other.isParticipating == isParticipating) &&
            (identical(other.participationInfo, participationInfo) ||
                other.participationInfo == participationInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isParticipating, participationInfo);

  /// Create a copy of UserGameStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserGameStatusModelImplCopyWith<_$UserGameStatusModelImpl> get copyWith =>
      __$$UserGameStatusModelImplCopyWithImpl<_$UserGameStatusModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserGameStatusModelImplToJson(this);
  }
}

abstract class _UserGameStatusModel implements UserGameStatusModel {
  const factory _UserGameStatusModel({
    required final bool isParticipating,
    final UserGameParticipationModel? participationInfo,
  }) = _$UserGameStatusModelImpl;

  factory _UserGameStatusModel.fromJson(Map<String, dynamic> json) =
      _$UserGameStatusModelImpl.fromJson;

  @override
  bool get isParticipating;
  @override
  UserGameParticipationModel? get participationInfo;

  /// Create a copy of UserGameStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserGameStatusModelImplCopyWith<_$UserGameStatusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserGameParticipationModel _$UserGameParticipationModelFromJson(
  Map<String, dynamic> json,
) {
  return _UserGameParticipationModel.fromJson(json);
}

/// @nodoc
mixin _$UserGameParticipationModel {
  int get gameId => throw _privateConstructorUsedError;
  int get participantId => throw _privateConstructorUsedError;

  /// 게임 상태. `WAITING` | `IN_PROGRESS`
  String get gameStatus => throw _privateConstructorUsedError;

  /// 팀. `POLICE` | `ROBBER`
  String get team => throw _privateConstructorUsedError;

  /// Serializes this UserGameParticipationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserGameParticipationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserGameParticipationModelCopyWith<UserGameParticipationModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserGameParticipationModelCopyWith<$Res> {
  factory $UserGameParticipationModelCopyWith(
    UserGameParticipationModel value,
    $Res Function(UserGameParticipationModel) then,
  ) =
      _$UserGameParticipationModelCopyWithImpl<
        $Res,
        UserGameParticipationModel
      >;
  @useResult
  $Res call({int gameId, int participantId, String gameStatus, String team});
}

/// @nodoc
class _$UserGameParticipationModelCopyWithImpl<
  $Res,
  $Val extends UserGameParticipationModel
>
    implements $UserGameParticipationModelCopyWith<$Res> {
  _$UserGameParticipationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserGameParticipationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? participantId = null,
    Object? gameStatus = null,
    Object? team = null,
  }) {
    return _then(
      _value.copyWith(
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as int,
            participantId: null == participantId
                ? _value.participantId
                : participantId // ignore: cast_nullable_to_non_nullable
                      as int,
            gameStatus: null == gameStatus
                ? _value.gameStatus
                : gameStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            team: null == team
                ? _value.team
                : team // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserGameParticipationModelImplCopyWith<$Res>
    implements $UserGameParticipationModelCopyWith<$Res> {
  factory _$$UserGameParticipationModelImplCopyWith(
    _$UserGameParticipationModelImpl value,
    $Res Function(_$UserGameParticipationModelImpl) then,
  ) = __$$UserGameParticipationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int gameId, int participantId, String gameStatus, String team});
}

/// @nodoc
class __$$UserGameParticipationModelImplCopyWithImpl<$Res>
    extends
        _$UserGameParticipationModelCopyWithImpl<
          $Res,
          _$UserGameParticipationModelImpl
        >
    implements _$$UserGameParticipationModelImplCopyWith<$Res> {
  __$$UserGameParticipationModelImplCopyWithImpl(
    _$UserGameParticipationModelImpl _value,
    $Res Function(_$UserGameParticipationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserGameParticipationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? participantId = null,
    Object? gameStatus = null,
    Object? team = null,
  }) {
    return _then(
      _$UserGameParticipationModelImpl(
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as int,
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as int,
        gameStatus: null == gameStatus
            ? _value.gameStatus
            : gameStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        team: null == team
            ? _value.team
            : team // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserGameParticipationModelImpl implements _UserGameParticipationModel {
  const _$UserGameParticipationModelImpl({
    required this.gameId,
    required this.participantId,
    required this.gameStatus,
    required this.team,
  });

  factory _$UserGameParticipationModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$UserGameParticipationModelImplFromJson(json);

  @override
  final int gameId;
  @override
  final int participantId;

  /// 게임 상태. `WAITING` | `IN_PROGRESS`
  @override
  final String gameStatus;

  /// 팀. `POLICE` | `ROBBER`
  @override
  final String team;

  @override
  String toString() {
    return 'UserGameParticipationModel(gameId: $gameId, participantId: $participantId, gameStatus: $gameStatus, team: $team)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGameParticipationModelImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.gameStatus, gameStatus) ||
                other.gameStatus == gameStatus) &&
            (identical(other.team, team) || other.team == team));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, gameId, participantId, gameStatus, team);

  /// Create a copy of UserGameParticipationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserGameParticipationModelImplCopyWith<_$UserGameParticipationModelImpl>
  get copyWith =>
      __$$UserGameParticipationModelImplCopyWithImpl<
        _$UserGameParticipationModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserGameParticipationModelImplToJson(this);
  }
}

abstract class _UserGameParticipationModel
    implements UserGameParticipationModel {
  const factory _UserGameParticipationModel({
    required final int gameId,
    required final int participantId,
    required final String gameStatus,
    required final String team,
  }) = _$UserGameParticipationModelImpl;

  factory _UserGameParticipationModel.fromJson(Map<String, dynamic> json) =
      _$UserGameParticipationModelImpl.fromJson;

  @override
  int get gameId;
  @override
  int get participantId;

  /// 게임 상태. `WAITING` | `IN_PROGRESS`
  @override
  String get gameStatus;

  /// 팀. `POLICE` | `ROBBER`
  @override
  String get team;

  /// Create a copy of UserGameParticipationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserGameParticipationModelImplCopyWith<_$UserGameParticipationModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
