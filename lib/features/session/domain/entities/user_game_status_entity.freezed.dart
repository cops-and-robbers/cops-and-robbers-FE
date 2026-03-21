// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_game_status_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserGameStatusEntity {
  bool get isParticipating => throw _privateConstructorUsedError;
  UserGameParticipationEntity? get participationInfo =>
      throw _privateConstructorUsedError;

  /// Create a copy of UserGameStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserGameStatusEntityCopyWith<UserGameStatusEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserGameStatusEntityCopyWith<$Res> {
  factory $UserGameStatusEntityCopyWith(
    UserGameStatusEntity value,
    $Res Function(UserGameStatusEntity) then,
  ) = _$UserGameStatusEntityCopyWithImpl<$Res, UserGameStatusEntity>;
  @useResult
  $Res call({
    bool isParticipating,
    UserGameParticipationEntity? participationInfo,
  });

  $UserGameParticipationEntityCopyWith<$Res>? get participationInfo;
}

/// @nodoc
class _$UserGameStatusEntityCopyWithImpl<
  $Res,
  $Val extends UserGameStatusEntity
>
    implements $UserGameStatusEntityCopyWith<$Res> {
  _$UserGameStatusEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserGameStatusEntity
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
                      as UserGameParticipationEntity?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserGameStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserGameParticipationEntityCopyWith<$Res>? get participationInfo {
    if (_value.participationInfo == null) {
      return null;
    }

    return $UserGameParticipationEntityCopyWith<$Res>(
      _value.participationInfo!,
      (value) {
        return _then(_value.copyWith(participationInfo: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$UserGameStatusEntityImplCopyWith<$Res>
    implements $UserGameStatusEntityCopyWith<$Res> {
  factory _$$UserGameStatusEntityImplCopyWith(
    _$UserGameStatusEntityImpl value,
    $Res Function(_$UserGameStatusEntityImpl) then,
  ) = __$$UserGameStatusEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isParticipating,
    UserGameParticipationEntity? participationInfo,
  });

  @override
  $UserGameParticipationEntityCopyWith<$Res>? get participationInfo;
}

/// @nodoc
class __$$UserGameStatusEntityImplCopyWithImpl<$Res>
    extends _$UserGameStatusEntityCopyWithImpl<$Res, _$UserGameStatusEntityImpl>
    implements _$$UserGameStatusEntityImplCopyWith<$Res> {
  __$$UserGameStatusEntityImplCopyWithImpl(
    _$UserGameStatusEntityImpl _value,
    $Res Function(_$UserGameStatusEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserGameStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isParticipating = null,
    Object? participationInfo = freezed,
  }) {
    return _then(
      _$UserGameStatusEntityImpl(
        isParticipating: null == isParticipating
            ? _value.isParticipating
            : isParticipating // ignore: cast_nullable_to_non_nullable
                  as bool,
        participationInfo: freezed == participationInfo
            ? _value.participationInfo
            : participationInfo // ignore: cast_nullable_to_non_nullable
                  as UserGameParticipationEntity?,
      ),
    );
  }
}

/// @nodoc

class _$UserGameStatusEntityImpl implements _UserGameStatusEntity {
  const _$UserGameStatusEntityImpl({
    required this.isParticipating,
    this.participationInfo,
  });

  @override
  final bool isParticipating;
  @override
  final UserGameParticipationEntity? participationInfo;

  @override
  String toString() {
    return 'UserGameStatusEntity(isParticipating: $isParticipating, participationInfo: $participationInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGameStatusEntityImpl &&
            (identical(other.isParticipating, isParticipating) ||
                other.isParticipating == isParticipating) &&
            (identical(other.participationInfo, participationInfo) ||
                other.participationInfo == participationInfo));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isParticipating, participationInfo);

  /// Create a copy of UserGameStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserGameStatusEntityImplCopyWith<_$UserGameStatusEntityImpl>
  get copyWith =>
      __$$UserGameStatusEntityImplCopyWithImpl<_$UserGameStatusEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _UserGameStatusEntity implements UserGameStatusEntity {
  const factory _UserGameStatusEntity({
    required final bool isParticipating,
    final UserGameParticipationEntity? participationInfo,
  }) = _$UserGameStatusEntityImpl;

  @override
  bool get isParticipating;
  @override
  UserGameParticipationEntity? get participationInfo;

  /// Create a copy of UserGameStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserGameStatusEntityImplCopyWith<_$UserGameStatusEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserGameParticipationEntity {
  int get gameId => throw _privateConstructorUsedError;
  int get participantId => throw _privateConstructorUsedError;

  /// 게임 상태. `WAITING` | `IN_PROGRESS`
  String get gameStatus => throw _privateConstructorUsedError;

  /// 팀. `POLICE` | `ROBBER`
  String get team => throw _privateConstructorUsedError;

  /// Create a copy of UserGameParticipationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserGameParticipationEntityCopyWith<UserGameParticipationEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserGameParticipationEntityCopyWith<$Res> {
  factory $UserGameParticipationEntityCopyWith(
    UserGameParticipationEntity value,
    $Res Function(UserGameParticipationEntity) then,
  ) =
      _$UserGameParticipationEntityCopyWithImpl<
        $Res,
        UserGameParticipationEntity
      >;
  @useResult
  $Res call({int gameId, int participantId, String gameStatus, String team});
}

/// @nodoc
class _$UserGameParticipationEntityCopyWithImpl<
  $Res,
  $Val extends UserGameParticipationEntity
>
    implements $UserGameParticipationEntityCopyWith<$Res> {
  _$UserGameParticipationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserGameParticipationEntity
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
abstract class _$$UserGameParticipationEntityImplCopyWith<$Res>
    implements $UserGameParticipationEntityCopyWith<$Res> {
  factory _$$UserGameParticipationEntityImplCopyWith(
    _$UserGameParticipationEntityImpl value,
    $Res Function(_$UserGameParticipationEntityImpl) then,
  ) = __$$UserGameParticipationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int gameId, int participantId, String gameStatus, String team});
}

/// @nodoc
class __$$UserGameParticipationEntityImplCopyWithImpl<$Res>
    extends
        _$UserGameParticipationEntityCopyWithImpl<
          $Res,
          _$UserGameParticipationEntityImpl
        >
    implements _$$UserGameParticipationEntityImplCopyWith<$Res> {
  __$$UserGameParticipationEntityImplCopyWithImpl(
    _$UserGameParticipationEntityImpl _value,
    $Res Function(_$UserGameParticipationEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserGameParticipationEntity
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
      _$UserGameParticipationEntityImpl(
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

class _$UserGameParticipationEntityImpl
    implements _UserGameParticipationEntity {
  const _$UserGameParticipationEntityImpl({
    required this.gameId,
    required this.participantId,
    required this.gameStatus,
    required this.team,
  });

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
    return 'UserGameParticipationEntity(gameId: $gameId, participantId: $participantId, gameStatus: $gameStatus, team: $team)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGameParticipationEntityImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.gameStatus, gameStatus) ||
                other.gameStatus == gameStatus) &&
            (identical(other.team, team) || other.team == team));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, gameId, participantId, gameStatus, team);

  /// Create a copy of UserGameParticipationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserGameParticipationEntityImplCopyWith<_$UserGameParticipationEntityImpl>
  get copyWith =>
      __$$UserGameParticipationEntityImplCopyWithImpl<
        _$UserGameParticipationEntityImpl
      >(this, _$identity);
}

abstract class _UserGameParticipationEntity
    implements UserGameParticipationEntity {
  const factory _UserGameParticipationEntity({
    required final int gameId,
    required final int participantId,
    required final String gameStatus,
    required final String team,
  }) = _$UserGameParticipationEntityImpl;

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

  /// Create a copy of UserGameParticipationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserGameParticipationEntityImplCopyWith<_$UserGameParticipationEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
