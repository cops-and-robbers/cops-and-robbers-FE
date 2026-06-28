// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deeplink_join_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DeepLinkJoinOutcome {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loginRedirect,
    required TResult Function(int gameId, int participantId, bool isEventGame)
    joinedRoom,
    required TResult Function(UserGameParticipationEntity? participation)
    alreadyInRoom,
    required TResult Function(String? messageKey, String? errorCode) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loginRedirect,
    TResult? Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult? Function(UserGameParticipationEntity? participation)?
    alreadyInRoom,
    TResult? Function(String? messageKey, String? errorCode)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loginRedirect,
    TResult Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult Function(UserGameParticipationEntity? participation)? alreadyInRoom,
    TResult Function(String? messageKey, String? errorCode)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginRedirectOutcome value) loginRedirect,
    required TResult Function(JoinedRoomOutcome value) joinedRoom,
    required TResult Function(AlreadyInRoomOutcome value) alreadyInRoom,
    required TResult Function(FailureOutcome value) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginRedirectOutcome value)? loginRedirect,
    TResult? Function(JoinedRoomOutcome value)? joinedRoom,
    TResult? Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult? Function(FailureOutcome value)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginRedirectOutcome value)? loginRedirect,
    TResult Function(JoinedRoomOutcome value)? joinedRoom,
    TResult Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult Function(FailureOutcome value)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeepLinkJoinOutcomeCopyWith<$Res> {
  factory $DeepLinkJoinOutcomeCopyWith(
    DeepLinkJoinOutcome value,
    $Res Function(DeepLinkJoinOutcome) then,
  ) = _$DeepLinkJoinOutcomeCopyWithImpl<$Res, DeepLinkJoinOutcome>;
}

/// @nodoc
class _$DeepLinkJoinOutcomeCopyWithImpl<$Res, $Val extends DeepLinkJoinOutcome>
    implements $DeepLinkJoinOutcomeCopyWith<$Res> {
  _$DeepLinkJoinOutcomeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoginRedirectOutcomeImplCopyWith<$Res> {
  factory _$$LoginRedirectOutcomeImplCopyWith(
    _$LoginRedirectOutcomeImpl value,
    $Res Function(_$LoginRedirectOutcomeImpl) then,
  ) = __$$LoginRedirectOutcomeImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoginRedirectOutcomeImplCopyWithImpl<$Res>
    extends _$DeepLinkJoinOutcomeCopyWithImpl<$Res, _$LoginRedirectOutcomeImpl>
    implements _$$LoginRedirectOutcomeImplCopyWith<$Res> {
  __$$LoginRedirectOutcomeImplCopyWithImpl(
    _$LoginRedirectOutcomeImpl _value,
    $Res Function(_$LoginRedirectOutcomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoginRedirectOutcomeImpl
    with DiagnosticableTreeMixin
    implements LoginRedirectOutcome {
  const _$LoginRedirectOutcomeImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DeepLinkJoinOutcome.loginRedirect()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DeepLinkJoinOutcome.loginRedirect'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRedirectOutcomeImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loginRedirect,
    required TResult Function(int gameId, int participantId, bool isEventGame)
    joinedRoom,
    required TResult Function(UserGameParticipationEntity? participation)
    alreadyInRoom,
    required TResult Function(String? messageKey, String? errorCode) failure,
  }) {
    return loginRedirect();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loginRedirect,
    TResult? Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult? Function(UserGameParticipationEntity? participation)?
    alreadyInRoom,
    TResult? Function(String? messageKey, String? errorCode)? failure,
  }) {
    return loginRedirect?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loginRedirect,
    TResult Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult Function(UserGameParticipationEntity? participation)? alreadyInRoom,
    TResult Function(String? messageKey, String? errorCode)? failure,
    required TResult orElse(),
  }) {
    if (loginRedirect != null) {
      return loginRedirect();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginRedirectOutcome value) loginRedirect,
    required TResult Function(JoinedRoomOutcome value) joinedRoom,
    required TResult Function(AlreadyInRoomOutcome value) alreadyInRoom,
    required TResult Function(FailureOutcome value) failure,
  }) {
    return loginRedirect(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginRedirectOutcome value)? loginRedirect,
    TResult? Function(JoinedRoomOutcome value)? joinedRoom,
    TResult? Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult? Function(FailureOutcome value)? failure,
  }) {
    return loginRedirect?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginRedirectOutcome value)? loginRedirect,
    TResult Function(JoinedRoomOutcome value)? joinedRoom,
    TResult Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult Function(FailureOutcome value)? failure,
    required TResult orElse(),
  }) {
    if (loginRedirect != null) {
      return loginRedirect(this);
    }
    return orElse();
  }
}

