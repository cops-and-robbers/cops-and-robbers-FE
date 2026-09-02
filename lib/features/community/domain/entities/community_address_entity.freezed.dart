// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_address_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityAddressEntity {
  /// 동 단위 지역 — `서울특별시 광진구 화양동`. 글에 저장될 값과 같다.
  String? get region => throw _privateConstructorUsedError;

  /// 번지까지 포함한 주소 — `서울특별시 광진구 화양동 1-20`. 확인용.
  String? get address => throw _privateConstructorUsedError;

  /// 국가 코드(ISO 3166-1 alpha-2) — **이 핀이 속한 나라**.
  ///
  /// 목록 필터에는 쓰지 않는다. 목록의 기준은 보는 사람의 현재 위치라
  /// `communityCountryCodeProvider`(`/country`)가 따로 구한다. 지금은 읽는
  /// 화면이 없고, 작성자가 목록과 다른 나라에 핀을 찍었는지 알아내려면
  /// 이 값이 필요해 남겨 둔다.
  String? get countryCode => throw _privateConstructorUsedError;

  /// Create a copy of CommunityAddressEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityAddressEntityCopyWith<CommunityAddressEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityAddressEntityCopyWith<$Res> {
  factory $CommunityAddressEntityCopyWith(
    CommunityAddressEntity value,
    $Res Function(CommunityAddressEntity) then,
  ) = _$CommunityAddressEntityCopyWithImpl<$Res, CommunityAddressEntity>;
  @useResult
  $Res call({String? region, String? address, String? countryCode});
}

/// @nodoc
class _$CommunityAddressEntityCopyWithImpl<
  $Res,
  $Val extends CommunityAddressEntity
>
    implements $CommunityAddressEntityCopyWith<$Res> {
  _$CommunityAddressEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityAddressEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? region = freezed,
    Object? address = freezed,
    Object? countryCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            countryCode: freezed == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityAddressEntityImplCopyWith<$Res>
    implements $CommunityAddressEntityCopyWith<$Res> {
  factory _$$CommunityAddressEntityImplCopyWith(
    _$CommunityAddressEntityImpl value,
    $Res Function(_$CommunityAddressEntityImpl) then,
  ) = __$$CommunityAddressEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? region, String? address, String? countryCode});
}

/// @nodoc
class __$$CommunityAddressEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityAddressEntityCopyWithImpl<$Res, _$CommunityAddressEntityImpl>
    implements _$$CommunityAddressEntityImplCopyWith<$Res> {
  __$$CommunityAddressEntityImplCopyWithImpl(
    _$CommunityAddressEntityImpl _value,
    $Res Function(_$CommunityAddressEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityAddressEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? region = freezed,
    Object? address = freezed,
    Object? countryCode = freezed,
  }) {
    return _then(
      _$CommunityAddressEntityImpl(
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        countryCode: freezed == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$CommunityAddressEntityImpl implements _CommunityAddressEntity {
  const _$CommunityAddressEntityImpl({
    this.region,
    this.address,
    this.countryCode,
  });

  /// 동 단위 지역 — `서울특별시 광진구 화양동`. 글에 저장될 값과 같다.
  @override
  final String? region;

  /// 번지까지 포함한 주소 — `서울특별시 광진구 화양동 1-20`. 확인용.
  @override
  final String? address;

  /// 국가 코드(ISO 3166-1 alpha-2) — **이 핀이 속한 나라**.
  ///
  /// 목록 필터에는 쓰지 않는다. 목록의 기준은 보는 사람의 현재 위치라
  /// `communityCountryCodeProvider`(`/country`)가 따로 구한다. 지금은 읽는
  /// 화면이 없고, 작성자가 목록과 다른 나라에 핀을 찍었는지 알아내려면
  /// 이 값이 필요해 남겨 둔다.
  @override
  final String? countryCode;

  @override
  String toString() {
    return 'CommunityAddressEntity(region: $region, address: $address, countryCode: $countryCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityAddressEntityImpl &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, region, address, countryCode);

  /// Create a copy of CommunityAddressEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityAddressEntityImplCopyWith<_$CommunityAddressEntityImpl>
  get copyWith =>
      __$$CommunityAddressEntityImplCopyWithImpl<_$CommunityAddressEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _CommunityAddressEntity implements CommunityAddressEntity {
  const factory _CommunityAddressEntity({
    final String? region,
    final String? address,
    final String? countryCode,
  }) = _$CommunityAddressEntityImpl;

  /// 동 단위 지역 — `서울특별시 광진구 화양동`. 글에 저장될 값과 같다.
  @override
  String? get region;

  /// 번지까지 포함한 주소 — `서울특별시 광진구 화양동 1-20`. 확인용.
  @override
  String? get address;

  /// 국가 코드(ISO 3166-1 alpha-2) — **이 핀이 속한 나라**.
  ///
  /// 목록 필터에는 쓰지 않는다. 목록의 기준은 보는 사람의 현재 위치라
  /// `communityCountryCodeProvider`(`/country`)가 따로 구한다. 지금은 읽는
  /// 화면이 없고, 작성자가 목록과 다른 나라에 핀을 찍었는지 알아내려면
  /// 이 값이 필요해 남겨 둔다.
  @override
  String? get countryCode;

  /// Create a copy of CommunityAddressEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityAddressEntityImplCopyWith<_$CommunityAddressEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
