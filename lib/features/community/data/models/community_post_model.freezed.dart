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

  /// 사람이 읽는 주소. 백엔드 추가 예정이라 지금은 항상 null이다.
  /// 클라이언트 역지오코딩을 하지 않는 이유는 설계 문서 1절 참고.
  String? get address => throw _privateConstructorUsedError;

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
  $Res call({double latitude, double longitude, String? address});
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
  $Res call({double latitude, double longitude, String? address});
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
  });

  factory _$CommunityLocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityLocationModelImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  /// 사람이 읽는 주소. 백엔드 추가 예정이라 지금은 항상 null이다.
  /// 클라이언트 역지오코딩을 하지 않는 이유는 설계 문서 1절 참고.
  @override
  final String? address;

  @override
  String toString() {
    return 'CommunityLocationModel(latitude: $latitude, longitude: $longitude, address: $address)';
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
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, address);

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
  }) = _$CommunityLocationModelImpl;

  factory _CommunityLocationModel.fromJson(Map<String, dynamic> json) =
      _$CommunityLocationModelImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// 사람이 읽는 주소. 백엔드 추가 예정이라 지금은 항상 null이다.
  /// 클라이언트 역지오코딩을 하지 않는 이유는 설계 문서 1절 참고.
  @override
  String? get address;

  /// Create a copy of CommunityLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityLocationModelImplCopyWith<_$CommunityLocationModelImpl>
  get copyWith => throw _privateConstructorUsedError;
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
  DateTime get createdAt =>
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
  // ── 백엔드 추가 예정 ──
  @override
  final int? currentParticipants;
  @override
  final int? likeCount;
  @override
  final int? bookmarkCount;

  @override
  String toString() {
    return 'CommunityPostResponseModel(id: $id, writerId: $writerId, title: $title, content: $content, meetingAt: $meetingAt, location: $location, maxParticipants: $maxParticipants, status: $status, createdAt: $createdAt, currentParticipants: $currentParticipants, likeCount: $likeCount, bookmarkCount: $bookmarkCount)';
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
  DateTime get createdAt; // ── 백엔드 추가 예정 ──
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
  PageInfoModel get page => throw _privateConstructorUsedError;

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
  $Res call({List<CommunityPostResponseModel> content, PageInfoModel page});

  $PageInfoModelCopyWith<$Res> get page;
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
  $Res call({Object? content = null, Object? page = null}) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as List<CommunityPostResponseModel>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as PageInfoModel,
          )
          as $Val,
    );
  }

  /// Create a copy of CommunityPostListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PageInfoModelCopyWith<$Res> get page {
    return $PageInfoModelCopyWith<$Res>(_value.page, (value) {
      return _then(_value.copyWith(page: value) as $Val);
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
  $Res call({List<CommunityPostResponseModel> content, PageInfoModel page});

  @override
  $PageInfoModelCopyWith<$Res> get page;
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
  $Res call({Object? content = null, Object? page = null}) {
    return _then(
      _$CommunityPostListResponseModelImpl(
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as List<CommunityPostResponseModel>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as PageInfoModel,
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
    required this.page,
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
  final PageInfoModel page;

  @override
  String toString() {
    return 'CommunityPostListResponseModel(content: $content, page: $page)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostListResponseModelImpl &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.page, page) || other.page == page));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_content),
    page,
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
    required final PageInfoModel page,
  }) = _$CommunityPostListResponseModelImpl;

  factory _CommunityPostListResponseModel.fromJson(Map<String, dynamic> json) =
      _$CommunityPostListResponseModelImpl.fromJson;

  @override
  List<CommunityPostResponseModel> get content;
  @override
  PageInfoModel get page;

  /// Create a copy of CommunityPostListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostListResponseModelImplCopyWith<
    _$CommunityPostListResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
