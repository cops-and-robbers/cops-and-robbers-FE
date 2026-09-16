// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_game_record_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MyGameRecordResponseModel _$MyGameRecordResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _MyGameRecordResponseModel.fromJson(json);
}

/// @nodoc
mixin _$MyGameRecordResponseModel {
  /// 게임 시작 시점 닉네임
  String get nickname => throw _privateConstructorUsedError;

  /// 팀 ("POLICE" | "ROBBER")
  String get team => throw _privateConstructorUsedError;

  /// 종료 시점 상태 ("WAITING" | "ALIVE" | "JAILED" | "POLICE_WAITING")
  String get status => throw _privateConstructorUsedError;

  /// 내가 체포한 횟수 (경찰 행만 증가)
  int get arrestCount => throw _privateConstructorUsedError;

  /// 내가 잡힌 횟수 (도둑 행만 증가)
  int get arrestedCount => throw _privateConstructorUsedError;

  /// 게임 중 퇴장한 시각. 끝까지 있었으면 null
  String? get leftAt => throw _privateConstructorUsedError;

  /// Serializes this MyGameRecordResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MyGameRecordResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyGameRecordResponseModelCopyWith<MyGameRecordResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyGameRecordResponseModelCopyWith<$Res> {
  factory $MyGameRecordResponseModelCopyWith(
    MyGameRecordResponseModel value,
    $Res Function(MyGameRecordResponseModel) then,
  ) = _$MyGameRecordResponseModelCopyWithImpl<$Res, MyGameRecordResponseModel>;
  @useResult
  $Res call({
    String nickname,
    String team,
    String status,
    int arrestCount,
    int arrestedCount,
    String? leftAt,
  });
}

/// @nodoc
class _$MyGameRecordResponseModelCopyWithImpl<
  $Res,
  $Val extends MyGameRecordResponseModel
>
    implements $MyGameRecordResponseModelCopyWith<$Res> {
  _$MyGameRecordResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyGameRecordResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = null,
    Object? team = null,
    Object? status = null,
    Object? arrestCount = null,
    Object? arrestedCount = null,
    Object? leftAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            team: null == team
                ? _value.team
                : team // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            arrestCount: null == arrestCount
                ? _value.arrestCount
                : arrestCount // ignore: cast_nullable_to_non_nullable
                      as int,
            arrestedCount: null == arrestedCount
                ? _value.arrestedCount
                : arrestedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            leftAt: freezed == leftAt
                ? _value.leftAt
                : leftAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MyGameRecordResponseModelImplCopyWith<$Res>
    implements $MyGameRecordResponseModelCopyWith<$Res> {
  factory _$$MyGameRecordResponseModelImplCopyWith(
    _$MyGameRecordResponseModelImpl value,
    $Res Function(_$MyGameRecordResponseModelImpl) then,
  ) = __$$MyGameRecordResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String nickname,
    String team,
    String status,
    int arrestCount,
    int arrestedCount,
    String? leftAt,
  });
}

/// @nodoc
class __$$MyGameRecordResponseModelImplCopyWithImpl<$Res>
    extends
        _$MyGameRecordResponseModelCopyWithImpl<
          $Res,
          _$MyGameRecordResponseModelImpl
        >
    implements _$$MyGameRecordResponseModelImplCopyWith<$Res> {
  __$$MyGameRecordResponseModelImplCopyWithImpl(
    _$MyGameRecordResponseModelImpl _value,
    $Res Function(_$MyGameRecordResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyGameRecordResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = null,
    Object? team = null,
    Object? status = null,
    Object? arrestCount = null,
    Object? arrestedCount = null,
    Object? leftAt = freezed,
  }) {
    return _then(
      _$MyGameRecordResponseModelImpl(
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        team: null == team
            ? _value.team
            : team // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        arrestCount: null == arrestCount
            ? _value.arrestCount
            : arrestCount // ignore: cast_nullable_to_non_nullable
                  as int,
        arrestedCount: null == arrestedCount
            ? _value.arrestedCount
            : arrestedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        leftAt: freezed == leftAt
            ? _value.leftAt
            : leftAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MyGameRecordResponseModelImpl implements _MyGameRecordResponseModel {
  const _$MyGameRecordResponseModelImpl({
    required this.nickname,
    required this.team,
    required this.status,
    required this.arrestCount,
    required this.arrestedCount,
    this.leftAt,
  });

  factory _$MyGameRecordResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyGameRecordResponseModelImplFromJson(json);

  /// 게임 시작 시점 닉네임
  @override
  final String nickname;

  /// 팀 ("POLICE" | "ROBBER")
  @override
  final String team;

  /// 종료 시점 상태 ("WAITING" | "ALIVE" | "JAILED" | "POLICE_WAITING")
  @override
  final String status;

  /// 내가 체포한 횟수 (경찰 행만 증가)
  @override
  final int arrestCount;

  /// 내가 잡힌 횟수 (도둑 행만 증가)
  @override
  final int arrestedCount;

  /// 게임 중 퇴장한 시각. 끝까지 있었으면 null
  @override
  final String? leftAt;

  @override
  String toString() {
    return 'MyGameRecordResponseModel(nickname: $nickname, team: $team, status: $status, arrestCount: $arrestCount, arrestedCount: $arrestedCount, leftAt: $leftAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyGameRecordResponseModelImpl &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.team, team) || other.team == team) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.arrestCount, arrestCount) ||
                other.arrestCount == arrestCount) &&
            (identical(other.arrestedCount, arrestedCount) ||
                other.arrestedCount == arrestedCount) &&
            (identical(other.leftAt, leftAt) || other.leftAt == leftAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    nickname,
    team,
    status,
    arrestCount,
    arrestedCount,
    leftAt,
  );

  /// Create a copy of MyGameRecordResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyGameRecordResponseModelImplCopyWith<_$MyGameRecordResponseModelImpl>
  get copyWith =>
      __$$MyGameRecordResponseModelImplCopyWithImpl<
        _$MyGameRecordResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MyGameRecordResponseModelImplToJson(this);
  }
}

abstract class _MyGameRecordResponseModel implements MyGameRecordResponseModel {
  const factory _MyGameRecordResponseModel({
    required final String nickname,
    required final String team,
    required final String status,
    required final int arrestCount,
    required final int arrestedCount,
    final String? leftAt,
  }) = _$MyGameRecordResponseModelImpl;

  factory _MyGameRecordResponseModel.fromJson(Map<String, dynamic> json) =
      _$MyGameRecordResponseModelImpl.fromJson;

  /// 게임 시작 시점 닉네임
  @override
  String get nickname;

  /// 팀 ("POLICE" | "ROBBER")
  @override
  String get team;

  /// 종료 시점 상태 ("WAITING" | "ALIVE" | "JAILED" | "POLICE_WAITING")
  @override
  String get status;

  /// 내가 체포한 횟수 (경찰 행만 증가)
  @override
  int get arrestCount;

  /// 내가 잡힌 횟수 (도둑 행만 증가)
  @override
  int get arrestedCount;

  /// 게임 중 퇴장한 시각. 끝까지 있었으면 null
  @override
  String? get leftAt;

  /// Create a copy of MyGameRecordResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyGameRecordResponseModelImplCopyWith<_$MyGameRecordResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
