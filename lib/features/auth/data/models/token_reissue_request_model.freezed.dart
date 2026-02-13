// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_reissue_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TokenReissueRequestModel _$TokenReissueRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _TokenReissueRequestModel.fromJson(json);
}

/// @nodoc
mixin _$TokenReissueRequestModel {
  /// Refresh Token
  String get refreshToken => throw _privateConstructorUsedError;

  /// Serializes this TokenReissueRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenReissueRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenReissueRequestModelCopyWith<TokenReissueRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenReissueRequestModelCopyWith<$Res> {
  factory $TokenReissueRequestModelCopyWith(
    TokenReissueRequestModel value,
    $Res Function(TokenReissueRequestModel) then,
  ) = _$TokenReissueRequestModelCopyWithImpl<$Res, TokenReissueRequestModel>;
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class _$TokenReissueRequestModelCopyWithImpl<
  $Res,
  $Val extends TokenReissueRequestModel
>
    implements $TokenReissueRequestModelCopyWith<$Res> {
  _$TokenReissueRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenReissueRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? refreshToken = null}) {
    return _then(
      _value.copyWith(
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
abstract class _$$TokenReissueRequestModelImplCopyWith<$Res>
    implements $TokenReissueRequestModelCopyWith<$Res> {
  factory _$$TokenReissueRequestModelImplCopyWith(
    _$TokenReissueRequestModelImpl value,
    $Res Function(_$TokenReissueRequestModelImpl) then,
  ) = __$$TokenReissueRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class __$$TokenReissueRequestModelImplCopyWithImpl<$Res>
    extends
        _$TokenReissueRequestModelCopyWithImpl<
          $Res,
          _$TokenReissueRequestModelImpl
        >
    implements _$$TokenReissueRequestModelImplCopyWith<$Res> {
  __$$TokenReissueRequestModelImplCopyWithImpl(
    _$TokenReissueRequestModelImpl _value,
    $Res Function(_$TokenReissueRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TokenReissueRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? refreshToken = null}) {
    return _then(
      _$TokenReissueRequestModelImpl(
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
class _$TokenReissueRequestModelImpl implements _TokenReissueRequestModel {
  const _$TokenReissueRequestModelImpl({required this.refreshToken});

  factory _$TokenReissueRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenReissueRequestModelImplFromJson(json);

  /// Refresh Token
  @override
  final String refreshToken;

  @override
  String toString() {
    return 'TokenReissueRequestModel(refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenReissueRequestModelImpl &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, refreshToken);

  /// Create a copy of TokenReissueRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenReissueRequestModelImplCopyWith<_$TokenReissueRequestModelImpl>
  get copyWith =>
      __$$TokenReissueRequestModelImplCopyWithImpl<
        _$TokenReissueRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenReissueRequestModelImplToJson(this);
  }
}

abstract class _TokenReissueRequestModel implements TokenReissueRequestModel {
  const factory _TokenReissueRequestModel({
    required final String refreshToken,
  }) = _$TokenReissueRequestModelImpl;

  factory _TokenReissueRequestModel.fromJson(Map<String, dynamic> json) =
      _$TokenReissueRequestModelImpl.fromJson;

  /// Refresh Token
  @override
  String get refreshToken;

  /// Create a copy of TokenReissueRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenReissueRequestModelImplCopyWith<_$TokenReissueRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
