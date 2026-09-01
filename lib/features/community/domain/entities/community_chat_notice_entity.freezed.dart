// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_chat_notice_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityChatNoticeEntity {
  int get id => throw _privateConstructorUsedError;
  int get writerId => throw _privateConstructorUsedError;

  /// 등록 시점이 아니라 **조회 시점의 현재 닉네임**이다(멤버 목록과 같은 규칙).
  String get writerNickname => throw _privateConstructorUsedError;
  int? get writerProfileIcon => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatNoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatNoticeEntityCopyWith<CommunityChatNoticeEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatNoticeEntityCopyWith<$Res> {
  factory $CommunityChatNoticeEntityCopyWith(
    CommunityChatNoticeEntity value,
    $Res Function(CommunityChatNoticeEntity) then,
  ) = _$CommunityChatNoticeEntityCopyWithImpl<$Res, CommunityChatNoticeEntity>;
  @useResult
  $Res call({
    int id,
    int writerId,
    String writerNickname,
    int? writerProfileIcon,
    String content,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CommunityChatNoticeEntityCopyWithImpl<
  $Res,
  $Val extends CommunityChatNoticeEntity
>
    implements $CommunityChatNoticeEntityCopyWith<$Res> {
  _$CommunityChatNoticeEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatNoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? writerId = null,
    Object? writerNickname = null,
    Object? writerProfileIcon = freezed,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            writerProfileIcon: freezed == writerProfileIcon
                ? _value.writerProfileIcon
                : writerProfileIcon // ignore: cast_nullable_to_non_nullable
                      as int?,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatNoticeEntityImplCopyWith<$Res>
    implements $CommunityChatNoticeEntityCopyWith<$Res> {
  factory _$$CommunityChatNoticeEntityImplCopyWith(
    _$CommunityChatNoticeEntityImpl value,
    $Res Function(_$CommunityChatNoticeEntityImpl) then,
  ) = __$$CommunityChatNoticeEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int writerId,
    String writerNickname,
    int? writerProfileIcon,
    String content,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CommunityChatNoticeEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityChatNoticeEntityCopyWithImpl<
          $Res,
          _$CommunityChatNoticeEntityImpl
        >
    implements _$$CommunityChatNoticeEntityImplCopyWith<$Res> {
  __$$CommunityChatNoticeEntityImplCopyWithImpl(
    _$CommunityChatNoticeEntityImpl _value,
    $Res Function(_$CommunityChatNoticeEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatNoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? writerId = null,
    Object? writerNickname = null,
    Object? writerProfileIcon = freezed,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CommunityChatNoticeEntityImpl(
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
        writerProfileIcon: freezed == writerProfileIcon
            ? _value.writerProfileIcon
            : writerProfileIcon // ignore: cast_nullable_to_non_nullable
                  as int?,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatNoticeEntityImpl implements _CommunityChatNoticeEntity {
  const _$CommunityChatNoticeEntityImpl({
    required this.id,
    required this.writerId,
    required this.writerNickname,
    required this.writerProfileIcon,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final int id;
  @override
  final int writerId;

  /// 등록 시점이 아니라 **조회 시점의 현재 닉네임**이다(멤버 목록과 같은 규칙).
  @override
  final String writerNickname;
  @override
  final int? writerProfileIcon;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CommunityChatNoticeEntity(id: $id, writerId: $writerId, writerNickname: $writerNickname, writerProfileIcon: $writerProfileIcon, content: $content, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatNoticeEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.writerId, writerId) ||
                other.writerId == writerId) &&
            (identical(other.writerNickname, writerNickname) ||
                other.writerNickname == writerNickname) &&
            (identical(other.writerProfileIcon, writerProfileIcon) ||
                other.writerProfileIcon == writerProfileIcon) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    writerId,
    writerNickname,
    writerProfileIcon,
    content,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CommunityChatNoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatNoticeEntityImplCopyWith<_$CommunityChatNoticeEntityImpl>
  get copyWith =>
      __$$CommunityChatNoticeEntityImplCopyWithImpl<
        _$CommunityChatNoticeEntityImpl
      >(this, _$identity);
}

abstract class _CommunityChatNoticeEntity implements CommunityChatNoticeEntity {
  const factory _CommunityChatNoticeEntity({
    required final int id,
    required final int writerId,
    required final String writerNickname,
    required final int? writerProfileIcon,
    required final String content,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CommunityChatNoticeEntityImpl;

  @override
  int get id;
  @override
  int get writerId;

  /// 등록 시점이 아니라 **조회 시점의 현재 닉네임**이다(멤버 목록과 같은 규칙).
  @override
  String get writerNickname;
  @override
  int? get writerProfileIcon;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CommunityChatNoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatNoticeEntityImplCopyWith<_$CommunityChatNoticeEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
