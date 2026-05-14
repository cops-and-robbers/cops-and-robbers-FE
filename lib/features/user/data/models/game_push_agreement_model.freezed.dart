// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_push_agreement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GamePushAgreementResponseModel _$GamePushAgreementResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _GamePushAgreementResponseModel.fromJson(json);
}

/// @nodoc
mixin _$GamePushAgreementResponseModel {
  bool get allowGamePush => throw _privateConstructorUsedError;

  /// Serializes this GamePushAgreementResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GamePushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GamePushAgreementResponseModelCopyWith<GamePushAgreementResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamePushAgreementResponseModelCopyWith<$Res> {
  factory $GamePushAgreementResponseModelCopyWith(
    GamePushAgreementResponseModel value,
    $Res Function(GamePushAgreementResponseModel) then,
  ) =
      _$GamePushAgreementResponseModelCopyWithImpl<
        $Res,
        GamePushAgreementResponseModel
      >;
  @useResult
  $Res call({bool allowGamePush});
}

/// @nodoc
class _$GamePushAgreementResponseModelCopyWithImpl<
  $Res,
  $Val extends GamePushAgreementResponseModel
>
    implements $GamePushAgreementResponseModelCopyWith<$Res> {
  _$GamePushAgreementResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamePushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allowGamePush = null}) {
    return _then(
      _value.copyWith(
            allowGamePush: null == allowGamePush
                ? _value.allowGamePush
                : allowGamePush // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GamePushAgreementResponseModelImplCopyWith<$Res>
    implements $GamePushAgreementResponseModelCopyWith<$Res> {
  factory _$$GamePushAgreementResponseModelImplCopyWith(
    _$GamePushAgreementResponseModelImpl value,
    $Res Function(_$GamePushAgreementResponseModelImpl) then,
  ) = __$$GamePushAgreementResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool allowGamePush});
}

/// @nodoc
class __$$GamePushAgreementResponseModelImplCopyWithImpl<$Res>
    extends
        _$GamePushAgreementResponseModelCopyWithImpl<
          $Res,
          _$GamePushAgreementResponseModelImpl
        >
    implements _$$GamePushAgreementResponseModelImplCopyWith<$Res> {
  __$$GamePushAgreementResponseModelImplCopyWithImpl(
    _$GamePushAgreementResponseModelImpl _value,
    $Res Function(_$GamePushAgreementResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamePushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allowGamePush = null}) {
    return _then(
      _$GamePushAgreementResponseModelImpl(
        allowGamePush: null == allowGamePush
            ? _value.allowGamePush
            : allowGamePush // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GamePushAgreementResponseModelImpl
    implements _GamePushAgreementResponseModel {
  const _$GamePushAgreementResponseModelImpl({required this.allowGamePush});

  factory _$GamePushAgreementResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$GamePushAgreementResponseModelImplFromJson(json);

  @override
  final bool allowGamePush;

  @override
  String toString() {
    return 'GamePushAgreementResponseModel(allowGamePush: $allowGamePush)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamePushAgreementResponseModelImpl &&
            (identical(other.allowGamePush, allowGamePush) ||
                other.allowGamePush == allowGamePush));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, allowGamePush);

  /// Create a copy of GamePushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamePushAgreementResponseModelImplCopyWith<
    _$GamePushAgreementResponseModelImpl
  >
  get copyWith =>
      __$$GamePushAgreementResponseModelImplCopyWithImpl<
        _$GamePushAgreementResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GamePushAgreementResponseModelImplToJson(this);
  }
}

abstract class _GamePushAgreementResponseModel
    implements GamePushAgreementResponseModel {
  const factory _GamePushAgreementResponseModel({
    required final bool allowGamePush,
  }) = _$GamePushAgreementResponseModelImpl;

  factory _GamePushAgreementResponseModel.fromJson(Map<String, dynamic> json) =
      _$GamePushAgreementResponseModelImpl.fromJson;

  @override
  bool get allowGamePush;

  /// Create a copy of GamePushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamePushAgreementResponseModelImplCopyWith<
    _$GamePushAgreementResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

GamePushAgreementRequestModel _$GamePushAgreementRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _GamePushAgreementRequestModel.fromJson(json);
}

/// @nodoc
mixin _$GamePushAgreementRequestModel {
  bool get allowGamePush => throw _privateConstructorUsedError;

  /// Serializes this GamePushAgreementRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GamePushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GamePushAgreementRequestModelCopyWith<GamePushAgreementRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamePushAgreementRequestModelCopyWith<$Res> {
  factory $GamePushAgreementRequestModelCopyWith(
    GamePushAgreementRequestModel value,
    $Res Function(GamePushAgreementRequestModel) then,
  ) =
      _$GamePushAgreementRequestModelCopyWithImpl<
        $Res,
        GamePushAgreementRequestModel
      >;
  @useResult
  $Res call({bool allowGamePush});
}

/// @nodoc
class _$GamePushAgreementRequestModelCopyWithImpl<
  $Res,
  $Val extends GamePushAgreementRequestModel
>
    implements $GamePushAgreementRequestModelCopyWith<$Res> {
  _$GamePushAgreementRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamePushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allowGamePush = null}) {
    return _then(
      _value.copyWith(
            allowGamePush: null == allowGamePush
                ? _value.allowGamePush
                : allowGamePush // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GamePushAgreementRequestModelImplCopyWith<$Res>
    implements $GamePushAgreementRequestModelCopyWith<$Res> {
  factory _$$GamePushAgreementRequestModelImplCopyWith(
    _$GamePushAgreementRequestModelImpl value,
    $Res Function(_$GamePushAgreementRequestModelImpl) then,
  ) = __$$GamePushAgreementRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool allowGamePush});
}

/// @nodoc
class __$$GamePushAgreementRequestModelImplCopyWithImpl<$Res>
    extends
        _$GamePushAgreementRequestModelCopyWithImpl<
          $Res,
          _$GamePushAgreementRequestModelImpl
        >
    implements _$$GamePushAgreementRequestModelImplCopyWith<$Res> {
  __$$GamePushAgreementRequestModelImplCopyWithImpl(
    _$GamePushAgreementRequestModelImpl _value,
    $Res Function(_$GamePushAgreementRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamePushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allowGamePush = null}) {
    return _then(
      _$GamePushAgreementRequestModelImpl(
        allowGamePush: null == allowGamePush
            ? _value.allowGamePush
            : allowGamePush // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GamePushAgreementRequestModelImpl
    implements _GamePushAgreementRequestModel {
  const _$GamePushAgreementRequestModelImpl({required this.allowGamePush});

  factory _$GamePushAgreementRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$GamePushAgreementRequestModelImplFromJson(json);

  @override
  final bool allowGamePush;

  @override
  String toString() {
    return 'GamePushAgreementRequestModel(allowGamePush: $allowGamePush)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamePushAgreementRequestModelImpl &&
            (identical(other.allowGamePush, allowGamePush) ||
                other.allowGamePush == allowGamePush));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, allowGamePush);

  /// Create a copy of GamePushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamePushAgreementRequestModelImplCopyWith<
    _$GamePushAgreementRequestModelImpl
  >
  get copyWith =>
      __$$GamePushAgreementRequestModelImplCopyWithImpl<
        _$GamePushAgreementRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GamePushAgreementRequestModelImplToJson(this);
  }
}

abstract class _GamePushAgreementRequestModel
    implements GamePushAgreementRequestModel {
  const factory _GamePushAgreementRequestModel({
    required final bool allowGamePush,
  }) = _$GamePushAgreementRequestModelImpl;

  factory _GamePushAgreementRequestModel.fromJson(Map<String, dynamic> json) =
      _$GamePushAgreementRequestModelImpl.fromJson;

  @override
  bool get allowGamePush;

  /// Create a copy of GamePushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamePushAgreementRequestModelImplCopyWith<
    _$GamePushAgreementRequestModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
