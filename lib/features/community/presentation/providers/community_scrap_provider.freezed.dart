// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_scrap_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityScrapState {
  List<CommunityPostEntity> get items => throw _privateConstructorUsedError;
  int? get nextCursor => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// Create a copy of CommunityScrapState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityScrapStateCopyWith<CommunityScrapState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityScrapStateCopyWith<$Res> {
  factory $CommunityScrapStateCopyWith(
    CommunityScrapState value,
    $Res Function(CommunityScrapState) then,
  ) = _$CommunityScrapStateCopyWithImpl<$Res, CommunityScrapState>;
  @useResult
  $Res call({
    List<CommunityPostEntity> items,
    int? nextCursor,
    bool hasMore,
    bool isLoadingMore,
  });
}

/// @nodoc
class _$CommunityScrapStateCopyWithImpl<$Res, $Val extends CommunityScrapState>
    implements $CommunityScrapStateCopyWith<$Res> {
  _$CommunityScrapStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityScrapState
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
                      as List<CommunityPostEntity>,
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
abstract class _$$CommunityScrapStateImplCopyWith<$Res>
    implements $CommunityScrapStateCopyWith<$Res> {
  factory _$$CommunityScrapStateImplCopyWith(
    _$CommunityScrapStateImpl value,
    $Res Function(_$CommunityScrapStateImpl) then,
  ) = __$$CommunityScrapStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CommunityPostEntity> items,
    int? nextCursor,
    bool hasMore,
    bool isLoadingMore,
  });
}

/// @nodoc
class __$$CommunityScrapStateImplCopyWithImpl<$Res>
    extends _$CommunityScrapStateCopyWithImpl<$Res, _$CommunityScrapStateImpl>
    implements _$$CommunityScrapStateImplCopyWith<$Res> {
  __$$CommunityScrapStateImplCopyWithImpl(
    _$CommunityScrapStateImpl _value,
    $Res Function(_$CommunityScrapStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityScrapState
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
      _$CommunityScrapStateImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CommunityPostEntity>,
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

class _$CommunityScrapStateImpl implements _CommunityScrapState {
  const _$CommunityScrapStateImpl({
    required final List<CommunityPostEntity> items,
    required this.nextCursor,
    required this.hasMore,
    this.isLoadingMore = false,
  }) : _items = items;

  final List<CommunityPostEntity> _items;
  @override
  List<CommunityPostEntity> get items {
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
    return 'CommunityScrapState(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityScrapStateImpl &&
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

  /// Create a copy of CommunityScrapState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityScrapStateImplCopyWith<_$CommunityScrapStateImpl> get copyWith =>
      __$$CommunityScrapStateImplCopyWithImpl<_$CommunityScrapStateImpl>(
        this,
        _$identity,
      );
}

abstract class _CommunityScrapState implements CommunityScrapState {
  const factory _CommunityScrapState({
    required final List<CommunityPostEntity> items,
    required final int? nextCursor,
    required final bool hasMore,
    final bool isLoadingMore,
  }) = _$CommunityScrapStateImpl;

  @override
  List<CommunityPostEntity> get items;
  @override
  int? get nextCursor;
  @override
  bool get hasMore;
  @override
  bool get isLoadingMore;

  /// Create a copy of CommunityScrapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityScrapStateImplCopyWith<_$CommunityScrapStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
