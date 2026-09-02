// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_chat_page_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityChatPageEntity {
  List<CommunityChatMessageEntity> get messages =>
      throw _privateConstructorUsedError;
  int? get nextCursor => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatPageEntityCopyWith<CommunityChatPageEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatPageEntityCopyWith<$Res> {
  factory $CommunityChatPageEntityCopyWith(
    CommunityChatPageEntity value,
    $Res Function(CommunityChatPageEntity) then,
  ) = _$CommunityChatPageEntityCopyWithImpl<$Res, CommunityChatPageEntity>;
  @useResult
  $Res call({
    List<CommunityChatMessageEntity> messages,
    int? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class _$CommunityChatPageEntityCopyWithImpl<
  $Res,
  $Val extends CommunityChatPageEntity
>
    implements $CommunityChatPageEntityCopyWith<$Res> {
  _$CommunityChatPageEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? nextCursor = freezed,
    Object? hasNext = null,
  }) {
    return _then(
      _value.copyWith(
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<CommunityChatMessageEntity>,
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
abstract class _$$CommunityChatPageEntityImplCopyWith<$Res>
    implements $CommunityChatPageEntityCopyWith<$Res> {
  factory _$$CommunityChatPageEntityImplCopyWith(
    _$CommunityChatPageEntityImpl value,
    $Res Function(_$CommunityChatPageEntityImpl) then,
  ) = __$$CommunityChatPageEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CommunityChatMessageEntity> messages,
    int? nextCursor,
    bool hasNext,
  });
}

/// @nodoc
class __$$CommunityChatPageEntityImplCopyWithImpl<$Res>
    extends
        _$CommunityChatPageEntityCopyWithImpl<
          $Res,
          _$CommunityChatPageEntityImpl
        >
    implements _$$CommunityChatPageEntityImplCopyWith<$Res> {
  __$$CommunityChatPageEntityImplCopyWithImpl(
    _$CommunityChatPageEntityImpl _value,
    $Res Function(_$CommunityChatPageEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? nextCursor = freezed,
    Object? hasNext = null,
  }) {
    return _then(
      _$CommunityChatPageEntityImpl(
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<CommunityChatMessageEntity>,
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

class _$CommunityChatPageEntityImpl implements _CommunityChatPageEntity {
  const _$CommunityChatPageEntityImpl({
    required final List<CommunityChatMessageEntity> messages,
    required this.nextCursor,
    required this.hasNext,
  }) : _messages = messages;

  final List<CommunityChatMessageEntity> _messages;
  @override
  List<CommunityChatMessageEntity> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final int? nextCursor;
  @override
  final bool hasNext;

  @override
  String toString() {
    return 'CommunityChatPageEntity(messages: $messages, nextCursor: $nextCursor, hasNext: $hasNext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatPageEntityImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_messages),
    nextCursor,
    hasNext,
  );

  /// Create a copy of CommunityChatPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatPageEntityImplCopyWith<_$CommunityChatPageEntityImpl>
  get copyWith =>
      __$$CommunityChatPageEntityImplCopyWithImpl<
        _$CommunityChatPageEntityImpl
      >(this, _$identity);
}

abstract class _CommunityChatPageEntity implements CommunityChatPageEntity {
  const factory _CommunityChatPageEntity({
    required final List<CommunityChatMessageEntity> messages,
    required final int? nextCursor,
    required final bool hasNext,
  }) = _$CommunityChatPageEntityImpl;

  @override
  List<CommunityChatMessageEntity> get messages;
  @override
  int? get nextCursor;
  @override
  bool get hasNext;

  /// Create a copy of CommunityChatPageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatPageEntityImplCopyWith<_$CommunityChatPageEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
