// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'in_game_participants_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InGameParticipant _$InGameParticipantFromJson(Map<String, dynamic> json) {
  return _InGameParticipant.fromJson(json);
}

/// @nodoc
mixin _$InGameParticipant {
  /// 참가자 ID
  int get participantId => throw _privateConstructorUsedError;

  /// 닉네임
  String get nickname => throw _privateConstructorUsedError;

  /// 상태 ("POLICE_WAITING" / "ALIVE" / "JAILED")
  String get status => throw _privateConstructorUsedError;

  /// Serializes this InGameParticipant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InGameParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InGameParticipantCopyWith<InGameParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InGameParticipantCopyWith<$Res> {
  factory $InGameParticipantCopyWith(
    InGameParticipant value,
    $Res Function(InGameParticipant) then,
  ) = _$InGameParticipantCopyWithImpl<$Res, InGameParticipant>;
  @useResult
  $Res call({int participantId, String nickname, String status});
}

/// @nodoc
class _$InGameParticipantCopyWithImpl<$Res, $Val extends InGameParticipant>
    implements $InGameParticipantCopyWith<$Res> {
  _$InGameParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InGameParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            participantId: null == participantId
                ? _value.participantId
                : participantId // ignore: cast_nullable_to_non_nullable
                      as int,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InGameParticipantImplCopyWith<$Res>
    implements $InGameParticipantCopyWith<$Res> {
  factory _$$InGameParticipantImplCopyWith(
    _$InGameParticipantImpl value,
    $Res Function(_$InGameParticipantImpl) then,
  ) = __$$InGameParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int participantId, String nickname, String status});
}

