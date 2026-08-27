// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_chat_message_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityChatMessageBody {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(CommunityChatSystemEvent event) system,
    required TResult Function(String inviteCode) gameInvite,
    required TResult Function() unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(CommunityChatSystemEvent event)? system,
    TResult? Function(String inviteCode)? gameInvite,
    TResult? Function()? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(CommunityChatSystemEvent event)? system,
    TResult Function(String inviteCode)? gameInvite,
    TResult Function()? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatTextBody value) text,
    required TResult Function(CommunityChatSystemBody value) system,
    required TResult Function(CommunityChatGameInviteBody value) gameInvite,
    required TResult Function(CommunityChatUnknownBody value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatTextBody value)? text,
    TResult? Function(CommunityChatSystemBody value)? system,
    TResult? Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult? Function(CommunityChatUnknownBody value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatTextBody value)? text,
    TResult Function(CommunityChatSystemBody value)? system,
    TResult Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult Function(CommunityChatUnknownBody value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatMessageBodyCopyWith<$Res> {
  factory $CommunityChatMessageBodyCopyWith(
    CommunityChatMessageBody value,
    $Res Function(CommunityChatMessageBody) then,
  ) = _$CommunityChatMessageBodyCopyWithImpl<$Res, CommunityChatMessageBody>;
}

/// @nodoc
class _$CommunityChatMessageBodyCopyWithImpl<
  $Res,
  $Val extends CommunityChatMessageBody
>
    implements $CommunityChatMessageBodyCopyWith<$Res> {
  _$CommunityChatMessageBodyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CommunityChatTextBodyImplCopyWith<$Res> {
  factory _$$CommunityChatTextBodyImplCopyWith(
    _$CommunityChatTextBodyImpl value,
    $Res Function(_$CommunityChatTextBodyImpl) then,
  ) = __$$CommunityChatTextBodyImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$$CommunityChatTextBodyImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMessageBodyCopyWithImpl<
          $Res,
          _$CommunityChatTextBodyImpl
        >
    implements _$$CommunityChatTextBodyImplCopyWith<$Res> {
  __$$CommunityChatTextBodyImplCopyWithImpl(
    _$CommunityChatTextBodyImpl _value,
    $Res Function(_$CommunityChatTextBodyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? text = null}) {
    return _then(
      _$CommunityChatTextBodyImpl(
        null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatTextBodyImpl implements CommunityChatTextBody {
  const _$CommunityChatTextBodyImpl(this.text);

  @override
  final String text;

  @override
  String toString() {
    return 'CommunityChatMessageBody.text(text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatTextBodyImpl &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text);

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatTextBodyImplCopyWith<_$CommunityChatTextBodyImpl>
  get copyWith =>
      __$$CommunityChatTextBodyImplCopyWithImpl<_$CommunityChatTextBodyImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(CommunityChatSystemEvent event) system,
    required TResult Function(String inviteCode) gameInvite,
    required TResult Function() unknown,
  }) {
    return text(this.text);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(CommunityChatSystemEvent event)? system,
    TResult? Function(String inviteCode)? gameInvite,
    TResult? Function()? unknown,
  }) {
    return text?.call(this.text);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(CommunityChatSystemEvent event)? system,
    TResult Function(String inviteCode)? gameInvite,
    TResult Function()? unknown,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this.text);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatTextBody value) text,
    required TResult Function(CommunityChatSystemBody value) system,
    required TResult Function(CommunityChatGameInviteBody value) gameInvite,
    required TResult Function(CommunityChatUnknownBody value) unknown,
  }) {
    return text(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatTextBody value)? text,
    TResult? Function(CommunityChatSystemBody value)? system,
    TResult? Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult? Function(CommunityChatUnknownBody value)? unknown,
  }) {
    return text?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatTextBody value)? text,
    TResult Function(CommunityChatSystemBody value)? system,
    TResult Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult Function(CommunityChatUnknownBody value)? unknown,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this);
    }
    return orElse();
  }
}

