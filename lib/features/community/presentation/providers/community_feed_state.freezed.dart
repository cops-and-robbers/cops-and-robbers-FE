// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityFeedState {
  List<CommunityPostEntity> get items => throw _privateConstructorUsedError;

  /// 다음 요청에 그대로 실을 커서. 첫 페이지만 받은 직후에는 서버가 준
  /// `nextCursor`가 들어 있고, 더 없으면 null이다.
  String? get nextCursor => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// 이 목록이 속한 국가 코드. 첫 페이지를 좌표로 물었을 때 서버가 판별해 준
  /// 값이며, 다음 페이지부터는 좌표 대신 이걸 보낸다 — 스크롤할 때마다 GPS를
  /// 다시 켜지 않으려는 것이다.
  String? get countryCode => throw _privateConstructorUsedError;

  /// Create a copy of CommunityFeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityFeedStateCopyWith<CommunityFeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityFeedStateCopyWith<$Res> {
  factory $CommunityFeedStateCopyWith(
    CommunityFeedState value,
    $Res Function(CommunityFeedState) then,
  ) = _$CommunityFeedStateCopyWithImpl<$Res, CommunityFeedState>;
  @useResult
  $Res call({
    List<CommunityPostEntity> items,
    String? nextCursor,
    bool hasMore,
    bool isLoadingMore,
    String? countryCode,
  });
}

/// @nodoc
class _$CommunityFeedStateCopyWithImpl<$Res, $Val extends CommunityFeedState>
    implements $CommunityFeedStateCopyWith<$Res> {
  _$CommunityFeedStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityFeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = null,
    Object? isLoadingMore = null,
    Object? countryCode = freezed,
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
                      as String?,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingMore: null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            countryCode: freezed == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityFeedStateImplCopyWith<$Res>
    implements $CommunityFeedStateCopyWith<$Res> {
  factory _$$CommunityFeedStateImplCopyWith(
    _$CommunityFeedStateImpl value,
    $Res Function(_$CommunityFeedStateImpl) then,
  ) = __$$CommunityFeedStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CommunityPostEntity> items,
    String? nextCursor,
    bool hasMore,
    bool isLoadingMore,
    String? countryCode,
  });
}

/// @nodoc
class __$$CommunityFeedStateImplCopyWithImpl<$Res>
    extends _$CommunityFeedStateCopyWithImpl<$Res, _$CommunityFeedStateImpl>
    implements _$$CommunityFeedStateImplCopyWith<$Res> {
  __$$CommunityFeedStateImplCopyWithImpl(
    _$CommunityFeedStateImpl _value,
    $Res Function(_$CommunityFeedStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityFeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = null,
    Object? isLoadingMore = null,
    Object? countryCode = freezed,
  }) {
    return _then(
      _$CommunityFeedStateImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CommunityPostEntity>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        countryCode: freezed == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$CommunityFeedStateImpl implements _CommunityFeedState {
  const _$CommunityFeedStateImpl({
    required final List<CommunityPostEntity> items,
    required this.nextCursor,
    required this.hasMore,
    this.isLoadingMore = false,
    this.countryCode,
  }) : _items = items;

  final List<CommunityPostEntity> _items;
  @override
  List<CommunityPostEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// 다음 요청에 그대로 실을 커서. 첫 페이지만 받은 직후에는 서버가 준
  /// `nextCursor`가 들어 있고, 더 없으면 null이다.
  @override
  final String? nextCursor;
  @override
  final bool hasMore;
  @override
  @JsonKey()
  final bool isLoadingMore;

  /// 이 목록이 속한 국가 코드. 첫 페이지를 좌표로 물었을 때 서버가 판별해 준
  /// 값이며, 다음 페이지부터는 좌표 대신 이걸 보낸다 — 스크롤할 때마다 GPS를
  /// 다시 켜지 않으려는 것이다.
  @override
  final String? countryCode;

  @override
  String toString() {
    return 'CommunityFeedState(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingMore: $isLoadingMore, countryCode: $countryCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityFeedStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    nextCursor,
    hasMore,
    isLoadingMore,
    countryCode,
  );

  /// Create a copy of CommunityFeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityFeedStateImplCopyWith<_$CommunityFeedStateImpl> get copyWith =>
      __$$CommunityFeedStateImplCopyWithImpl<_$CommunityFeedStateImpl>(
        this,
        _$identity,
      );
}

abstract class _CommunityFeedState implements CommunityFeedState {
  const factory _CommunityFeedState({
    required final List<CommunityPostEntity> items,
    required final String? nextCursor,
    required final bool hasMore,
    final bool isLoadingMore,
    final String? countryCode,
  }) = _$CommunityFeedStateImpl;

  @override
  List<CommunityPostEntity> get items;

  /// 다음 요청에 그대로 실을 커서. 첫 페이지만 받은 직후에는 서버가 준
  /// `nextCursor`가 들어 있고, 더 없으면 null이다.
  @override
  String? get nextCursor;
  @override
  bool get hasMore;
  @override
  bool get isLoadingMore;

  /// 이 목록이 속한 국가 코드. 첫 페이지를 좌표로 물었을 때 서버가 판별해 준
  /// 값이며, 다음 페이지부터는 좌표 대신 이걸 보낸다 — 스크롤할 때마다 GPS를
  /// 다시 켜지 않으려는 것이다.
  @override
  String? get countryCode;

  /// Create a copy of CommunityFeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityFeedStateImplCopyWith<_$CommunityFeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
