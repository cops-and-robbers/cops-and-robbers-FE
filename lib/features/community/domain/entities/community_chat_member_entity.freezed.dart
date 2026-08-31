// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_chat_member_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityChatMemberEntity {
  int get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;

  /// 프로필 아이콘 번호. 탈퇴한 멤버는 서버가 기본값을 채워 준다 (DEC-0041).
  int? get profileIcon => throw _privateConstructorUsedError;
  bool get isAuthor => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatMemberEntityCopyWith<CommunityChatMemberEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatMemberEntityCopyWith<$Res> {
  factory $CommunityChatMemberEntityCopyWith(
    CommunityChatMemberEntity value,
    $Res Function(CommunityChatMemberEntity) then,
  ) = _$CommunityChatMemberEntityCopyWithImpl<$Res, CommunityChatMemberEntity>;
  @useResult
  $Res call({int userId, String nickname, int? profileIcon, bool isAuthor});
}

/// @nodoc
class _$CommunityChatMemberEntityCopyWithImpl<
  $Res,
  $Val extends CommunityChatMemberEntity
>
    implements $CommunityChatMemberEntityCopyWith<$Res> {
  _$CommunityChatMemberEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? profileIcon = freezed,
    Object? isAuthor = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            profileIcon: freezed == profileIcon
                ? _value.profileIcon
                : profileIcon // ignore: cast_nullable_to_non_nullable
                      as int?,
            isAuthor: null == isAuthor
                ? _value.isAuthor
                : isAuthor // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatMemberEntityImplCopyWith<$Res>
    implements $CommunityChatMemberEntityCopyWith<$Res> {
  factory _$$CommunityChatMemberEntityImplCopyWith(
    _$CommunityChatMemberEntityImpl value,
    $Res Function(_$CommunityChatMemberEntityImpl) then,
  ) = __$$CommunityChatMemberEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, String nickname, int? profileIcon, bool isAuthor});
}

/// @nodoc
class __$$CommunityChatMemberEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMemberEntityCopyWithImpl<
          $Res,
          _$CommunityChatMemberEntityImpl
        >
    implements _$$CommunityChatMemberEntityImplCopyWith<$Res> {
  __$$CommunityChatMemberEntityImplCopyWithImpl(
    _$CommunityChatMemberEntityImpl _value,
    $Res Function(_$CommunityChatMemberEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? profileIcon = freezed,
    Object? isAuthor = null,
  }) {
    return _then(
      _$CommunityChatMemberEntityImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        profileIcon: freezed == profileIcon
            ? _value.profileIcon
            : profileIcon // ignore: cast_nullable_to_non_nullable
                  as int?,
        isAuthor: null == isAuthor
            ? _value.isAuthor
            : isAuthor // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatMemberEntityImpl implements _CommunityChatMemberEntity {
  const _$CommunityChatMemberEntityImpl({
    required this.userId,
    required this.nickname,
    this.profileIcon,
    required this.isAuthor,
  });

  @override
  final int userId;
  @override
  final String nickname;

  /// 프로필 아이콘 번호. 탈퇴한 멤버는 서버가 기본값을 채워 준다 (DEC-0041).
  @override
  final int? profileIcon;
  @override
  final bool isAuthor;

  @override
  String toString() {
    return 'CommunityChatMemberEntity(userId: $userId, nickname: $nickname, profileIcon: $profileIcon, isAuthor: $isAuthor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatMemberEntityImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileIcon, profileIcon) ||
                other.profileIcon == profileIcon) &&
            (identical(other.isAuthor, isAuthor) ||
                other.isAuthor == isAuthor));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, nickname, profileIcon, isAuthor);

  /// Create a copy of CommunityChatMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatMemberEntityImplCopyWith<_$CommunityChatMemberEntityImpl>
  get copyWith =>
      __$$CommunityChatMemberEntityImplCopyWithImpl<
        _$CommunityChatMemberEntityImpl
      >(this, _$identity);
}

abstract class _CommunityChatMemberEntity implements CommunityChatMemberEntity {
  const factory _CommunityChatMemberEntity({
    required final int userId,
    required final String nickname,
    final int? profileIcon,
    required final bool isAuthor,
  }) = _$CommunityChatMemberEntityImpl;

  @override
  int get userId;
  @override
  String get nickname;

  /// 프로필 아이콘 번호. 탈퇴한 멤버는 서버가 기본값을 채워 준다 (DEC-0041).
  @override
  int? get profileIcon;
  @override
  bool get isAuthor;

