// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommunityLocationModel _$CommunityLocationModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityLocationModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityLocationModel {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// 동 단위 지역 — `서울특별시 광진구 군자동`. 역지오코딩 실패 시 null.
  String? get region => throw _privateConstructorUsedError;

  /// 작성자가 입력한 만나는 곳 — `어린이대공원 정문`.
  ///
  /// 스키마상 non-null이지만 nullable로 받는다: v2.17.0 이전에 쓰인 글까지
  /// 서버가 채웠다는 보장이 없고, 응답 한 건 때문에 목록 전체가 파싱 실패로
  /// 날아가는 편이 장소 한 줄이 비는 것보다 나쁘다.
  String? get placeName => throw _privateConstructorUsedError;

  /// 국가 코드(ISO 3166-1 alpha-2). 역지오코딩 실패 시 null.
  String? get countryCode => throw _privateConstructorUsedError;

  /// Serializes this CommunityLocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityLocationModelCopyWith<CommunityLocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityLocationModelCopyWith<$Res> {
  factory $CommunityLocationModelCopyWith(
    CommunityLocationModel value,
    $Res Function(CommunityLocationModel) then,
  ) = _$CommunityLocationModelCopyWithImpl<$Res, CommunityLocationModel>;
  @useResult
  $Res call({
    double latitude,
    double longitude,
    String? region,
    String? placeName,
    String? countryCode,
  });
}

/// @nodoc
class _$CommunityLocationModelCopyWithImpl<
  $Res,
  $Val extends CommunityLocationModel
>
    implements $CommunityLocationModelCopyWith<$Res> {
  _$CommunityLocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? region = freezed,
    Object? placeName = freezed,
    Object? countryCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            placeName: freezed == placeName
                ? _value.placeName
                : placeName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CommunityLocationModelImplCopyWith<$Res>
    implements $CommunityLocationModelCopyWith<$Res> {
  factory _$$CommunityLocationModelImplCopyWith(
    _$CommunityLocationModelImpl value,
    $Res Function(_$CommunityLocationModelImpl) then,
  ) = __$$CommunityLocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double latitude,
    double longitude,
    String? region,
    String? placeName,
    String? countryCode,
  });
}

