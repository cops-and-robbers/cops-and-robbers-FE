// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_change_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamChangeRequest _$TeamChangeRequestFromJson(Map<String, dynamic> json) {
  return _TeamChangeRequest.fromJson(json);
}

/// @nodoc
mixin _$TeamChangeRequest {
  /// 변경할 팀 ("POLICE" 또는 "ROBBER")
  String get targetTeam => throw _privateConstructorUsedError;

  /// Serializes this TeamChangeRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamChangeRequestCopyWith<TeamChangeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamChangeRequestCopyWith<$Res> {
  factory $TeamChangeRequestCopyWith(
    TeamChangeRequest value,
    $Res Function(TeamChangeRequest) then,
  ) = _$TeamChangeRequestCopyWithImpl<$Res, TeamChangeRequest>;
  @useResult
  $Res call({String targetTeam});
}

/// @nodoc
class _$TeamChangeRequestCopyWithImpl<$Res, $Val extends TeamChangeRequest>
    implements $TeamChangeRequestCopyWith<$Res> {
  _$TeamChangeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? targetTeam = null}) {
    return _then(
      _value.copyWith(
            targetTeam: null == targetTeam
                ? _value.targetTeam
                : targetTeam // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamChangeRequestImplCopyWith<$Res>
    implements $TeamChangeRequestCopyWith<$Res> {
  factory _$$TeamChangeRequestImplCopyWith(
    _$TeamChangeRequestImpl value,
    $Res Function(_$TeamChangeRequestImpl) then,
  ) = __$$TeamChangeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String targetTeam});
}

/// @nodoc
class __$$TeamChangeRequestImplCopyWithImpl<$Res>
    extends _$TeamChangeRequestCopyWithImpl<$Res, _$TeamChangeRequestImpl>
    implements _$$TeamChangeRequestImplCopyWith<$Res> {
  __$$TeamChangeRequestImplCopyWithImpl(
    _$TeamChangeRequestImpl _value,
    $Res Function(_$TeamChangeRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? targetTeam = null}) {
    return _then(
      _$TeamChangeRequestImpl(
        targetTeam: null == targetTeam
            ? _value.targetTeam
            : targetTeam // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamChangeRequestImpl implements _TeamChangeRequest {
  const _$TeamChangeRequestImpl({required this.targetTeam});

  factory _$TeamChangeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamChangeRequestImplFromJson(json);

  /// 변경할 팀 ("POLICE" 또는 "ROBBER")
  @override
  final String targetTeam;

  @override
  String toString() {
    return 'TeamChangeRequest(targetTeam: $targetTeam)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamChangeRequestImpl &&
            (identical(other.targetTeam, targetTeam) ||
                other.targetTeam == targetTeam));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, targetTeam);

  /// Create a copy of TeamChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamChangeRequestImplCopyWith<_$TeamChangeRequestImpl> get copyWith =>
      __$$TeamChangeRequestImplCopyWithImpl<_$TeamChangeRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamChangeRequestImplToJson(this);
  }
}

abstract class _TeamChangeRequest implements TeamChangeRequest {
  const factory _TeamChangeRequest({required final String targetTeam}) =
      _$TeamChangeRequestImpl;

  factory _TeamChangeRequest.fromJson(Map<String, dynamic> json) =
      _$TeamChangeRequestImpl.fromJson;

  /// 변경할 팀 ("POLICE" 또는 "ROBBER")
  @override
  String get targetTeam;

  /// Create a copy of TeamChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamChangeRequestImplCopyWith<_$TeamChangeRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
