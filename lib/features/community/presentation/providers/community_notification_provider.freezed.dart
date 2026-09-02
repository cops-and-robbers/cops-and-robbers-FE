// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_notification_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityNotificationState {
  List<CommunityNotificationEntity> get items =>
      throw _privateConstructorUsedError;
  int? get nextCursor => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// Create a copy of CommunityNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityNotificationStateCopyWith<CommunityNotificationState>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityNotificationStateCopyWith<$Res> {
  factory $CommunityNotificationStateCopyWith(
    CommunityNotificationState value,
    $Res Function(CommunityNotificationState) then,
  ) =
      _$CommunityNotificationStateCopyWithImpl<
        $Res,
        CommunityNotificationState
      >;
  @useResult
  $Res call({
    List<CommunityNotificationEntity> items,
    int? nextCursor,
    bool hasMore,
    bool isLoadingMore,
  });
}

/// @nodoc
class _$CommunityNotificationStateCopyWithImpl<
  $Res,
  $Val extends CommunityNotificationState
>
    implements $CommunityNotificationStateCopyWith<$Res> {
  _$CommunityNotificationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = null,
    Object? isLoadingMore = null,
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
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingMore: null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityNotificationStateImplCopyWith<$Res>
    implements $CommunityNotificationStateCopyWith<$Res> {
  factory _$$CommunityNotificationStateImplCopyWith(
    _$CommunityNotificationStateImpl value,
    $Res Function(_$CommunityNotificationStateImpl) then,
  ) = __$$CommunityNotificationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CommunityNotificationEntity> items,
    int? nextCursor,
    bool hasMore,
    bool isLoadingMore,
  });
}

/// @nodoc
class __$$CommunityNotificationStateImplCopyWithImpl<$Res>
    extends
        _$CommunityNotificationStateCopyWithImpl<
          $Res,
          _$CommunityNotificationStateImpl
        >
    implements _$$CommunityNotificationStateImplCopyWith<$Res> {
  __$$CommunityNotificationStateImplCopyWithImpl(
    _$CommunityNotificationStateImpl _value,
    $Res Function(_$CommunityNotificationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = null,
    Object? isLoadingMore = null,
  }) {
    return _then(
      _$CommunityNotificationStateImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CommunityNotificationEntity>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as int?,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CommunityNotificationStateImpl implements _CommunityNotificationState {
  const _$CommunityNotificationStateImpl({
    required final List<CommunityNotificationEntity> items,
    required this.nextCursor,
    required this.hasMore,
    this.isLoadingMore = false,
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
  final bool hasMore;
  @override
  @JsonKey()
  final bool isLoadingMore;

  @override
  String toString() {
    return 'CommunityNotificationState(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityNotificationStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    nextCursor,
    hasMore,
    isLoadingMore,
  );

  /// Create a copy of CommunityNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityNotificationStateImplCopyWith<_$CommunityNotificationStateImpl>
  get copyWith =>
      __$$CommunityNotificationStateImplCopyWithImpl<
        _$CommunityNotificationStateImpl
      >(this, _$identity);
}

abstract class _CommunityNotificationState
    implements CommunityNotificationState {
  const factory _CommunityNotificationState({
    required final List<CommunityNotificationEntity> items,
    required final int? nextCursor,
    required final bool hasMore,
    final bool isLoadingMore,
  }) = _$CommunityNotificationStateImpl;

  @override
  List<CommunityNotificationEntity> get items;
  @override
  int? get nextCursor;
  @override
  bool get hasMore;
  @override
  bool get isLoadingMore;

  /// Create a copy of CommunityNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityNotificationStateImplCopyWith<_$CommunityNotificationStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
