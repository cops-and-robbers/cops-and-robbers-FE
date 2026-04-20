// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agreement_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AgreementRequestModel _$AgreementRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _AgreementRequestModel.fromJson(json);
}

/// @nodoc
mixin _$AgreementRequestModel {
  /// 이용약관 동의 여부 (필수)
  bool get termsOfService => throw _privateConstructorUsedError;

  /// 개인정보 처리방침 동의 여부 (필수)
  bool get privacyPolicy => throw _privateConstructorUsedError;

  /// 위치정보 이용약관 동의 여부 (필수)
  bool get locationTerms => throw _privateConstructorUsedError;

  /// 마케팅 수신 동의 여부 (선택)
  bool get marketing => throw _privateConstructorUsedError;

  /// Serializes this AgreementRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgreementRequestModelCopyWith<AgreementRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgreementRequestModelCopyWith<$Res> {
  factory $AgreementRequestModelCopyWith(
    AgreementRequestModel value,
    $Res Function(AgreementRequestModel) then,
  ) = _$AgreementRequestModelCopyWithImpl<$Res, AgreementRequestModel>;
  @useResult
  $Res call({
    bool termsOfService,
    bool privacyPolicy,
    bool locationTerms,
    bool marketing,
  });
}

/// @nodoc
class _$AgreementRequestModelCopyWithImpl<
  $Res,
  $Val extends AgreementRequestModel
>
    implements $AgreementRequestModelCopyWith<$Res> {
  _$AgreementRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? termsOfService = null,
    Object? privacyPolicy = null,
    Object? locationTerms = null,
    Object? marketing = null,
  }) {
    return _then(
      _value.copyWith(
            termsOfService: null == termsOfService
                ? _value.termsOfService
                : termsOfService // ignore: cast_nullable_to_non_nullable
                      as bool,
            privacyPolicy: null == privacyPolicy
                ? _value.privacyPolicy
                : privacyPolicy // ignore: cast_nullable_to_non_nullable
                      as bool,
            locationTerms: null == locationTerms
                ? _value.locationTerms
                : locationTerms // ignore: cast_nullable_to_non_nullable
                      as bool,
            marketing: null == marketing
                ? _value.marketing
                : marketing // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AgreementRequestModelImplCopyWith<$Res>
    implements $AgreementRequestModelCopyWith<$Res> {
  factory _$$AgreementRequestModelImplCopyWith(
    _$AgreementRequestModelImpl value,
    $Res Function(_$AgreementRequestModelImpl) then,
  ) = __$$AgreementRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool termsOfService,
    bool privacyPolicy,
    bool locationTerms,
    bool marketing,
  });
}

/// @nodoc
class __$$AgreementRequestModelImplCopyWithImpl<$Res>
    extends
        _$AgreementRequestModelCopyWithImpl<$Res, _$AgreementRequestModelImpl>
    implements _$$AgreementRequestModelImplCopyWith<$Res> {
  __$$AgreementRequestModelImplCopyWithImpl(
    _$AgreementRequestModelImpl _value,
    $Res Function(_$AgreementRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? termsOfService = null,
    Object? privacyPolicy = null,
    Object? locationTerms = null,
    Object? marketing = null,
  }) {
    return _then(
      _$AgreementRequestModelImpl(
        termsOfService: null == termsOfService
            ? _value.termsOfService
            : termsOfService // ignore: cast_nullable_to_non_nullable
                  as bool,
        privacyPolicy: null == privacyPolicy
            ? _value.privacyPolicy
            : privacyPolicy // ignore: cast_nullable_to_non_nullable
                  as bool,
        locationTerms: null == locationTerms
            ? _value.locationTerms
            : locationTerms // ignore: cast_nullable_to_non_nullable
                  as bool,
        marketing: null == marketing
            ? _value.marketing
            : marketing // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AgreementRequestModelImpl implements _AgreementRequestModel {
  const _$AgreementRequestModelImpl({
    required this.termsOfService,
    required this.privacyPolicy,
    required this.locationTerms,
    required this.marketing,
  });

  factory _$AgreementRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgreementRequestModelImplFromJson(json);

  /// 이용약관 동의 여부 (필수)
  @override
  final bool termsOfService;

  /// 개인정보 처리방침 동의 여부 (필수)
  @override
  final bool privacyPolicy;

  /// 위치정보 이용약관 동의 여부 (필수)
  @override
  final bool locationTerms;

  /// 마케팅 수신 동의 여부 (선택)
  @override
  final bool marketing;

  @override
  String toString() {
    return 'AgreementRequestModel(termsOfService: $termsOfService, privacyPolicy: $privacyPolicy, locationTerms: $locationTerms, marketing: $marketing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgreementRequestModelImpl &&
            (identical(other.termsOfService, termsOfService) ||
                other.termsOfService == termsOfService) &&
            (identical(other.privacyPolicy, privacyPolicy) ||
                other.privacyPolicy == privacyPolicy) &&
            (identical(other.locationTerms, locationTerms) ||
                other.locationTerms == locationTerms) &&
            (identical(other.marketing, marketing) ||
                other.marketing == marketing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    termsOfService,
    privacyPolicy,
    locationTerms,
    marketing,
  );

  /// Create a copy of AgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgreementRequestModelImplCopyWith<_$AgreementRequestModelImpl>
  get copyWith =>
      __$$AgreementRequestModelImplCopyWithImpl<_$AgreementRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AgreementRequestModelImplToJson(this);
  }
}

abstract class _AgreementRequestModel implements AgreementRequestModel {
  const factory _AgreementRequestModel({
    required final bool termsOfService,
    required final bool privacyPolicy,
    required final bool locationTerms,
    required final bool marketing,
  }) = _$AgreementRequestModelImpl;

  factory _AgreementRequestModel.fromJson(Map<String, dynamic> json) =
      _$AgreementRequestModelImpl.fromJson;

  /// 이용약관 동의 여부 (필수)
  @override
  bool get termsOfService;

  /// 개인정보 처리방침 동의 여부 (필수)
  @override
  bool get privacyPolicy;

  /// 위치정보 이용약관 동의 여부 (필수)
  @override
  bool get locationTerms;

  /// 마케팅 수신 동의 여부 (선택)
  @override
  bool get marketing;

  /// Create a copy of AgreementRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgreementRequestModelImplCopyWith<_$AgreementRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
