// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_chat_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityChatEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int postId, CommunityChatMessageEntity message)
    message,
    required TResult Function(CommunityChatConnectionState state) connection,
    required TResult Function(int postId) noticeChanged,
    required TResult Function(String errorCode) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int postId, CommunityChatMessageEntity message)? message,
    TResult? Function(CommunityChatConnectionState state)? connection,
    TResult? Function(int postId)? noticeChanged,
    TResult? Function(String errorCode)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int postId, CommunityChatMessageEntity message)? message,
    TResult Function(CommunityChatConnectionState state)? connection,
    TResult Function(int postId)? noticeChanged,
    TResult Function(String errorCode)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatMessageEvent value) message,
    required TResult Function(CommunityChatConnectionEvent value) connection,
    required TResult Function(CommunityChatNoticeChangedEvent value)
    noticeChanged,
    required TResult Function(CommunityChatErrorEvent value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatMessageEvent value)? message,
    TResult? Function(CommunityChatConnectionEvent value)? connection,
    TResult? Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult? Function(CommunityChatErrorEvent value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatMessageEvent value)? message,
    TResult Function(CommunityChatConnectionEvent value)? connection,
    TResult Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult Function(CommunityChatErrorEvent value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatEventCopyWith<$Res> {
  factory $CommunityChatEventCopyWith(
    CommunityChatEvent value,
    $Res Function(CommunityChatEvent) then,
  ) = _$CommunityChatEventCopyWithImpl<$Res, CommunityChatEvent>;
}

/// @nodoc
class _$CommunityChatEventCopyWithImpl<$Res, $Val extends CommunityChatEvent>
    implements $CommunityChatEventCopyWith<$Res> {
  _$CommunityChatEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CommunityChatMessageEventImplCopyWith<$Res> {
  factory _$$CommunityChatMessageEventImplCopyWith(
    _$CommunityChatMessageEventImpl value,
    $Res Function(_$CommunityChatMessageEventImpl) then,
  ) = __$$CommunityChatMessageEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int postId, CommunityChatMessageEntity message});

  $CommunityChatMessageEntityCopyWith<$Res> get message;
}

/// @nodoc
class __$$CommunityChatMessageEventImplCopyWithImpl<$Res>
    extends
        _$CommunityChatEventCopyWithImpl<$Res, _$CommunityChatMessageEventImpl>
    implements _$$CommunityChatMessageEventImplCopyWith<$Res> {
  __$$CommunityChatMessageEventImplCopyWithImpl(
    _$CommunityChatMessageEventImpl _value,
    $Res Function(_$CommunityChatMessageEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? postId = null, Object? message = null}) {
    return _then(
      _$CommunityChatMessageEventImpl(
        null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as int,
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as CommunityChatMessageEntity,
      ),
    );
  }

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommunityChatMessageEntityCopyWith<$Res> get message {
    return $CommunityChatMessageEntityCopyWith<$Res>(_value.message, (value) {
      return _then(_value.copyWith(message: value));
    });
  }
}

/// @nodoc

class _$CommunityChatMessageEventImpl implements CommunityChatMessageEvent {
  const _$CommunityChatMessageEventImpl(this.postId, this.message);

  @override
  final int postId;
  @override
  final CommunityChatMessageEntity message;

