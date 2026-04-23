// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agreement_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AgreementResponseModel _$AgreementResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _AgreementResponseModel.fromJson(json);
}

/// @nodoc
mixin _$AgreementResponseModel {
  /// 이용약관 동의 여부
  bool get termsOfServiceAgreed => throw _privateConstructorUsedError;

  /// 개인정보처리방침 동의 여부
  bool get privacyPolicyAgreed => throw _privateConstructorUsedError;

  /// 위치정보 이용약관 동의 여부
  bool get locationTermsAgreed => throw _privateConstructorUsedError;

  /// 마케팅 수신 동의 여부
  bool get marketingAgreed => throw _privateConstructorUsedError;

  /// 필수 약관 최초 동의 시각 (미동의 시 null)
  String? get termsAgreedAt => throw _privateConstructorUsedError;

  /// 마케팅 동의 시각 (미동의 시 null)
  String? get marketingAgreedAt => throw _privateConstructorUsedError;

  /// Serializes this AgreementResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgreementResponseModelCopyWith<AgreementResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgreementResponseModelCopyWith<$Res> {
  factory $AgreementResponseModelCopyWith(
    AgreementResponseModel value,
    $Res Function(AgreementResponseModel) then,
  ) = _$AgreementResponseModelCopyWithImpl<$Res, AgreementResponseModel>;
  @useResult
  $Res call({
    bool termsOfServiceAgreed,
    bool privacyPolicyAgreed,
    bool locationTermsAgreed,
    bool marketingAgreed,
    String? termsAgreedAt,
    String? marketingAgreedAt,
  });
}

/// @nodoc
class _$AgreementResponseModelCopyWithImpl<
  $Res,
  $Val extends AgreementResponseModel
>
    implements $AgreementResponseModelCopyWith<$Res> {
  _$AgreementResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? termsOfServiceAgreed = null,
    Object? privacyPolicyAgreed = null,
    Object? locationTermsAgreed = null,
    Object? marketingAgreed = null,
    Object? termsAgreedAt = freezed,
    Object? marketingAgreedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            termsOfServiceAgreed: null == termsOfServiceAgreed
                ? _value.termsOfServiceAgreed
                : termsOfServiceAgreed // ignore: cast_nullable_to_non_nullable
                      as bool,
            privacyPolicyAgreed: null == privacyPolicyAgreed
                ? _value.privacyPolicyAgreed
                : privacyPolicyAgreed // ignore: cast_nullable_to_non_nullable
                      as bool,
            locationTermsAgreed: null == locationTermsAgreed
                ? _value.locationTermsAgreed
                : locationTermsAgreed // ignore: cast_nullable_to_non_nullable
                      as bool,
            marketingAgreed: null == marketingAgreed
                ? _value.marketingAgreed
                : marketingAgreed // ignore: cast_nullable_to_non_nullable
                      as bool,
            termsAgreedAt: freezed == termsAgreedAt
                ? _value.termsAgreedAt
                : termsAgreedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            marketingAgreedAt: freezed == marketingAgreedAt
                ? _value.marketingAgreedAt
                : marketingAgreedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AgreementResponseModelImplCopyWith<$Res>
    implements $AgreementResponseModelCopyWith<$Res> {
  factory _$$AgreementResponseModelImplCopyWith(
    _$AgreementResponseModelImpl value,
    $Res Function(_$AgreementResponseModelImpl) then,
  ) = __$$AgreementResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool termsOfServiceAgreed,
    bool privacyPolicyAgreed,
    bool locationTermsAgreed,
    bool marketingAgreed,
    String? termsAgreedAt,
    String? marketingAgreedAt,
  });
}

