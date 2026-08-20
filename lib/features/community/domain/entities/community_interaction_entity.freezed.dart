// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_interaction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityInteractionEntity {
  bool get isLiked => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;
  int get bookmarkCount => throw _privateConstructorUsedError;

  /// 현재 참여 인원. 모르면 null — 화면이 정원만 표시한다.
  int? get currentParticipants => throw _privateConstructorUsedError;

  /// Create a copy of CommunityInteractionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityInteractionEntityCopyWith<CommunityInteractionEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityInteractionEntityCopyWith<$Res> {
  factory $CommunityInteractionEntityCopyWith(
    CommunityInteractionEntity value,
    $Res Function(CommunityInteractionEntity) then,
  ) =
      _$CommunityInteractionEntityCopyWithImpl<
        $Res,
        CommunityInteractionEntity
      >;
  @useResult
  $Res call({
    bool isLiked,
    int likeCount,
    bool isBookmarked,
    int bookmarkCount,
    int? currentParticipants,
  });
}

/// @nodoc
class _$CommunityInteractionEntityCopyWithImpl<
  $Res,
  $Val extends CommunityInteractionEntity
>
    implements $CommunityInteractionEntityCopyWith<$Res> {
  _$CommunityInteractionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityInteractionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLiked = null,
    Object? likeCount = null,
    Object? isBookmarked = null,
    Object? bookmarkCount = null,
    Object? currentParticipants = freezed,
  }) {
    return _then(
      _value.copyWith(
            isLiked: null == isLiked
                ? _value.isLiked
                : isLiked // ignore: cast_nullable_to_non_nullable
                      as bool,
            likeCount: null == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isBookmarked: null == isBookmarked
                ? _value.isBookmarked
                : isBookmarked // ignore: cast_nullable_to_non_nullable
                      as bool,
            bookmarkCount: null == bookmarkCount
                ? _value.bookmarkCount
                : bookmarkCount // ignore: cast_nullable_to_non_nullable
                      as int,
            currentParticipants: freezed == currentParticipants
                ? _value.currentParticipants
                : currentParticipants // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityInteractionEntityImplCopyWith<$Res>
    implements $CommunityInteractionEntityCopyWith<$Res> {
  factory _$$CommunityInteractionEntityImplCopyWith(
    _$CommunityInteractionEntityImpl value,
    $Res Function(_$CommunityInteractionEntityImpl) then,
  ) = __$$CommunityInteractionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLiked,
    int likeCount,
    bool isBookmarked,
    int bookmarkCount,
    int? currentParticipants,
  });
}

/// @nodoc
class __$$CommunityInteractionEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityInteractionEntityCopyWithImpl<
          $Res,
          _$CommunityInteractionEntityImpl
        >
    implements _$$CommunityInteractionEntityImplCopyWith<$Res> {
  __$$CommunityInteractionEntityImplCopyWithImpl(
    _$CommunityInteractionEntityImpl _value,
    $Res Function(_$CommunityInteractionEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityInteractionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLiked = null,
    Object? likeCount = null,
    Object? isBookmarked = null,
    Object? bookmarkCount = null,
    Object? currentParticipants = freezed,
  }) {
    return _then(
      _$CommunityInteractionEntityImpl(
        isLiked: null == isLiked
            ? _value.isLiked
            : isLiked // ignore: cast_nullable_to_non_nullable
                  as bool,
        likeCount: null == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isBookmarked: null == isBookmarked
            ? _value.isBookmarked
            : isBookmarked // ignore: cast_nullable_to_non_nullable
                  as bool,
        bookmarkCount: null == bookmarkCount
            ? _value.bookmarkCount
            : bookmarkCount // ignore: cast_nullable_to_non_nullable
                  as int,
        currentParticipants: freezed == currentParticipants
            ? _value.currentParticipants
            : currentParticipants // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$CommunityInteractionEntityImpl implements _CommunityInteractionEntity {
  const _$CommunityInteractionEntityImpl({
    required this.isLiked,
    required this.likeCount,
    required this.isBookmarked,
    required this.bookmarkCount,
    this.currentParticipants,
  });

  @override
  final bool isLiked;
  @override
  final int likeCount;
  @override
  final bool isBookmarked;
  @override
  final int bookmarkCount;

  /// 현재 참여 인원. 모르면 null — 화면이 정원만 표시한다.
  @override
  final int? currentParticipants;

  @override
  String toString() {
    return 'CommunityInteractionEntity(isLiked: $isLiked, likeCount: $likeCount, isBookmarked: $isBookmarked, bookmarkCount: $bookmarkCount, currentParticipants: $currentParticipants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityInteractionEntityImpl &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount) &&
            (identical(other.currentParticipants, currentParticipants) ||
                other.currentParticipants == currentParticipants));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLiked,
    likeCount,
    isBookmarked,
    bookmarkCount,
    currentParticipants,
  );

  /// Create a copy of CommunityInteractionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityInteractionEntityImplCopyWith<_$CommunityInteractionEntityImpl>
  get copyWith =>
      __$$CommunityInteractionEntityImplCopyWithImpl<
        _$CommunityInteractionEntityImpl
      >(this, _$identity);
}

abstract class _CommunityInteractionEntity
    implements CommunityInteractionEntity {
  const factory _CommunityInteractionEntity({
    required final bool isLiked,
    required final int likeCount,
    required final bool isBookmarked,
    required final int bookmarkCount,
    final int? currentParticipants,
  }) = _$CommunityInteractionEntityImpl;

  @override
  bool get isLiked;
  @override
  int get likeCount;
  @override
  bool get isBookmarked;
  @override
  int get bookmarkCount;

  /// 현재 참여 인원. 모르면 null — 화면이 정원만 표시한다.
  @override
  int? get currentParticipants;

  /// Create a copy of CommunityInteractionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityInteractionEntityImplCopyWith<_$CommunityInteractionEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommunityCommentEntity {
  int get id => throw _privateConstructorUsedError;
  int get writerId => throw _privateConstructorUsedError;
  String get writerNickname => throw _privateConstructorUsedError;
  int get writerProfileIconId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<CommunityCommentEntity> get replies =>
      throw _privateConstructorUsedError;

  /// Create a copy of CommunityCommentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityCommentEntityCopyWith<CommunityCommentEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityCommentEntityCopyWith<$Res> {
  factory $CommunityCommentEntityCopyWith(
    CommunityCommentEntity value,
    $Res Function(CommunityCommentEntity) then,
  ) = _$CommunityCommentEntityCopyWithImpl<$Res, CommunityCommentEntity>;
  @useResult
  $Res call({
    int id,
    int writerId,
    String writerNickname,
    int writerProfileIconId,
    String content,
    DateTime createdAt,
    List<CommunityCommentEntity> replies,
  });
}

/// @nodoc
class _$CommunityCommentEntityCopyWithImpl<
  $Res,
  $Val extends CommunityCommentEntity
>
    implements $CommunityCommentEntityCopyWith<$Res> {
  _$CommunityCommentEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityCommentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? writerId = null,
    Object? writerNickname = null,
    Object? writerProfileIconId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? replies = null,
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
            writerNickname: null == writerNickname
                ? _value.writerNickname
                : writerNickname // ignore: cast_nullable_to_non_nullable
                      as String,
            writerProfileIconId: null == writerProfileIconId
                ? _value.writerProfileIconId
                : writerProfileIconId // ignore: cast_nullable_to_non_nullable
                      as int,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            replies: null == replies
                ? _value.replies
                : replies // ignore: cast_nullable_to_non_nullable
                      as List<CommunityCommentEntity>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityCommentEntityImplCopyWith<$Res>
    implements $CommunityCommentEntityCopyWith<$Res> {
  factory _$$CommunityCommentEntityImplCopyWith(
    _$CommunityCommentEntityImpl value,
    $Res Function(_$CommunityCommentEntityImpl) then,
  ) = __$$CommunityCommentEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int writerId,
    String writerNickname,
    int writerProfileIconId,
    String content,
    DateTime createdAt,
    List<CommunityCommentEntity> replies,
  });
}

/// @nodoc
class __$$CommunityCommentEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityCommentEntityCopyWithImpl<$Res, _$CommunityCommentEntityImpl>
    implements _$$CommunityCommentEntityImplCopyWith<$Res> {
  __$$CommunityCommentEntityImplCopyWithImpl(
    _$CommunityCommentEntityImpl _value,
    $Res Function(_$CommunityCommentEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityCommentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? writerId = null,
    Object? writerNickname = null,
    Object? writerProfileIconId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? replies = null,
  }) {
    return _then(
      _$CommunityCommentEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        writerId: null == writerId
            ? _value.writerId
            : writerId // ignore: cast_nullable_to_non_nullable
                  as int,
        writerNickname: null == writerNickname
            ? _value.writerNickname
            : writerNickname // ignore: cast_nullable_to_non_nullable
                  as String,
        writerProfileIconId: null == writerProfileIconId
            ? _value.writerProfileIconId
            : writerProfileIconId // ignore: cast_nullable_to_non_nullable
                  as int,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        replies: null == replies
            ? _value._replies
            : replies // ignore: cast_nullable_to_non_nullable
                  as List<CommunityCommentEntity>,
      ),
    );
  }
}

/// @nodoc

class _$CommunityCommentEntityImpl implements _CommunityCommentEntity {
  const _$CommunityCommentEntityImpl({
    required this.id,
    required this.writerId,
    required this.writerNickname,
    required this.writerProfileIconId,
    required this.content,
    required this.createdAt,
    final List<CommunityCommentEntity> replies = const [],
  }) : _replies = replies;

  @override
  final int id;
  @override
  final int writerId;
  @override
  final String writerNickname;
  @override
  final int writerProfileIconId;
  @override
  final String content;
  @override
  final DateTime createdAt;
  final List<CommunityCommentEntity> _replies;
  @override
  @JsonKey()
  List<CommunityCommentEntity> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  @override
  String toString() {
    return 'CommunityCommentEntity(id: $id, writerId: $writerId, writerNickname: $writerNickname, writerProfileIconId: $writerProfileIconId, content: $content, createdAt: $createdAt, replies: $replies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityCommentEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.writerId, writerId) ||
                other.writerId == writerId) &&
            (identical(other.writerNickname, writerNickname) ||
                other.writerNickname == writerNickname) &&
            (identical(other.writerProfileIconId, writerProfileIconId) ||
                other.writerProfileIconId == writerProfileIconId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._replies, _replies));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    writerId,
    writerNickname,
    writerProfileIconId,
    content,
    createdAt,
    const DeepCollectionEquality().hash(_replies),
  );

  /// Create a copy of CommunityCommentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityCommentEntityImplCopyWith<_$CommunityCommentEntityImpl>
  get copyWith =>
      __$$CommunityCommentEntityImplCopyWithImpl<_$CommunityCommentEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _CommunityCommentEntity implements CommunityCommentEntity {
  const factory _CommunityCommentEntity({
    required final int id,
    required final int writerId,
    required final String writerNickname,
    required final int writerProfileIconId,
    required final String content,
    required final DateTime createdAt,
    final List<CommunityCommentEntity> replies,
  }) = _$CommunityCommentEntityImpl;

  @override
  int get id;
  @override
  int get writerId;
  @override
  String get writerNickname;
  @override
  int get writerProfileIconId;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  List<CommunityCommentEntity> get replies;

  /// Create a copy of CommunityCommentEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityCommentEntityImplCopyWith<_$CommunityCommentEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
