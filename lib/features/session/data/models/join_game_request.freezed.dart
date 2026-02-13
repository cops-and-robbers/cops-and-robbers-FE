// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'join_game_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JoinGameRequest _$JoinGameRequestFromJson(Map<String, dynamic> json) {
  return _JoinGameRequest.fromJson(json);
}

/// @nodoc
mixin _$JoinGameRequest {
  /// 초대 코드
  String get inviteCode => throw _privateConstructorUsedError;

  /// Serializes this JoinGameRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JoinGameRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JoinGameRequestCopyWith<JoinGameRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JoinGameRequestCopyWith<$Res> {
  factory $JoinGameRequestCopyWith(
    JoinGameRequest value,
    $Res Function(JoinGameRequest) then,
  ) = _$JoinGameRequestCopyWithImpl<$Res, JoinGameRequest>;
  @useResult
  $Res call({String inviteCode});
}

/// @nodoc
class _$JoinGameRequestCopyWithImpl<$Res, $Val extends JoinGameRequest>
    implements $JoinGameRequestCopyWith<$Res> {
  _$JoinGameRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JoinGameRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? inviteCode = null}) {
    return _then(
      _value.copyWith(
            inviteCode: null == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JoinGameRequestImplCopyWith<$Res>
    implements $JoinGameRequestCopyWith<$Res> {
  factory _$$JoinGameRequestImplCopyWith(
    _$JoinGameRequestImpl value,
    $Res Function(_$JoinGameRequestImpl) then,
  ) = __$$JoinGameRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String inviteCode});
}

/// @nodoc
class __$$JoinGameRequestImplCopyWithImpl<$Res>
    extends _$JoinGameRequestCopyWithImpl<$Res, _$JoinGameRequestImpl>
    implements _$$JoinGameRequestImplCopyWith<$Res> {
  __$$JoinGameRequestImplCopyWithImpl(
    _$JoinGameRequestImpl _value,
    $Res Function(_$JoinGameRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JoinGameRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? inviteCode = null}) {
    return _then(
      _$JoinGameRequestImpl(
        inviteCode: null == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JoinGameRequestImpl implements _JoinGameRequest {
  const _$JoinGameRequestImpl({required this.inviteCode});

  factory _$JoinGameRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$JoinGameRequestImplFromJson(json);

  /// 초대 코드
  @override
  final String inviteCode;

  @override
  String toString() {
    return 'JoinGameRequest(inviteCode: $inviteCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JoinGameRequestImpl &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, inviteCode);

  /// Create a copy of JoinGameRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JoinGameRequestImplCopyWith<_$JoinGameRequestImpl> get copyWith =>
      __$$JoinGameRequestImplCopyWithImpl<_$JoinGameRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JoinGameRequestImplToJson(this);
  }
}

abstract class _JoinGameRequest implements JoinGameRequest {
  const factory _JoinGameRequest({required final String inviteCode}) =
      _$JoinGameRequestImpl;

  factory _JoinGameRequest.fromJson(Map<String, dynamic> json) =
      _$JoinGameRequestImpl.fromJson;

  /// 초대 코드
  @override
  String get inviteCode;

  /// Create a copy of JoinGameRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JoinGameRequestImplCopyWith<_$JoinGameRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
