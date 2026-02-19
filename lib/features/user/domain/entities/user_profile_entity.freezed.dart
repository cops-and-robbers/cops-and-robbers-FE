// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserProfileEntity {
  /// 사용자 ID
  int get userId => throw _privateConstructorUsedError;

  /// 닉네임
  String get nickname => throw _privateConstructorUsedError;

  /// 소셜 로그인 플랫폼 (GOOGLE, KAKAO, APPLE 등)
  String get socialPlatform => throw _privateConstructorUsedError;

  /// 게임 푸시 알림 허용 여부
  bool get allowGamePush => throw _privateConstructorUsedError;

  /// 마케팅 푸시 알림 허용 여부
  bool get allowMarketingPush => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileEntityCopyWith<UserProfileEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileEntityCopyWith<$Res> {
  factory $UserProfileEntityCopyWith(
    UserProfileEntity value,
    $Res Function(UserProfileEntity) then,
  ) = _$UserProfileEntityCopyWithImpl<$Res, UserProfileEntity>;
  @useResult
  $Res call({
    int userId,
    String nickname,
    String socialPlatform,
    bool allowGamePush,
    bool allowMarketingPush,
  });
}

/// @nodoc
class _$UserProfileEntityCopyWithImpl<$Res, $Val extends UserProfileEntity>
    implements $UserProfileEntityCopyWith<$Res> {
  _$UserProfileEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? socialPlatform = null,
    Object? allowGamePush = null,
    Object? allowMarketingPush = null,
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
            socialPlatform: null == socialPlatform
                ? _value.socialPlatform
                : socialPlatform // ignore: cast_nullable_to_non_nullable
                      as String,
            allowGamePush: null == allowGamePush
                ? _value.allowGamePush
                : allowGamePush // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowMarketingPush: null == allowMarketingPush
                ? _value.allowMarketingPush
                : allowMarketingPush // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileEntityImplCopyWith<$Res>
    implements $UserProfileEntityCopyWith<$Res> {
  factory _$$UserProfileEntityImplCopyWith(
    _$UserProfileEntityImpl value,
    $Res Function(_$UserProfileEntityImpl) then,
  ) = __$$UserProfileEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int userId,
    String nickname,
    String socialPlatform,
    bool allowGamePush,
    bool allowMarketingPush,
  });
}

/// @nodoc
class __$$UserProfileEntityImplCopyWithImpl<$Res>
    extends _$UserProfileEntityCopyWithImpl<$Res, _$UserProfileEntityImpl>
    implements _$$UserProfileEntityImplCopyWith<$Res> {
  __$$UserProfileEntityImplCopyWithImpl(
    _$UserProfileEntityImpl _value,
    $Res Function(_$UserProfileEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? socialPlatform = null,
    Object? allowGamePush = null,
    Object? allowMarketingPush = null,
  }) {
    return _then(
      _$UserProfileEntityImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        socialPlatform: null == socialPlatform
            ? _value.socialPlatform
            : socialPlatform // ignore: cast_nullable_to_non_nullable
                  as String,
        allowGamePush: null == allowGamePush
            ? _value.allowGamePush
            : allowGamePush // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowMarketingPush: null == allowMarketingPush
            ? _value.allowMarketingPush
            : allowMarketingPush // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$UserProfileEntityImpl implements _UserProfileEntity {
  const _$UserProfileEntityImpl({
    required this.userId,
    required this.nickname,
    required this.socialPlatform,
    required this.allowGamePush,
    required this.allowMarketingPush,
  });

  /// 사용자 ID
  @override
  final int userId;

  /// 닉네임
  @override
  final String nickname;

  /// 소셜 로그인 플랫폼 (GOOGLE, KAKAO, APPLE 등)
  @override
  final String socialPlatform;

  /// 게임 푸시 알림 허용 여부
  @override
  final bool allowGamePush;

  /// 마케팅 푸시 알림 허용 여부
  @override
  final bool allowMarketingPush;

  @override
  String toString() {
    return 'UserProfileEntity(userId: $userId, nickname: $nickname, socialPlatform: $socialPlatform, allowGamePush: $allowGamePush, allowMarketingPush: $allowMarketingPush)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileEntityImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.socialPlatform, socialPlatform) ||
                other.socialPlatform == socialPlatform) &&
            (identical(other.allowGamePush, allowGamePush) ||
                other.allowGamePush == allowGamePush) &&
            (identical(other.allowMarketingPush, allowMarketingPush) ||
                other.allowMarketingPush == allowMarketingPush));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    nickname,
    socialPlatform,
    allowGamePush,
    allowMarketingPush,
  );

  /// Create a copy of UserProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileEntityImplCopyWith<_$UserProfileEntityImpl> get copyWith =>
      __$$UserProfileEntityImplCopyWithImpl<_$UserProfileEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _UserProfileEntity implements UserProfileEntity {
  const factory _UserProfileEntity({
    required final int userId,
    required final String nickname,
    required final String socialPlatform,
    required final bool allowGamePush,
    required final bool allowMarketingPush,
  }) = _$UserProfileEntityImpl;

  /// 사용자 ID
  @override
  int get userId;

  /// 닉네임
  @override
  String get nickname;

  /// 소셜 로그인 플랫폼 (GOOGLE, KAKAO, APPLE 등)
  @override
  String get socialPlatform;

  /// 게임 푸시 알림 허용 여부
  @override
  bool get allowGamePush;

  /// 마케팅 푸시 알림 허용 여부
  @override
  bool get allowMarketingPush;

  /// Create a copy of UserProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileEntityImplCopyWith<_$UserProfileEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