  @override
  String toString() {
    return 'CommunityChatEvent.message(postId: $postId, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatMessageEventImpl &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId, message);

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatMessageEventImplCopyWith<_$CommunityChatMessageEventImpl>
  get copyWith =>
      __$$CommunityChatMessageEventImplCopyWithImpl<
        _$CommunityChatMessageEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int postId, CommunityChatMessageEntity message)
    message,
    required TResult Function(CommunityChatConnectionState state) connection,
    required TResult Function(int postId) noticeChanged,
    required TResult Function(String errorCode) error,
  }) {
    return message(postId, this.message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int postId, CommunityChatMessageEntity message)? message,
    TResult? Function(CommunityChatConnectionState state)? connection,
    TResult? Function(int postId)? noticeChanged,
    TResult? Function(String errorCode)? error,
  }) {
    return message?.call(postId, this.message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int postId, CommunityChatMessageEntity message)? message,
    TResult Function(CommunityChatConnectionState state)? connection,
    TResult Function(int postId)? noticeChanged,
    TResult Function(String errorCode)? error,
    required TResult orElse(),
  }) {
    if (message != null) {
      return message(postId, this.message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatMessageEvent value) message,
    required TResult Function(CommunityChatConnectionEvent value) connection,
    required TResult Function(CommunityChatNoticeChangedEvent value)
    noticeChanged,
    required TResult Function(CommunityChatErrorEvent value) error,
  }) {
    return message(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatMessageEvent value)? message,
    TResult? Function(CommunityChatConnectionEvent value)? connection,
    TResult? Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult? Function(CommunityChatErrorEvent value)? error,
  }) {
    return message?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatMessageEvent value)? message,
    TResult Function(CommunityChatConnectionEvent value)? connection,
    TResult Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult Function(CommunityChatErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (message != null) {
      return message(this);
    }
    return orElse();
  }
}

abstract class CommunityChatMessageEvent implements CommunityChatEvent {
  const factory CommunityChatMessageEvent(
    final int postId,
    final CommunityChatMessageEntity message,
  ) = _$CommunityChatMessageEventImpl;

  int get postId;
  CommunityChatMessageEntity get message;

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatMessageEventImplCopyWith<_$CommunityChatMessageEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CommunityChatConnectionEventImplCopyWith<$Res> {
  factory _$$CommunityChatConnectionEventImplCopyWith(
    _$CommunityChatConnectionEventImpl value,
    $Res Function(_$CommunityChatConnectionEventImpl) then,
  ) = __$$CommunityChatConnectionEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CommunityChatConnectionState state});
}

/// @nodoc
class __$$CommunityChatConnectionEventImplCopyWithImpl<$Res>
    extends
        _$CommunityChatEventCopyWithImpl<
          $Res,
          _$CommunityChatConnectionEventImpl
        >
    implements _$$CommunityChatConnectionEventImplCopyWith<$Res> {
  __$$CommunityChatConnectionEventImplCopyWithImpl(
    _$CommunityChatConnectionEventImpl _value,
    $Res Function(_$CommunityChatConnectionEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? state = null}) {
    return _then(
      _$CommunityChatConnectionEventImpl(
        null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as CommunityChatConnectionState,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatConnectionEventImpl
    implements CommunityChatConnectionEvent {
  const _$CommunityChatConnectionEventImpl(this.state);

  @override
  final CommunityChatConnectionState state;

  @override
  String toString() {
    return 'CommunityChatEvent.connection(state: $state)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatConnectionEventImpl &&
            (identical(other.state, state) || other.state == state));
  }

  @override
  int get hashCode => Object.hash(runtimeType, state);

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatConnectionEventImplCopyWith<
    _$CommunityChatConnectionEventImpl
  >
  get copyWith =>
      __$$CommunityChatConnectionEventImplCopyWithImpl<
        _$CommunityChatConnectionEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int postId, CommunityChatMessageEntity message)
    message,
    required TResult Function(CommunityChatConnectionState state) connection,
    required TResult Function(int postId) noticeChanged,
    required TResult Function(String errorCode) error,
  }) {
    return connection(state);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int postId, CommunityChatMessageEntity message)? message,
    TResult? Function(CommunityChatConnectionState state)? connection,
    TResult? Function(int postId)? noticeChanged,
    TResult? Function(String errorCode)? error,
  }) {
    return connection?.call(state);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int postId, CommunityChatMessageEntity message)? message,
    TResult Function(CommunityChatConnectionState state)? connection,
    TResult Function(int postId)? noticeChanged,
    TResult Function(String errorCode)? error,
    required TResult orElse(),
  }) {
    if (connection != null) {
      return connection(state);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatMessageEvent value) message,
    required TResult Function(CommunityChatConnectionEvent value) connection,
    required TResult Function(CommunityChatNoticeChangedEvent value)
    noticeChanged,
    required TResult Function(CommunityChatErrorEvent value) error,
  }) {
    return connection(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatMessageEvent value)? message,
    TResult? Function(CommunityChatConnectionEvent value)? connection,
    TResult? Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult? Function(CommunityChatErrorEvent value)? error,
  }) {
    return connection?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatMessageEvent value)? message,
    TResult Function(CommunityChatConnectionEvent value)? connection,
    TResult Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult Function(CommunityChatErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (connection != null) {
      return connection(this);
    }
    return orElse();
  }
}