abstract class LoginRedirectOutcome implements DeepLinkJoinOutcome {
  const factory LoginRedirectOutcome() = _$LoginRedirectOutcomeImpl;
}

/// @nodoc
abstract class _$$JoinedRoomOutcomeImplCopyWith<$Res> {
  factory _$$JoinedRoomOutcomeImplCopyWith(
    _$JoinedRoomOutcomeImpl value,
    $Res Function(_$JoinedRoomOutcomeImpl) then,
  ) = __$$JoinedRoomOutcomeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int gameId, int participantId, bool isEventGame});
}

/// @nodoc
class __$$JoinedRoomOutcomeImplCopyWithImpl<$Res>
    extends _$DeepLinkJoinOutcomeCopyWithImpl<$Res, _$JoinedRoomOutcomeImpl>
    implements _$$JoinedRoomOutcomeImplCopyWith<$Res> {
  __$$JoinedRoomOutcomeImplCopyWithImpl(
    _$JoinedRoomOutcomeImpl _value,
    $Res Function(_$JoinedRoomOutcomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? participantId = null,
    Object? isEventGame = null,
  }) {
    return _then(
      _$JoinedRoomOutcomeImpl(
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

class _$JoinedRoomOutcomeImpl
    with DiagnosticableTreeMixin
    implements JoinedRoomOutcome {
  const _$JoinedRoomOutcomeImpl({
    required this.gameId,
    required this.participantId,
    this.isEventGame = false,
  });

  @override
  final int gameId;
  @override
  final int participantId;
  @override
  @JsonKey()
  final bool isEventGame;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DeepLinkJoinOutcome.joinedRoom(gameId: $gameId, participantId: $participantId, isEventGame: $isEventGame)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DeepLinkJoinOutcome.joinedRoom'))
      ..add(DiagnosticsProperty('gameId', gameId))
      ..add(DiagnosticsProperty('participantId', participantId))
      ..add(DiagnosticsProperty('isEventGame', isEventGame));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JoinedRoomOutcomeImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.isEventGame, isEventGame) ||
                other.isEventGame == isEventGame));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, gameId, participantId, isEventGame);

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JoinedRoomOutcomeImplCopyWith<_$JoinedRoomOutcomeImpl> get copyWith =>
      __$$JoinedRoomOutcomeImplCopyWithImpl<_$JoinedRoomOutcomeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loginRedirect,
    required TResult Function(int gameId, int participantId, bool isEventGame)
    joinedRoom,
    required TResult Function(UserGameParticipationEntity? participation)
    alreadyInRoom,
    required TResult Function(String? messageKey, String? errorCode) failure,
  }) {
    return joinedRoom(gameId, participantId, isEventGame);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loginRedirect,
    TResult? Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult? Function(UserGameParticipationEntity? participation)?
    alreadyInRoom,
    TResult? Function(String? messageKey, String? errorCode)? failure,
  }) {
    return joinedRoom?.call(gameId, participantId, isEventGame);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loginRedirect,
    TResult Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult Function(UserGameParticipationEntity? participation)? alreadyInRoom,
    TResult Function(String? messageKey, String? errorCode)? failure,
    required TResult orElse(),
  }) {
    if (joinedRoom != null) {
      return joinedRoom(gameId, participantId, isEventGame);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginRedirectOutcome value) loginRedirect,
    required TResult Function(JoinedRoomOutcome value) joinedRoom,
    required TResult Function(AlreadyInRoomOutcome value) alreadyInRoom,
    required TResult Function(FailureOutcome value) failure,
  }) {
    return joinedRoom(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginRedirectOutcome value)? loginRedirect,
    TResult? Function(JoinedRoomOutcome value)? joinedRoom,
    TResult? Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult? Function(FailureOutcome value)? failure,
  }) {
    return joinedRoom?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginRedirectOutcome value)? loginRedirect,
    TResult Function(JoinedRoomOutcome value)? joinedRoom,
    TResult Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult Function(FailureOutcome value)? failure,
    required TResult orElse(),
  }) {
    if (joinedRoom != null) {
      return joinedRoom(this);
    }
    return orElse();
  }
}

