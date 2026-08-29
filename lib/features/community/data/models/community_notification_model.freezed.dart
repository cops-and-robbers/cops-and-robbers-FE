// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommunityNotificationResponseModel _$CommunityNotificationResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityNotificationResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityNotificationResponseModel {
  int get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get communityPostId => throw _privateConstructorUsedError;
  String get postTitle => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  bool get read => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CommunityNotificationResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityNotificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityNotificationResponseModelCopyWith<
    CommunityNotificationResponseModel
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityNotificationResponseModelCopyWith<$Res> {
  factory $CommunityNotificationResponseModelCopyWith(
    CommunityNotificationResponseModel value,
    $Res Function(CommunityNotificationResponseModel) then,
  ) =
      _$CommunityNotificationResponseModelCopyWithImpl<
        $Res,
        CommunityNotificationResponseModel
      >;
  @useResult
  $Res call({
    int id,
    String type,
    int communityPostId,
    String postTitle,
    String content,
    bool read,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CommunityNotificationResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityNotificationResponseModel
>
    implements $CommunityNotificationResponseModelCopyWith<$Res> {
  _$CommunityNotificationResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityNotificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? communityPostId = null,
    Object? postTitle = null,
    Object? content = null,
    Object? read = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            communityPostId: null == communityPostId
                ? _value.communityPostId
                : communityPostId // ignore: cast_nullable_to_non_nullable
                      as int,
            postTitle: null == postTitle
                ? _value.postTitle
                : postTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            read: null == read
                ? _value.read
                : read // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityNotificationResponseModelImplCopyWith<$Res>
    implements $CommunityNotificationResponseModelCopyWith<$Res> {
  factory _$$CommunityNotificationResponseModelImplCopyWith(
    _$CommunityNotificationResponseModelImpl value,
    $Res Function(_$CommunityNotificationResponseModelImpl) then,
  ) = __$$CommunityNotificationResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String type,
    int communityPostId,
    String postTitle,
    String content,
    bool read,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CommunityNotificationResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityNotificationResponseModelCopyWithImpl<
          $Res,
          _$CommunityNotificationResponseModelImpl
        >
    implements _$$CommunityNotificationResponseModelImplCopyWith<$Res> {
  __$$CommunityNotificationResponseModelImplCopyWithImpl(
    _$CommunityNotificationResponseModelImpl _value,
    $Res Function(_$CommunityNotificationResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityNotificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? communityPostId = null,
    Object? postTitle = null,
    Object? content = null,
    Object? read = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$CommunityNotificationResponseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        communityPostId: null == communityPostId
            ? _value.communityPostId
            : communityPostId // ignore: cast_nullable_to_non_nullable
                  as int,
        postTitle: null == postTitle
            ? _value.postTitle
            : postTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        read: null == read
            ? _value.read
            : read // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityNotificationResponseModelImpl
    implements _CommunityNotificationResponseModel {
  const _$CommunityNotificationResponseModelImpl({
    required this.id,
    required this.type,
    required this.communityPostId,
    required this.postTitle,
    required this.content,
    required this.read,
    required this.createdAt,
  });

  factory _$CommunityNotificationResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityNotificationResponseModelImplFromJson(json);

  @override
  final int id;
  @override
  final String type;
  @override
  final int communityPostId;
  @override
  final String postTitle;
  @override
  final String content;
  @override
  final bool read;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CommunityNotificationResponseModel(id: $id, type: $type, communityPostId: $communityPostId, postTitle: $postTitle, content: $content, read: $read, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityNotificationResponseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.communityPostId, communityPostId) ||
                other.communityPostId == communityPostId) &&
            (identical(other.postTitle, postTitle) ||
                other.postTitle == postTitle) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.read, read) || other.read == read) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    communityPostId,
    postTitle,
    content,
    read,
    createdAt,
  );

  /// Create a copy of CommunityNotificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityNotificationResponseModelImplCopyWith<
    _$CommunityNotificationResponseModelImpl
  >
  get copyWith =>
      __$$CommunityNotificationResponseModelImplCopyWithImpl<
        _$CommunityNotificationResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityNotificationResponseModelImplToJson(this);
  }
}

abstract class _CommunityNotificationResponseModel
    implements CommunityNotificationResponseModel {
  const factory _CommunityNotificationResponseModel({
    required final int id,
    required final String type,
    required final int communityPostId,
    required final String postTitle,
    required final String content,
    required final bool read,
    required final DateTime createdAt,
  }) = _$CommunityNotificationResponseModelImpl;

  factory _CommunityNotificationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityNotificationResponseModelImpl.fromJson;

  @override
  int get id;
  @override
  String get type;
  @override
  int get communityPostId;
  @override
  String get postTitle;
  @override
  String get content;
  @override
  bool get read;
  @override
  DateTime get createdAt;

  /// Create a copy of CommunityNotificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityNotificationResponseModelImplCopyWith<
    _$CommunityNotificationResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityNotificationListResponseModel
_$CommunityNotificationListResponseModelFromJson(Map<String, dynamic> json) {
  return _CommunityNotificationListResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityNotificationListResponseModel {
  List<CommunityNotificationResponseModel> get content =>
      throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  int? get nextCursor => throw _privateConstructorUsedError;

  /// Serializes this CommunityNotificationListResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityNotificationListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityNotificationListResponseModelCopyWith<
    CommunityNotificationListResponseModel
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityNotificationListResponseModelCopyWith<$Res> {
  factory $CommunityNotificationListResponseModelCopyWith(
    CommunityNotificationListResponseModel value,
    $Res Function(CommunityNotificationListResponseModel) then,
  ) =
      _$CommunityNotificationListResponseModelCopyWithImpl<
        $Res,
        CommunityNotificationListResponseModel
      >;
  @useResult
  $Res call({
    List<CommunityNotificationResponseModel> content,
    bool hasNext,
    int? nextCursor,
  });
}

/// @nodoc
class _$CommunityNotificationListResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityNotificationListResponseModel
>
    implements $CommunityNotificationListResponseModelCopyWith<$Res> {
  _$CommunityNotificationListResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityNotificationListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? hasNext = null,
    Object? nextCursor = freezed,
  }) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as List<CommunityNotificationResponseModel>,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityNotificationListResponseModelImplCopyWith<$Res>
    implements $CommunityNotificationListResponseModelCopyWith<$Res> {
  factory _$$CommunityNotificationListResponseModelImplCopyWith(
    _$CommunityNotificationListResponseModelImpl value,
    $Res Function(_$CommunityNotificationListResponseModelImpl) then,
  ) = __$$CommunityNotificationListResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CommunityNotificationResponseModel> content,
    bool hasNext,
    int? nextCursor,
  });
}

/// @nodoc
class __$$CommunityNotificationListResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityNotificationListResponseModelCopyWithImpl<
          $Res,
          _$CommunityNotificationListResponseModelImpl
        >
    implements _$$CommunityNotificationListResponseModelImplCopyWith<$Res> {
  __$$CommunityNotificationListResponseModelImplCopyWithImpl(
    _$CommunityNotificationListResponseModelImpl _value,
    $Res Function(_$CommunityNotificationListResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityNotificationListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? hasNext = null,
    Object? nextCursor = freezed,
  }) {
    return _then(
      _$CommunityNotificationListResponseModelImpl(
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as List<CommunityNotificationResponseModel>,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityNotificationListResponseModelImpl
    implements _CommunityNotificationListResponseModel {
  const _$CommunityNotificationListResponseModelImpl({
    required final List<CommunityNotificationResponseModel> content,
    required this.hasNext,
    this.nextCursor,
  }) : _content = content;

  factory _$CommunityNotificationListResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityNotificationListResponseModelImplFromJson(json);

  final List<CommunityNotificationResponseModel> _content;
  @override
  List<CommunityNotificationResponseModel> get content {
    if (_content is EqualUnmodifiableListView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_content);
  }

  @override
  final bool hasNext;
  @override
  final int? nextCursor;

  @override
  String toString() {
    return 'CommunityNotificationListResponseModel(content: $content, hasNext: $hasNext, nextCursor: $nextCursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityNotificationListResponseModelImpl &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_content),
    hasNext,
    nextCursor,
  );

  /// Create a copy of CommunityNotificationListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityNotificationListResponseModelImplCopyWith<
    _$CommunityNotificationListResponseModelImpl
  >
  get copyWith =>
      __$$CommunityNotificationListResponseModelImplCopyWithImpl<
        _$CommunityNotificationListResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityNotificationListResponseModelImplToJson(this);
  }
}

abstract class _CommunityNotificationListResponseModel
    implements CommunityNotificationListResponseModel {
  const factory _CommunityNotificationListResponseModel({
    required final List<CommunityNotificationResponseModel> content,
    required final bool hasNext,
    final int? nextCursor,
  }) = _$CommunityNotificationListResponseModelImpl;

  factory _CommunityNotificationListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityNotificationListResponseModelImpl.fromJson;

  @override
  List<CommunityNotificationResponseModel> get content;
  @override
  bool get hasNext;
  @override
  int? get nextCursor;

  /// Create a copy of CommunityNotificationListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityNotificationListResponseModelImplCopyWith<
    _$CommunityNotificationListResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityNotificationUnreadCountResponseModel
_$CommunityNotificationUnreadCountResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityNotificationUnreadCountResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityNotificationUnreadCountResponseModel {
  int get unreadCount => throw _privateConstructorUsedError;

  /// Serializes this CommunityNotificationUnreadCountResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityNotificationUnreadCountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityNotificationUnreadCountResponseModelCopyWith<
    CommunityNotificationUnreadCountResponseModel
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityNotificationUnreadCountResponseModelCopyWith<$Res> {
  factory $CommunityNotificationUnreadCountResponseModelCopyWith(
    CommunityNotificationUnreadCountResponseModel value,
    $Res Function(CommunityNotificationUnreadCountResponseModel) then,
  ) =
      _$CommunityNotificationUnreadCountResponseModelCopyWithImpl<
        $Res,
        CommunityNotificationUnreadCountResponseModel
      >;
  @useResult
  $Res call({int unreadCount});
}

/// @nodoc
class _$CommunityNotificationUnreadCountResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityNotificationUnreadCountResponseModel
>
    implements $CommunityNotificationUnreadCountResponseModelCopyWith<$Res> {
  _$CommunityNotificationUnreadCountResponseModelCopyWithImpl(
    this._value,
    this._then,
  );

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityNotificationUnreadCountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? unreadCount = null}) {
    return _then(
      _value.copyWith(
            unreadCount: null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityNotificationUnreadCountResponseModelImplCopyWith<
  $Res
>
    implements $CommunityNotificationUnreadCountResponseModelCopyWith<$Res> {
  factory _$$CommunityNotificationUnreadCountResponseModelImplCopyWith(
    _$CommunityNotificationUnreadCountResponseModelImpl value,
    $Res Function(_$CommunityNotificationUnreadCountResponseModelImpl) then,
  ) = __$$CommunityNotificationUnreadCountResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int unreadCount});
}

/// @nodoc
class __$$CommunityNotificationUnreadCountResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityNotificationUnreadCountResponseModelCopyWithImpl<
          $Res,
          _$CommunityNotificationUnreadCountResponseModelImpl
        >
    implements
        _$$CommunityNotificationUnreadCountResponseModelImplCopyWith<$Res> {
  __$$CommunityNotificationUnreadCountResponseModelImplCopyWithImpl(
    _$CommunityNotificationUnreadCountResponseModelImpl _value,
    $Res Function(_$CommunityNotificationUnreadCountResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityNotificationUnreadCountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? unreadCount = null}) {
    return _then(
      _$CommunityNotificationUnreadCountResponseModelImpl(
        unreadCount: null == unreadCount
            ? _value.unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityNotificationUnreadCountResponseModelImpl
    implements _CommunityNotificationUnreadCountResponseModel {
  const _$CommunityNotificationUnreadCountResponseModelImpl({
    required this.unreadCount,
  });

  factory _$CommunityNotificationUnreadCountResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityNotificationUnreadCountResponseModelImplFromJson(json);

  @override
  final int unreadCount;

  @override
  String toString() {
    return 'CommunityNotificationUnreadCountResponseModel(unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityNotificationUnreadCountResponseModelImpl &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, unreadCount);

  /// Create a copy of CommunityNotificationUnreadCountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityNotificationUnreadCountResponseModelImplCopyWith<
    _$CommunityNotificationUnreadCountResponseModelImpl
  >
  get copyWith =>
      __$$CommunityNotificationUnreadCountResponseModelImplCopyWithImpl<
        _$CommunityNotificationUnreadCountResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityNotificationUnreadCountResponseModelImplToJson(this);
  }
}

abstract class _CommunityNotificationUnreadCountResponseModel
    implements CommunityNotificationUnreadCountResponseModel {
  const factory _CommunityNotificationUnreadCountResponseModel({
    required final int unreadCount,
  }) = _$CommunityNotificationUnreadCountResponseModelImpl;

  factory _CommunityNotificationUnreadCountResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityNotificationUnreadCountResponseModelImpl.fromJson;

  @override
  int get unreadCount;

  /// Create a copy of CommunityNotificationUnreadCountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityNotificationUnreadCountResponseModelImplCopyWith<
    _$CommunityNotificationUnreadCountResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
