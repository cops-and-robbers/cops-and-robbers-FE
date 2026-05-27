// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_join_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GameJoinResult {
  /// 참여한 게임의 고유 ID
  int get gameId => throw _privateConstructorUsedError;

  /// 해당 게임에서 부여받은 참여자 고유 ID
  int get participantId => throw _privateConstructorUsedError;

  /// Create a copy of GameJoinResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameJoinResultCopyWith<GameJoinResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameJoinResultCopyWith<$Res> {
  factory $GameJoinResultCopyWith(
    GameJoinResult value,
    $Res Function(GameJoinResult) then,
  ) = _$GameJoinResultCopyWithImpl<$Res, GameJoinResult>;
  @useResult
  $Res call({int gameId, int participantId});
}

/// @nodoc
class _$GameJoinResultCopyWithImpl<$Res, $Val extends GameJoinResult>
    implements $GameJoinResultCopyWith<$Res> {
  _$GameJoinResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameJoinResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? gameId = null, Object? participantId = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameJoinResultImplCopyWith<$Res>
    implements $GameJoinResultCopyWith<$Res> {
  factory _$$GameJoinResultImplCopyWith(
    _$GameJoinResultImpl value,
    $Res Function(_$GameJoinResultImpl) then,
  ) = __$$GameJoinResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int gameId, int participantId});
}

/// @nodoc
class __$$GameJoinResultImplCopyWithImpl<$Res>
    extends _$GameJoinResultCopyWithImpl<$Res, _$GameJoinResultImpl>
    implements _$$GameJoinResultImplCopyWith<$Res> {
  __$$GameJoinResultImplCopyWithImpl(
    _$GameJoinResultImpl _value,
    $Res Function(_$GameJoinResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameJoinResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? gameId = null, Object? participantId = null}) {
    return _then(
      _$GameJoinResultImpl(
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as int,
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$GameJoinResultImpl implements _GameJoinResult {
  const _$GameJoinResultImpl({
    required this.gameId,
    required this.participantId,
  });

  /// 참여한 게임의 고유 ID
  @override
  final int gameId;

  /// 해당 게임에서 부여받은 참여자 고유 ID
  @override
  final int participantId;

  @override
  String toString() {
    return 'GameJoinResult(gameId: $gameId, participantId: $participantId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameJoinResultImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, gameId, participantId);

  /// Create a copy of GameJoinResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameJoinResultImplCopyWith<_$GameJoinResultImpl> get copyWith =>
      __$$GameJoinResultImplCopyWithImpl<_$GameJoinResultImpl>(
        this,
        _$identity,
      );
}

abstract class _GameJoinResult implements GameJoinResult {
  const factory _GameJoinResult({
    required final int gameId,
    required final int participantId,
  }) = _$GameJoinResultImpl;

  /// 참여한 게임의 고유 ID
  @override
  int get gameId;

  /// 해당 게임에서 부여받은 참여자 고유 ID
  @override
  int get participantId;

  /// Create a copy of GameJoinResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameJoinResultImplCopyWith<_$GameJoinResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