abstract class JoinedRoomOutcome implements DeepLinkJoinOutcome {
  const factory JoinedRoomOutcome({
    required final int gameId,
    required final int participantId,
    final bool isEventGame,
  }) = _$JoinedRoomOutcomeImpl;

  int get gameId;
  int get participantId;
  bool get isEventGame;

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JoinedRoomOutcomeImplCopyWith<_$JoinedRoomOutcomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AlreadyInRoomOutcomeImplCopyWith<$Res> {
  factory _$$AlreadyInRoomOutcomeImplCopyWith(
    _$AlreadyInRoomOutcomeImpl value,
    $Res Function(_$AlreadyInRoomOutcomeImpl) then,
  ) = __$$AlreadyInRoomOutcomeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({UserGameParticipationEntity? participation});

  $UserGameParticipationEntityCopyWith<$Res>? get participation;
}

/// @nodoc
class __$$AlreadyInRoomOutcomeImplCopyWithImpl<$Res>
    extends _$DeepLinkJoinOutcomeCopyWithImpl<$Res, _$AlreadyInRoomOutcomeImpl>
    implements _$$AlreadyInRoomOutcomeImplCopyWith<$Res> {
  __$$AlreadyInRoomOutcomeImplCopyWithImpl(
    _$AlreadyInRoomOutcomeImpl _value,
    $Res Function(_$AlreadyInRoomOutcomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? participation = freezed}) {
    return _then(
      _$AlreadyInRoomOutcomeImpl(
        participation: freezed == participation
            ? _value.participation
            : participation // ignore: cast_nullable_to_non_nullable
                  as UserGameParticipationEntity?,
      ),
    );
  }

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserGameParticipationEntityCopyWith<$Res>? get participation {
    if (_value.participation == null) {
      return null;
    }

    return $UserGameParticipationEntityCopyWith<$Res>(_value.participation!, (
      value,
    ) {
      return _then(_value.copyWith(participation: value));
    });
  }
}

/// @nodoc

class _$AlreadyInRoomOutcomeImpl
    with DiagnosticableTreeMixin
    implements AlreadyInRoomOutcome {
  const _$AlreadyInRoomOutcomeImpl({this.participation});

  @override
  final UserGameParticipationEntity? participation;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DeepLinkJoinOutcome.alreadyInRoom(participation: $participation)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DeepLinkJoinOutcome.alreadyInRoom'))
      ..add(DiagnosticsProperty('participation', participation));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlreadyInRoomOutcomeImpl &&
            (identical(other.participation, participation) ||
                other.participation == participation));
  }

  @override
  int get hashCode => Object.hash(runtimeType, participation);

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlreadyInRoomOutcomeImplCopyWith<_$AlreadyInRoomOutcomeImpl>
  get copyWith =>
      __$$AlreadyInRoomOutcomeImplCopyWithImpl<_$AlreadyInRoomOutcomeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loginRedirect,
    required TResult Function(int gameId, int participantId, bool isEventGame)
    joinedRoom,
    required TResult Function(UserGameParticipationEntity? participation)
    alreadyInRoom,
    required TResult Function(String? messageKey, String? errorCode) failure,
  }) {
    return alreadyInRoom(participation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loginRedirect,
    TResult? Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult? Function(UserGameParticipationEntity? participation)?
    alreadyInRoom,
    TResult? Function(String? messageKey, String? errorCode)? failure,
  }) {
    return alreadyInRoom?.call(participation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loginRedirect,
    TResult Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult Function(UserGameParticipationEntity? participation)? alreadyInRoom,
    TResult Function(String? messageKey, String? errorCode)? failure,
    required TResult orElse(),
  }) {
    if (alreadyInRoom != null) {
      return alreadyInRoom(participation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginRedirectOutcome value) loginRedirect,
    required TResult Function(JoinedRoomOutcome value) joinedRoom,
    required TResult Function(AlreadyInRoomOutcome value) alreadyInRoom,
    required TResult Function(FailureOutcome value) failure,
  }) {
    return alreadyInRoom(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginRedirectOutcome value)? loginRedirect,
    TResult? Function(JoinedRoomOutcome value)? joinedRoom,
    TResult? Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult? Function(FailureOutcome value)? failure,
  }) {
    return alreadyInRoom?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginRedirectOutcome value)? loginRedirect,
    TResult Function(JoinedRoomOutcome value)? joinedRoom,
    TResult Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult Function(FailureOutcome value)? failure,
    required TResult orElse(),
  }) {
    if (alreadyInRoom != null) {
      return alreadyInRoom(this);
    }
    return orElse();
  }
}

