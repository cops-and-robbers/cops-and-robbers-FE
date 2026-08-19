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

  /// 지번 주소 — `서울 광진구 군자동 98`
  String? get address => throw _privateConstructorUsedError;

  /// 도로명 주소 — `서울특별시 광진구 능동로 209`. 도로명이 없는 지역이면 null.
  String? get roadAddress => throw _privateConstructorUsedError;

  /// 건물명 — `세종대학교`. 공터·공원·길 위 좌표면 null.
  String? get buildingName => throw _privateConstructorUsedError;

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
    String? address,
    String? roadAddress,
    String? buildingName,
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
    Object? address = freezed,
    Object? roadAddress = freezed,
    Object? buildingName = freezed,
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
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            roadAddress: freezed == roadAddress
                ? _value.roadAddress
                : roadAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            buildingName: freezed == buildingName
                ? _value.buildingName
                : buildingName // ignore: cast_nullable_to_non_nullable
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
    String? address,
    String? roadAddress,
    String? buildingName,
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
    Object? address = freezed,
    Object? roadAddress = freezed,
    Object? buildingName = freezed,
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
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        roadAddress: freezed == roadAddress
            ? _value.roadAddress
            : roadAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        buildingName: freezed == buildingName
            ? _value.buildingName
            : buildingName // ignore: cast_nullable_to_non_nullable
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
    this.address,
    this.roadAddress,
    this.buildingName,
  });

  factory _$CommunityLocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityLocationModelImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  /// 지번 주소 — `서울 광진구 군자동 98`
  @override
  final String? address;

  /// 도로명 주소 — `서울특별시 광진구 능동로 209`. 도로명이 없는 지역이면 null.
  @override
  final String? roadAddress;

  /// 건물명 — `세종대학교`. 공터·공원·길 위 좌표면 null.
  @override
  final String? buildingName;

  @override
  String toString() {
    return 'CommunityLocationModel(latitude: $latitude, longitude: $longitude, address: $address, roadAddress: $roadAddress, buildingName: $buildingName)';
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
            (identical(other.address, address) || other.address == address) &&
            (identical(other.roadAddress, roadAddress) ||
                other.roadAddress == roadAddress) &&
            (identical(other.buildingName, buildingName) ||
                other.buildingName == buildingName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    latitude,
    longitude,
    address,
    roadAddress,
    buildingName,
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
    final String? address,
    final String? roadAddress,
    final String? buildingName,
  }) = _$CommunityLocationModelImpl;

  factory _CommunityLocationModel.fromJson(Map<String, dynamic> json) =
      _$CommunityLocationModelImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// 지번 주소 — `서울 광진구 군자동 98`
  @override
  String? get address;

  /// 도로명 주소 — `서울특별시 광진구 능동로 209`. 도로명이 없는 지역이면 null.
  @override
  String? get roadAddress;

  /// 건물명 — `세종대학교`. 공터·공원·길 위 좌표면 null.
  @override
  String? get buildingName;

  /// Create a copy of CommunityLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityLocationModelImplCopyWith<_$CommunityLocationModelImpl>
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