abstract class CommunityChatTextBody implements CommunityChatMessageBody {
  const factory CommunityChatTextBody(final String text) =
      _$CommunityChatTextBodyImpl;

  String get text;

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatTextBodyImplCopyWith<_$CommunityChatTextBodyImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CommunityChatSystemBodyImplCopyWith<$Res> {
  factory _$$CommunityChatSystemBodyImplCopyWith(
    _$CommunityChatSystemBodyImpl value,
    $Res Function(_$CommunityChatSystemBodyImpl) then,
  ) = __$$CommunityChatSystemBodyImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CommunityChatSystemEvent event});
}

/// @nodoc
class __$$CommunityChatSystemBodyImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMessageBodyCopyWithImpl<
          $Res,
          _$CommunityChatSystemBodyImpl
        >
    implements _$$CommunityChatSystemBodyImplCopyWith<$Res> {
  __$$CommunityChatSystemBodyImplCopyWithImpl(
    _$CommunityChatSystemBodyImpl _value,
    $Res Function(_$CommunityChatSystemBodyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? event = null}) {
    return _then(
      _$CommunityChatSystemBodyImpl(
        null == event
            ? _value.event
            : event // ignore: cast_nullable_to_non_nullable
                  as CommunityChatSystemEvent,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatSystemBodyImpl implements CommunityChatSystemBody {
  const _$CommunityChatSystemBodyImpl(this.event);

  @override
  final CommunityChatSystemEvent event;

  @override
  String toString() {
    return 'CommunityChatMessageBody.system(event: $event)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatSystemBodyImpl &&
            (identical(other.event, event) || other.event == event));
  }

  @override
  int get hashCode => Object.hash(runtimeType, event);

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatSystemBodyImplCopyWith<_$CommunityChatSystemBodyImpl>
  get copyWith =>
      __$$CommunityChatSystemBodyImplCopyWithImpl<
        _$CommunityChatSystemBodyImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(CommunityChatSystemEvent event) system,
    required TResult Function(String inviteCode) gameInvite,
    required TResult Function() unknown,
  }) {
    return system(event);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(CommunityChatSystemEvent event)? system,
    TResult? Function(String inviteCode)? gameInvite,
    TResult? Function()? unknown,
  }) {
    return system?.call(event);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(CommunityChatSystemEvent event)? system,
    TResult Function(String inviteCode)? gameInvite,
    TResult Function()? unknown,
    required TResult orElse(),
  }) {
    if (system != null) {
      return system(event);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatTextBody value) text,
    required TResult Function(CommunityChatSystemBody value) system,
    required TResult Function(CommunityChatGameInviteBody value) gameInvite,
    required TResult Function(CommunityChatUnknownBody value) unknown,
  }) {
    return system(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatTextBody value)? text,
    TResult? Function(CommunityChatSystemBody value)? system,
    TResult? Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult? Function(CommunityChatUnknownBody value)? unknown,
  }) {
    return system?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatTextBody value)? text,
    TResult Function(CommunityChatSystemBody value)? system,
    TResult Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult Function(CommunityChatUnknownBody value)? unknown,
    required TResult orElse(),
  }) {
    if (system != null) {
      return system(this);
    }
    return orElse();
  }
}

abstract class CommunityChatSystemBody implements CommunityChatMessageBody {
  const factory CommunityChatSystemBody(final CommunityChatSystemEvent event) =
      _$CommunityChatSystemBodyImpl;

  CommunityChatSystemEvent get event;

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatSystemBodyImplCopyWith<_$CommunityChatSystemBodyImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CommunityChatGameInviteBodyImplCopyWith<$Res> {
  factory _$$CommunityChatGameInviteBodyImplCopyWith(
    _$CommunityChatGameInviteBodyImpl value,
    $Res Function(_$CommunityChatGameInviteBodyImpl) then,
  ) = __$$CommunityChatGameInviteBodyImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String inviteCode});
}

