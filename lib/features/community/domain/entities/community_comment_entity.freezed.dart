// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_comment_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityCommentEntity {
  int get id => throw _privateConstructorUsedError;

  /// 부모 댓글 id. 1depth 댓글이면 null.
  int? get parentId => throw _privateConstructorUsedError;
  int? get writerId => throw _privateConstructorUsedError;
  String? get writerNickname => throw _privateConstructorUsedError;
  int? get writerProfileIconId => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;

  /// 삭제되어 자리만 남은 댓글인지.
  bool get deleted => throw _privateConstructorUsedError;

  /// 내 댓글에 답글이 달릴 때 알림을 받을지. 남의 댓글에서는 의미가 없다 —
  /// 화면은 내 1depth 댓글의 메뉴에서만 이 값을 쓴다.
  bool get replyNotificationsEnabled => throw _privateConstructorUsedError;
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
    int? parentId,
    int? writerId,
    String? writerNickname,
    int? writerProfileIconId,
    String? content,
    bool deleted,
    bool replyNotificationsEnabled,
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
    Object? parentId = freezed,
    Object? writerId = freezed,
    Object? writerNickname = freezed,
    Object? writerProfileIconId = freezed,
    Object? content = freezed,
    Object? deleted = null,
    Object? replyNotificationsEnabled = null,
    Object? createdAt = null,
    Object? replies = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as int?,
            writerId: freezed == writerId
                ? _value.writerId
                : writerId // ignore: cast_nullable_to_non_nullable
                      as int?,
            writerNickname: freezed == writerNickname
                ? _value.writerNickname
                : writerNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            writerProfileIconId: freezed == writerProfileIconId
                ? _value.writerProfileIconId
                : writerProfileIconId // ignore: cast_nullable_to_non_nullable
                      as int?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            deleted: null == deleted
                ? _value.deleted
                : deleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            replyNotificationsEnabled: null == replyNotificationsEnabled
                ? _value.replyNotificationsEnabled
                : replyNotificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
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
    int? parentId,
    int? writerId,
    String? writerNickname,
    int? writerProfileIconId,
    String? content,
    bool deleted,
    bool replyNotificationsEnabled,
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
    Object? parentId = freezed,
    Object? writerId = freezed,
    Object? writerNickname = freezed,
    Object? writerProfileIconId = freezed,
    Object? content = freezed,
    Object? deleted = null,
    Object? replyNotificationsEnabled = null,
    Object? createdAt = null,
    Object? replies = null,
  }) {
    return _then(
      _$CommunityCommentEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as int?,
        writerId: freezed == writerId
            ? _value.writerId
            : writerId // ignore: cast_nullable_to_non_nullable
                  as int?,
        writerNickname: freezed == writerNickname
            ? _value.writerNickname
            : writerNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        writerProfileIconId: freezed == writerProfileIconId
            ? _value.writerProfileIconId
            : writerProfileIconId // ignore: cast_nullable_to_non_nullable
                  as int?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        deleted: null == deleted
            ? _value.deleted
            : deleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        replyNotificationsEnabled: null == replyNotificationsEnabled
            ? _value.replyNotificationsEnabled
            : replyNotificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
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
    this.parentId,
    this.writerId,
    this.writerNickname,
    this.writerProfileIconId,
    this.content,
    this.deleted = false,
    this.replyNotificationsEnabled = true,
    required this.createdAt,
    final List<CommunityCommentEntity> replies = const [],
  }) : _replies = replies;

  @override
  final int id;

  /// 부모 댓글 id. 1depth 댓글이면 null.
  @override
  final int? parentId;
  @override
  final int? writerId;
  @override
  final String? writerNickname;
  @override
  final int? writerProfileIconId;
  @override
  final String? content;

  /// 삭제되어 자리만 남은 댓글인지.
  @override
  @JsonKey()
  final bool deleted;

  /// 내 댓글에 답글이 달릴 때 알림을 받을지. 남의 댓글에서는 의미가 없다 —
  /// 화면은 내 1depth 댓글의 메뉴에서만 이 값을 쓴다.
  @override
  @JsonKey()
  final bool replyNotificationsEnabled;
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
    return 'CommunityCommentEntity(id: $id, parentId: $parentId, writerId: $writerId, writerNickname: $writerNickname, writerProfileIconId: $writerProfileIconId, content: $content, deleted: $deleted, replyNotificationsEnabled: $replyNotificationsEnabled, createdAt: $createdAt, replies: $replies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityCommentEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.writerId, writerId) ||
                other.writerId == writerId) &&
            (identical(other.writerNickname, writerNickname) ||
                other.writerNickname == writerNickname) &&
            (identical(other.writerProfileIconId, writerProfileIconId) ||
                other.writerProfileIconId == writerProfileIconId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.deleted, deleted) || other.deleted == deleted) &&
            (identical(
                  other.replyNotificationsEnabled,
                  replyNotificationsEnabled,
                ) ||
                other.replyNotificationsEnabled == replyNotificationsEnabled) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._replies, _replies));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    parentId,
    writerId,
    writerNickname,
    writerProfileIconId,
    content,
    deleted,
    replyNotificationsEnabled,
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
    final int? parentId,
    final int? writerId,
    final String? writerNickname,
    final int? writerProfileIconId,
    final String? content,
    final bool deleted,
    final bool replyNotificationsEnabled,
    required final DateTime createdAt,
    final List<CommunityCommentEntity> replies,
  }) = _$CommunityCommentEntityImpl;

  @override
  int get id;

  /// 부모 댓글 id. 1depth 댓글이면 null.
  @override
  int? get parentId;
  @override
  int? get writerId;
  @override
  String? get writerNickname;
  @override
  int? get writerProfileIconId;
  @override
  String? get content;

  /// 삭제되어 자리만 남은 댓글인지.
  @override
  bool get deleted;

  /// 내 댓글에 답글이 달릴 때 알림을 받을지. 남의 댓글에서는 의미가 없다 —
  /// 화면은 내 1depth 댓글의 메뉴에서만 이 값을 쓴다.
  @override
  bool get replyNotificationsEnabled;
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