/// @nodoc
class __$$InGameParticipantImplCopyWithImpl<$Res>
    extends _$InGameParticipantCopyWithImpl<$Res, _$InGameParticipantImpl>
    implements _$$InGameParticipantImplCopyWith<$Res> {
  __$$InGameParticipantImplCopyWithImpl(
    _$InGameParticipantImpl _value,
    $Res Function(_$InGameParticipantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InGameParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? status = null,
  }) {
    return _then(
      _$InGameParticipantImpl(
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InGameParticipantImpl implements _InGameParticipant {
  const _$InGameParticipantImpl({
    required this.participantId,
    required this.nickname,
    required this.status,
  });

  factory _$InGameParticipantImpl.fromJson(Map<String, dynamic> json) =>
      _$$InGameParticipantImplFromJson(json);

  /// 참가자 ID
  @override
  final int participantId;

  /// 닉네임
  @override
  final String nickname;

  /// 상태 ("POLICE_WAITING" / "ALIVE" / "JAILED")
  @override
  final String status;

  @override
  String toString() {
    return 'InGameParticipant(participantId: $participantId, nickname: $nickname, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InGameParticipantImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, participantId, nickname, status);

  /// Create a copy of InGameParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InGameParticipantImplCopyWith<_$InGameParticipantImpl> get copyWith =>
      __$$InGameParticipantImplCopyWithImpl<_$InGameParticipantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InGameParticipantImplToJson(this);
  }
}

abstract class _InGameParticipant implements InGameParticipant {
  const factory _InGameParticipant({
    required final int participantId,
    required final String nickname,
    required final String status,
  }) = _$InGameParticipantImpl;

  factory _InGameParticipant.fromJson(Map<String, dynamic> json) =
      _$InGameParticipantImpl.fromJson;

  /// 참가자 ID
  @override
  int get participantId;

  /// 닉네임
  @override
  String get nickname;

  /// 상태 ("POLICE_WAITING" / "ALIVE" / "JAILED")
  @override
  String get status;

  /// Create a copy of InGameParticipant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InGameParticipantImplCopyWith<_$InGameParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InGameParticipantsResponse _$InGameParticipantsResponseFromJson(
  Map<String, dynamic> json,
) {
  return _InGameParticipantsResponse.fromJson(json);
}

/// @nodoc
mixin _$InGameParticipantsResponse {
  /// 경찰 목록
  List<InGameParticipant> get police => throw _privateConstructorUsedError;

  /// 도둑 목록
  List<InGameParticipant> get robbers => throw _privateConstructorUsedError;

  /// Serializes this InGameParticipantsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InGameParticipantsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InGameParticipantsResponseCopyWith<InGameParticipantsResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InGameParticipantsResponseCopyWith<$Res> {
  factory $InGameParticipantsResponseCopyWith(
    InGameParticipantsResponse value,
    $Res Function(InGameParticipantsResponse) then,
  ) =
      _$InGameParticipantsResponseCopyWithImpl<
        $Res,
        InGameParticipantsResponse
      >;
  @useResult
  $Res call({List<InGameParticipant> police, List<InGameParticipant> robbers});
}

/// @nodoc
class _$InGameParticipantsResponseCopyWithImpl<
  $Res,
  $Val extends InGameParticipantsResponse
>
    implements $InGameParticipantsResponseCopyWith<$Res> {
  _$InGameParticipantsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InGameParticipantsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? police = null, Object? robbers = null}) {
    return _then(
      _value.copyWith(
            police: null == police
                ? _value.police
                : police // ignore: cast_nullable_to_non_nullable
                      as List<InGameParticipant>,
            robbers: null == robbers
                ? _value.robbers
                : robbers // ignore: cast_nullable_to_non_nullable
                      as List<InGameParticipant>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InGameParticipantsResponseImplCopyWith<$Res>
    implements $InGameParticipantsResponseCopyWith<$Res> {
  factory _$$InGameParticipantsResponseImplCopyWith(
    _$InGameParticipantsResponseImpl value,
    $Res Function(_$InGameParticipantsResponseImpl) then,
  ) = __$$InGameParticipantsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<InGameParticipant> police, List<InGameParticipant> robbers});
}

/// @nodoc
class __$$InGameParticipantsResponseImplCopyWithImpl<$Res>
    extends
        _$InGameParticipantsResponseCopyWithImpl<
          $Res,
          _$InGameParticipantsResponseImpl
        >
    implements _$$InGameParticipantsResponseImplCopyWith<$Res> {
  __$$InGameParticipantsResponseImplCopyWithImpl(
    _$InGameParticipantsResponseImpl _value,
    $Res Function(_$InGameParticipantsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InGameParticipantsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? police = null, Object? robbers = null}) {
    return _then(
      _$InGameParticipantsResponseImpl(
        police: null == police
            ? _value._police
            : police // ignore: cast_nullable_to_non_nullable
                  as List<InGameParticipant>,
        robbers: null == robbers
            ? _value._robbers
            : robbers // ignore: cast_nullable_to_non_nullable
                  as List<InGameParticipant>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InGameParticipantsResponseImpl implements _InGameParticipantsResponse {
  const _$InGameParticipantsResponseImpl({
    required final List<InGameParticipant> police,
    required final List<InGameParticipant> robbers,
  }) : _police = police,
       _robbers = robbers;

  factory _$InGameParticipantsResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$InGameParticipantsResponseImplFromJson(json);

  /// 경찰 목록
  final List<InGameParticipant> _police;

  /// 경찰 목록
  @override
  List<InGameParticipant> get police {
    if (_police is EqualUnmodifiableListView) return _police;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_police);
  }

  /// 도둑 목록
  final List<InGameParticipant> _robbers;

  /// 도둑 목록
  @override
  List<InGameParticipant> get robbers {
    if (_robbers is EqualUnmodifiableListView) return _robbers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_robbers);
  }

  @override
  String toString() {
    return 'InGameParticipantsResponse(police: $police, robbers: $robbers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InGameParticipantsResponseImpl &&
            const DeepCollectionEquality().equals(other._police, _police) &&
            const DeepCollectionEquality().equals(other._robbers, _robbers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_police),
    const DeepCollectionEquality().hash(_robbers),
  );

  /// Create a copy of InGameParticipantsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InGameParticipantsResponseImplCopyWith<_$InGameParticipantsResponseImpl>
  get copyWith =>
      __$$InGameParticipantsResponseImplCopyWithImpl<
        _$InGameParticipantsResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InGameParticipantsResponseImplToJson(this);
  }
}

abstract class _InGameParticipantsResponse
    implements InGameParticipantsResponse {
  const factory _InGameParticipantsResponse({
    required final List<InGameParticipant> police,
    required final List<InGameParticipant> robbers,
  }) = _$InGameParticipantsResponseImpl;

  factory _InGameParticipantsResponse.fromJson(Map<String, dynamic> json) =
      _$InGameParticipantsResponseImpl.fromJson;

  /// 경찰 목록
  @override
  List<InGameParticipant> get police;

  /// 도둑 목록
  @override
  List<InGameParticipant> get robbers;

  /// Create a copy of InGameParticipantsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InGameParticipantsResponseImplCopyWith<_$InGameParticipantsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
