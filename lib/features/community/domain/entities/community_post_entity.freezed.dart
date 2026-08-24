// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_post_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityPostEntity {
  int get id => throw _privateConstructorUsedError;
  int get writerId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get meetingAt => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  CommunityPostStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 작성자가 입력한 만나는 곳 — `어린이대공원 정문`.
  ///
  /// [region]과 병기한다(DEC-0015): 좌표로는 건물명을 신뢰할 수준으로 얻을 수
  /// 없어 장소명은 작성자에게 받고, 서버 주소는 그 옆에 보조로 붙인다.
  /// 둘 다 null이면 화면이 장소 행 자체를 그리지 않는다 — 좌표는 사용자에게
  /// 무의미하다.
  String? get placeName => throw _privateConstructorUsedError;

  /// 서버가 좌표를 역지오코딩한 동 단위 지역 — `서울특별시 광진구 군자동`.
  /// 역지오코딩이 실패하면 null이다.
  String? get region => throw _privateConstructorUsedError;

  /// 번지까지 붙은 지번 주소 — `서울특별시 광진구 화양동 164-2`.
  ///
  /// 화면에 그리지 않고 복사에만 쓴다([locationLabel] 참고).
  /// 역지오코딩이 실패한 글은 null이다.
  String? get address => throw _privateConstructorUsedError;

  /// 현재 참여 인원. 백엔드 추가 예정. null이면 정원만 표시한다 —
  /// "0/10명"은 아무도 안 모인 것으로 오독된다.
  int? get currentParticipants => throw _privateConstructorUsedError;

  /// 좋아요 수. 백엔드 추가 예정. null이면 0으로 표시한다.
  int? get likeCount => throw _privateConstructorUsedError;

  /// 스크랩 수. 백엔드 추가 예정. null이면 0으로 표시한다.
  int? get bookmarkCount => throw _privateConstructorUsedError;

  /// 내가 이 글의 채팅방 멤버인가. BE 이슈로 요청한 필드 — 서버가 아직 안 주면
  /// false이고, 그때는 항상 join을 보내 409면 입장한다.
  bool get chatJoined => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPostEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostEntityCopyWith<CommunityPostEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostEntityCopyWith<$Res> {
  factory $CommunityPostEntityCopyWith(
    CommunityPostEntity value,
    $Res Function(CommunityPostEntity) then,
  ) = _$CommunityPostEntityCopyWithImpl<$Res, CommunityPostEntity>;
  @useResult
  $Res call({
    int id,
    int writerId,
    String title,
    String content,
    DateTime meetingAt,
    double latitude,
    double longitude,
    int maxParticipants,
    CommunityPostStatus status,
    DateTime createdAt,
    String? placeName,
    String? region,
    String? address,
    int? currentParticipants,
    int? likeCount,
    int? bookmarkCount,
    bool chatJoined,
  });
}

/// @nodoc
class _$CommunityPostEntityCopyWithImpl<$Res, $Val extends CommunityPostEntity>
    implements $CommunityPostEntityCopyWith<$Res> {
  _$CommunityPostEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPostEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? writerId = null,
    Object? title = null,
    Object? content = null,
    Object? meetingAt = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? maxParticipants = null,
    Object? status = null,
    Object? createdAt = null,
    Object? placeName = freezed,
    Object? region = freezed,
    Object? address = freezed,
    Object? currentParticipants = freezed,
    Object? likeCount = freezed,
    Object? bookmarkCount = freezed,
    Object? chatJoined = null,
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
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            maxParticipants: null == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CommunityPostStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            placeName: freezed == placeName
                ? _value.placeName
                : placeName // ignore: cast_nullable_to_non_nullable
                      as String?,
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
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
            chatJoined: null == chatJoined
                ? _value.chatJoined
                : chatJoined // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityPostEntityImplCopyWith<$Res>
    implements $CommunityPostEntityCopyWith<$Res> {
  factory _$$CommunityPostEntityImplCopyWith(
    _$CommunityPostEntityImpl value,
    $Res Function(_$CommunityPostEntityImpl) then,
  ) = __$$CommunityPostEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int writerId,
    String title,
    String content,
    DateTime meetingAt,
    double latitude,
    double longitude,
    int maxParticipants,
    CommunityPostStatus status,
    DateTime createdAt,
    String? placeName,
    String? region,
    String? address,
    int? currentParticipants,
    int? likeCount,
    int? bookmarkCount,
    bool chatJoined,
  });
}

