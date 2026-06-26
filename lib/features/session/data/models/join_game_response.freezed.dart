// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'join_game_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JoinGameResponse _$JoinGameResponseFromJson(Map<String, dynamic> json) {
  return _JoinGameResponse.fromJson(json);
}

/// @nodoc
mixin _$JoinGameResponse {
  /// 게임 ID
  int get gameId => throw _privateConstructorUsedError;

  /// 참여자 ID
  int get participantId => throw _privateConstructorUsedError;

  /// 이벤트 게임 여부 (백엔드 신규 필드, 미포함 시 false)
  bool get isEventGame => throw _privateConstructorUsedError;

  /// Serializes this JoinGameResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JoinGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JoinGameResponseCopyWith<JoinGameResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JoinGameResponseCopyWith<$Res> {
  factory $JoinGameResponseCopyWith(
    JoinGameResponse value,
    $Res Function(JoinGameResponse) then,
  ) = _$JoinGameResponseCopyWithImpl<$Res, JoinGameResponse>;
  @useResult
  $Res call({int gameId, int participantId, bool isEventGame});
}

/// @nodoc
class _$JoinGameResponseCopyWithImpl<$Res, $Val extends JoinGameResponse>
    implements $JoinGameResponseCopyWith<$Res> {
  _$JoinGameResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JoinGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? participantId = null,
    Object? isEventGame = null,
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
            isEventGame: null == isEventGame
                ? _value.isEventGame
                : isEventGame // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JoinGameResponseImplCopyWith<$Res>
    implements $JoinGameResponseCopyWith<$Res> {
  factory _$$JoinGameResponseImplCopyWith(
    _$JoinGameResponseImpl value,
    $Res Function(_$JoinGameResponseImpl) then,
  ) = __$$JoinGameResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int gameId, int participantId, bool isEventGame});
}

/// @nodoc
class __$$JoinGameResponseImplCopyWithImpl<$Res>
    extends _$JoinGameResponseCopyWithImpl<$Res, _$JoinGameResponseImpl>
    implements _$$JoinGameResponseImplCopyWith<$Res> {
  __$$JoinGameResponseImplCopyWithImpl(
    _$JoinGameResponseImpl _value,
    $Res Function(_$JoinGameResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JoinGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? participantId = null,
    Object? isEventGame = null,
  }) {
    return _then(
      _$JoinGameResponseImpl(
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as int,
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as int,
        isEventGame: null == isEventGame
            ? _value.isEventGame
            : isEventGame // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JoinGameResponseImpl implements _JoinGameResponse {
  const _$JoinGameResponseImpl({
    required this.gameId,
    required this.participantId,
    this.isEventGame = false,
  });

  factory _$JoinGameResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$JoinGameResponseImplFromJson(json);

  /// 게임 ID
  @override
  final int gameId;

  /// 참여자 ID
  @override
  final int participantId;

  /// 이벤트 게임 여부 (백엔드 신규 필드, 미포함 시 false)
  @override
  @JsonKey()
  final bool isEventGame;

  @override
  String toString() {
    return 'JoinGameResponse(gameId: $gameId, participantId: $participantId, isEventGame: $isEventGame)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JoinGameResponseImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.isEventGame, isEventGame) ||
                other.isEventGame == isEventGame));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, gameId, participantId, isEventGame);

  /// Create a copy of JoinGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JoinGameResponseImplCopyWith<_$JoinGameResponseImpl> get copyWith =>
      __$$JoinGameResponseImplCopyWithImpl<_$JoinGameResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JoinGameResponseImplToJson(this);
  }
}

abstract class _JoinGameResponse implements JoinGameResponse {
  const factory _JoinGameResponse({
    required final int gameId,
    required final int participantId,
    final bool isEventGame,
  }) = _$JoinGameResponseImpl;

  factory _JoinGameResponse.fromJson(Map<String, dynamic> json) =
      _$JoinGameResponseImpl.fromJson;

  /// 게임 ID
  @override
  int get gameId;

  /// 참여자 ID
  @override
  int get participantId;

  /// 이벤트 게임 여부 (백엔드 신규 필드, 미포함 시 false)
  @override
  bool get isEventGame;

  /// Create a copy of JoinGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JoinGameResponseImplCopyWith<_$JoinGameResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
