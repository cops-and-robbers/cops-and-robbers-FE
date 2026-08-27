// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommunityCommentResponseModel _$CommunityCommentResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityCommentResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityCommentResponseModel {
  int get id => throw _privateConstructorUsedError;

  /// 부모 댓글 id. 1depth 댓글이면 null.
  int? get parentId => throw _privateConstructorUsedError;
  int? get writerId => throw _privateConstructorUsedError;
  String? get writerNickname => throw _privateConstructorUsedError;
  int? get writerProfileIcon => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;

  /// 삭제 여부. true면 답글이 남아 자리만 지킨 댓글이다.
  bool get deleted => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// 답글 목록. 댓글은 2depth 고정이라 답글의 이 값은 항상 비어 있다.
  List<CommunityCommentResponseModel> get replies =>
      throw _privateConstructorUsedError;

  /// Serializes this CommunityCommentResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityCommentResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityCommentResponseModelCopyWith<CommunityCommentResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityCommentResponseModelCopyWith<$Res> {
  factory $CommunityCommentResponseModelCopyWith(
    CommunityCommentResponseModel value,
    $Res Function(CommunityCommentResponseModel) then,
  ) =
      _$CommunityCommentResponseModelCopyWithImpl<
        $Res,
        CommunityCommentResponseModel
      >;
  @useResult
  $Res call({
    int id,
    int? parentId,
    int? writerId,
    String? writerNickname,
    int? writerProfileIcon,
    String? content,
    bool deleted,
    DateTime createdAt,
    DateTime? updatedAt,
    List<CommunityCommentResponseModel> replies,
  });
}

/// @nodoc
class _$CommunityCommentResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityCommentResponseModel
>
    implements $CommunityCommentResponseModelCopyWith<$Res> {
  _$CommunityCommentResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityCommentResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentId = freezed,
    Object? writerId = freezed,
    Object? writerNickname = freezed,
    Object? writerProfileIcon = freezed,
    Object? content = freezed,
    Object? deleted = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
            writerProfileIcon: freezed == writerProfileIcon
                ? _value.writerProfileIcon
                : writerProfileIcon // ignore: cast_nullable_to_non_nullable
                      as int?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            deleted: null == deleted
                ? _value.deleted
                : deleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            replies: null == replies
                ? _value.replies
                : replies // ignore: cast_nullable_to_non_nullable
                      as List<CommunityCommentResponseModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityCommentResponseModelImplCopyWith<$Res>
    implements $CommunityCommentResponseModelCopyWith<$Res> {
  factory _$$CommunityCommentResponseModelImplCopyWith(
    _$CommunityCommentResponseModelImpl value,
    $Res Function(_$CommunityCommentResponseModelImpl) then,
  ) = __$$CommunityCommentResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int? parentId,
    int? writerId,
    String? writerNickname,
    int? writerProfileIcon,
    String? content,
    bool deleted,
    DateTime createdAt,
    DateTime? updatedAt,
    List<CommunityCommentResponseModel> replies,
  });
}