/// @nodoc
class __$$CommunityLocationModelImplCopyWithImpl<$Res>
    extends
        _$CommunityLocationModelCopyWithImpl<$Res, _$CommunityLocationModelImpl>
    implements _$$CommunityLocationModelImplCopyWith<$Res> {
  __$$CommunityLocationModelImplCopyWithImpl(
    _$CommunityLocationModelImpl _value,
    $Res Function(_$CommunityLocationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? region = freezed,
    Object? placeName = freezed,
    Object? countryCode = freezed,
  }) {
    return _then(
      _$CommunityLocationModelImpl(
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        placeName: freezed == placeName
            ? _value.placeName
            : placeName // ignore: cast_nullable_to_non_nullable
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
@JsonSerializable()
class _$CommunityLocationModelImpl implements _CommunityLocationModel {
  const _$CommunityLocationModelImpl({
    required this.latitude,
    required this.longitude,
    this.region,
    this.placeName,
    this.countryCode,
  });

  factory _$CommunityLocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityLocationModelImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  /// 동 단위 지역 — `서울특별시 광진구 군자동`. 역지오코딩 실패 시 null.
  @override
  final String? region;

  /// 작성자가 입력한 만나는 곳 — `어린이대공원 정문`.
  ///
  /// 스키마상 non-null이지만 nullable로 받는다: v2.17.0 이전에 쓰인 글까지
  /// 서버가 채웠다는 보장이 없고, 응답 한 건 때문에 목록 전체가 파싱 실패로
  /// 날아가는 편이 장소 한 줄이 비는 것보다 나쁘다.
  @override
  final String? placeName;

  /// 국가 코드(ISO 3166-1 alpha-2). 역지오코딩 실패 시 null.
  @override
  final String? countryCode;

  @override
  String toString() {
    return 'CommunityLocationModel(latitude: $latitude, longitude: $longitude, region: $region, placeName: $placeName, countryCode: $countryCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityLocationModelImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    latitude,
    longitude,
    region,
    placeName,
    countryCode,
  );

  /// Create a copy of CommunityLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityLocationModelImplCopyWith<_$CommunityLocationModelImpl>
  get copyWith =>
      __$$CommunityLocationModelImplCopyWithImpl<_$CommunityLocationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityLocationModelImplToJson(this);
  }
}

abstract class _CommunityLocationModel implements CommunityLocationModel {
  const factory _CommunityLocationModel({
    required final double latitude,
    required final double longitude,
    final String? region,
    final String? placeName,
    final String? countryCode,
  }) = _$CommunityLocationModelImpl;

  factory _CommunityLocationModel.fromJson(Map<String, dynamic> json) =
      _$CommunityLocationModelImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// 동 단위 지역 — `서울특별시 광진구 군자동`. 역지오코딩 실패 시 null.
  @override
  String? get region;

  /// 작성자가 입력한 만나는 곳 — `어린이대공원 정문`.
  ///
  /// 스키마상 non-null이지만 nullable로 받는다: v2.17.0 이전에 쓰인 글까지
  /// 서버가 채웠다는 보장이 없고, 응답 한 건 때문에 목록 전체가 파싱 실패로
  /// 날아가는 편이 장소 한 줄이 비는 것보다 나쁘다.
  @override
  String? get placeName;

  /// 국가 코드(ISO 3166-1 alpha-2). 역지오코딩 실패 시 null.
  @override
  String? get countryCode;

  /// Create a copy of CommunityLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityLocationModelImplCopyWith<_$CommunityLocationModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CommunityAddressResponseModel _$CommunityAddressResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityAddressResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityAddressResponseModel {
  String? get region => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get countryCode => throw _privateConstructorUsedError;

  /// Serializes this CommunityAddressResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityAddressResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityAddressResponseModelCopyWith<CommunityAddressResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityAddressResponseModelCopyWith<$Res> {
  factory $CommunityAddressResponseModelCopyWith(
    CommunityAddressResponseModel value,
    $Res Function(CommunityAddressResponseModel) then,
  ) =
      _$CommunityAddressResponseModelCopyWithImpl<
        $Res,
        CommunityAddressResponseModel
      >;
  @useResult
  $Res call({String? region, String? address, String? countryCode});
}

/// @nodoc
class _$CommunityAddressResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityAddressResponseModel
>
    implements $CommunityAddressResponseModelCopyWith<$Res> {
  _$CommunityAddressResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityAddressResponseModel
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
abstract class _$$CommunityAddressResponseModelImplCopyWith<$Res>
    implements $CommunityAddressResponseModelCopyWith<$Res> {
  factory _$$CommunityAddressResponseModelImplCopyWith(
    _$CommunityAddressResponseModelImpl value,
    $Res Function(_$CommunityAddressResponseModelImpl) then,
  ) = __$$CommunityAddressResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? region, String? address, String? countryCode});
}

/// @nodoc
class __$$CommunityAddressResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityAddressResponseModelCopyWithImpl<
          $Res,
          _$CommunityAddressResponseModelImpl
        >
    implements _$$CommunityAddressResponseModelImplCopyWith<$Res> {
  __$$CommunityAddressResponseModelImplCopyWithImpl(
    _$CommunityAddressResponseModelImpl _value,
    $Res Function(_$CommunityAddressResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityAddressResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? region = freezed,
    Object? address = freezed,
    Object? countryCode = freezed,
  }) {
    return _then(
      _$CommunityAddressResponseModelImpl(
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
@JsonSerializable()
class _$CommunityAddressResponseModelImpl
    implements _CommunityAddressResponseModel {
  const _$CommunityAddressResponseModelImpl({
    this.region,
    this.address,
    this.countryCode,
  });

  factory _$CommunityAddressResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityAddressResponseModelImplFromJson(json);

  @override
  final String? region;
  @override
  final String? address;
  @override
  final String? countryCode;

  @override
  String toString() {
    return 'CommunityAddressResponseModel(region: $region, address: $address, countryCode: $countryCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityAddressResponseModelImpl &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, region, address, countryCode);

  /// Create a copy of CommunityAddressResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityAddressResponseModelImplCopyWith<
    _$CommunityAddressResponseModelImpl
  >
  get copyWith =>
      __$$CommunityAddressResponseModelImplCopyWithImpl<
        _$CommunityAddressResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityAddressResponseModelImplToJson(this);
  }
}

abstract class _CommunityAddressResponseModel
    implements CommunityAddressResponseModel {
  const factory _CommunityAddressResponseModel({
    final String? region,
    final String? address,
    final String? countryCode,
  }) = _$CommunityAddressResponseModelImpl;

  factory _CommunityAddressResponseModel.fromJson(Map<String, dynamic> json) =
      _$CommunityAddressResponseModelImpl.fromJson;

  @override
  String? get region;
  @override
  String? get address;
  @override
  String? get countryCode;

  /// Create a copy of CommunityAddressResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityAddressResponseModelImplCopyWith<
    _$CommunityAddressResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CursorInfoModel _$CursorInfoModelFromJson(Map<String, dynamic> json) {
  return _CursorInfoModel.fromJson(json);
}

/// @nodoc
mixin _$CursorInfoModel {
  String? get nextCursor => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;

  /// Serializes this CursorInfoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CursorInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CursorInfoModelCopyWith<CursorInfoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CursorInfoModelCopyWith<$Res> {
  factory $CursorInfoModelCopyWith(
    CursorInfoModel value,
    $Res Function(CursorInfoModel) then,
  ) = _$CursorInfoModelCopyWithImpl<$Res, CursorInfoModel>;
  @useResult
  $Res call({String? nextCursor, bool hasNext});
}

/// @nodoc
class _$CursorInfoModelCopyWithImpl<$Res, $Val extends CursorInfoModel>
    implements $CursorInfoModelCopyWith<$Res> {
  _$CursorInfoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CursorInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nextCursor = freezed, Object? hasNext = null}) {
    return _then(
      _value.copyWith(
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CursorInfoModelImplCopyWith<$Res>
    implements $CursorInfoModelCopyWith<$Res> {
  factory _$$CursorInfoModelImplCopyWith(
    _$CursorInfoModelImpl value,
    $Res Function(_$CursorInfoModelImpl) then,
  ) = __$$CursorInfoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? nextCursor, bool hasNext});
}

/// @nodoc
class __$$CursorInfoModelImplCopyWithImpl<$Res>
    extends _$CursorInfoModelCopyWithImpl<$Res, _$CursorInfoModelImpl>
    implements _$$CursorInfoModelImplCopyWith<$Res> {
  __$$CursorInfoModelImplCopyWithImpl(
    _$CursorInfoModelImpl _value,
    $Res Function(_$CursorInfoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CursorInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nextCursor = freezed, Object? hasNext = null}) {
    return _then(
      _$CursorInfoModelImpl(
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CursorInfoModelImpl implements _CursorInfoModel {
  const _$CursorInfoModelImpl({
    required this.nextCursor,
    required this.hasNext,
  });

  factory _$CursorInfoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CursorInfoModelImplFromJson(json);

  @override
  final String? nextCursor;
  @override
  final bool hasNext;

  @override
  String toString() {
    return 'CursorInfoModel(nextCursor: $nextCursor, hasNext: $hasNext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CursorInfoModelImpl &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nextCursor, hasNext);

  /// Create a copy of CursorInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CursorInfoModelImplCopyWith<_$CursorInfoModelImpl> get copyWith =>
      __$$CursorInfoModelImplCopyWithImpl<_$CursorInfoModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CursorInfoModelImplToJson(this);
  }
}

abstract class _CursorInfoModel implements CursorInfoModel {
  const factory _CursorInfoModel({
    required final String? nextCursor,
    required final bool hasNext,
  }) = _$CursorInfoModelImpl;

  factory _CursorInfoModel.fromJson(Map<String, dynamic> json) =
      _$CursorInfoModelImpl.fromJson;

  @override
  String? get nextCursor;
  @override
  bool get hasNext;

  /// Create a copy of CursorInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CursorInfoModelImplCopyWith<_$CursorInfoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommunityPostResponseModel _$CommunityPostResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityPostResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityPostResponseModel {
  int get id => throw _privateConstructorUsedError;
  int get writerId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get meetingAt => throw _privateConstructorUsedError;
  CommunityLocationModel get location => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 작성자 닉네임. 탈퇴한 작성자면 null.
  String? get writerNickname =>
      throw _privateConstructorUsedError; // ── 백엔드 추가 예정 ──
  int? get currentParticipants => throw _privateConstructorUsedError;
  int? get likeCount => throw _privateConstructorUsedError;
  int? get bookmarkCount => throw _privateConstructorUsedError;

  /// Serializes this CommunityPostResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPostResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostResponseModelCopyWith<CommunityPostResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostResponseModelCopyWith<$Res> {
  factory $CommunityPostResponseModelCopyWith(
    CommunityPostResponseModel value,
    $Res Function(CommunityPostResponseModel) then,
  ) =
      _$CommunityPostResponseModelCopyWithImpl<
        $Res,
        CommunityPostResponseModel
      >;
  @useResult
  $Res call({
    int id,
    int writerId,
    String title,
    String content,
    DateTime meetingAt,
    CommunityLocationModel location,
    int maxParticipants,
    String status,
    DateTime createdAt,
    String? writerNickname,
    int? currentParticipants,
    int? likeCount,
    int? bookmarkCount,
  });

  $CommunityLocationModelCopyWith<$Res> get location;
}

/// @nodoc
class _$CommunityPostResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityPostResponseModel
>
    implements $CommunityPostResponseModelCopyWith<$Res> {
  _$CommunityPostResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPostResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? writerId = null,
    Object? title = null,
    Object? content = null,
    Object? meetingAt = null,
    Object? location = null,
    Object? maxParticipants = null,
    Object? status = null,
    Object? createdAt = null,
    Object? writerNickname = freezed,
    Object? currentParticipants = freezed,
    Object? likeCount = freezed,
    Object? bookmarkCount = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            writerId: null == writerId
                ? _value.writerId
                : writerId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            meetingAt: null == meetingAt
                ? _value.meetingAt
                : meetingAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as CommunityLocationModel,
            maxParticipants: null == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            writerNickname: freezed == writerNickname
                ? _value.writerNickname
                : writerNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentParticipants: freezed == currentParticipants
                ? _value.currentParticipants
                : currentParticipants // ignore: cast_nullable_to_non_nullable
                      as int?,
            likeCount: freezed == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            bookmarkCount: freezed == bookmarkCount
                ? _value.bookmarkCount
                : bookmarkCount // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of CommunityPostResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommunityLocationModelCopyWith<$Res> get location {
    return $CommunityLocationModelCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommunityPostResponseModelImplCopyWith<$Res>
    implements $CommunityPostResponseModelCopyWith<$Res> {
  factory _$$CommunityPostResponseModelImplCopyWith(
    _$CommunityPostResponseModelImpl value,
    $Res Function(_$CommunityPostResponseModelImpl) then,
  ) = __$$CommunityPostResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int writerId,
    String title,
    String content,
    DateTime meetingAt,
    CommunityLocationModel location,
    int maxParticipants,
    String status,
    DateTime createdAt,
    String? writerNickname,
    int? currentParticipants,
    int? likeCount,
    int? bookmarkCount,
  });

  @override
  $CommunityLocationModelCopyWith<$Res> get location;
}

/// @nodoc
class __$$CommunityPostResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityPostResponseModelCopyWithImpl<
          $Res,
          _$CommunityPostResponseModelImpl
        >
    implements _$$CommunityPostResponseModelImplCopyWith<$Res> {
  __$$CommunityPostResponseModelImplCopyWithImpl(
    _$CommunityPostResponseModelImpl _value,
    $Res Function(_$CommunityPostResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPostResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? writerId = null,
    Object? title = null,
    Object? content = null,
    Object? meetingAt = null,
    Object? location = null,
    Object? maxParticipants = null,
    Object? status = null,
    Object? createdAt = null,
    Object? writerNickname = freezed,
    Object? currentParticipants = freezed,
    Object? likeCount = freezed,
    Object? bookmarkCount = freezed,
  }) {
    return _then(
      _$CommunityPostResponseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        writerId: null == writerId
            ? _value.writerId
            : writerId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        meetingAt: null == meetingAt
            ? _value.meetingAt
            : meetingAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as CommunityLocationModel,
        maxParticipants: null == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        writerNickname: freezed == writerNickname
            ? _value.writerNickname
            : writerNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentParticipants: freezed == currentParticipants
            ? _value.currentParticipants
            : currentParticipants // ignore: cast_nullable_to_non_nullable
                  as int?,
        likeCount: freezed == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        bookmarkCount: freezed == bookmarkCount
            ? _value.bookmarkCount
            : bookmarkCount // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityPostResponseModelImpl implements _CommunityPostResponseModel {
  const _$CommunityPostResponseModelImpl({
    required this.id,
    required this.writerId,
    required this.title,
    required this.content,
    required this.meetingAt,
    required this.location,
    required this.maxParticipants,
    required this.status,
    required this.createdAt,
    this.writerNickname,
    this.currentParticipants,
    this.likeCount,
    this.bookmarkCount,
  });

  factory _$CommunityPostResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityPostResponseModelImplFromJson(json);

  @override
  final int id;
  @override
  final int writerId;
  @override
  final String title;
  @override
  final String content;
  @override
  final DateTime meetingAt;
  @override
  final CommunityLocationModel location;
  @override
  final int maxParticipants;
  @override
  final String status;
  @override
  final DateTime createdAt;

  /// 작성자 닉네임. 탈퇴한 작성자면 null.
  @override
  final String? writerNickname;
  // ── 백엔드 추가 예정 ──
  @override
  final int? currentParticipants;
  @override
  final int? likeCount;
  @override
  final int? bookmarkCount;

  @override
  String toString() {
    return 'CommunityPostResponseModel(id: $id, writerId: $writerId, title: $title, content: $content, meetingAt: $meetingAt, location: $location, maxParticipants: $maxParticipants, status: $status, createdAt: $createdAt, writerNickname: $writerNickname, currentParticipants: $currentParticipants, likeCount: $likeCount, bookmarkCount: $bookmarkCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostResponseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.writerId, writerId) ||
                other.writerId == writerId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.meetingAt, meetingAt) ||
                other.meetingAt == meetingAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.writerNickname, writerNickname) ||
                other.writerNickname == writerNickname) &&
            (identical(other.currentParticipants, currentParticipants) ||
                other.currentParticipants == currentParticipants) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    writerId,
    title,
    content,
    meetingAt,
    location,
    maxParticipants,
    status,
    createdAt,
    writerNickname,
    currentParticipants,
    likeCount,
    bookmarkCount,
  );

  /// Create a copy of CommunityPostResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostResponseModelImplCopyWith<_$CommunityPostResponseModelImpl>
  get copyWith =>
      __$$CommunityPostResponseModelImplCopyWithImpl<
        _$CommunityPostResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPostResponseModelImplToJson(this);
  }
}

abstract class _CommunityPostResponseModel
    implements CommunityPostResponseModel {
  const factory _CommunityPostResponseModel({
    required final int id,
    required final int writerId,
    required final String title,
    required final String content,
    required final DateTime meetingAt,
    required final CommunityLocationModel location,
    required final int maxParticipants,
    required final String status,
    required final DateTime createdAt,
    final String? writerNickname,
    final int? currentParticipants,
    final int? likeCount,
    final int? bookmarkCount,
  }) = _$CommunityPostResponseModelImpl;

  factory _CommunityPostResponseModel.fromJson(Map<String, dynamic> json) =
      _$CommunityPostResponseModelImpl.fromJson;

  @override
  int get id;
  @override
  int get writerId;
  @override
  String get title;
  @override
  String get content;
  @override
  DateTime get meetingAt;
  @override
  CommunityLocationModel get location;
  @override
  int get maxParticipants;
  @override
  String get status;
  @override
  DateTime get createdAt;

  /// 작성자 닉네임. 탈퇴한 작성자면 null.
  @override
  String? get writerNickname; // ── 백엔드 추가 예정 ──
  @override
  int? get currentParticipants;
  @override
  int? get likeCount;
  @override
  int? get bookmarkCount;

  /// Create a copy of CommunityPostResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostResponseModelImplCopyWith<_$CommunityPostResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CommunityPostListResponseModel _$CommunityPostListResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityPostListResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityPostListResponseModel {
  List<CommunityPostResponseModel> get content =>
      throw _privateConstructorUsedError;
  CursorInfoModel get cursor => throw _privateConstructorUsedError;

  /// Serializes this CommunityPostListResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPostListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostListResponseModelCopyWith<CommunityPostListResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostListResponseModelCopyWith<$Res> {
  factory $CommunityPostListResponseModelCopyWith(
    CommunityPostListResponseModel value,
    $Res Function(CommunityPostListResponseModel) then,
  ) =
      _$CommunityPostListResponseModelCopyWithImpl<
        $Res,
        CommunityPostListResponseModel
      >;
  @useResult
  $Res call({List<CommunityPostResponseModel> content, CursorInfoModel cursor});

  $CursorInfoModelCopyWith<$Res> get cursor;
}

/// @nodoc
class _$CommunityPostListResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityPostListResponseModel
>
    implements $CommunityPostListResponseModelCopyWith<$Res> {
  _$CommunityPostListResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPostListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null, Object? cursor = null}) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as List<CommunityPostResponseModel>,
            cursor: null == cursor
                ? _value.cursor
                : cursor // ignore: cast_nullable_to_non_nullable
                      as CursorInfoModel,
          )
          as $Val,
    );
  }

  /// Create a copy of CommunityPostListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CursorInfoModelCopyWith<$Res> get cursor {
    return $CursorInfoModelCopyWith<$Res>(_value.cursor, (value) {
      return _then(_value.copyWith(cursor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommunityPostListResponseModelImplCopyWith<$Res>
    implements $CommunityPostListResponseModelCopyWith<$Res> {
  factory _$$CommunityPostListResponseModelImplCopyWith(
    _$CommunityPostListResponseModelImpl value,
    $Res Function(_$CommunityPostListResponseModelImpl) then,
  ) = __$$CommunityPostListResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CommunityPostResponseModel> content, CursorInfoModel cursor});

  @override
  $CursorInfoModelCopyWith<$Res> get cursor;
}

/// @nodoc
class __$$CommunityPostListResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityPostListResponseModelCopyWithImpl<
          $Res,
          _$CommunityPostListResponseModelImpl
        >
    implements _$$CommunityPostListResponseModelImplCopyWith<$Res> {
  __$$CommunityPostListResponseModelImplCopyWithImpl(
    _$CommunityPostListResponseModelImpl _value,
    $Res Function(_$CommunityPostListResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPostListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null, Object? cursor = null}) {
    return _then(
      _$CommunityPostListResponseModelImpl(
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as List<CommunityPostResponseModel>,
        cursor: null == cursor
            ? _value.cursor
            : cursor // ignore: cast_nullable_to_non_nullable
                  as CursorInfoModel,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityPostListResponseModelImpl
    implements _CommunityPostListResponseModel {
  const _$CommunityPostListResponseModelImpl({
    required final List<CommunityPostResponseModel> content,
    required this.cursor,
  }) : _content = content;

  factory _$CommunityPostListResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityPostListResponseModelImplFromJson(json);

  final List<CommunityPostResponseModel> _content;
  @override
  List<CommunityPostResponseModel> get content {
    if (_content is EqualUnmodifiableListView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_content);
  }

  @override
  final CursorInfoModel cursor;

  @override
  String toString() {
    return 'CommunityPostListResponseModel(content: $content, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostListResponseModelImpl &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_content),
    cursor,
  );

  /// Create a copy of CommunityPostListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostListResponseModelImplCopyWith<
    _$CommunityPostListResponseModelImpl
  >
  get copyWith =>
      __$$CommunityPostListResponseModelImplCopyWithImpl<
        _$CommunityPostListResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPostListResponseModelImplToJson(this);
  }
}

abstract class _CommunityPostListResponseModel
    implements CommunityPostListResponseModel {
  const factory _CommunityPostListResponseModel({
    required final List<CommunityPostResponseModel> content,
    required final CursorInfoModel cursor,
  }) = _$CommunityPostListResponseModelImpl;

  factory _CommunityPostListResponseModel.fromJson(Map<String, dynamic> json) =
      _$CommunityPostListResponseModelImpl.fromJson;

  @override
  List<CommunityPostResponseModel> get content;
  @override
  CursorInfoModel get cursor;

  /// Create a copy of CommunityPostListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostListResponseModelImplCopyWith<
    _$CommunityPostListResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityCountryResponseModel _$CommunityCountryResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityCountryResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityCountryResponseModel {
  String? get countryCode => throw _privateConstructorUsedError;

  /// Serializes this CommunityCountryResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityCountryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityCountryResponseModelCopyWith<CommunityCountryResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityCountryResponseModelCopyWith<$Res> {
  factory $CommunityCountryResponseModelCopyWith(
    CommunityCountryResponseModel value,
    $Res Function(CommunityCountryResponseModel) then,
  ) =
      _$CommunityCountryResponseModelCopyWithImpl<
        $Res,
        CommunityCountryResponseModel
      >;
  @useResult
  $Res call({String? countryCode});
}

/// @nodoc
class _$CommunityCountryResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityCountryResponseModel
>
    implements $CommunityCountryResponseModelCopyWith<$Res> {
  _$CommunityCountryResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityCountryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? countryCode = freezed}) {
    return _then(
      _value.copyWith(
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
abstract class _$$CommunityCountryResponseModelImplCopyWith<$Res>
    implements $CommunityCountryResponseModelCopyWith<$Res> {
  factory _$$CommunityCountryResponseModelImplCopyWith(
    _$CommunityCountryResponseModelImpl value,
    $Res Function(_$CommunityCountryResponseModelImpl) then,
  ) = __$$CommunityCountryResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? countryCode});
}

/// @nodoc
class __$$CommunityCountryResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityCountryResponseModelCopyWithImpl<
          $Res,
          _$CommunityCountryResponseModelImpl
        >
    implements _$$CommunityCountryResponseModelImplCopyWith<$Res> {
  __$$CommunityCountryResponseModelImplCopyWithImpl(
    _$CommunityCountryResponseModelImpl _value,
    $Res Function(_$CommunityCountryResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityCountryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? countryCode = freezed}) {
    return _then(
      _$CommunityCountryResponseModelImpl(
        countryCode: freezed == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityCountryResponseModelImpl
    implements _CommunityCountryResponseModel {
  const _$CommunityCountryResponseModelImpl({this.countryCode});

  factory _$CommunityCountryResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityCountryResponseModelImplFromJson(json);

  @override
  final String? countryCode;

  @override
  String toString() {
    return 'CommunityCountryResponseModel(countryCode: $countryCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityCountryResponseModelImpl &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, countryCode);

  /// Create a copy of CommunityCountryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityCountryResponseModelImplCopyWith<
    _$CommunityCountryResponseModelImpl
  >
  get copyWith =>
      __$$CommunityCountryResponseModelImplCopyWithImpl<
        _$CommunityCountryResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityCountryResponseModelImplToJson(this);
  }
}

abstract class _CommunityCountryResponseModel
    implements CommunityCountryResponseModel {
  const factory _CommunityCountryResponseModel({final String? countryCode}) =
      _$CommunityCountryResponseModelImpl;

  factory _CommunityCountryResponseModel.fromJson(Map<String, dynamic> json) =
      _$CommunityCountryResponseModelImpl.fromJson;

  @override
  String? get countryCode;

  /// Create a copy of CommunityCountryResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityCountryResponseModelImplCopyWith<
    _$CommunityCountryResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityLocationRequestModel _$CommunityLocationRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityLocationRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityLocationRequestModel {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// 만나는 곳 — 최대 50자. 예: `어린이대공원 정문`
  String get placeName => throw _privateConstructorUsedError;

  /// Serializes this CommunityLocationRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityLocationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityLocationRequestModelCopyWith<CommunityLocationRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityLocationRequestModelCopyWith<$Res> {
  factory $CommunityLocationRequestModelCopyWith(
    CommunityLocationRequestModel value,
    $Res Function(CommunityLocationRequestModel) then,
  ) =
      _$CommunityLocationRequestModelCopyWithImpl<
        $Res,
        CommunityLocationRequestModel
      >;
  @useResult
  $Res call({double latitude, double longitude, String placeName});
}

/// @nodoc
class _$CommunityLocationRequestModelCopyWithImpl<
  $Res,
  $Val extends CommunityLocationRequestModel
>
    implements $CommunityLocationRequestModelCopyWith<$Res> {
  _$CommunityLocationRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityLocationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? placeName = null,
  }) {
    return _then(
      _value.copyWith(
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            placeName: null == placeName
                ? _value.placeName
                : placeName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityLocationRequestModelImplCopyWith<$Res>
    implements $CommunityLocationRequestModelCopyWith<$Res> {
  factory _$$CommunityLocationRequestModelImplCopyWith(
    _$CommunityLocationRequestModelImpl value,
    $Res Function(_$CommunityLocationRequestModelImpl) then,
  ) = __$$CommunityLocationRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude, String placeName});
}

/// @nodoc
class __$$CommunityLocationRequestModelImplCopyWithImpl<$Res>
    extends
        _$CommunityLocationRequestModelCopyWithImpl<
          $Res,
          _$CommunityLocationRequestModelImpl
        >
    implements _$$CommunityLocationRequestModelImplCopyWith<$Res> {
  __$$CommunityLocationRequestModelImplCopyWithImpl(
    _$CommunityLocationRequestModelImpl _value,
    $Res Function(_$CommunityLocationRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityLocationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? placeName = null,
  }) {
    return _then(
      _$CommunityLocationRequestModelImpl(
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        placeName: null == placeName
            ? _value.placeName
            : placeName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityLocationRequestModelImpl
    implements _CommunityLocationRequestModel {
  const _$CommunityLocationRequestModelImpl({
    required this.latitude,
    required this.longitude,
    required this.placeName,
  });

  factory _$CommunityLocationRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityLocationRequestModelImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  /// 만나는 곳 — 최대 50자. 예: `어린이대공원 정문`
  @override
  final String placeName;

  @override
  String toString() {
    return 'CommunityLocationRequestModel(latitude: $latitude, longitude: $longitude, placeName: $placeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityLocationRequestModelImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, placeName);

  /// Create a copy of CommunityLocationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityLocationRequestModelImplCopyWith<
    _$CommunityLocationRequestModelImpl
  >
  get copyWith =>
      __$$CommunityLocationRequestModelImplCopyWithImpl<
        _$CommunityLocationRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityLocationRequestModelImplToJson(this);
  }
}

abstract class _CommunityLocationRequestModel
    implements CommunityLocationRequestModel {
  const factory _CommunityLocationRequestModel({
    required final double latitude,
    required final double longitude,
    required final String placeName,
  }) = _$CommunityLocationRequestModelImpl;

  factory _CommunityLocationRequestModel.fromJson(Map<String, dynamic> json) =
      _$CommunityLocationRequestModelImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// 만나는 곳 — 최대 50자. 예: `어린이대공원 정문`
  @override
  String get placeName;

  /// Create a copy of CommunityLocationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityLocationRequestModelImplCopyWith<
    _$CommunityLocationRequestModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityPostWriteRequestModel _$CommunityPostWriteRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityPostWriteRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityPostWriteRequestModel {
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// 서버는 timezone suffix가 붙은 ISO 8601을 기대한다. 로컬 DateTime을 그냥
  /// 직렬화하면 suffix가 빠져 서버 로컬 시각으로 읽히므로 UTC로 정규화한다
  /// (`create_session_response.dart`와 같은 판단).
  @JsonKey(toJson: _dateTimeToIso)
  DateTime get meetingAt => throw _privateConstructorUsedError;
  CommunityLocationRequestModel get location =>
      throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;

  /// Serializes this CommunityPostWriteRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPostWriteRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostWriteRequestModelCopyWith<CommunityPostWriteRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostWriteRequestModelCopyWith<$Res> {
  factory $CommunityPostWriteRequestModelCopyWith(
    CommunityPostWriteRequestModel value,
    $Res Function(CommunityPostWriteRequestModel) then,
  ) =
      _$CommunityPostWriteRequestModelCopyWithImpl<
        $Res,
        CommunityPostWriteRequestModel
      >;
  @useResult
  $Res call({
    String title,
    String content,
    @JsonKey(toJson: _dateTimeToIso) DateTime meetingAt,
    CommunityLocationRequestModel location,
    int maxParticipants,
  });

  $CommunityLocationRequestModelCopyWith<$Res> get location;
}

/// @nodoc
class _$CommunityPostWriteRequestModelCopyWithImpl<
  $Res,
  $Val extends CommunityPostWriteRequestModel
>
    implements $CommunityPostWriteRequestModelCopyWith<$Res> {
  _$CommunityPostWriteRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPostWriteRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? meetingAt = null,
    Object? location = null,
    Object? maxParticipants = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            meetingAt: null == meetingAt
                ? _value.meetingAt
                : meetingAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as CommunityLocationRequestModel,
            maxParticipants: null == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of CommunityPostWriteRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommunityLocationRequestModelCopyWith<$Res> get location {
    return $CommunityLocationRequestModelCopyWith<$Res>(_value.location, (
      value,
    ) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommunityPostWriteRequestModelImplCopyWith<$Res>
    implements $CommunityPostWriteRequestModelCopyWith<$Res> {
  factory _$$CommunityPostWriteRequestModelImplCopyWith(
    _$CommunityPostWriteRequestModelImpl value,
    $Res Function(_$CommunityPostWriteRequestModelImpl) then,
  ) = __$$CommunityPostWriteRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String content,
    @JsonKey(toJson: _dateTimeToIso) DateTime meetingAt,
    CommunityLocationRequestModel location,
    int maxParticipants,
  });

  @override
  $CommunityLocationRequestModelCopyWith<$Res> get location;
}

/// @nodoc
class __$$CommunityPostWriteRequestModelImplCopyWithImpl<$Res>
    extends
        _$CommunityPostWriteRequestModelCopyWithImpl<
          $Res,
          _$CommunityPostWriteRequestModelImpl
        >
    implements _$$CommunityPostWriteRequestModelImplCopyWith<$Res> {
  __$$CommunityPostWriteRequestModelImplCopyWithImpl(
    _$CommunityPostWriteRequestModelImpl _value,
    $Res Function(_$CommunityPostWriteRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPostWriteRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? meetingAt = null,
    Object? location = null,
    Object? maxParticipants = null,
  }) {
    return _then(
      _$CommunityPostWriteRequestModelImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        meetingAt: null == meetingAt
            ? _value.meetingAt
            : meetingAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as CommunityLocationRequestModel,
        maxParticipants: null == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityPostWriteRequestModelImpl
    implements _CommunityPostWriteRequestModel {
  const _$CommunityPostWriteRequestModelImpl({
    required this.title,
    required this.content,
    @JsonKey(toJson: _dateTimeToIso) required this.meetingAt,
    required this.location,
    required this.maxParticipants,
  });

  factory _$CommunityPostWriteRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityPostWriteRequestModelImplFromJson(json);

  @override
  final String title;
  @override
  final String content;

  /// 서버는 timezone suffix가 붙은 ISO 8601을 기대한다. 로컬 DateTime을 그냥
  /// 직렬화하면 suffix가 빠져 서버 로컬 시각으로 읽히므로 UTC로 정규화한다
  /// (`create_session_response.dart`와 같은 판단).
  @override
  @JsonKey(toJson: _dateTimeToIso)
  final DateTime meetingAt;
  @override
  final CommunityLocationRequestModel location;
  @override
  final int maxParticipants;

  @override
  String toString() {
    return 'CommunityPostWriteRequestModel(title: $title, content: $content, meetingAt: $meetingAt, location: $location, maxParticipants: $maxParticipants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostWriteRequestModelImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.meetingAt, meetingAt) ||
                other.meetingAt == meetingAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    content,
    meetingAt,
    location,
    maxParticipants,
  );

  /// Create a copy of CommunityPostWriteRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostWriteRequestModelImplCopyWith<
    _$CommunityPostWriteRequestModelImpl
  >
  get copyWith =>
      __$$CommunityPostWriteRequestModelImplCopyWithImpl<
        _$CommunityPostWriteRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPostWriteRequestModelImplToJson(this);
  }
}

abstract class _CommunityPostWriteRequestModel
    implements CommunityPostWriteRequestModel {
  const factory _CommunityPostWriteRequestModel({
    required final String title,
    required final String content,
    @JsonKey(toJson: _dateTimeToIso) required final DateTime meetingAt,
    required final CommunityLocationRequestModel location,
    required final int maxParticipants,
  }) = _$CommunityPostWriteRequestModelImpl;

  factory _CommunityPostWriteRequestModel.fromJson(Map<String, dynamic> json) =
      _$CommunityPostWriteRequestModelImpl.fromJson;

  @override
  String get title;
  @override
  String get content;

  /// 서버는 timezone suffix가 붙은 ISO 8601을 기대한다. 로컬 DateTime을 그냥
  /// 직렬화하면 suffix가 빠져 서버 로컬 시각으로 읽히므로 UTC로 정규화한다
  /// (`create_session_response.dart`와 같은 판단).
  @override
  @JsonKey(toJson: _dateTimeToIso)
  DateTime get meetingAt;
  @override
  CommunityLocationRequestModel get location;
  @override
  int get maxParticipants;

  /// Create a copy of CommunityPostWriteRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostWriteRequestModelImplCopyWith<
    _$CommunityPostWriteRequestModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityPostStatusRequestModel _$CommunityPostStatusRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityPostStatusRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityPostStatusRequestModel {
  String get status => throw _privateConstructorUsedError;

  /// Serializes this CommunityPostStatusRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPostStatusRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostStatusRequestModelCopyWith<CommunityPostStatusRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostStatusRequestModelCopyWith<$Res> {
  factory $CommunityPostStatusRequestModelCopyWith(
    CommunityPostStatusRequestModel value,
    $Res Function(CommunityPostStatusRequestModel) then,
  ) =
      _$CommunityPostStatusRequestModelCopyWithImpl<
        $Res,
        CommunityPostStatusRequestModel
      >;
  @useResult
  $Res call({String status});
}

/// @nodoc
class _$CommunityPostStatusRequestModelCopyWithImpl<
  $Res,
  $Val extends CommunityPostStatusRequestModel
>
    implements $CommunityPostStatusRequestModelCopyWith<$Res> {
  _$CommunityPostStatusRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPostStatusRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null}) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityPostStatusRequestModelImplCopyWith<$Res>
    implements $CommunityPostStatusRequestModelCopyWith<$Res> {
  factory _$$CommunityPostStatusRequestModelImplCopyWith(
    _$CommunityPostStatusRequestModelImpl value,
    $Res Function(_$CommunityPostStatusRequestModelImpl) then,
  ) = __$$CommunityPostStatusRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String status});
}

/// @nodoc
class __$$CommunityPostStatusRequestModelImplCopyWithImpl<$Res>
    extends
        _$CommunityPostStatusRequestModelCopyWithImpl<
          $Res,
          _$CommunityPostStatusRequestModelImpl
        >
    implements _$$CommunityPostStatusRequestModelImplCopyWith<$Res> {
  __$$CommunityPostStatusRequestModelImplCopyWithImpl(
    _$CommunityPostStatusRequestModelImpl _value,
    $Res Function(_$CommunityPostStatusRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPostStatusRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null}) {
    return _then(
      _$CommunityPostStatusRequestModelImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityPostStatusRequestModelImpl
    implements _CommunityPostStatusRequestModel {
  const _$CommunityPostStatusRequestModelImpl({required this.status});

  factory _$CommunityPostStatusRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityPostStatusRequestModelImplFromJson(json);

  @override
  final String status;

  @override
  String toString() {
    return 'CommunityPostStatusRequestModel(status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostStatusRequestModelImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status);

  /// Create a copy of CommunityPostStatusRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostStatusRequestModelImplCopyWith<
    _$CommunityPostStatusRequestModelImpl
  >
  get copyWith =>
      __$$CommunityPostStatusRequestModelImplCopyWithImpl<
        _$CommunityPostStatusRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPostStatusRequestModelImplToJson(this);
  }
}

abstract class _CommunityPostStatusRequestModel
    implements CommunityPostStatusRequestModel {
  const factory _CommunityPostStatusRequestModel({
    required final String status,
  }) = _$CommunityPostStatusRequestModelImpl;

  factory _CommunityPostStatusRequestModel.fromJson(Map<String, dynamic> json) =
      _$CommunityPostStatusRequestModelImpl.fromJson;

  @override
  String get status;

  /// Create a copy of CommunityPostStatusRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostStatusRequestModelImplCopyWith<
    _$CommunityPostStatusRequestModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
