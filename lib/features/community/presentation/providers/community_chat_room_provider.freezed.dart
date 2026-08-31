// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_chat_room_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityChatRoomState {
  CommunityChatTimeline get timeline => throw _privateConstructorUsedError;
  CommunityChatConnectionState get connection =>
      throw _privateConstructorUsedError;

  /// 목록(`GET /chat/rooms`)에서 찾은 인원수. 못 찾으면 null — 헤더가 정원만 그린다.
  int? get memberCount => throw _privateConstructorUsedError;
  int? get nextCursor => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get loadingOlder => throw _privateConstructorUsedError;

  /// 방 멤버가 아니라는 소켓 에러(다른 기기에서 나감). 화면이 목록으로 나간다.
  bool get evicted => throw _privateConstructorUsedError;

  /// 가장 최근 소켓 에러 코드. [errorSeq]가 바뀔 때마다 화면이 한 번 알린다.
  String? get lastErrorCode => throw _privateConstructorUsedError;
  int get errorSeq => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatRoomState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatRoomStateCopyWith<CommunityChatRoomState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatRoomStateCopyWith<$Res> {
  factory $CommunityChatRoomStateCopyWith(
    CommunityChatRoomState value,
    $Res Function(CommunityChatRoomState) then,
  ) = _$CommunityChatRoomStateCopyWithImpl<$Res, CommunityChatRoomState>;
  @useResult
  $Res call({
    CommunityChatTimeline timeline,
    CommunityChatConnectionState connection,
    int? memberCount,
    int? nextCursor,
    bool hasNext,
    bool loadingOlder,
    bool evicted,
    String? lastErrorCode,
    int errorSeq,
  });
}

/// @nodoc
class _$CommunityChatRoomStateCopyWithImpl<
  $Res,
  $Val extends CommunityChatRoomState