/// @nodoc
class __$$CommunityCommentResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityCommentResponseModelCopyWithImpl<
          $Res,
          _$CommunityCommentResponseModelImpl
        >
    implements _$$CommunityCommentResponseModelImplCopyWith<$Res> {
  __$$CommunityCommentResponseModelImplCopyWithImpl(
    _$CommunityCommentResponseModelImpl _value,
    $Res Function(_$CommunityCommentResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityCommentResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentId = freezed,
    Object? writerId = freezed,
    Object? writerNickname = freezed,
    Object? writerProfileIcon = freezed,
    Object? content = freezed,
    Object? deleted = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? replies = null,
  }) {
    return _then(
      _$CommunityCommentResponseModelImpl(
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
        writerProfileIcon: freezed == writerProfileIcon
            ? _value.writerProfileIcon
            : writerProfileIcon // ignore: cast_nullable_to_non_nullable
                  as int?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        deleted: null == deleted
            ? _value.deleted
            : deleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        replies: null == replies
            ? _value._replies
            : replies // ignore: cast_nullable_to_non_nullable
                  as List<CommunityCommentResponseModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityCommentResponseModelImpl
    implements _CommunityCommentResponseModel {
  const _$CommunityCommentResponseModelImpl({
    required this.id,
    this.parentId,
    this.writerId,
    this.writerNickname,
    this.writerProfileIcon,
    this.content,
    this.deleted = false,
    required this.createdAt,
    this.updatedAt,
    final List<CommunityCommentResponseModel> replies =
        const <CommunityCommentResponseModel>[],
  }) : _replies = replies;

  factory _$CommunityCommentResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityCommentResponseModelImplFromJson(json);

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
  final int? writerProfileIcon;
  @override
  final String? content;

  /// 삭제 여부. true면 답글이 남아 자리만 지킨 댓글이다.
  @override
  @JsonKey()
  final bool deleted;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  /// 답글 목록. 댓글은 2depth 고정이라 답글의 이 값은 항상 비어 있다.
  final List<CommunityCommentResponseModel> _replies;

  /// 답글 목록. 댓글은 2depth 고정이라 답글의 이 값은 항상 비어 있다.
  @override
  @JsonKey()
  List<CommunityCommentResponseModel> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  @override
  String toString() {
    return 'CommunityCommentResponseModel(id: $id, parentId: $parentId, writerId: $writerId, writerNickname: $writerNickname, writerProfileIcon: $writerProfileIcon, content: $content, deleted: $deleted, createdAt: $createdAt, updatedAt: $updatedAt, replies: $replies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityCommentResponseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.writerId, writerId) ||
                other.writerId == writerId) &&
            (identical(other.writerNickname, writerNickname) ||
                other.writerNickname == writerNickname) &&
            (identical(other.writerProfileIcon, writerProfileIcon) ||
                other.writerProfileIcon == writerProfileIcon) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.deleted, deleted) || other.deleted == deleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._replies, _replies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    parentId,
    writerId,
    writerNickname,
    writerProfileIcon,
    content,
    deleted,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_replies),
  );

  /// Create a copy of CommunityCommentResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityCommentResponseModelImplCopyWith<
    _$CommunityCommentResponseModelImpl
  >
  get copyWith =>
      __$$CommunityCommentResponseModelImplCopyWithImpl<
        _$CommunityCommentResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityCommentResponseModelImplToJson(this);
  }
}

