// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_push_agreement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommunityPushAgreementResponseModel
_$CommunityPushAgreementResponseModelFromJson(Map<String, dynamic> json) {
  return _CommunityPushAgreementResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityPushAgreementResponseModel {
  bool get allowCommunityPush => throw _privateConstructorUsedError;

  /// Serializes this CommunityPushAgreementResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPushAgreementResponseModelCopyWith<
    CommunityPushAgreementResponseModel
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPushAgreementResponseModelCopyWith<$Res> {
  factory $CommunityPushAgreementResponseModelCopyWith(
    CommunityPushAgreementResponseModel value,
    $Res Function(CommunityPushAgreementResponseModel) then,
  ) =
      _$CommunityPushAgreementResponseModelCopyWithImpl<
        $Res,
        CommunityPushAgreementResponseModel
      >;
  @useResult
  $Res call({bool allowCommunityPush});
}

/// @nodoc
class _$CommunityPushAgreementResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityPushAgreementResponseModel
>
    implements $CommunityPushAgreementResponseModelCopyWith<$Res> {
  _$CommunityPushAgreementResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allowCommunityPush = null}) {
    return _then(
      _value.copyWith(
            allowCommunityPush: null == allowCommunityPush
                ? _value.allowCommunityPush
                : allowCommunityPush // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityPushAgreementResponseModelImplCopyWith<$Res>
    implements $CommunityPushAgreementResponseModelCopyWith<$Res> {
  factory _$$CommunityPushAgreementResponseModelImplCopyWith(
    _$CommunityPushAgreementResponseModelImpl value,
    $Res Function(_$CommunityPushAgreementResponseModelImpl) then,
  ) = __$$CommunityPushAgreementResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool allowCommunityPush});
}

/// @nodoc
class __$$CommunityPushAgreementResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityPushAgreementResponseModelCopyWithImpl<
          $Res,
          _$CommunityPushAgreementResponseModelImpl
        >
    implements _$$CommunityPushAgreementResponseModelImplCopyWith<$Res> {
  __$$CommunityPushAgreementResponseModelImplCopyWithImpl(
    _$CommunityPushAgreementResponseModelImpl _value,
    $Res Function(_$CommunityPushAgreementResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allowCommunityPush = null}) {
    return _then(
      _$CommunityPushAgreementResponseModelImpl(
        allowCommunityPush: null == allowCommunityPush
            ? _value.allowCommunityPush
            : allowCommunityPush // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityPushAgreementResponseModelImpl
    implements _CommunityPushAgreementResponseModel {
  const _$CommunityPushAgreementResponseModelImpl({
    this.allowCommunityPush = true,
  });

  factory _$CommunityPushAgreementResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityPushAgreementResponseModelImplFromJson(json);

  @override
  @JsonKey()
  final bool allowCommunityPush;

  @override
  String toString() {
    return 'CommunityPushAgreementResponseModel(allowCommunityPush: $allowCommunityPush)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPushAgreementResponseModelImpl &&
            (identical(other.allowCommunityPush, allowCommunityPush) ||
                other.allowCommunityPush == allowCommunityPush));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, allowCommunityPush);

  /// Create a copy of CommunityPushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPushAgreementResponseModelImplCopyWith<
    _$CommunityPushAgreementResponseModelImpl
  >
  get copyWith =>
      __$$CommunityPushAgreementResponseModelImplCopyWithImpl<
        _$CommunityPushAgreementResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPushAgreementResponseModelImplToJson(this);
  }
}

abstract class _CommunityPushAgreementResponseModel
    implements CommunityPushAgreementResponseModel {
  const factory _CommunityPushAgreementResponseModel({
    final bool allowCommunityPush,
  }) = _$CommunityPushAgreementResponseModelImpl;

  factory _CommunityPushAgreementResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityPushAgreementResponseModelImpl.fromJson;

  @override
  bool get allowCommunityPush;

  /// Create a copy of CommunityPushAgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPushAgreementResponseModelImplCopyWith<
    _$CommunityPushAgreementResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityPushAgreementRequestModel _$CommunityPushAgreementRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityPushAgreementRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityPushAgreementRequestModel {
  bool get allowCommunityPush => throw _privateConstructorUsedError;

  /// Serializes this CommunityPushAgreementRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPushAgreementRequestModelCopyWith<
    CommunityPushAgreementRequestModel
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPushAgreementRequestModelCopyWith<$Res> {
  factory $CommunityPushAgreementRequestModelCopyWith(
    CommunityPushAgreementRequestModel value,
    $Res Function(CommunityPushAgreementRequestModel) then,
  ) =
      _$CommunityPushAgreementRequestModelCopyWithImpl<
        $Res,
        CommunityPushAgreementRequestModel
      >;
  @useResult
  $Res call({bool allowCommunityPush});
}

/// @nodoc
class _$CommunityPushAgreementRequestModelCopyWithImpl<
  $Res,
  $Val extends CommunityPushAgreementRequestModel
>
    implements $CommunityPushAgreementRequestModelCopyWith<$Res> {
  _$CommunityPushAgreementRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allowCommunityPush = null}) {
    return _then(
      _value.copyWith(
            allowCommunityPush: null == allowCommunityPush
                ? _value.allowCommunityPush
                : allowCommunityPush // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityPushAgreementRequestModelImplCopyWith<$Res>
    implements $CommunityPushAgreementRequestModelCopyWith<$Res> {
  factory _$$CommunityPushAgreementRequestModelImplCopyWith(
    _$CommunityPushAgreementRequestModelImpl value,
    $Res Function(_$CommunityPushAgreementRequestModelImpl) then,
  ) = __$$CommunityPushAgreementRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool allowCommunityPush});
}

/// @nodoc
class __$$CommunityPushAgreementRequestModelImplCopyWithImpl<$Res>
    extends
        _$CommunityPushAgreementRequestModelCopyWithImpl<
          $Res,
          _$CommunityPushAgreementRequestModelImpl
        >
    implements _$$CommunityPushAgreementRequestModelImplCopyWith<$Res> {
  __$$CommunityPushAgreementRequestModelImplCopyWithImpl(
    _$CommunityPushAgreementRequestModelImpl _value,
    $Res Function(_$CommunityPushAgreementRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allowCommunityPush = null}) {
    return _then(
      _$CommunityPushAgreementRequestModelImpl(
        allowCommunityPush: null == allowCommunityPush
            ? _value.allowCommunityPush
            : allowCommunityPush // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityPushAgreementRequestModelImpl
    implements _CommunityPushAgreementRequestModel {
  const _$CommunityPushAgreementRequestModelImpl({
    required this.allowCommunityPush,
  });

  factory _$CommunityPushAgreementRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityPushAgreementRequestModelImplFromJson(json);

  @override
  final bool allowCommunityPush;

  @override
  String toString() {
    return 'CommunityPushAgreementRequestModel(allowCommunityPush: $allowCommunityPush)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPushAgreementRequestModelImpl &&
            (identical(other.allowCommunityPush, allowCommunityPush) ||
                other.allowCommunityPush == allowCommunityPush));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, allowCommunityPush);

  /// Create a copy of CommunityPushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPushAgreementRequestModelImplCopyWith<
    _$CommunityPushAgreementRequestModelImpl
  >
  get copyWith =>
      __$$CommunityPushAgreementRequestModelImplCopyWithImpl<
        _$CommunityPushAgreementRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPushAgreementRequestModelImplToJson(this);
  }
}

abstract class _CommunityPushAgreementRequestModel
    implements CommunityPushAgreementRequestModel {
  const factory _CommunityPushAgreementRequestModel({
    required final bool allowCommunityPush,
  }) = _$CommunityPushAgreementRequestModelImpl;

  factory _CommunityPushAgreementRequestModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityPushAgreementRequestModelImpl.fromJson;

  @override
  bool get allowCommunityPush;

  /// Create a copy of CommunityPushAgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPushAgreementRequestModelImplCopyWith<
    _$CommunityPushAgreementRequestModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
