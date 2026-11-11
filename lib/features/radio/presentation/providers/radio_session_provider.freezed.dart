// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radio_session_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RadioSessionState {
  RadioStatus get status => throw _privateConstructorUsedError;

  /// 내가 버튼을 누르고 말하는 중
  bool get isTalking => throw _privateConstructorUsedError;

  /// 다른 경찰이 발언권을 쥐고 있으면 그 참가자 ID
  String? get speakerIdentity => throw _privateConstructorUsedError;

  /// 마이크가 올라가 있어 누르면 바로 말할 수 있다. false면 첫 누름에 권한을 묻는다.
  bool get isMicReady => throw _privateConstructorUsedError;

  /// Create a copy of RadioSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RadioSessionStateCopyWith<RadioSessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RadioSessionStateCopyWith<$Res> {
  factory $RadioSessionStateCopyWith(
    RadioSessionState value,
    $Res Function(RadioSessionState) then,
  ) = _$RadioSessionStateCopyWithImpl<$Res, RadioSessionState>;
  @useResult
  $Res call({
    RadioStatus status,
    bool isTalking,
    String? speakerIdentity,
    bool isMicReady,
  });
}

/// @nodoc
class _$RadioSessionStateCopyWithImpl<$Res, $Val extends RadioSessionState>
    implements $RadioSessionStateCopyWith<$Res> {
  _$RadioSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RadioSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? isTalking = null,
    Object? speakerIdentity = freezed,
    Object? isMicReady = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RadioStatus,
            isTalking: null == isTalking
                ? _value.isTalking
                : isTalking // ignore: cast_nullable_to_non_nullable
                      as bool,
            speakerIdentity: freezed == speakerIdentity
                ? _value.speakerIdentity
                : speakerIdentity // ignore: cast_nullable_to_non_nullable
                      as String?,
            isMicReady: null == isMicReady
                ? _value.isMicReady
                : isMicReady // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RadioSessionStateImplCopyWith<$Res>
    implements $RadioSessionStateCopyWith<$Res> {
  factory _$$RadioSessionStateImplCopyWith(
    _$RadioSessionStateImpl value,
    $Res Function(_$RadioSessionStateImpl) then,
  ) = __$$RadioSessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RadioStatus status,
    bool isTalking,
    String? speakerIdentity,
    bool isMicReady,
  });
}

/// @nodoc
class __$$RadioSessionStateImplCopyWithImpl<$Res>
    extends _$RadioSessionStateCopyWithImpl<$Res, _$RadioSessionStateImpl>
    implements _$$RadioSessionStateImplCopyWith<$Res> {
  __$$RadioSessionStateImplCopyWithImpl(
    _$RadioSessionStateImpl _value,
    $Res Function(_$RadioSessionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? isTalking = null,
    Object? speakerIdentity = freezed,
    Object? isMicReady = null,
  }) {
    return _then(
      _$RadioSessionStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RadioStatus,
        isTalking: null == isTalking
            ? _value.isTalking
            : isTalking // ignore: cast_nullable_to_non_nullable
                  as bool,
        speakerIdentity: freezed == speakerIdentity
            ? _value.speakerIdentity
            : speakerIdentity // ignore: cast_nullable_to_non_nullable
                  as String?,
        isMicReady: null == isMicReady
            ? _value.isMicReady
            : isMicReady // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$RadioSessionStateImpl implements _RadioSessionState {
  const _$RadioSessionStateImpl({
    this.status = RadioStatus.off,
    this.isTalking = false,
    this.speakerIdentity,
    this.isMicReady = false,
  });

  @override
  @JsonKey()
  final RadioStatus status;

  /// 내가 버튼을 누르고 말하는 중
  @override
  @JsonKey()
  final bool isTalking;

  /// 다른 경찰이 발언권을 쥐고 있으면 그 참가자 ID
  @override
  final String? speakerIdentity;

  /// 마이크가 올라가 있어 누르면 바로 말할 수 있다. false면 첫 누름에 권한을 묻는다.
  @override
  @JsonKey()
  final bool isMicReady;

  @override
  String toString() {
    return 'RadioSessionState(status: $status, isTalking: $isTalking, speakerIdentity: $speakerIdentity, isMicReady: $isMicReady)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RadioSessionStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isTalking, isTalking) ||
                other.isTalking == isTalking) &&
            (identical(other.speakerIdentity, speakerIdentity) ||
                other.speakerIdentity == speakerIdentity) &&
            (identical(other.isMicReady, isMicReady) ||
                other.isMicReady == isMicReady));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, status, isTalking, speakerIdentity, isMicReady);

  /// Create a copy of RadioSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RadioSessionStateImplCopyWith<_$RadioSessionStateImpl> get copyWith =>
      __$$RadioSessionStateImplCopyWithImpl<_$RadioSessionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RadioSessionState implements RadioSessionState {
  const factory _RadioSessionState({
    final RadioStatus status,
    final bool isTalking,
    final String? speakerIdentity,
    final bool isMicReady,
  }) = _$RadioSessionStateImpl;

  @override
  RadioStatus get status;

  /// 내가 버튼을 누르고 말하는 중
  @override
  bool get isTalking;

  /// 다른 경찰이 발언권을 쥐고 있으면 그 참가자 ID
  @override
  String? get speakerIdentity;

  /// 마이크가 올라가 있어 누르면 바로 말할 수 있다. false면 첫 누름에 권한을 묻는다.
  @override
  bool get isMicReady;

  /// Create a copy of RadioSessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RadioSessionStateImplCopyWith<_$RadioSessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
