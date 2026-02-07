// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_reissue_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TokenReissueResponseModel _$TokenReissueResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _TokenReissueResponseModel.fromJson(json);
}

/// @nodoc
mixin _$TokenReissueResponseModel {
  /// JWT 토큰 (Access + Refresh)
  TokensModel get tokens => throw _privateConstructorUsedError;

  /// Serializes this TokenReissueResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenReissueResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenReissueResponseModelCopyWith<TokenReissueResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenReissueResponseModelCopyWith<$Res> {
  factory $TokenReissueResponseModelCopyWith(
    TokenReissueResponseModel value,
    $Res Function(TokenReissueResponseModel) then,
  ) = _$TokenReissueResponseModelCopyWithImpl<$Res, TokenReissueResponseModel>;
  @useResult
  $Res call({TokensModel tokens});

  $TokensModelCopyWith<$Res> get tokens;
}

/// @nodoc
class _$TokenReissueResponseModelCopyWithImpl<
  $Res,
  $Val extends TokenReissueResponseModel
>
    implements $TokenReissueResponseModelCopyWith<$Res> {
  _$TokenReissueResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenReissueResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tokens = null}) {
    return _then(
      _value.copyWith(
            tokens: null == tokens
                ? _value.tokens
                : tokens // ignore: cast_nullable_to_non_nullable
                      as TokensModel,
          )
          as $Val,
    );
  }

  /// Create a copy of TokenReissueResponseModel
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
abstract class _$$TokenReissueResponseModelImplCopyWith<$Res>
    implements $TokenReissueResponseModelCopyWith<$Res> {
  factory _$$TokenReissueResponseModelImplCopyWith(
    _$TokenReissueResponseModelImpl value,
    $Res Function(_$TokenReissueResponseModelImpl) then,
  ) = __$$TokenReissueResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TokensModel tokens});

  @override
  $TokensModelCopyWith<$Res> get tokens;
}

/// @nodoc
class __$$TokenReissueResponseModelImplCopyWithImpl<$Res>
    extends
        _$TokenReissueResponseModelCopyWithImpl<
          $Res,
          _$TokenReissueResponseModelImpl
        >
    implements _$$TokenReissueResponseModelImplCopyWith<$Res> {
  __$$TokenReissueResponseModelImplCopyWithImpl(
    _$TokenReissueResponseModelImpl _value,
    $Res Function(_$TokenReissueResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TokenReissueResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tokens = null}) {
    return _then(
      _$TokenReissueResponseModelImpl(
        tokens: null == tokens
            ? _value.tokens
            : tokens // ignore: cast_nullable_to_non_nullable
                  as TokensModel,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenReissueResponseModelImpl implements _TokenReissueResponseModel {
  const _$TokenReissueResponseModelImpl({required this.tokens});

  factory _$TokenReissueResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenReissueResponseModelImplFromJson(json);

  /// JWT 토큰 (Access + Refresh)
  @override
  final TokensModel tokens;

  @override
  String toString() {
    return 'TokenReissueResponseModel(tokens: $tokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenReissueResponseModelImpl &&
            (identical(other.tokens, tokens) || other.tokens == tokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tokens);

  /// Create a copy of TokenReissueResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenReissueResponseModelImplCopyWith<_$TokenReissueResponseModelImpl>
  get copyWith =>
      __$$TokenReissueResponseModelImplCopyWithImpl<
        _$TokenReissueResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenReissueResponseModelImplToJson(this);
  }
}

abstract class _TokenReissueResponseModel implements TokenReissueResponseModel {
  const factory _TokenReissueResponseModel({
    required final TokensModel tokens,
  }) = _$TokenReissueResponseModelImpl;

  factory _TokenReissueResponseModel.fromJson(Map<String, dynamic> json) =
      _$TokenReissueResponseModelImpl.fromJson;

  /// JWT 토큰 (Access + Refresh)
  @override
  TokensModel get tokens;

  /// Create a copy of TokenReissueResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenReissueResponseModelImplCopyWith<_$TokenReissueResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