  /// Create a copy of CommunityChatMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatMemberEntityImplCopyWith<_$CommunityChatMemberEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommunityChatMembersEntity {
  bool get notificationEnabled => throw _privateConstructorUsedError;
  List<CommunityChatMemberEntity> get members =>
      throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatMembersEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatMembersEntityCopyWith<CommunityChatMembersEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatMembersEntityCopyWith<$Res> {
  factory $CommunityChatMembersEntityCopyWith(
    CommunityChatMembersEntity value,
    $Res Function(CommunityChatMembersEntity) then,
  ) =
      _$CommunityChatMembersEntityCopyWithImpl<
        $Res,
        CommunityChatMembersEntity
      >;
  @useResult
  $Res call({
    bool notificationEnabled,
    List<CommunityChatMemberEntity> members,
  });
}

/// @nodoc
class _$CommunityChatMembersEntityCopyWithImpl<
  $Res,
  $Val extends CommunityChatMembersEntity
>
    implements $CommunityChatMembersEntityCopyWith<$Res> {
  _$CommunityChatMembersEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatMembersEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? notificationEnabled = null, Object? members = null}) {
    return _then(
      _value.copyWith(
            notificationEnabled: null == notificationEnabled
                ? _value.notificationEnabled
                : notificationEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            members: null == members
                ? _value.members
                : members // ignore: cast_nullable_to_non_nullable
                      as List<CommunityChatMemberEntity>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatMembersEntityImplCopyWith<$Res>
    implements $CommunityChatMembersEntityCopyWith<$Res> {
  factory _$$CommunityChatMembersEntityImplCopyWith(
    _$CommunityChatMembersEntityImpl value,
    $Res Function(_$CommunityChatMembersEntityImpl) then,
  ) = __$$CommunityChatMembersEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool notificationEnabled,
    List<CommunityChatMemberEntity> members,
  });
}

/// @nodoc
class __$$CommunityChatMembersEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMembersEntityCopyWithImpl<
          $Res,
          _$CommunityChatMembersEntityImpl
        >
    implements _$$CommunityChatMembersEntityImplCopyWith<$Res> {
  __$$CommunityChatMembersEntityImplCopyWithImpl(
    _$CommunityChatMembersEntityImpl _value,
    $Res Function(_$CommunityChatMembersEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMembersEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? notificationEnabled = null, Object? members = null}) {
    return _then(
      _$CommunityChatMembersEntityImpl(
        notificationEnabled: null == notificationEnabled
            ? _value.notificationEnabled
            : notificationEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        members: null == members
            ? _value._members
            : members // ignore: cast_nullable_to_non_nullable
                  as List<CommunityChatMemberEntity>,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatMembersEntityImpl implements _CommunityChatMembersEntity {
  const _$CommunityChatMembersEntityImpl({
    this.notificationEnabled = true,
    required final List<CommunityChatMemberEntity> members,
  }) : _members = members;

  @override
  @JsonKey()
  final bool notificationEnabled;
  final List<CommunityChatMemberEntity> _members;
  @override
  List<CommunityChatMemberEntity> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  String toString() {
    return 'CommunityChatMembersEntity(notificationEnabled: $notificationEnabled, members: $members)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatMembersEntityImpl &&
            (identical(other.notificationEnabled, notificationEnabled) ||
                other.notificationEnabled == notificationEnabled) &&
            const DeepCollectionEquality().equals(other._members, _members));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    notificationEnabled,
    const DeepCollectionEquality().hash(_members),
  );

  /// Create a copy of CommunityChatMembersEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatMembersEntityImplCopyWith<_$CommunityChatMembersEntityImpl>
  get copyWith =>
      __$$CommunityChatMembersEntityImplCopyWithImpl<
        _$CommunityChatMembersEntityImpl
      >(this, _$identity);
}

abstract class _CommunityChatMembersEntity
    implements CommunityChatMembersEntity {
  const factory _CommunityChatMembersEntity({
    final bool notificationEnabled,
    required final List<CommunityChatMemberEntity> members,
  }) = _$CommunityChatMembersEntityImpl;

  @override
  bool get notificationEnabled;
  @override
  List<CommunityChatMemberEntity> get members;

  /// Create a copy of CommunityChatMembersEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatMembersEntityImplCopyWith<_$CommunityChatMembersEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
