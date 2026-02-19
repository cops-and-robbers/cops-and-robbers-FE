// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_page_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MyPageResponseModel _$MyPageResponseModelFromJson(Map<String, dynamic> json) {
  return _MyPageResponseModel.fromJson(json);
}

/// @nodoc
mixin _$MyPageResponseModel {
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

  /// Serializes this MyPageResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MyPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyPageResponseModelCopyWith<MyPageResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyPageResponseModelCopyWith<$Res> {
  factory $MyPageResponseModelCopyWith(
    MyPageResponseModel value,
    $Res Function(MyPageResponseModel) then,
  ) = _$MyPageResponseModelCopyWithImpl<$Res, MyPageResponseModel>;
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
class _$MyPageResponseModelCopyWithImpl<$Res, $Val extends MyPageResponseModel>
    implements $MyPageResponseModelCopyWith<$Res> {
  _$MyPageResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyPageResponseModel
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
abstract class _$$MyPageResponseModelImplCopyWith<$Res>
    implements $MyPageResponseModelCopyWith<$Res> {
  factory _$$MyPageResponseModelImplCopyWith(
    _$MyPageResponseModelImpl value,
    $Res Function(_$MyPageResponseModelImpl) then,
  ) = __$$MyPageResponseModelImplCopyWithImpl<$Res>;
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
class __$$MyPageResponseModelImplCopyWithImpl<$Res>
    extends _$MyPageResponseModelCopyWithImpl<$Res, _$MyPageResponseModelImpl>
    implements _$$MyPageResponseModelImplCopyWith<$Res> {
  __$$MyPageResponseModelImplCopyWithImpl(
    _$MyPageResponseModelImpl _value,
    $Res Function(_$MyPageResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyPageResponseModel
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
      _$MyPageResponseModelImpl(
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
@JsonSerializable()
class _$MyPageResponseModelImpl implements _MyPageResponseModel {
  const _$MyPageResponseModelImpl({
    required this.userId,
    required this.nickname,
    required this.socialPlatform,
    required this.allowGamePush,
    required this.allowMarketingPush,
  });

  factory _$MyPageResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyPageResponseModelImplFromJson(json);

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
    return 'MyPageResponseModel(userId: $userId, nickname: $nickname, socialPlatform: $socialPlatform, allowGamePush: $allowGamePush, allowMarketingPush: $allowMarketingPush)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyPageResponseModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    nickname,
    socialPlatform,
    allowGamePush,
    allowMarketingPush,
  );

  /// Create a copy of MyPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyPageResponseModelImplCopyWith<_$MyPageResponseModelImpl> get copyWith =>
      __$$MyPageResponseModelImplCopyWithImpl<_$MyPageResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MyPageResponseModelImplToJson(this);
  }
}

abstract class _MyPageResponseModel implements MyPageResponseModel {
  const factory _MyPageResponseModel({
    required final int userId,
    required final String nickname,
    required final String socialPlatform,
    required final bool allowGamePush,
    required final bool allowMarketingPush,
  }) = _$MyPageResponseModelImpl;

  factory _MyPageResponseModel.fromJson(Map<String, dynamic> json) =
      _$MyPageResponseModelImpl.fromJson;

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

  /// Create a copy of MyPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyPageResponseModelImplCopyWith<_$MyPageResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
