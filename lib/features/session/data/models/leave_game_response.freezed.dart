// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_game_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaveGameResponse _$LeaveGameResponseFromJson(Map<String, dynamic> json) {
  return _LeaveGameResponse.fromJson(json);
}

/// @nodoc
mixin _$LeaveGameResponse {
  /// 퇴장한 사용자 ID
  int get leftUserId => throw _privateConstructorUsedError;

  /// 남은 참여자 수
  int get remainingCount => throw _privateConstructorUsedError;

  /// Serializes this LeaveGameResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveGameResponseCopyWith<LeaveGameResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveGameResponseCopyWith<$Res> {
  factory $LeaveGameResponseCopyWith(
    LeaveGameResponse value,
    $Res Function(LeaveGameResponse) then,
  ) = _$LeaveGameResponseCopyWithImpl<$Res, LeaveGameResponse>;
  @useResult
  $Res call({int leftUserId, int remainingCount});
}

/// @nodoc
class _$LeaveGameResponseCopyWithImpl<$Res, $Val extends LeaveGameResponse>
    implements $LeaveGameResponseCopyWith<$Res> {
  _$LeaveGameResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? leftUserId = null, Object? remainingCount = null}) {
    return _then(
      _value.copyWith(
            leftUserId: null == leftUserId
                ? _value.leftUserId
                : leftUserId // ignore: cast_nullable_to_non_nullable
                      as int,
            remainingCount: null == remainingCount
                ? _value.remainingCount
                : remainingCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaveGameResponseImplCopyWith<$Res>
    implements $LeaveGameResponseCopyWith<$Res> {
  factory _$$LeaveGameResponseImplCopyWith(
    _$LeaveGameResponseImpl value,
    $Res Function(_$LeaveGameResponseImpl) then,
  ) = __$$LeaveGameResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int leftUserId, int remainingCount});
}

/// @nodoc
class __$$LeaveGameResponseImplCopyWithImpl<$Res>
    extends _$LeaveGameResponseCopyWithImpl<$Res, _$LeaveGameResponseImpl>
    implements _$$LeaveGameResponseImplCopyWith<$Res> {
  __$$LeaveGameResponseImplCopyWithImpl(
    _$LeaveGameResponseImpl _value,
    $Res Function(_$LeaveGameResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaveGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? leftUserId = null, Object? remainingCount = null}) {
    return _then(
      _$LeaveGameResponseImpl(
        leftUserId: null == leftUserId
            ? _value.leftUserId
            : leftUserId // ignore: cast_nullable_to_non_nullable
                  as int,
        remainingCount: null == remainingCount
            ? _value.remainingCount
            : remainingCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveGameResponseImpl implements _LeaveGameResponse {
  const _$LeaveGameResponseImpl({
    required this.leftUserId,
    required this.remainingCount,
  });

  factory _$LeaveGameResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveGameResponseImplFromJson(json);

  /// 퇴장한 사용자 ID
  @override
  final int leftUserId;

  /// 남은 참여자 수
  @override
  final int remainingCount;

  @override
  String toString() {
    return 'LeaveGameResponse(leftUserId: $leftUserId, remainingCount: $remainingCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveGameResponseImpl &&
            (identical(other.leftUserId, leftUserId) ||
                other.leftUserId == leftUserId) &&
            (identical(other.remainingCount, remainingCount) ||
                other.remainingCount == remainingCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, leftUserId, remainingCount);

  /// Create a copy of LeaveGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveGameResponseImplCopyWith<_$LeaveGameResponseImpl> get copyWith =>
      __$$LeaveGameResponseImplCopyWithImpl<_$LeaveGameResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveGameResponseImplToJson(this);
  }
}

abstract class _LeaveGameResponse implements LeaveGameResponse {
  const factory _LeaveGameResponse({
    required final int leftUserId,
    required final int remainingCount,
  }) = _$LeaveGameResponseImpl;

  factory _LeaveGameResponse.fromJson(Map<String, dynamic> json) =
      _$LeaveGameResponseImpl.fromJson;

  /// 퇴장한 사용자 ID
  @override
  int get leftUserId;

  /// 남은 참여자 수
  @override
  int get remainingCount;

  /// Create a copy of LeaveGameResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveGameResponseImplCopyWith<_$LeaveGameResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