abstract class CommunityChatConnectionEvent implements CommunityChatEvent {
  const factory CommunityChatConnectionEvent(
    final CommunityChatConnectionState state,
  ) = _$CommunityChatConnectionEventImpl;

  CommunityChatConnectionState get state;

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatConnectionEventImplCopyWith<
    _$CommunityChatConnectionEventImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CommunityChatNoticeChangedEventImplCopyWith<$Res> {
  factory _$$CommunityChatNoticeChangedEventImplCopyWith(
    _$CommunityChatNoticeChangedEventImpl value,
    $Res Function(_$CommunityChatNoticeChangedEventImpl) then,
  ) = __$$CommunityChatNoticeChangedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int postId});
}

/// @nodoc
class __$$CommunityChatNoticeChangedEventImplCopyWithImpl<$Res>
    extends
        _$CommunityChatEventCopyWithImpl<
          $Res,
          _$CommunityChatNoticeChangedEventImpl
        >
    implements _$$CommunityChatNoticeChangedEventImplCopyWith<$Res> {
  __$$CommunityChatNoticeChangedEventImplCopyWithImpl(
    _$CommunityChatNoticeChangedEventImpl _value,
    $Res Function(_$CommunityChatNoticeChangedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? postId = null}) {
    return _then(
      _$CommunityChatNoticeChangedEventImpl(
        null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatNoticeChangedEventImpl
    implements CommunityChatNoticeChangedEvent {
  const _$CommunityChatNoticeChangedEventImpl(this.postId);

  @override
  final int postId;

  @override
  String toString() {
    return 'CommunityChatEvent.noticeChanged(postId: $postId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatNoticeChangedEventImpl &&
            (identical(other.postId, postId) || other.postId == postId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId);

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatNoticeChangedEventImplCopyWith<
    _$CommunityChatNoticeChangedEventImpl
  >
  get copyWith =>
      __$$CommunityChatNoticeChangedEventImplCopyWithImpl<
        _$CommunityChatNoticeChangedEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int postId, CommunityChatMessageEntity message)
    message,
    required TResult Function(CommunityChatConnectionState state) connection,
    required TResult Function(int postId) noticeChanged,
    required TResult Function(String errorCode) error,
  }) {
    return noticeChanged(postId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int postId, CommunityChatMessageEntity message)? message,
    TResult? Function(CommunityChatConnectionState state)? connection,
    TResult? Function(int postId)? noticeChanged,
    TResult? Function(String errorCode)? error,
  }) {
    return noticeChanged?.call(postId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int postId, CommunityChatMessageEntity message)? message,
    TResult Function(CommunityChatConnectionState state)? connection,
    TResult Function(int postId)? noticeChanged,
    TResult Function(String errorCode)? error,
    required TResult orElse(),
  }) {
    if (noticeChanged != null) {
      return noticeChanged(postId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatMessageEvent value) message,
    required TResult Function(CommunityChatConnectionEvent value) connection,
    required TResult Function(CommunityChatNoticeChangedEvent value)
    noticeChanged,
    required TResult Function(CommunityChatErrorEvent value) error,
  }) {
    return noticeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatMessageEvent value)? message,
    TResult? Function(CommunityChatConnectionEvent value)? connection,
    TResult? Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult? Function(CommunityChatErrorEvent value)? error,
  }) {
    return noticeChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatMessageEvent value)? message,
    TResult Function(CommunityChatConnectionEvent value)? connection,
    TResult Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult Function(CommunityChatErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (noticeChanged != null) {
      return noticeChanged(this);
    }
    return orElse();
  }
}