/// @nodoc
class __$$AgreementResponseModelImplCopyWithImpl<$Res>
    extends
        _$AgreementResponseModelCopyWithImpl<$Res, _$AgreementResponseModelImpl>
    implements _$$AgreementResponseModelImplCopyWith<$Res> {
  __$$AgreementResponseModelImplCopyWithImpl(
    _$AgreementResponseModelImpl _value,
    $Res Function(_$AgreementResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? termsOfServiceAgreed = null,
    Object? privacyPolicyAgreed = null,
    Object? locationTermsAgreed = null,
    Object? marketingAgreed = null,
    Object? termsAgreedAt = freezed,
    Object? marketingAgreedAt = freezed,
  }) {
    return _then(
      _$AgreementResponseModelImpl(
        termsOfServiceAgreed: null == termsOfServiceAgreed
            ? _value.termsOfServiceAgreed
            : termsOfServiceAgreed // ignore: cast_nullable_to_non_nullable
                  as bool,
        privacyPolicyAgreed: null == privacyPolicyAgreed
            ? _value.privacyPolicyAgreed
            : privacyPolicyAgreed // ignore: cast_nullable_to_non_nullable
                  as bool,
        locationTermsAgreed: null == locationTermsAgreed
            ? _value.locationTermsAgreed
            : locationTermsAgreed // ignore: cast_nullable_to_non_nullable
                  as bool,
        marketingAgreed: null == marketingAgreed
            ? _value.marketingAgreed
            : marketingAgreed // ignore: cast_nullable_to_non_nullable
                  as bool,
        termsAgreedAt: freezed == termsAgreedAt
            ? _value.termsAgreedAt
            : termsAgreedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        marketingAgreedAt: freezed == marketingAgreedAt
            ? _value.marketingAgreedAt
            : marketingAgreedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AgreementResponseModelImpl implements _AgreementResponseModel {
  const _$AgreementResponseModelImpl({
    required this.termsOfServiceAgreed,
    required this.privacyPolicyAgreed,
    required this.locationTermsAgreed,
    required this.marketingAgreed,
    this.termsAgreedAt,
    this.marketingAgreedAt,
  });

  factory _$AgreementResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgreementResponseModelImplFromJson(json);

  /// 이용약관 동의 여부
  @override
  final bool termsOfServiceAgreed;

  /// 개인정보처리방침 동의 여부
  @override
  final bool privacyPolicyAgreed;

  /// 위치정보 이용약관 동의 여부
  @override
  final bool locationTermsAgreed;

  /// 마케팅 수신 동의 여부
  @override
  final bool marketingAgreed;

  /// 필수 약관 최초 동의 시각 (미동의 시 null)
  @override
  final String? termsAgreedAt;

  /// 마케팅 동의 시각 (미동의 시 null)
  @override
  final String? marketingAgreedAt;

  @override
  String toString() {
    return 'AgreementResponseModel(termsOfServiceAgreed: $termsOfServiceAgreed, privacyPolicyAgreed: $privacyPolicyAgreed, locationTermsAgreed: $locationTermsAgreed, marketingAgreed: $marketingAgreed, termsAgreedAt: $termsAgreedAt, marketingAgreedAt: $marketingAgreedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgreementResponseModelImpl &&
            (identical(other.termsOfServiceAgreed, termsOfServiceAgreed) ||
                other.termsOfServiceAgreed == termsOfServiceAgreed) &&
            (identical(other.privacyPolicyAgreed, privacyPolicyAgreed) ||
                other.privacyPolicyAgreed == privacyPolicyAgreed) &&
            (identical(other.locationTermsAgreed, locationTermsAgreed) ||
                other.locationTermsAgreed == locationTermsAgreed) &&
            (identical(other.marketingAgreed, marketingAgreed) ||
                other.marketingAgreed == marketingAgreed) &&
            (identical(other.termsAgreedAt, termsAgreedAt) ||
                other.termsAgreedAt == termsAgreedAt) &&
            (identical(other.marketingAgreedAt, marketingAgreedAt) ||
                other.marketingAgreedAt == marketingAgreedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    termsOfServiceAgreed,
    privacyPolicyAgreed,
    locationTermsAgreed,
    marketingAgreed,
    termsAgreedAt,
    marketingAgreedAt,
  );

  /// Create a copy of AgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgreementResponseModelImplCopyWith<_$AgreementResponseModelImpl>
  get copyWith =>
      __$$AgreementResponseModelImplCopyWithImpl<_$AgreementResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AgreementResponseModelImplToJson(this);
  }
}

abstract class _AgreementResponseModel implements AgreementResponseModel {
  const factory _AgreementResponseModel({
    required final bool termsOfServiceAgreed,
    required final bool privacyPolicyAgreed,
    required final bool locationTermsAgreed,
    required final bool marketingAgreed,
    final String? termsAgreedAt,
    final String? marketingAgreedAt,
  }) = _$AgreementResponseModelImpl;

  factory _AgreementResponseModel.fromJson(Map<String, dynamic> json) =
      _$AgreementResponseModelImpl.fromJson;

  /// 이용약관 동의 여부
  @override
  bool get termsOfServiceAgreed;

  /// 개인정보처리방침 동의 여부
  @override
  bool get privacyPolicyAgreed;

  /// 위치정보 이용약관 동의 여부
  @override
  bool get locationTermsAgreed;

  /// 마케팅 수신 동의 여부
  @override
  bool get marketingAgreed;

  /// 필수 약관 최초 동의 시각 (미동의 시 null)
  @override
  String? get termsAgreedAt;

  /// 마케팅 동의 시각 (미동의 시 null)
  @override
  String? get marketingAgreedAt;

  /// Create a copy of AgreementResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgreementResponseModelImplCopyWith<_$AgreementResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