>
    implements $CommunityChatRoomStateCopyWith<$Res> {
  _$CommunityChatRoomStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatRoomState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timeline = null,
    Object? connection = null,
    Object? memberCount = freezed,
    Object? nextCursor = freezed,
    Object? hasNext = null,
    Object? loadingOlder = null,
    Object? evicted = null,
    Object? lastErrorCode = freezed,
    Object? errorSeq = null,
  }) {
    return _then(
      _value.copyWith(
            timeline: null == timeline
                ? _value.timeline
                : timeline // ignore: cast_nullable_to_non_nullable
                      as CommunityChatTimeline,
            connection: null == connection
                ? _value.connection
                : connection // ignore: cast_nullable_to_non_nullable
                      as CommunityChatConnectionState,
            memberCount: freezed == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as int?,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
            loadingOlder: null == loadingOlder
                ? _value.loadingOlder
                : loadingOlder // ignore: cast_nullable_to_non_nullable
                      as bool,
            evicted: null == evicted
                ? _value.evicted
                : evicted // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastErrorCode: freezed == lastErrorCode
                ? _value.lastErrorCode
                : lastErrorCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorSeq: null == errorSeq
                ? _value.errorSeq
                : errorSeq // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatRoomStateImplCopyWith<$Res>
    implements $CommunityChatRoomStateCopyWith<$Res> {
  factory _$$CommunityChatRoomStateImplCopyWith(
    _$CommunityChatRoomStateImpl value,
    $Res Function(_$CommunityChatRoomStateImpl) then,
  ) = __$$CommunityChatRoomStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CommunityChatTimeline timeline,
    CommunityChatConnectionState connection,
    int? memberCount,
    int? nextCursor,
    bool hasNext,
    bool loadingOlder,
    bool evicted,
    String? lastErrorCode,
    int errorSeq,
  });
}

/// @nodoc
class __$$CommunityChatRoomStateImplCopyWithImpl<$Res>
    extends
        _$CommunityChatRoomStateCopyWithImpl<$Res, _$CommunityChatRoomStateImpl>
    implements _$$CommunityChatRoomStateImplCopyWith<$Res> {
  __$$CommunityChatRoomStateImplCopyWithImpl(
    _$CommunityChatRoomStateImpl _value,
    $Res Function(_$CommunityChatRoomStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatRoomState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timeline = null,
    Object? connection = null,
    Object? memberCount = freezed,
    Object? nextCursor = freezed,
    Object? hasNext = null,
    Object? loadingOlder = null,
    Object? evicted = null,
    Object? lastErrorCode = freezed,
    Object? errorSeq = null,
  }) {
    return _then(
      _$CommunityChatRoomStateImpl(
        timeline: null == timeline
            ? _value.timeline
            : timeline // ignore: cast_nullable_to_non_nullable
                  as CommunityChatTimeline,
        connection: null == connection
            ? _value.connection
            : connection // ignore: cast_nullable_to_non_nullable
                  as CommunityChatConnectionState,
        memberCount: freezed == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as int?,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
        loadingOlder: null == loadingOlder
            ? _value.loadingOlder
            : loadingOlder // ignore: cast_nullable_to_non_nullable
                  as bool,
        evicted: null == evicted
            ? _value.evicted
            : evicted // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastErrorCode: freezed == lastErrorCode
            ? _value.lastErrorCode
            : lastErrorCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorSeq: null == errorSeq
            ? _value.errorSeq
            : errorSeq // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatRoomStateImpl
    with DiagnosticableTreeMixin
    implements _CommunityChatRoomState {
  const _$CommunityChatRoomStateImpl({
    required this.timeline,
    this.connection = CommunityChatConnectionState.connecting,
    this.memberCount,
    this.nextCursor,
    this.hasNext = false,
    this.loadingOlder = false,
    this.evicted = false,
    this.lastErrorCode,
    this.errorSeq = 0,
  });

  @override
  final CommunityChatTimeline timeline;
  @override
  @JsonKey()
  final CommunityChatConnectionState connection;

  /// 목록(`GET /chat/rooms`)에서 찾은 인원수. 못 찾으면 null — 헤더가 정원만 그린다.
  @override
  final int? memberCount;
  @override
  final int? nextCursor;
  @override
  @JsonKey()
  final bool hasNext;
  @override
  @JsonKey()
  final bool loadingOlder;

  /// 방 멤버가 아니라는 소켓 에러(다른 기기에서 나감). 화면이 목록으로 나간다.
  @override
  @JsonKey()
  final bool evicted;

  /// 가장 최근 소켓 에러 코드. [errorSeq]가 바뀔 때마다 화면이 한 번 알린다.
  @override
  final String? lastErrorCode;
  @override
  @JsonKey()
  final int errorSeq;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommunityChatRoomState(timeline: $timeline, connection: $connection, memberCount: $memberCount, nextCursor: $nextCursor, hasNext: $hasNext, loadingOlder: $loadingOlder, evicted: $evicted, lastErrorCode: $lastErrorCode, errorSeq: $errorSeq)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CommunityChatRoomState'))
      ..add(DiagnosticsProperty('timeline', timeline))
      ..add(DiagnosticsProperty('connection', connection))
      ..add(DiagnosticsProperty('memberCount', memberCount))
      ..add(DiagnosticsProperty('nextCursor', nextCursor))
      ..add(DiagnosticsProperty('hasNext', hasNext))
      ..add(DiagnosticsProperty('loadingOlder', loadingOlder))
      ..add(DiagnosticsProperty('evicted', evicted))
      ..add(DiagnosticsProperty('lastErrorCode', lastErrorCode))
      ..add(DiagnosticsProperty('errorSeq', errorSeq));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatRoomStateImpl &&
            (identical(other.timeline, timeline) ||
                other.timeline == timeline) &&
            (identical(other.connection, connection) ||
                other.connection == connection) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.loadingOlder, loadingOlder) ||
                other.loadingOlder == loadingOlder) &&
            (identical(other.evicted, evicted) || other.evicted == evicted) &&
            (identical(other.lastErrorCode, lastErrorCode) ||
                other.lastErrorCode == lastErrorCode) &&
            (identical(other.errorSeq, errorSeq) ||
                other.errorSeq == errorSeq));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    timeline,
    connection,
    memberCount,
    nextCursor,
    hasNext,
    loadingOlder,
    evicted,
    lastErrorCode,
    errorSeq,
  );

  /// Create a copy of CommunityChatRoomState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatRoomStateImplCopyWith<_$CommunityChatRoomStateImpl>
  get copyWith =>
      __$$CommunityChatRoomStateImplCopyWithImpl<_$CommunityChatRoomStateImpl>(
        this,
        _$identity,
      );
}

abstract class _CommunityChatRoomState implements CommunityChatRoomState {
  const factory _CommunityChatRoomState({
    required final CommunityChatTimeline timeline,
    final CommunityChatConnectionState connection,
    final int? memberCount,
    final int? nextCursor,
    final bool hasNext,
    final bool loadingOlder,
    final bool evicted,
    final String? lastErrorCode,
    final int errorSeq,
  }) = _$CommunityChatRoomStateImpl;

  @override
  CommunityChatTimeline get timeline;
  @override
  CommunityChatConnectionState get connection;

  /// 목록(`GET /chat/rooms`)에서 찾은 인원수. 못 찾으면 null — 헤더가 정원만 그린다.
  @override
  int? get memberCount;
  @override
  int? get nextCursor;
  @override
  bool get hasNext;
  @override
  bool get loadingOlder;

  /// 방 멤버가 아니라는 소켓 에러(다른 기기에서 나감). 화면이 목록으로 나간다.
  @override
  bool get evicted;

  /// 가장 최근 소켓 에러 코드. [errorSeq]가 바뀔 때마다 화면이 한 번 알린다.
  @override
  String? get lastErrorCode;
  @override
  int get errorSeq;

  /// Create a copy of CommunityChatRoomState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatRoomStateImplCopyWith<_$CommunityChatRoomStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
