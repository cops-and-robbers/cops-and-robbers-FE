// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_navigation_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PushNavigationEvent {
  int get postId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int postId) communityPost,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int postId)? communityPost,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int postId)? communityPost,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityPostPushEvent value) communityPost,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityPostPushEvent value)? communityPost,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityPostPushEvent value)? communityPost,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of PushNavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PushNavigationEventCopyWith<PushNavigationEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PushNavigationEventCopyWith<$Res> {
  factory $PushNavigationEventCopyWith(
    PushNavigationEvent value,
    $Res Function(PushNavigationEvent) then,
  ) = _$PushNavigationEventCopyWithImpl<$Res, PushNavigationEvent>;
  @useResult
  $Res call({int postId});
}

/// @nodoc
class _$PushNavigationEventCopyWithImpl<$Res, $Val extends PushNavigationEvent>
    implements $PushNavigationEventCopyWith<$Res> {
  _$PushNavigationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PushNavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? postId = null}) {
    return _then(
      _value.copyWith(
            postId: null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityPostPushEventImplCopyWith<$Res>
    implements $PushNavigationEventCopyWith<$Res> {
  factory _$$CommunityPostPushEventImplCopyWith(
    _$CommunityPostPushEventImpl value,
    $Res Function(_$CommunityPostPushEventImpl) then,
  ) = __$$CommunityPostPushEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int postId});
}

/// @nodoc
class __$$CommunityPostPushEventImplCopyWithImpl<$Res>
    extends
        _$PushNavigationEventCopyWithImpl<$Res, _$CommunityPostPushEventImpl>
    implements _$$CommunityPostPushEventImplCopyWith<$Res> {
  __$$CommunityPostPushEventImplCopyWithImpl(
    _$CommunityPostPushEventImpl _value,
    $Res Function(_$CommunityPostPushEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PushNavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? postId = null}) {
    return _then(
      _$CommunityPostPushEventImpl(
        postId: null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$CommunityPostPushEventImpl implements CommunityPostPushEvent {
  const _$CommunityPostPushEventImpl({required this.postId});

  @override
  final int postId;

  @override
  String toString() {
    return 'PushNavigationEvent.communityPost(postId: $postId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostPushEventImpl &&
            (identical(other.postId, postId) || other.postId == postId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId);

  /// Create a copy of PushNavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostPushEventImplCopyWith<_$CommunityPostPushEventImpl>
  get copyWith =>
      __$$CommunityPostPushEventImplCopyWithImpl<_$CommunityPostPushEventImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int postId) communityPost,
  }) {
    return communityPost(postId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int postId)? communityPost,
  }) {
    return communityPost?.call(postId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int postId)? communityPost,
    required TResult orElse(),
  }) {
    if (communityPost != null) {
      return communityPost(postId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CommunityPostPushEvent value) communityPost,
  }) {
    return communityPost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CommunityPostPushEvent value)? communityPost,
  }) {
    return communityPost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CommunityPostPushEvent value)? communityPost,
    required TResult orElse(),
  }) {
    if (communityPost != null) {
      return communityPost(this);
    }
    return orElse();
  }
}

abstract class CommunityPostPushEvent implements PushNavigationEvent {
  const factory CommunityPostPushEvent({required final int postId}) =
      _$CommunityPostPushEventImpl;

  @override
  int get postId;

  /// Create a copy of PushNavigationEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostPushEventImplCopyWith<_$CommunityPostPushEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}
