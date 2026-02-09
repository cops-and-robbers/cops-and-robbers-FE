// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) {
  return _LoginResponseModel.fromJson(json);
}

/// @nodoc
mixin _$LoginResponseModel {
  /// 사용자 ID
  int get userId => throw _privateConstructorUsedError;

  /// 닉네임 (서버에서 자동 생성)
  String get nickname => throw _privateConstructorUsedError;

  /// JWT 토큰 (Access + Refresh)
  TokensModel get tokens => throw _privateConstructorUsedError;

  /// 신규 회원 여부
  bool get isNewUser => throw _privateConstructorUsedError;

  /// Serializes this LoginResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseModelCopyWith<LoginResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseModelCopyWith<$Res> {
  factory $LoginResponseModelCopyWith(
    LoginResponseModel value,
    $Res Function(LoginResponseModel) then,
  ) = _$LoginResponseModelCopyWithImpl<$Res, LoginResponseModel>;
  @useResult
  $Res call({int userId, String nickname, TokensModel tokens, bool isNewUser});

  $TokensModelCopyWith<$Res> get tokens;
}

/// @nodoc
class _$LoginResponseModelCopyWithImpl<$Res, $Val extends LoginResponseModel>
    implements $LoginResponseModelCopyWith<$Res> {
  _$LoginResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? tokens = null,
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
            tokens: null == tokens
                ? _value.tokens
                : tokens // ignore: cast_nullable_to_non_nullable
                      as TokensModel,
            isNewUser: null == isNewUser
                ? _value.isNewUser
                : isNewUser // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of LoginResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TokensModelCopyWith<$Res> get tokens {
    return $TokensModelCopyWith<$Res>(_value.tokens, (value) {
      return _then(_value.copyWith(tokens: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginResponseModelImplCopyWith<$Res>
    implements $LoginResponseModelCopyWith<$Res> {
  factory _$$LoginResponseModelImplCopyWith(
    _$LoginResponseModelImpl value,
    $Res Function(_$LoginResponseModelImpl) then,
  ) = __$$LoginResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, String nickname, TokensModel tokens, bool isNewUser});

  @override
  $TokensModelCopyWith<$Res> get tokens;
}

/// @nodoc
class __$$LoginResponseModelImplCopyWithImpl<$Res>
    extends _$LoginResponseModelCopyWithImpl<$Res, _$LoginResponseModelImpl>
    implements _$$LoginResponseModelImplCopyWith<$Res> {
  __$$LoginResponseModelImplCopyWithImpl(
    _$LoginResponseModelImpl _value,
    $Res Function(_$LoginResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? tokens = null,
    Object? isNewUser = null,
  }) {
    return _then(
      _$LoginResponseModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        tokens: null == tokens
            ? _value.tokens
            : tokens // ignore: cast_nullable_to_non_nullable
                  as TokensModel,
        isNewUser: null == isNewUser
            ? _value.isNewUser
            : isNewUser // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseModelImpl implements _LoginResponseModel {
  const _$LoginResponseModelImpl({
    required this.userId,
    required this.nickname,
    required this.tokens,
    required this.isNewUser,
  });

  factory _$LoginResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseModelImplFromJson(json);

  /// 사용자 ID
  @override
  final int userId;

  /// 닉네임 (서버에서 자동 생성)
  @override
  final String nickname;

  /// JWT 토큰 (Access + Refresh)
  @override
  final TokensModel tokens;

  /// 신규 회원 여부
  @override
  final bool isNewUser;

  @override
  String toString() {
    return 'LoginResponseModel(userId: $userId, nickname: $nickname, tokens: $tokens, isNewUser: $isNewUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.tokens, tokens) || other.tokens == tokens) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, nickname, tokens, isNewUser);

  /// Create a copy of LoginResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseModelImplCopyWith<_$LoginResponseModelImpl> get copyWith =>
      __$$LoginResponseModelImplCopyWithImpl<_$LoginResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseModelImplToJson(this);
  }
}

abstract class _LoginResponseModel implements LoginResponseModel {
  const factory _LoginResponseModel({
    required final int userId,
    required final String nickname,
    required final TokensModel tokens,
    required final bool isNewUser,
  }) = _$LoginResponseModelImpl;

  factory _LoginResponseModel.fromJson(Map<String, dynamic> json) =
      _$LoginResponseModelImpl.fromJson;

  /// 사용자 ID
  @override
  int get userId;

  /// 닉네임 (서버에서 자동 생성)
  @override
  String get nickname;

  /// JWT 토큰 (Access + Refresh)
  @override
  TokensModel get tokens;

  /// 신규 회원 여부
  @override
  bool get isNewUser;

  /// Create a copy of LoginResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginResponseModelImplCopyWith<_$LoginResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokensModel _$TokensModelFromJson(Map<String, dynamic> json) {
  return _TokensModel.fromJson(json);
}

/// @nodoc
mixin _$TokensModel {
  /// JWT Access Token
  String get accessToken => throw _privateConstructorUsedError;

  /// JWT Refresh Token
  String get refreshToken => throw _privateConstructorUsedError;

  /// Serializes this TokensModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokensModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokensModelCopyWith<TokensModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokensModelCopyWith<$Res> {
  factory $TokensModelCopyWith(
    TokensModel value,
    $Res Function(TokensModel) then,
  ) = _$TokensModelCopyWithImpl<$Res, TokensModel>;
  @useResult
  $Res call({String accessToken, String refreshToken});
}

/// @nodoc
class _$TokensModelCopyWithImpl<$Res, $Val extends TokensModel>
    implements $TokensModelCopyWith<$Res> {
  _$TokensModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokensModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? accessToken = null, Object? refreshToken = null}) {
    return _then(
      _value.copyWith(
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TokensModelImplCopyWith<$Res>
    implements $TokensModelCopyWith<$Res> {
  factory _$$TokensModelImplCopyWith(
    _$TokensModelImpl value,
    $Res Function(_$TokensModelImpl) then,
  ) = __$$TokensModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, String refreshToken});
}

/// @nodoc
class __$$TokensModelImplCopyWithImpl<$Res>
    extends _$TokensModelCopyWithImpl<$Res, _$TokensModelImpl>
    implements _$$TokensModelImplCopyWith<$Res> {
  __$$TokensModelImplCopyWithImpl(
    _$TokensModelImpl _value,
    $Res Function(_$TokensModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TokensModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? accessToken = null, Object? refreshToken = null}) {
    return _then(
      _$TokensModelImpl(
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TokensModelImpl implements _TokensModel {
  const _$TokensModelImpl({
    required this.accessToken,
    required this.refreshToken,
  });

  factory _$TokensModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokensModelImplFromJson(json);

  /// JWT Access Token
  @override
  final String accessToken;

  /// JWT Refresh Token
  @override
  final String refreshToken;

  @override
  String toString() {
    return 'TokensModel(accessToken: $accessToken, refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokensModelImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken, refreshToken);

  /// Create a copy of TokensModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokensModelImplCopyWith<_$TokensModelImpl> get copyWith =>
      __$$TokensModelImplCopyWithImpl<_$TokensModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokensModelImplToJson(this);
  }
}

abstract class _TokensModel implements TokensModel {
  const factory _TokensModel({
    required final String accessToken,
    required final String refreshToken,
  }) = _$TokensModelImpl;

  factory _TokensModel.fromJson(Map<String, dynamic> json) =
      _$TokensModelImpl.fromJson;

  /// JWT Access Token
  @override
  String get accessToken;

  /// JWT Refresh Token
  @override
  String get refreshToken;

  /// Create a copy of TokensModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokensModelImplCopyWith<_$TokensModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