/// @nodoc
class __$$CommunityChatGameInviteBodyImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMessageBodyCopyWithImpl<
          $Res,
          _$CommunityChatGameInviteBodyImpl
        >
    implements _$$CommunityChatGameInviteBodyImplCopyWith<$Res> {
  __$$CommunityChatGameInviteBodyImplCopyWithImpl(
    _$CommunityChatGameInviteBodyImpl _value,
    $Res Function(_$CommunityChatGameInviteBodyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? inviteCode = null}) {
    return _then(
      _$CommunityChatGameInviteBodyImpl(
        null == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatGameInviteBodyImpl implements CommunityChatGameInviteBody {
  const _$CommunityChatGameInviteBodyImpl(this.inviteCode);

  @override
  final String inviteCode;

  @override
  String toString() {
    return 'CommunityChatMessageBody.gameInvite(inviteCode: $inviteCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatGameInviteBodyImpl &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, inviteCode);

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatGameInviteBodyImplCopyWith<_$CommunityChatGameInviteBodyImpl>
  get copyWith =>
      __$$CommunityChatGameInviteBodyImplCopyWithImpl<
        _$CommunityChatGameInviteBodyImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(CommunityChatSystemEvent event) system,
    required TResult Function(String inviteCode) gameInvite,
    required TResult Function() unknown,
  }) {
    return gameInvite(inviteCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(CommunityChatSystemEvent event)? system,
    TResult? Function(String inviteCode)? gameInvite,
    TResult? Function()? unknown,
  }) {
    return gameInvite?.call(inviteCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(CommunityChatSystemEvent event)? system,
    TResult Function(String inviteCode)? gameInvite,
    TResult Function()? unknown,
    required TResult orElse(),
  }) {
    if (gameInvite != null) {
      return gameInvite(inviteCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatTextBody value) text,
    required TResult Function(CommunityChatSystemBody value) system,
    required TResult Function(CommunityChatGameInviteBody value) gameInvite,
    required TResult Function(CommunityChatUnknownBody value) unknown,
  }) {
    return gameInvite(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatTextBody value)? text,
    TResult? Function(CommunityChatSystemBody value)? system,
    TResult? Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult? Function(CommunityChatUnknownBody value)? unknown,
  }) {
    return gameInvite?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatTextBody value)? text,
    TResult Function(CommunityChatSystemBody value)? system,
    TResult Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult Function(CommunityChatUnknownBody value)? unknown,
    required TResult orElse(),
  }) {
    if (gameInvite != null) {
      return gameInvite(this);
    }
    return orElse();
  }
}

abstract class CommunityChatGameInviteBody implements CommunityChatMessageBody {
  const factory CommunityChatGameInviteBody(final String inviteCode) =
      _$CommunityChatGameInviteBodyImpl;