abstract class AlreadyInRoomOutcome implements DeepLinkJoinOutcome {
  const factory AlreadyInRoomOutcome({
    final UserGameParticipationEntity? participation,
  }) = _$AlreadyInRoomOutcomeImpl;

  UserGameParticipationEntity? get participation;

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlreadyInRoomOutcomeImplCopyWith<_$AlreadyInRoomOutcomeImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailureOutcomeImplCopyWith<$Res> {
  factory _$$FailureOutcomeImplCopyWith(
    _$FailureOutcomeImpl value,
    $Res Function(_$FailureOutcomeImpl) then,
  ) = __$$FailureOutcomeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? messageKey, String? errorCode});
}

/// @nodoc
class __$$FailureOutcomeImplCopyWithImpl<$Res>
    extends _$DeepLinkJoinOutcomeCopyWithImpl<$Res, _$FailureOutcomeImpl>
    implements _$$FailureOutcomeImplCopyWith<$Res> {
  __$$FailureOutcomeImplCopyWithImpl(
    _$FailureOutcomeImpl _value,
    $Res Function(_$FailureOutcomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? messageKey = freezed, Object? errorCode = freezed}) {
    return _then(
      _$FailureOutcomeImpl(
        messageKey: freezed == messageKey
            ? _value.messageKey
            : messageKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorCode: freezed == errorCode
            ? _value.errorCode
            : errorCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$FailureOutcomeImpl
    with DiagnosticableTreeMixin
    implements FailureOutcome {
  const _$FailureOutcomeImpl({this.messageKey, this.errorCode});

  @override
  final String? messageKey;
  @override
  final String? errorCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DeepLinkJoinOutcome.failure(messageKey: $messageKey, errorCode: $errorCode)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DeepLinkJoinOutcome.failure'))
      ..add(DiagnosticsProperty('messageKey', messageKey))
      ..add(DiagnosticsProperty('errorCode', errorCode));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailureOutcomeImpl &&
            (identical(other.messageKey, messageKey) ||
                other.messageKey == messageKey) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, messageKey, errorCode);

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FailureOutcomeImplCopyWith<_$FailureOutcomeImpl> get copyWith =>
      __$$FailureOutcomeImplCopyWithImpl<_$FailureOutcomeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loginRedirect,
    required TResult Function(int gameId, int participantId, bool isEventGame)
    joinedRoom,
    required TResult Function(UserGameParticipationEntity? participation)
    alreadyInRoom,
    required TResult Function(String? messageKey, String? errorCode) failure,
  }) {
    return failure(messageKey, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loginRedirect,
    TResult? Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult? Function(UserGameParticipationEntity? participation)?
    alreadyInRoom,
    TResult? Function(String? messageKey, String? errorCode)? failure,
  }) {
    return failure?.call(messageKey, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loginRedirect,
    TResult Function(int gameId, int participantId, bool isEventGame)?
    joinedRoom,
    TResult Function(UserGameParticipationEntity? participation)? alreadyInRoom,
    TResult Function(String? messageKey, String? errorCode)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(messageKey, errorCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginRedirectOutcome value) loginRedirect,
    required TResult Function(JoinedRoomOutcome value) joinedRoom,
    required TResult Function(AlreadyInRoomOutcome value) alreadyInRoom,
    required TResult Function(FailureOutcome value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginRedirectOutcome value)? loginRedirect,
    TResult? Function(JoinedRoomOutcome value)? joinedRoom,
    TResult? Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult? Function(FailureOutcome value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginRedirectOutcome value)? loginRedirect,
    TResult Function(JoinedRoomOutcome value)? joinedRoom,
    TResult Function(AlreadyInRoomOutcome value)? alreadyInRoom,
    TResult Function(FailureOutcome value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class FailureOutcome implements DeepLinkJoinOutcome {
  const factory FailureOutcome({
    final String? messageKey,
    final String? errorCode,
  }) = _$FailureOutcomeImpl;

  String? get messageKey;
  String? get errorCode;

  /// Create a copy of DeepLinkJoinOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FailureOutcomeImplCopyWith<_$FailureOutcomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
