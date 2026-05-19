// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agreement_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AgreementState {
  bool get termsOfService => throw _privateConstructorUsedError;
  bool get privacyPolicy => throw _privateConstructorUsedError;
  bool get locationTerms => throw _privateConstructorUsedError;
  bool get marketing => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;

  /// Create a copy of AgreementState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgreementStateCopyWith<AgreementState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgreementStateCopyWith<$Res> {
  factory $AgreementStateCopyWith(
    AgreementState value,
    $Res Function(AgreementState) then,
  ) = _$AgreementStateCopyWithImpl<$Res, AgreementState>;
  @useResult
  $Res call({
    bool termsOfService,
    bool privacyPolicy,
    bool locationTerms,
    bool marketing,
    bool isLoading,
    bool isSubmitting,
  });
}

/// @nodoc
class _$AgreementStateCopyWithImpl<$Res, $Val extends AgreementState>
    implements $AgreementStateCopyWith<$Res> {
  _$AgreementStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgreementState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? termsOfService = null,
    Object? privacyPolicy = null,
    Object? locationTerms = null,
    Object? marketing = null,
    Object? isLoading = null,
    Object? isSubmitting = null,
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
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AgreementStateImplCopyWith<$Res>
    implements $AgreementStateCopyWith<$Res> {
  factory _$$AgreementStateImplCopyWith(
    _$AgreementStateImpl value,
    $Res Function(_$AgreementStateImpl) then,
  ) = __$$AgreementStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool termsOfService,
    bool privacyPolicy,
    bool locationTerms,
    bool marketing,
    bool isLoading,
    bool isSubmitting,
  });
}

/// @nodoc
class __$$AgreementStateImplCopyWithImpl<$Res>
    extends _$AgreementStateCopyWithImpl<$Res, _$AgreementStateImpl>
    implements _$$AgreementStateImplCopyWith<$Res> {
  __$$AgreementStateImplCopyWithImpl(
    _$AgreementStateImpl _value,
    $Res Function(_$AgreementStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgreementState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? termsOfService = null,
    Object? privacyPolicy = null,
    Object? locationTerms = null,
    Object? marketing = null,
    Object? isLoading = null,
    Object? isSubmitting = null,
  }) {
    return _then(
      _$AgreementStateImpl(
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
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AgreementStateImpl extends _AgreementState
    with DiagnosticableTreeMixin {
  const _$AgreementStateImpl({
    this.termsOfService = false,
    this.privacyPolicy = false,
    this.locationTerms = false,
    this.marketing = false,
    this.isLoading = true,
    this.isSubmitting = false,
  }) : super._();

  @override
  @JsonKey()
  final bool termsOfService;
  @override
  @JsonKey()
  final bool privacyPolicy;
  @override
  @JsonKey()
  final bool locationTerms;
  @override
  @JsonKey()
  final bool marketing;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSubmitting;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AgreementState(termsOfService: $termsOfService, privacyPolicy: $privacyPolicy, locationTerms: $locationTerms, marketing: $marketing, isLoading: $isLoading, isSubmitting: $isSubmitting)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AgreementState'))
      ..add(DiagnosticsProperty('termsOfService', termsOfService))
      ..add(DiagnosticsProperty('privacyPolicy', privacyPolicy))
      ..add(DiagnosticsProperty('locationTerms', locationTerms))
      ..add(DiagnosticsProperty('marketing', marketing))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('isSubmitting', isSubmitting));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgreementStateImpl &&
            (identical(other.termsOfService, termsOfService) ||
                other.termsOfService == termsOfService) &&
            (identical(other.privacyPolicy, privacyPolicy) ||
                other.privacyPolicy == privacyPolicy) &&
            (identical(other.locationTerms, locationTerms) ||
                other.locationTerms == locationTerms) &&
            (identical(other.marketing, marketing) ||
                other.marketing == marketing) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    termsOfService,
    privacyPolicy,
    locationTerms,
    marketing,
    isLoading,
    isSubmitting,
  );

  /// Create a copy of AgreementState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgreementStateImplCopyWith<_$AgreementStateImpl> get copyWith =>
      __$$AgreementStateImplCopyWithImpl<_$AgreementStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AgreementState extends AgreementState {
  const factory _AgreementState({
    final bool termsOfService,
    final bool privacyPolicy,
    final bool locationTerms,
    final bool marketing,
    final bool isLoading,
    final bool isSubmitting,
  }) = _$AgreementStateImpl;
  const _AgreementState._() : super._();

  @override
  bool get termsOfService;
  @override
  bool get privacyPolicy;
  @override
  bool get locationTerms;
  @override
  bool get marketing;
  @override
  bool get isLoading;
  @override
  bool get isSubmitting;

  /// Create a copy of AgreementState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgreementStateImplCopyWith<_$AgreementStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
