// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_notification_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityNotificationEntity {
  int get id => throw _privateConstructorUsedError;
  CommunityNotificationType get type => throw _privateConstructorUsedError;
  int get communityPostId => throw _privateConstructorUsedError;
  String get postTitle => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  bool get read => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of CommunityNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityNotificationEntityCopyWith<CommunityNotificationEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityNotificationEntityCopyWith<$Res> {
  factory $CommunityNotificationEntityCopyWith(
    CommunityNotificationEntity value,
    $Res Function(CommunityNotificationEntity) then,
  ) =
      _$CommunityNotificationEntityCopyWithImpl<
        $Res,
        CommunityNotificationEntity
      >;
  @useResult
  $Res call({
    int id,
    CommunityNotificationType type,
    int communityPostId,
    String postTitle,
    String content,
    bool read,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CommunityNotificationEntityCopyWithImpl<
  $Res,
  $Val extends CommunityNotificationEntity
>
    implements $CommunityNotificationEntityCopyWith<$Res> {
  _$CommunityNotificationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityNotificationEntity
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
                      as CommunityNotificationType,
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
abstract class _$$CommunityNotificationEntityImplCopyWith<$Res>
    implements $CommunityNotificationEntityCopyWith<$Res> {
  factory _$$CommunityNotificationEntityImplCopyWith(
    _$CommunityNotificationEntityImpl value,
    $Res Function(_$CommunityNotificationEntityImpl) then,
  ) = __$$CommunityNotificationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    CommunityNotificationType type,
    int communityPostId,
    String postTitle,
    String content,
    bool read,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CommunityNotificationEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityNotificationEntityCopyWithImpl<
          $Res,
          _$CommunityNotificationEntityImpl
        >
    implements _$$CommunityNotificationEntityImplCopyWith<$Res> {
  __$$CommunityNotificationEntityImplCopyWithImpl(
    _$CommunityNotificationEntityImpl _value,
    $Res Function(_$CommunityNotificationEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityNotificationEntity
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
      _$CommunityNotificationEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as CommunityNotificationType,
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

class _$CommunityNotificationEntityImpl
    implements _CommunityNotificationEntity {
  const _$CommunityNotificationEntityImpl({
    required this.id,
    required this.type,
    required this.communityPostId,
    required this.postTitle,
    required this.content,
    required this.read,
    required this.createdAt,
  });

  @override
  final int id;
  @override
  final CommunityNotificationType type;
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
    return 'CommunityNotificationEntity(id: $id, type: $type, communityPostId: $communityPostId, postTitle: $postTitle, content: $content, read: $read, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityNotificationEntityImpl &&
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

  /// Create a copy of CommunityNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityNotificationEntityImplCopyWith<_$CommunityNotificationEntityImpl>
  get copyWith =>
      __$$CommunityNotificationEntityImplCopyWithImpl<
        _$CommunityNotificationEntityImpl
      >(this, _$identity);
}

abstract class _CommunityNotificationEntity
    implements CommunityNotificationEntity {
  const factory _CommunityNotificationEntity({
    required final int id,
    required final CommunityNotificationType type,
    required final int communityPostId,
    required final String postTitle,
    required final String content,
    required final bool read,
    required final DateTime createdAt,
  }) = _$CommunityNotificationEntityImpl;

  @override
  int get id;
  @override
  CommunityNotificationType get type;
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

  /// Create a copy of CommunityNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityNotificationEntityImplCopyWith<_$CommunityNotificationEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommunityNotificationPageEntity {
  List<CommunityNotificationEntity> get items =>
      throw _privateConstructorUsedError;
  int? get nextCursor => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;

  /// Create a copy of CommunityNotificationPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityNotificationPageEntityCopyWith<CommunityNotificationPageEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityNotificationPageEntityCopyWith<$Res> {
  factory $CommunityNotificationPageEntityCopyWith(
    CommunityNotificationPageEntity value,
    $Res Function(CommunityNotificationPageEntity) then,
  ) =
      _$CommunityNotificationPageEntityCopyWithImpl<
        $Res,
        CommunityNotificationPageEntity
      >;
  @useResult
  $Res call({
    List<CommunityNotificationEntity> items,
    int? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class _$CommunityNotificationPageEntityCopyWithImpl<
  $Res,
  $Val extends CommunityNotificationPageEntity
>
    implements $CommunityNotificationPageEntityCopyWith<$Res> {
  _$CommunityNotificationPageEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityNotificationPageEntity
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
                      as List<CommunityNotificationEntity>,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$CommunityNotificationPageEntityImplCopyWith<$Res>
    implements $CommunityNotificationPageEntityCopyWith<$Res> {
  factory _$$CommunityNotificationPageEntityImplCopyWith(
    _$CommunityNotificationPageEntityImpl value,
    $Res Function(_$CommunityNotificationPageEntityImpl) then,
  ) = __$$CommunityNotificationPageEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CommunityNotificationEntity> items,
    int? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class __$$CommunityNotificationPageEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityNotificationPageEntityCopyWithImpl<
          $Res,
          _$CommunityNotificationPageEntityImpl
        >
    implements _$$CommunityNotificationPageEntityImplCopyWith<$Res> {
  __$$CommunityNotificationPageEntityImplCopyWithImpl(
    _$CommunityNotificationPageEntityImpl _value,
    $Res Function(_$CommunityNotificationPageEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityNotificationPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasNext = null,
  }) {
    return _then(
      _$CommunityNotificationPageEntityImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CommunityNotificationEntity>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as int?,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CommunityNotificationPageEntityImpl
    implements _CommunityNotificationPageEntity {
  const _$CommunityNotificationPageEntityImpl({
    required final List<CommunityNotificationEntity> items,
    required this.nextCursor,
    required this.hasNext,
  }) : _items = items;

  final List<CommunityNotificationEntity> _items;
  @override
  List<CommunityNotificationEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int? nextCursor;
  @override
  final bool hasNext;

  @override
  String toString() {
    return 'CommunityNotificationPageEntity(items: $items, nextCursor: $nextCursor, hasNext: $hasNext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityNotificationPageEntityImpl &&
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

  /// Create a copy of CommunityNotificationPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityNotificationPageEntityImplCopyWith<
    _$CommunityNotificationPageEntityImpl
  >
  get copyWith =>
      __$$CommunityNotificationPageEntityImplCopyWithImpl<
        _$CommunityNotificationPageEntityImpl
      >(this, _$identity);
}

abstract class _CommunityNotificationPageEntity
    implements CommunityNotificationPageEntity {
  const factory _CommunityNotificationPageEntity({
    required final List<CommunityNotificationEntity> items,
    required final int? nextCursor,
    required final bool hasNext,
  }) = _$CommunityNotificationPageEntityImpl;

  @override
  List<CommunityNotificationEntity> get items;
  @override
  int? get nextCursor;
  @override
  bool get hasNext;

  /// Create a copy of CommunityNotificationPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityNotificationPageEntityImplCopyWith<
    _$CommunityNotificationPageEntityImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
