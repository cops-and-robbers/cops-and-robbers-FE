// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agreement_status_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AgreementStatusEntity {
  /// 이용약관 동의 여부 (필수)
  bool get termsOfService => throw _privateConstructorUsedError;

  /// 개인정보 처리방침 동의 여부 (필수)
  bool get privacyPolicy => throw _privateConstructorUsedError;

  /// 위치정보 이용약관 동의 여부 (필수)
  bool get locationTerms => throw _privateConstructorUsedError;

  /// 마케팅 수신 동의 여부 (선택)
  bool get marketing => throw _privateConstructorUsedError;

  /// Create a copy of AgreementStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgreementStatusEntityCopyWith<AgreementStatusEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgreementStatusEntityCopyWith<$Res> {
  factory $AgreementStatusEntityCopyWith(
    AgreementStatusEntity value,
    $Res Function(AgreementStatusEntity) then,
  ) = _$AgreementStatusEntityCopyWithImpl<$Res, AgreementStatusEntity>;
  @useResult
  $Res call({
    bool termsOfService,
    bool privacyPolicy,
    bool locationTerms,
    bool marketing,
  });
}

/// @nodoc
class _$AgreementStatusEntityCopyWithImpl<
  $Res,
  $Val extends AgreementStatusEntity
>
    implements $AgreementStatusEntityCopyWith<$Res> {
  _$AgreementStatusEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgreementStatusEntity
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
abstract class _$$AgreementStatusEntityImplCopyWith<$Res>
    implements $AgreementStatusEntityCopyWith<$Res> {
  factory _$$AgreementStatusEntityImplCopyWith(
    _$AgreementStatusEntityImpl value,
    $Res Function(_$AgreementStatusEntityImpl) then,
  ) = __$$AgreementStatusEntityImplCopyWithImpl<$Res>;
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
class __$$AgreementStatusEntityImplCopyWithImpl<$Res>
    extends
        _$AgreementStatusEntityCopyWithImpl<$Res, _$AgreementStatusEntityImpl>
    implements _$$AgreementStatusEntityImplCopyWith<$Res> {
  __$$AgreementStatusEntityImplCopyWithImpl(
    _$AgreementStatusEntityImpl _value,
    $Res Function(_$AgreementStatusEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgreementStatusEntity
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
      _$AgreementStatusEntityImpl(
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

class _$AgreementStatusEntityImpl extends _AgreementStatusEntity {
  const _$AgreementStatusEntityImpl({
    required this.termsOfService,
    required this.privacyPolicy,
    required this.locationTerms,
    required this.marketing,
  }) : super._();

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
    return 'AgreementStatusEntity(termsOfService: $termsOfService, privacyPolicy: $privacyPolicy, locationTerms: $locationTerms, marketing: $marketing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgreementStatusEntityImpl &&
            (identical(other.termsOfService, termsOfService) ||
                other.termsOfService == termsOfService) &&
            (identical(other.privacyPolicy, privacyPolicy) ||
                other.privacyPolicy == privacyPolicy) &&
            (identical(other.locationTerms, locationTerms) ||
                other.locationTerms == locationTerms) &&
            (identical(other.marketing, marketing) ||
                other.marketing == marketing));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    termsOfService,
    privacyPolicy,
    locationTerms,
    marketing,
  );

  /// Create a copy of AgreementStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgreementStatusEntityImplCopyWith<_$AgreementStatusEntityImpl>
  get copyWith =>
      __$$AgreementStatusEntityImplCopyWithImpl<_$AgreementStatusEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _AgreementStatusEntity extends AgreementStatusEntity {
  const factory _AgreementStatusEntity({
    required final bool termsOfService,
    required final bool privacyPolicy,
    required final bool locationTerms,
    required final bool marketing,
  }) = _$AgreementStatusEntityImpl;
  const _AgreementStatusEntity._() : super._();

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

  /// Create a copy of AgreementStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgreementStatusEntityImplCopyWith<_$AgreementStatusEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