abstract class _CommunityCommentResponseModel
    implements CommunityCommentResponseModel {
  const factory _CommunityCommentResponseModel({
    required final int id,
    final int? parentId,
    final int? writerId,
    final String? writerNickname,
    final int? writerProfileIcon,
    final String? content,
    final bool deleted,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final List<CommunityCommentResponseModel> replies,
  }) = _$CommunityCommentResponseModelImpl;

  factory _CommunityCommentResponseModel.fromJson(Map<String, dynamic> json) =
      _$CommunityCommentResponseModelImpl.fromJson;

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
  int? get writerProfileIcon;
  @override
  String? get content;

  /// 삭제 여부. true면 답글이 남아 자리만 지킨 댓글이다.
  @override
  bool get deleted;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// 답글 목록. 댓글은 2depth 고정이라 답글의 이 값은 항상 비어 있다.
  @override
  List<CommunityCommentResponseModel> get replies;

  /// Create a copy of CommunityCommentResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityCommentResponseModelImplCopyWith<
    _$CommunityCommentResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityCommentListResponseModel _$CommunityCommentListResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityCommentListResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityCommentListResponseModel {
  /// 1depth 댓글 목록 (오래된 순). 각 댓글의 답글은 `replies`에 모두 담긴다.
  List<CommunityCommentResponseModel> get content =>
      throw _privateConstructorUsedError;

  /// 다음 페이지 커서. 마지막 페이지면 null.
  int? get nextCursor => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;

  /// Serializes this CommunityCommentListResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityCommentListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityCommentListResponseModelCopyWith<CommunityCommentListResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityCommentListResponseModelCopyWith<$Res> {
  factory $CommunityCommentListResponseModelCopyWith(
    CommunityCommentListResponseModel value,
    $Res Function(CommunityCommentListResponseModel) then,
  ) =
      _$CommunityCommentListResponseModelCopyWithImpl<
        $Res,
        CommunityCommentListResponseModel
      >;
  @useResult
  $Res call({
    List<CommunityCommentResponseModel> content,
    int? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class _$CommunityCommentListResponseModelCopyWithImpl<
  $Res,
  $Val extends CommunityCommentListResponseModel
>
    implements $CommunityCommentListResponseModelCopyWith<$Res> {
  _$CommunityCommentListResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityCommentListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? nextCursor = freezed,
    Object? hasNext = null,
  }) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as List<CommunityCommentResponseModel>,
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
abstract class _$$CommunityCommentListResponseModelImplCopyWith<$Res>
    implements $CommunityCommentListResponseModelCopyWith<$Res> {
  factory _$$CommunityCommentListResponseModelImplCopyWith(
    _$CommunityCommentListResponseModelImpl value,
    $Res Function(_$CommunityCommentListResponseModelImpl) then,
  ) = __$$CommunityCommentListResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CommunityCommentResponseModel> content,
    int? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class __$$CommunityCommentListResponseModelImplCopyWithImpl<$Res>
    extends
        _$CommunityCommentListResponseModelCopyWithImpl<
          $Res,
          _$CommunityCommentListResponseModelImpl
        >
    implements _$$CommunityCommentListResponseModelImplCopyWith<$Res> {
  __$$CommunityCommentListResponseModelImplCopyWithImpl(
    _$CommunityCommentListResponseModelImpl _value,
    $Res Function(_$CommunityCommentListResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityCommentListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? nextCursor = freezed,
    Object? hasNext = null,
  }) {
    return _then(
      _$CommunityCommentListResponseModelImpl(
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as List<CommunityCommentResponseModel>,
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
@JsonSerializable()
class _$CommunityCommentListResponseModelImpl
    implements _CommunityCommentListResponseModel {
  const _$CommunityCommentListResponseModelImpl({
    final List<CommunityCommentResponseModel> content =
        const <CommunityCommentResponseModel>[],
    this.nextCursor,
    this.hasNext = false,
  }) : _content = content;

  factory _$CommunityCommentListResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityCommentListResponseModelImplFromJson(json);

  /// 1depth 댓글 목록 (오래된 순). 각 댓글의 답글은 `replies`에 모두 담긴다.
  final List<CommunityCommentResponseModel> _content;

  /// 1depth 댓글 목록 (오래된 순). 각 댓글의 답글은 `replies`에 모두 담긴다.
  @override
  @JsonKey()
  List<CommunityCommentResponseModel> get content {
    if (_content is EqualUnmodifiableListView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_content);
  }

  /// 다음 페이지 커서. 마지막 페이지면 null.
  @override
  final int? nextCursor;
  @override
  @JsonKey()
  final bool hasNext;

  @override
  String toString() {
    return 'CommunityCommentListResponseModel(content: $content, nextCursor: $nextCursor, hasNext: $hasNext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityCommentListResponseModelImpl &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_content),
    nextCursor,
    hasNext,
  );

  /// Create a copy of CommunityCommentListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityCommentListResponseModelImplCopyWith<
    _$CommunityCommentListResponseModelImpl
  >
  get copyWith =>
      __$$CommunityCommentListResponseModelImplCopyWithImpl<
        _$CommunityCommentListResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityCommentListResponseModelImplToJson(this);
  }
}

abstract class _CommunityCommentListResponseModel
    implements CommunityCommentListResponseModel {
  const factory _CommunityCommentListResponseModel({
    final List<CommunityCommentResponseModel> content,
    final int? nextCursor,
    final bool hasNext,
  }) = _$CommunityCommentListResponseModelImpl;

  factory _CommunityCommentListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityCommentListResponseModelImpl.fromJson;

  /// 1depth 댓글 목록 (오래된 순). 각 댓글의 답글은 `replies`에 모두 담긴다.
  @override
  List<CommunityCommentResponseModel> get content;

  /// 다음 페이지 커서. 마지막 페이지면 null.
  @override
  int? get nextCursor;
  @override
  bool get hasNext;

  /// Create a copy of CommunityCommentListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityCommentListResponseModelImplCopyWith<
    _$CommunityCommentListResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CommunityCommentCreateRequestModel _$CommunityCommentCreateRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityCommentCreateRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityCommentCreateRequestModel {
  int? get parentId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// Serializes this CommunityCommentCreateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityCommentCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityCommentCreateRequestModelCopyWith<
    CommunityCommentCreateRequestModel
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityCommentCreateRequestModelCopyWith<$Res> {
  factory $CommunityCommentCreateRequestModelCopyWith(
    CommunityCommentCreateRequestModel value,
    $Res Function(CommunityCommentCreateRequestModel) then,
  ) =
      _$CommunityCommentCreateRequestModelCopyWithImpl<
        $Res,
        CommunityCommentCreateRequestModel
      >;
  @useResult
  $Res call({int? parentId, String content});
}

/// @nodoc
class _$CommunityCommentCreateRequestModelCopyWithImpl<
  $Res,
  $Val extends CommunityCommentCreateRequestModel
>
    implements $CommunityCommentCreateRequestModelCopyWith<$Res> {
  _$CommunityCommentCreateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityCommentCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? parentId = freezed, Object? content = null}) {
    return _then(
      _value.copyWith(
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as int?,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityCommentCreateRequestModelImplCopyWith<$Res>
    implements $CommunityCommentCreateRequestModelCopyWith<$Res> {
  factory _$$CommunityCommentCreateRequestModelImplCopyWith(
    _$CommunityCommentCreateRequestModelImpl value,
    $Res Function(_$CommunityCommentCreateRequestModelImpl) then,
  ) = __$$CommunityCommentCreateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? parentId, String content});
}

/// @nodoc
class __$$CommunityCommentCreateRequestModelImplCopyWithImpl<$Res>
    extends
        _$CommunityCommentCreateRequestModelCopyWithImpl<
          $Res,
          _$CommunityCommentCreateRequestModelImpl
        >
    implements _$$CommunityCommentCreateRequestModelImplCopyWith<$Res> {
  __$$CommunityCommentCreateRequestModelImplCopyWithImpl(
    _$CommunityCommentCreateRequestModelImpl _value,
    $Res Function(_$CommunityCommentCreateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityCommentCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? parentId = freezed, Object? content = null}) {
    return _then(
      _$CommunityCommentCreateRequestModelImpl(
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as int?,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityCommentCreateRequestModelImpl
    implements _CommunityCommentCreateRequestModel {
  const _$CommunityCommentCreateRequestModelImpl({
    this.parentId,
    required this.content,
  });

  factory _$CommunityCommentCreateRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityCommentCreateRequestModelImplFromJson(json);

  @override
  final int? parentId;
  @override
  final String content;

  @override
  String toString() {
    return 'CommunityCommentCreateRequestModel(parentId: $parentId, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityCommentCreateRequestModelImpl &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, parentId, content);

  /// Create a copy of CommunityCommentCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityCommentCreateRequestModelImplCopyWith<
    _$CommunityCommentCreateRequestModelImpl
  >
  get copyWith =>
      __$$CommunityCommentCreateRequestModelImplCopyWithImpl<
        _$CommunityCommentCreateRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityCommentCreateRequestModelImplToJson(this);
  }
}

abstract class _CommunityCommentCreateRequestModel
    implements CommunityCommentCreateRequestModel {
  const factory _CommunityCommentCreateRequestModel({
    final int? parentId,
    required final String content,
  }) = _$CommunityCommentCreateRequestModelImpl;

  factory _CommunityCommentCreateRequestModel.fromJson(
    Map<String, dynamic> json,
  ) = _$CommunityCommentCreateRequestModelImpl.fromJson;

  @override
  int? get parentId;
  @override
  String get content;

  /// Create a copy of CommunityCommentCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityCommentCreateRequestModelImplCopyWith<
    _$CommunityCommentCreateRequestModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
