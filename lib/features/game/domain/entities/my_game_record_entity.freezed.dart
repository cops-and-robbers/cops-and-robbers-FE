// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_game_record_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MyGameRecordEntity {
  /// 게임 시작 시점 닉네임 (개인 탭 1행)
  String get nickname => throw _privateConstructorUsedError;

  /// 팀 ("POLICE" | "ROBBER")
  String get team => throw _privateConstructorUsedError;

  /// 종료 시점 상태 ("ALIVE" | "JAILED" 등)
  String get status => throw _privateConstructorUsedError;

  /// 내가 체포한 횟수
  int get arrestCount => throw _privateConstructorUsedError;

  /// 내가 잡힌 횟수
  int get arrestedCount => throw _privateConstructorUsedError;

  /// Create a copy of MyGameRecordEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyGameRecordEntityCopyWith<MyGameRecordEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyGameRecordEntityCopyWith<$Res> {
  factory $MyGameRecordEntityCopyWith(
    MyGameRecordEntity value,
    $Res Function(MyGameRecordEntity) then,
  ) = _$MyGameRecordEntityCopyWithImpl<$Res, MyGameRecordEntity>;
  @useResult
  $Res call({
    String nickname,
    String team,
    String status,
    int arrestCount,
    int arrestedCount,
  });
}

/// @nodoc
class _$MyGameRecordEntityCopyWithImpl<$Res, $Val extends MyGameRecordEntity>
    implements $MyGameRecordEntityCopyWith<$Res> {
  _$MyGameRecordEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyGameRecordEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = null,
    Object? team = null,
    Object? status = null,
    Object? arrestCount = null,
    Object? arrestedCount = null,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MyGameRecordEntityImplCopyWith<$Res>
    implements $MyGameRecordEntityCopyWith<$Res> {
  factory _$$MyGameRecordEntityImplCopyWith(
    _$MyGameRecordEntityImpl value,
    $Res Function(_$MyGameRecordEntityImpl) then,
  ) = __$$MyGameRecordEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String nickname,
    String team,
    String status,
    int arrestCount,
    int arrestedCount,
  });
}

/// @nodoc
class __$$MyGameRecordEntityImplCopyWithImpl<$Res>
    extends _$MyGameRecordEntityCopyWithImpl<$Res, _$MyGameRecordEntityImpl>
    implements _$$MyGameRecordEntityImplCopyWith<$Res> {
  __$$MyGameRecordEntityImplCopyWithImpl(
    _$MyGameRecordEntityImpl _value,
    $Res Function(_$MyGameRecordEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyGameRecordEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = null,
    Object? team = null,
    Object? status = null,
    Object? arrestCount = null,
    Object? arrestedCount = null,
  }) {
    return _then(
      _$MyGameRecordEntityImpl(
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
      ),
    );
  }
}

/// @nodoc

class _$MyGameRecordEntityImpl implements _MyGameRecordEntity {
  const _$MyGameRecordEntityImpl({
    required this.nickname,
    required this.team,
    required this.status,
    required this.arrestCount,
    required this.arrestedCount,
  });

  /// 게임 시작 시점 닉네임 (개인 탭 1행)
  @override
  final String nickname;

  /// 팀 ("POLICE" | "ROBBER")
  @override
  final String team;

  /// 종료 시점 상태 ("ALIVE" | "JAILED" 등)
  @override
  final String status;

  /// 내가 체포한 횟수
  @override
  final int arrestCount;

  /// 내가 잡힌 횟수
  @override
  final int arrestedCount;

  @override
  String toString() {
    return 'MyGameRecordEntity(nickname: $nickname, team: $team, status: $status, arrestCount: $arrestCount, arrestedCount: $arrestedCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyGameRecordEntityImpl &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.team, team) || other.team == team) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.arrestCount, arrestCount) ||
                other.arrestCount == arrestCount) &&
            (identical(other.arrestedCount, arrestedCount) ||
                other.arrestedCount == arrestedCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    nickname,
    team,
    status,
    arrestCount,
    arrestedCount,
  );

  /// Create a copy of MyGameRecordEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyGameRecordEntityImplCopyWith<_$MyGameRecordEntityImpl> get copyWith =>
      __$$MyGameRecordEntityImplCopyWithImpl<_$MyGameRecordEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _MyGameRecordEntity implements MyGameRecordEntity {
  const factory _MyGameRecordEntity({
    required final String nickname,
    required final String team,
    required final String status,
    required final int arrestCount,
    required final int arrestedCount,
  }) = _$MyGameRecordEntityImpl;

  /// 게임 시작 시점 닉네임 (개인 탭 1행)
  @override
  String get nickname;

  /// 팀 ("POLICE" | "ROBBER")
  @override
  String get team;

  /// 종료 시점 상태 ("ALIVE" | "JAILED" 등)
  @override
  String get status;

  /// 내가 체포한 횟수
  @override
  int get arrestCount;

  /// 내가 잡힌 횟수
  @override
  int get arrestedCount;

  /// Create a copy of MyGameRecordEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyGameRecordEntityImplCopyWith<_$MyGameRecordEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