/// @nodoc
class __$$CommunityPostEntityImplCopyWithImpl<$Res>
    extends _$CommunityPostEntityCopyWithImpl<$Res, _$CommunityPostEntityImpl>
    implements _$$CommunityPostEntityImplCopyWith<$Res> {
  __$$CommunityPostEntityImplCopyWithImpl(
    _$CommunityPostEntityImpl _value,
    $Res Function(_$CommunityPostEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPostEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? writerId = null,
    Object? title = null,
    Object? content = null,
    Object? meetingAt = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? maxParticipants = null,
    Object? status = null,
    Object? createdAt = null,
    Object? placeName = freezed,
    Object? region = freezed,
    Object? address = freezed,
    Object? currentParticipants = freezed,
    Object? likeCount = freezed,
    Object? bookmarkCount = freezed,
    Object? chatJoined = null,
  }) {
    return _then(
      _$CommunityPostEntityImpl(
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
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        maxParticipants: null == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CommunityPostStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        placeName: freezed == placeName
            ? _value.placeName
            : placeName // ignore: cast_nullable_to_non_nullable
                  as String?,
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
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
        chatJoined: null == chatJoined
            ? _value.chatJoined
            : chatJoined // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CommunityPostEntityImpl extends _CommunityPostEntity {
  const _$CommunityPostEntityImpl({
    required this.id,
    required this.writerId,
    required this.title,
    required this.content,
    required this.meetingAt,
    required this.latitude,
    required this.longitude,
    required this.maxParticipants,
    required this.status,
    required this.createdAt,
    this.placeName,
    this.region,
    this.address,
    this.currentParticipants,
    this.likeCount,
    this.bookmarkCount,
    this.chatJoined = false,
  }) : super._();

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
  final double latitude;
  @override
  final double longitude;
  @override
  final int maxParticipants;
  @override
  final CommunityPostStatus status;
  @override
  final DateTime createdAt;

  /// 작성자가 입력한 만나는 곳 — `어린이대공원 정문`.
  ///
  /// [region]과 병기한다(DEC-0015): 좌표로는 건물명을 신뢰할 수준으로 얻을 수
  /// 없어 장소명은 작성자에게 받고, 서버 주소는 그 옆에 보조로 붙인다.
  /// 둘 다 null이면 화면이 장소 행 자체를 그리지 않는다 — 좌표는 사용자에게
  /// 무의미하다.
  @override
  final String? placeName;

  /// 서버가 좌표를 역지오코딩한 동 단위 지역 — `서울특별시 광진구 군자동`.
  /// 역지오코딩이 실패하면 null이다.
  @override
  final String? region;

  /// 번지까지 붙은 지번 주소 — `서울특별시 광진구 화양동 164-2`.
  ///
  /// 화면에 그리지 않고 복사에만 쓴다([locationLabel] 참고).
  /// 역지오코딩이 실패한 글은 null이다.
  @override
  final String? address;

  /// 현재 참여 인원. 백엔드 추가 예정. null이면 정원만 표시한다 —
  /// "0/10명"은 아무도 안 모인 것으로 오독된다.
  @override
  final int? currentParticipants;

  /// 좋아요 수. 백엔드 추가 예정. null이면 0으로 표시한다.
  @override
  final int? likeCount;

  /// 스크랩 수. 백엔드 추가 예정. null이면 0으로 표시한다.
  @override
  final int? bookmarkCount;

  /// 내가 이 글의 채팅방 멤버인가. BE 이슈로 요청한 필드 — 서버가 아직 안 주면
  /// false이고, 그때는 항상 join을 보내 409면 입장한다.
  @override
  @JsonKey()
  final bool chatJoined;

  @override
  String toString() {
    return 'CommunityPostEntity(id: $id, writerId: $writerId, title: $title, content: $content, meetingAt: $meetingAt, latitude: $latitude, longitude: $longitude, maxParticipants: $maxParticipants, status: $status, createdAt: $createdAt, placeName: $placeName, region: $region, address: $address, currentParticipants: $currentParticipants, likeCount: $likeCount, bookmarkCount: $bookmarkCount, chatJoined: $chatJoined)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.writerId, writerId) ||
                other.writerId == writerId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.meetingAt, meetingAt) ||
                other.meetingAt == meetingAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.currentParticipants, currentParticipants) ||
                other.currentParticipants == currentParticipants) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount) &&
            (identical(other.chatJoined, chatJoined) ||
                other.chatJoined == chatJoined));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    writerId,
    title,
    content,
    meetingAt,
    latitude,
    longitude,
    maxParticipants,
    status,
    createdAt,
    placeName,
    region,
    address,
    currentParticipants,
    likeCount,
    bookmarkCount,
    chatJoined,
  );

  /// Create a copy of CommunityPostEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostEntityImplCopyWith<_$CommunityPostEntityImpl> get copyWith =>
      __$$CommunityPostEntityImplCopyWithImpl<_$CommunityPostEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _CommunityPostEntity extends CommunityPostEntity {
  const factory _CommunityPostEntity({
    required final int id,
    required final int writerId,
    required final String title,
    required final String content,
    required final DateTime meetingAt,
    required final double latitude,
    required final double longitude,
    required final int maxParticipants,
    required final CommunityPostStatus status,
    required final DateTime createdAt,
    final String? placeName,
    final String? region,
    final String? address,
    final int? currentParticipants,
    final int? likeCount,
    final int? bookmarkCount,
    final bool chatJoined,
  }) = _$CommunityPostEntityImpl;
  const _CommunityPostEntity._() : super._();

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
  double get latitude;
  @override
  double get longitude;
  @override
  int get maxParticipants;
  @override
  CommunityPostStatus get status;
  @override
  DateTime get createdAt;

  /// 작성자가 입력한 만나는 곳 — `어린이대공원 정문`.
  ///
  /// [region]과 병기한다(DEC-0015): 좌표로는 건물명을 신뢰할 수준으로 얻을 수
  /// 없어 장소명은 작성자에게 받고, 서버 주소는 그 옆에 보조로 붙인다.
  /// 둘 다 null이면 화면이 장소 행 자체를 그리지 않는다 — 좌표는 사용자에게
  /// 무의미하다.
  @override
  String? get placeName;

  /// 서버가 좌표를 역지오코딩한 동 단위 지역 — `서울특별시 광진구 군자동`.
  /// 역지오코딩이 실패하면 null이다.
  @override
  String? get region;

  /// 번지까지 붙은 지번 주소 — `서울특별시 광진구 화양동 164-2`.
  ///
  /// 화면에 그리지 않고 복사에만 쓴다([locationLabel] 참고).
  /// 역지오코딩이 실패한 글은 null이다.
  @override
  String? get address;

  /// 현재 참여 인원. 백엔드 추가 예정. null이면 정원만 표시한다 —
  /// "0/10명"은 아무도 안 모인 것으로 오독된다.
  @override
  int? get currentParticipants;

  /// 좋아요 수. 백엔드 추가 예정. null이면 0으로 표시한다.
  @override
  int? get likeCount;

  /// 스크랩 수. 백엔드 추가 예정. null이면 0으로 표시한다.
  @override
  int? get bookmarkCount;

  /// 내가 이 글의 채팅방 멤버인가. BE 이슈로 요청한 필드 — 서버가 아직 안 주면
  /// false이고, 그때는 항상 join을 보내 409면 입장한다.
  @override
  bool get chatJoined;

  /// Create a copy of CommunityPostEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostEntityImplCopyWith<_$CommunityPostEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommunityPostPageEntity {
  List<CommunityPostEntity> get items => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPostPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostPageEntityCopyWith<CommunityPostPageEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostPageEntityCopyWith<$Res> {
  factory $CommunityPostPageEntityCopyWith(
    CommunityPostPageEntity value,
    $Res Function(CommunityPostPageEntity) then,
  ) = _$CommunityPostPageEntityCopyWithImpl<$Res, CommunityPostPageEntity>;
  @useResult
  $Res call({
    List<CommunityPostEntity> items,
    String? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class _$CommunityPostPageEntityCopyWithImpl<
  $Res,
  $Val extends CommunityPostPageEntity
>
    implements $CommunityPostPageEntityCopyWith<$Res> {
  _$CommunityPostPageEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPostPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasNext = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<CommunityPostEntity>,
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
abstract class _$$CommunityPostPageEntityImplCopyWith<$Res>
    implements $CommunityPostPageEntityCopyWith<$Res> {
  factory _$$CommunityPostPageEntityImplCopyWith(
    _$CommunityPostPageEntityImpl value,
    $Res Function(_$CommunityPostPageEntityImpl) then,
  ) = __$$CommunityPostPageEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CommunityPostEntity> items,
    String? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class __$$CommunityPostPageEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityPostPageEntityCopyWithImpl<
          $Res,
          _$CommunityPostPageEntityImpl
        >
    implements _$$CommunityPostPageEntityImplCopyWith<$Res> {
  __$$CommunityPostPageEntityImplCopyWithImpl(
    _$CommunityPostPageEntityImpl _value,
    $Res Function(_$CommunityPostPageEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPostPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasNext = null,
  }) {
    return _then(
      _$CommunityPostPageEntityImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CommunityPostEntity>,
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

class _$CommunityPostPageEntityImpl implements _CommunityPostPageEntity {
  const _$CommunityPostPageEntityImpl({
    required final List<CommunityPostEntity> items,
    required this.nextCursor,
    required this.hasNext,
  }) : _items = items;

  final List<CommunityPostEntity> _items;
  @override
  List<CommunityPostEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? nextCursor;
  @override
  final bool hasNext;

  @override
  String toString() {
    return 'CommunityPostPageEntity(items: $items, nextCursor: $nextCursor, hasNext: $hasNext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostPageEntityImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    nextCursor,
    hasNext,
  );

  /// Create a copy of CommunityPostPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostPageEntityImplCopyWith<_$CommunityPostPageEntityImpl>
  get copyWith =>
      __$$CommunityPostPageEntityImplCopyWithImpl<
        _$CommunityPostPageEntityImpl
      >(this, _$identity);
}

abstract class _CommunityPostPageEntity implements CommunityPostPageEntity {
  const factory _CommunityPostPageEntity({
    required final List<CommunityPostEntity> items,
    required final String? nextCursor,
    required final bool hasNext,
  }) = _$CommunityPostPageEntityImpl;

  @override
  List<CommunityPostEntity> get items;
  @override
  String? get nextCursor;
  @override
  bool get hasNext;

  /// Create a copy of CommunityPostPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostPageEntityImplCopyWith<_$CommunityPostPageEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