abstract class CommunityChatNoticeChangedEvent implements CommunityChatEvent {
  const factory CommunityChatNoticeChangedEvent(final int postId) =
      _$CommunityChatNoticeChangedEventImpl;

  int get postId;

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatNoticeChangedEventImplCopyWith<
    _$CommunityChatNoticeChangedEventImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CommunityChatErrorEventImplCopyWith<$Res> {
  factory _$$CommunityChatErrorEventImplCopyWith(
    _$CommunityChatErrorEventImpl value,
    $Res Function(_$CommunityChatErrorEventImpl) then,
  ) = __$$CommunityChatErrorEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String errorCode});
}

/// @nodoc
class __$$CommunityChatErrorEventImplCopyWithImpl<$Res>
    extends
        _$CommunityChatEventCopyWithImpl<$Res, _$CommunityChatErrorEventImpl>
    implements _$$CommunityChatErrorEventImplCopyWith<$Res> {
  __$$CommunityChatErrorEventImplCopyWithImpl(
    _$CommunityChatErrorEventImpl _value,
    $Res Function(_$CommunityChatErrorEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? errorCode = null}) {
    return _then(
      _$CommunityChatErrorEventImpl(
        null == errorCode
            ? _value.errorCode
            : errorCode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatErrorEventImpl implements CommunityChatErrorEvent {
  const _$CommunityChatErrorEventImpl(this.errorCode);

  @override
  final String errorCode;

  @override
  String toString() {
    return 'CommunityChatEvent.error(errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatErrorEventImpl &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, errorCode);

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatErrorEventImplCopyWith<_$CommunityChatErrorEventImpl>
  get copyWith =>
      __$$CommunityChatErrorEventImplCopyWithImpl<
        _$CommunityChatErrorEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int postId, CommunityChatMessageEntity message)
    message,
    required TResult Function(CommunityChatConnectionState state) connection,
    required TResult Function(int postId) noticeChanged,
    required TResult Function(String errorCode) error,
  }) {
    return error(errorCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int postId, CommunityChatMessageEntity message)? message,
    TResult? Function(CommunityChatConnectionState state)? connection,
    TResult? Function(int postId)? noticeChanged,
    TResult? Function(String errorCode)? error,
  }) {
    return error?.call(errorCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int postId, CommunityChatMessageEntity message)? message,
    TResult Function(CommunityChatConnectionState state)? connection,
    TResult Function(int postId)? noticeChanged,
    TResult Function(String errorCode)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(errorCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityChatMessageEvent value) message,
    required TResult Function(CommunityChatConnectionEvent value) connection,
    required TResult Function(CommunityChatNoticeChangedEvent value)
    noticeChanged,
    required TResult Function(CommunityChatErrorEvent value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityChatMessageEvent value)? message,
    TResult? Function(CommunityChatConnectionEvent value)? connection,
    TResult? Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult? Function(CommunityChatErrorEvent value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityChatMessageEvent value)? message,
    TResult Function(CommunityChatConnectionEvent value)? connection,
    TResult Function(CommunityChatNoticeChangedEvent value)? noticeChanged,
    TResult Function(CommunityChatErrorEvent value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class CommunityChatErrorEvent implements CommunityChatEvent {
  const factory CommunityChatErrorEvent(final String errorCode) =
      _$CommunityChatErrorEventImpl;

  String get errorCode;

  /// Create a copy of CommunityChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatErrorEventImplCopyWith<_$CommunityChatErrorEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}
