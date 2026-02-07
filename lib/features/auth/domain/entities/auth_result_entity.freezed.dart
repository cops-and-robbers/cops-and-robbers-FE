// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthResultEntity {
  /// 사용자 ID
  int get userId => throw _privateConstructorUsedError;

  /// 닉네임 (서버에서 자동 생성)
  String get nickname => throw _privateConstructorUsedError;

  /// 신규 회원 여부
  ///
  /// true일 경우 닉네임 설정 페이지로 이동해야 합니다.
  bool get isNewUser => throw _privateConstructorUsedError;

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResultEntityCopyWith<AuthResultEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResultEntityCopyWith<$Res> {
  factory $AuthResultEntityCopyWith(
    AuthResultEntity value,
    $Res Function(AuthResultEntity) then,
  ) = _$AuthResultEntityCopyWithImpl<$Res, AuthResultEntity>;
  @useResult
  $Res call({int userId, String nickname, bool isNewUser});
}

/// @nodoc
class _$AuthResultEntityCopyWithImpl<$Res, $Val extends AuthResultEntity>
    implements $AuthResultEntityCopyWith<$Res> {
  _$AuthResultEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? isNewUser = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            isNewUser: null == isNewUser
                ? _value.isNewUser
                : isNewUser // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthResultEntityImplCopyWith<$Res>
    implements $AuthResultEntityCopyWith<$Res> {
  factory _$$AuthResultEntityImplCopyWith(
    _$AuthResultEntityImpl value,
    $Res Function(_$AuthResultEntityImpl) then,
  ) = __$$AuthResultEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, String nickname, bool isNewUser});
}

/// @nodoc
class __$$AuthResultEntityImplCopyWithImpl<$Res>
    extends _$AuthResultEntityCopyWithImpl<$Res, _$AuthResultEntityImpl>
    implements _$$AuthResultEntityImplCopyWith<$Res> {
  __$$AuthResultEntityImplCopyWithImpl(
    _$AuthResultEntityImpl _value,
    $Res Function(_$AuthResultEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? isNewUser = null,
  }) {
    return _then(
      _$AuthResultEntityImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        isNewUser: null == isNewUser
            ? _value.isNewUser
            : isNewUser // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AuthResultEntityImpl implements _AuthResultEntity {
  const _$AuthResultEntityImpl({
    required this.userId,
    required this.nickname,
    required this.isNewUser,
  });

  /// 사용자 ID
  @override
  final int userId;

  /// 닉네임 (서버에서 자동 생성)
  @override
  final String nickname;

  /// 신규 회원 여부
  ///
  /// true일 경우 닉네임 설정 페이지로 이동해야 합니다.
  @override
  final bool isNewUser;

  @override
  String toString() {
    return 'AuthResultEntity(userId: $userId, nickname: $nickname, isNewUser: $isNewUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResultEntityImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, nickname, isNewUser);

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResultEntityImplCopyWith<_$AuthResultEntityImpl> get copyWith =>
      __$$AuthResultEntityImplCopyWithImpl<_$AuthResultEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _AuthResultEntity implements AuthResultEntity {
  const factory _AuthResultEntity({
    required final int userId,
    required final String nickname,
    required final bool isNewUser,
  }) = _$AuthResultEntityImpl;

  /// 사용자 ID
  @override
  int get userId;

  /// 닉네임 (서버에서 자동 생성)
  @override
  String get nickname;

  /// 신규 회원 여부
  ///
  /// true일 경우 닉네임 설정 페이지로 이동해야 합니다.
  @override
  bool get isNewUser;

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResultEntityImplCopyWith<_$AuthResultEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
