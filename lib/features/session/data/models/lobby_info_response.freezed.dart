// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lobby_info_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LobbyInfoResponse _$LobbyInfoResponseFromJson(Map<String, dynamic> json) {
  return _LobbyInfoResponse.fromJson(json);
}

/// @nodoc
mixin _$LobbyInfoResponse {
  /// 내 participantId
  int get myParticipantId => throw _privateConstructorUsedError;

  /// 방장 participantId
  int get hostParticipantId => throw _privateConstructorUsedError;

  /// 전체 참가자 목록
  List<LobbyParticipantInfo> get participants =>
      throw _privateConstructorUsedError;

  /// 초대 코드 (재접속 시 AppBar 표시용)
  String? get inviteCode => throw _privateConstructorUsedError;

  /// Serializes this LobbyInfoResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LobbyInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LobbyInfoResponseCopyWith<LobbyInfoResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LobbyInfoResponseCopyWith<$Res> {
  factory $LobbyInfoResponseCopyWith(
    LobbyInfoResponse value,
    $Res Function(LobbyInfoResponse) then,
  ) = _$LobbyInfoResponseCopyWithImpl<$Res, LobbyInfoResponse>;
  @useResult
  $Res call({
    int myParticipantId,
    int hostParticipantId,
    List<LobbyParticipantInfo> participants,
    String? inviteCode,
  });
}

/// @nodoc
class _$LobbyInfoResponseCopyWithImpl<$Res, $Val extends LobbyInfoResponse>
    implements $LobbyInfoResponseCopyWith<$Res> {
  _$LobbyInfoResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LobbyInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? myParticipantId = null,
    Object? hostParticipantId = null,
    Object? participants = null,
    Object? inviteCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            myParticipantId: null == myParticipantId
                ? _value.myParticipantId
                : myParticipantId // ignore: cast_nullable_to_non_nullable
                      as int,
            hostParticipantId: null == hostParticipantId
                ? _value.hostParticipantId
                : hostParticipantId // ignore: cast_nullable_to_non_nullable
                      as int,
            participants: null == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as List<LobbyParticipantInfo>,
            inviteCode: freezed == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LobbyInfoResponseImplCopyWith<$Res>
    implements $LobbyInfoResponseCopyWith<$Res> {
  factory _$$LobbyInfoResponseImplCopyWith(
    _$LobbyInfoResponseImpl value,
    $Res Function(_$LobbyInfoResponseImpl) then,
  ) = __$$LobbyInfoResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int myParticipantId,
    int hostParticipantId,
    List<LobbyParticipantInfo> participants,
    String? inviteCode,
  });
}

/// @nodoc
class __$$LobbyInfoResponseImplCopyWithImpl<$Res>
    extends _$LobbyInfoResponseCopyWithImpl<$Res, _$LobbyInfoResponseImpl>
    implements _$$LobbyInfoResponseImplCopyWith<$Res> {
  __$$LobbyInfoResponseImplCopyWithImpl(
    _$LobbyInfoResponseImpl _value,
    $Res Function(_$LobbyInfoResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LobbyInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? myParticipantId = null,
    Object? hostParticipantId = null,
    Object? participants = null,
    Object? inviteCode = freezed,
  }) {
    return _then(
      _$LobbyInfoResponseImpl(
        myParticipantId: null == myParticipantId
            ? _value.myParticipantId
            : myParticipantId // ignore: cast_nullable_to_non_nullable
                  as int,
        hostParticipantId: null == hostParticipantId
            ? _value.hostParticipantId
            : hostParticipantId // ignore: cast_nullable_to_non_nullable
                  as int,
        participants: null == participants
            ? _value._participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as List<LobbyParticipantInfo>,
        inviteCode: freezed == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LobbyInfoResponseImpl implements _LobbyInfoResponse {
  const _$LobbyInfoResponseImpl({
    required this.myParticipantId,
    required this.hostParticipantId,
    required final List<LobbyParticipantInfo> participants,
    this.inviteCode,
  }) : _participants = participants;

  factory _$LobbyInfoResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LobbyInfoResponseImplFromJson(json);

  /// 내 participantId
  @override
  final int myParticipantId;

  /// 방장 participantId
  @override
  final int hostParticipantId;

  /// 전체 참가자 목록
  final List<LobbyParticipantInfo> _participants;

  /// 전체 참가자 목록
  @override
  List<LobbyParticipantInfo> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  /// 초대 코드 (재접속 시 AppBar 표시용)
  @override
  final String? inviteCode;

  @override
  String toString() {
    return 'LobbyInfoResponse(myParticipantId: $myParticipantId, hostParticipantId: $hostParticipantId, participants: $participants, inviteCode: $inviteCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LobbyInfoResponseImpl &&
            (identical(other.myParticipantId, myParticipantId) ||
                other.myParticipantId == myParticipantId) &&
            (identical(other.hostParticipantId, hostParticipantId) ||
                other.hostParticipantId == hostParticipantId) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    myParticipantId,
    hostParticipantId,
    const DeepCollectionEquality().hash(_participants),
    inviteCode,
  );

  /// Create a copy of LobbyInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LobbyInfoResponseImplCopyWith<_$LobbyInfoResponseImpl> get copyWith =>
      __$$LobbyInfoResponseImplCopyWithImpl<_$LobbyInfoResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LobbyInfoResponseImplToJson(this);
  }
}

abstract class _LobbyInfoResponse implements LobbyInfoResponse {
  const factory _LobbyInfoResponse({
    required final int myParticipantId,
    required final int hostParticipantId,
    required final List<LobbyParticipantInfo> participants,
    final String? inviteCode,
  }) = _$LobbyInfoResponseImpl;

  factory _LobbyInfoResponse.fromJson(Map<String, dynamic> json) =
      _$LobbyInfoResponseImpl.fromJson;

  /// 내 participantId
  @override
  int get myParticipantId;

  /// 방장 participantId
  @override
  int get hostParticipantId;

  /// 전체 참가자 목록
  @override
  List<LobbyParticipantInfo> get participants;

  /// 초대 코드 (재접속 시 AppBar 표시용)
  @override
  String? get inviteCode;

  /// Create a copy of LobbyInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LobbyInfoResponseImplCopyWith<_$LobbyInfoResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
