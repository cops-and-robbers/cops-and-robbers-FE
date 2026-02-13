// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_session_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CreateSessionResult {
  /// 게임 세션 ID
  int get gameId => throw _privateConstructorUsedError;

  /// 초대 코드 (예: "ABC123")
  String get inviteCode => throw _privateConstructorUsedError;

  /// 세션 상태 (예: "WAITING")
  String get status => throw _privateConstructorUsedError;

  /// Create a copy of CreateSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateSessionResultCopyWith<CreateSessionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSessionResultCopyWith<$Res> {
  factory $CreateSessionResultCopyWith(
    CreateSessionResult value,
    $Res Function(CreateSessionResult) then,
  ) = _$CreateSessionResultCopyWithImpl<$Res, CreateSessionResult>;
  @useResult
  $Res call({int gameId, String inviteCode, String status});
}

/// @nodoc
class _$CreateSessionResultCopyWithImpl<$Res, $Val extends CreateSessionResult>
    implements $CreateSessionResultCopyWith<$Res> {
  _$CreateSessionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? inviteCode = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as int,
            inviteCode: null == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateSessionResultImplCopyWith<$Res>
    implements $CreateSessionResultCopyWith<$Res> {
  factory _$$CreateSessionResultImplCopyWith(
    _$CreateSessionResultImpl value,
    $Res Function(_$CreateSessionResultImpl) then,
  ) = __$$CreateSessionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int gameId, String inviteCode, String status});
}

/// @nodoc
class __$$CreateSessionResultImplCopyWithImpl<$Res>
    extends _$CreateSessionResultCopyWithImpl<$Res, _$CreateSessionResultImpl>
    implements _$$CreateSessionResultImplCopyWith<$Res> {
  __$$CreateSessionResultImplCopyWithImpl(
    _$CreateSessionResultImpl _value,
    $Res Function(_$CreateSessionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? inviteCode = null,
    Object? status = null,
  }) {
    return _then(
      _$CreateSessionResultImpl(
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as int,
        inviteCode: null == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CreateSessionResultImpl implements _CreateSessionResult {
  const _$CreateSessionResultImpl({
    required this.gameId,
    required this.inviteCode,
    required this.status,
  });

  /// 게임 세션 ID
  @override
  final int gameId;

  /// 초대 코드 (예: "ABC123")
  @override
  final String inviteCode;

  /// 세션 상태 (예: "WAITING")
  @override
  final String status;

  @override
  String toString() {
    return 'CreateSessionResult(gameId: $gameId, inviteCode: $inviteCode, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateSessionResultImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, gameId, inviteCode, status);

  /// Create a copy of CreateSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateSessionResultImplCopyWith<_$CreateSessionResultImpl> get copyWith =>
      __$$CreateSessionResultImplCopyWithImpl<_$CreateSessionResultImpl>(
        this,
        _$identity,
      );
}

abstract class _CreateSessionResult implements CreateSessionResult {
  const factory _CreateSessionResult({
    required final int gameId,
    required final String inviteCode,
    required final String status,
  }) = _$CreateSessionResultImpl;

  /// 게임 세션 ID
  @override
  int get gameId;

  /// 초대 코드 (예: "ABC123")
  @override
  String get inviteCode;

  /// 세션 상태 (예: "WAITING")
  @override
  String get status;

  /// Create a copy of CreateSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateSessionResultImplCopyWith<_$CreateSessionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