  String get inviteCode;

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatGameInviteBodyImplCopyWith<_$CommunityChatGameInviteBodyImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CommunityChatUnknownBodyImplCopyWith<$Res> {
  factory _$$CommunityChatUnknownBodyImplCopyWith(
    _$CommunityChatUnknownBodyImpl value,
    $Res Function(_$CommunityChatUnknownBodyImpl) then,
  ) = __$$CommunityChatUnknownBodyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CommunityChatUnknownBodyImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMessageBodyCopyWithImpl<
          $Res,
          _$CommunityChatUnknownBodyImpl
        >
    implements _$$CommunityChatUnknownBodyImplCopyWith<$Res> {
  __$$CommunityChatUnknownBodyImplCopyWithImpl(
    _$CommunityChatUnknownBodyImpl _value,
    $Res Function(_$CommunityChatUnknownBodyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMessageBody
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CommunityChatUnknownBodyImpl implements CommunityChatUnknownBody {
  const _$CommunityChatUnknownBodyImpl();

  @override
  String toString() {
    return 'CommunityChatMessageBody.unknown()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatUnknownBodyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(CommunityChatSystemEvent event) system,
    required TResult Function(String inviteCode) gameInvite,
    required TResult Function() unknown,
  }) {
    return unknown();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(CommunityChatSystemEvent event)? system,
    TResult? Function(String inviteCode)? gameInvite,
    TResult? Function()? unknown,
  }) {
    return unknown?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(CommunityChatSystemEvent event)? system,
    TResult Function(String inviteCode)? gameInvite,
    TResult Function()? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatTextBody value) text,
    required TResult Function(CommunityChatSystemBody value) system,
    required TResult Function(CommunityChatGameInviteBody value) gameInvite,
    required TResult Function(CommunityChatUnknownBody value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatTextBody value)? text,
    TResult? Function(CommunityChatSystemBody value)? system,
    TResult? Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult? Function(CommunityChatUnknownBody value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatTextBody value)? text,
    TResult Function(CommunityChatSystemBody value)? system,
    TResult Function(CommunityChatGameInviteBody value)? gameInvite,
    TResult Function(CommunityChatUnknownBody value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class CommunityChatUnknownBody implements CommunityChatMessageBody {
  const factory CommunityChatUnknownBody() = _$CommunityChatUnknownBodyImpl;
}

/// @nodoc
mixin _$CommunityChatMessageEntity {
  int? get id => throw _privateConstructorUsedError;
  String get messageKey => throw _privateConstructorUsedError;
  int get senderId => throw _privateConstructorUsedError;
  String get senderNickname => throw _privateConstructorUsedError;

  /// 프로필 아이콘 번호. 서버가 안 줬으면 null — 화면이 기본 아이콘을 쓴다.
  int? get senderProfileIcon => throw _privateConstructorUsedError;
  CommunityChatMessageBody get body => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  CommunityChatMessageStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatMessageEntityCopyWith<CommunityChatMessageEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatMessageEntityCopyWith<$Res> {
  factory $CommunityChatMessageEntityCopyWith(
    CommunityChatMessageEntity value,
    $Res Function(CommunityChatMessageEntity) then,
  ) =
      _$CommunityChatMessageEntityCopyWithImpl<
        $Res,
        CommunityChatMessageEntity
      >;
  @useResult
  $Res call({
    int? id,
    String messageKey,
    int senderId,
    String senderNickname,
    int? senderProfileIcon,
    CommunityChatMessageBody body,
    DateTime createdAt,
    CommunityChatMessageStatus status,
  });

  $CommunityChatMessageBodyCopyWith<$Res> get body;
}

/// @nodoc
class _$CommunityChatMessageEntityCopyWithImpl<
  $Res,
  $Val extends CommunityChatMessageEntity
>
    implements $CommunityChatMessageEntityCopyWith<$Res> {
  _$CommunityChatMessageEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? messageKey = null,
    Object? senderId = null,
    Object? senderNickname = null,
    Object? senderProfileIcon = freezed,
    Object? body = null,
    Object? createdAt = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            messageKey: null == messageKey
                ? _value.messageKey
                : messageKey // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as int,
            senderNickname: null == senderNickname
                ? _value.senderNickname
                : senderNickname // ignore: cast_nullable_to_non_nullable
                      as String,
            senderProfileIcon: freezed == senderProfileIcon
                ? _value.senderProfileIcon
                : senderProfileIcon // ignore: cast_nullable_to_non_nullable
                      as int?,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as CommunityChatMessageBody,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CommunityChatMessageStatus,
          )
          as $Val,
    );
  }

  /// Create a copy of CommunityChatMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommunityChatMessageBodyCopyWith<$Res> get body {
    return $CommunityChatMessageBodyCopyWith<$Res>(_value.body, (value) {
      return _then(_value.copyWith(body: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommunityChatMessageEntityImplCopyWith<$Res>
    implements $CommunityChatMessageEntityCopyWith<$Res> {
  factory _$$CommunityChatMessageEntityImplCopyWith(
    _$CommunityChatMessageEntityImpl value,
    $Res Function(_$CommunityChatMessageEntityImpl) then,
  ) = __$$CommunityChatMessageEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String messageKey,
    int senderId,
    String senderNickname,
    int? senderProfileIcon,
    CommunityChatMessageBody body,
    DateTime createdAt,
    CommunityChatMessageStatus status,
  });

  @override
  $CommunityChatMessageBodyCopyWith<$Res> get body;
}

/// @nodoc
class __$$CommunityChatMessageEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityChatMessageEntityCopyWithImpl<
          $Res,
          _$CommunityChatMessageEntityImpl
        >
    implements _$$CommunityChatMessageEntityImplCopyWith<$Res> {
  __$$CommunityChatMessageEntityImplCopyWithImpl(
    _$CommunityChatMessageEntityImpl _value,
    $Res Function(_$CommunityChatMessageEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? messageKey = null,
    Object? senderId = null,
    Object? senderNickname = null,
    Object? senderProfileIcon = freezed,
    Object? body = null,
    Object? createdAt = null,
    Object? status = null,
  }) {
    return _then(
      _$CommunityChatMessageEntityImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        messageKey: null == messageKey
            ? _value.messageKey
            : messageKey // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as int,
        senderNickname: null == senderNickname
            ? _value.senderNickname
            : senderNickname // ignore: cast_nullable_to_non_nullable
                  as String,
        senderProfileIcon: freezed == senderProfileIcon
            ? _value.senderProfileIcon
            : senderProfileIcon // ignore: cast_nullable_to_non_nullable
                  as int?,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as CommunityChatMessageBody,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CommunityChatMessageStatus,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatMessageEntityImpl extends _CommunityChatMessageEntity {
  const _$CommunityChatMessageEntityImpl({
    this.id,
    required this.messageKey,
    required this.senderId,
    required this.senderNickname,
    this.senderProfileIcon,
    required this.body,
    required this.createdAt,
    this.status = CommunityChatMessageStatus.sent,
  }) : super._();

  @override
  final int? id;
  @override
  final String messageKey;
  @override
  final int senderId;
  @override
  final String senderNickname;

  /// 프로필 아이콘 번호. 서버가 안 줬으면 null — 화면이 기본 아이콘을 쓴다.
  @override
  final int? senderProfileIcon;
  @override
  final CommunityChatMessageBody body;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final CommunityChatMessageStatus status;

  @override
  String toString() {
    return 'CommunityChatMessageEntity(id: $id, messageKey: $messageKey, senderId: $senderId, senderNickname: $senderNickname, senderProfileIcon: $senderProfileIcon, body: $body, createdAt: $createdAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatMessageEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageKey, messageKey) ||
                other.messageKey == messageKey) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderNickname, senderNickname) ||
                other.senderNickname == senderNickname) &&
            (identical(other.senderProfileIcon, senderProfileIcon) ||
                other.senderProfileIcon == senderProfileIcon) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    messageKey,
    senderId,
    senderNickname,
    senderProfileIcon,
    body,
    createdAt,
    status,
  );

  /// Create a copy of CommunityChatMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatMessageEntityImplCopyWith<_$CommunityChatMessageEntityImpl>
  get copyWith =>
      __$$CommunityChatMessageEntityImplCopyWithImpl<
        _$CommunityChatMessageEntityImpl
      >(this, _$identity);
}

abstract class _CommunityChatMessageEntity extends CommunityChatMessageEntity {
  const factory _CommunityChatMessageEntity({
    final int? id,
    required final String messageKey,
    required final int senderId,
    required final String senderNickname,
    final int? senderProfileIcon,
    required final CommunityChatMessageBody body,
    required final DateTime createdAt,
    final CommunityChatMessageStatus status,
  }) = _$CommunityChatMessageEntityImpl;
  const _CommunityChatMessageEntity._() : super._();

  @override
  int? get id;
  @override
  String get messageKey;
  @override
  int get senderId;
  @override
  String get senderNickname;

  /// 프로필 아이콘 번호. 서버가 안 줬으면 null — 화면이 기본 아이콘을 쓴다.
  @override
  int? get senderProfileIcon;
  @override
  CommunityChatMessageBody get body;
  @override
  DateTime get createdAt;
  @override
  CommunityChatMessageStatus get status;

  /// Create a copy of CommunityChatMessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatMessageEntityImplCopyWith<_$CommunityChatMessageEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
