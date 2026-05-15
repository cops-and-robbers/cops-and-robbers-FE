// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ParticipantInfoModel _$ParticipantInfoModelFromJson(Map<String, dynamic> json) {
  return _ParticipantInfoModel.fromJson(json);
}

/// @nodoc
mixin _$ParticipantInfoModel {
  int get participantId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get team => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this ParticipantInfoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParticipantInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticipantInfoModelCopyWith<ParticipantInfoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantInfoModelCopyWith<$Res> {
  factory $ParticipantInfoModelCopyWith(
    ParticipantInfoModel value,
    $Res Function(ParticipantInfoModel) then,
  ) = _$ParticipantInfoModelCopyWithImpl<$Res, ParticipantInfoModel>;
  @useResult
  $Res call({int participantId, String nickname, String team, String status});
}

/// @nodoc
class _$ParticipantInfoModelCopyWithImpl<
  $Res,
  $Val extends ParticipantInfoModel
>
    implements $ParticipantInfoModelCopyWith<$Res> {
  _$ParticipantInfoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParticipantInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? team = null,
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
            team: null == team
                ? _value.team
                : team // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ParticipantInfoModelImplCopyWith<$Res>
    implements $ParticipantInfoModelCopyWith<$Res> {
  factory _$$ParticipantInfoModelImplCopyWith(
    _$ParticipantInfoModelImpl value,
    $Res Function(_$ParticipantInfoModelImpl) then,
  ) = __$$ParticipantInfoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int participantId, String nickname, String team, String status});
}

/// @nodoc
class __$$ParticipantInfoModelImplCopyWithImpl<$Res>
    extends _$ParticipantInfoModelCopyWithImpl<$Res, _$ParticipantInfoModelImpl>
    implements _$$ParticipantInfoModelImplCopyWith<$Res> {
  __$$ParticipantInfoModelImplCopyWithImpl(
    _$ParticipantInfoModelImpl _value,
    $Res Function(_$ParticipantInfoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParticipantInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? team = null,
    Object? status = null,
  }) {
    return _then(
      _$ParticipantInfoModelImpl(
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        team: null == team
            ? _value.team
            : team // ignore: cast_nullable_to_non_nullable
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
class _$ParticipantInfoModelImpl implements _ParticipantInfoModel {
  const _$ParticipantInfoModelImpl({
    required this.participantId,
    required this.nickname,
    required this.team,
    required this.status,
  });

  factory _$ParticipantInfoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParticipantInfoModelImplFromJson(json);

  @override
  final int participantId;
  @override
  final String nickname;
  @override
  final String team;
  @override
  final String status;

  @override
  String toString() {
    return 'ParticipantInfoModel(participantId: $participantId, nickname: $nickname, team: $team, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticipantInfoModelImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.team, team) || other.team == team) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, participantId, nickname, team, status);

  /// Create a copy of ParticipantInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticipantInfoModelImplCopyWith<_$ParticipantInfoModelImpl>
  get copyWith =>
      __$$ParticipantInfoModelImplCopyWithImpl<_$ParticipantInfoModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParticipantInfoModelImplToJson(this);
  }
}

abstract class _ParticipantInfoModel implements ParticipantInfoModel {
  const factory _ParticipantInfoModel({
    required final int participantId,
    required final String nickname,
    required final String team,
    required final String status,
  }) = _$ParticipantInfoModelImpl;

  factory _ParticipantInfoModel.fromJson(Map<String, dynamic> json) =
      _$ParticipantInfoModelImpl.fromJson;

  @override
  int get participantId;
  @override
  String get nickname;
  @override
  String get team;
  @override
  String get status;

  /// Create a copy of ParticipantInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticipantInfoModelImplCopyWith<_$ParticipantInfoModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RobberLocationInfoModel _$RobberLocationInfoModelFromJson(
  Map<String, dynamic> json,
) {
  return _RobberLocationInfoModel.fromJson(json);
}

/// @nodoc
mixin _$RobberLocationInfoModel {
  int get participantId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this RobberLocationInfoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RobberLocationInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RobberLocationInfoModelCopyWith<RobberLocationInfoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RobberLocationInfoModelCopyWith<$Res> {
  factory $RobberLocationInfoModelCopyWith(
    RobberLocationInfoModel value,
    $Res Function(RobberLocationInfoModel) then,
  ) = _$RobberLocationInfoModelCopyWithImpl<$Res, RobberLocationInfoModel>;
  @useResult
  $Res call({
    int participantId,
    String nickname,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class _$RobberLocationInfoModelCopyWithImpl<
  $Res,
  $Val extends RobberLocationInfoModel
>
    implements $RobberLocationInfoModelCopyWith<$Res> {
  _$RobberLocationInfoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RobberLocationInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? latitude = null,
    Object? longitude = null,
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
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RobberLocationInfoModelImplCopyWith<$Res>
    implements $RobberLocationInfoModelCopyWith<$Res> {
  factory _$$RobberLocationInfoModelImplCopyWith(
    _$RobberLocationInfoModelImpl value,
    $Res Function(_$RobberLocationInfoModelImpl) then,
  ) = __$$RobberLocationInfoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int participantId,
    String nickname,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class __$$RobberLocationInfoModelImplCopyWithImpl<$Res>
    extends
        _$RobberLocationInfoModelCopyWithImpl<
          $Res,
          _$RobberLocationInfoModelImpl
        >
    implements _$$RobberLocationInfoModelImplCopyWith<$Res> {
  __$$RobberLocationInfoModelImplCopyWithImpl(
    _$RobberLocationInfoModelImpl _value,
    $Res Function(_$RobberLocationInfoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RobberLocationInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? nickname = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(
      _$RobberLocationInfoModelImpl(
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RobberLocationInfoModelImpl implements _RobberLocationInfoModel {
  const _$RobberLocationInfoModelImpl({
    required this.participantId,
    required this.nickname,
    required this.latitude,
    required this.longitude,
  });

  factory _$RobberLocationInfoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RobberLocationInfoModelImplFromJson(json);

  @override
  final int participantId;
  @override
  final String nickname;
  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'RobberLocationInfoModel(participantId: $participantId, nickname: $nickname, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RobberLocationInfoModelImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, participantId, nickname, latitude, longitude);

  /// Create a copy of RobberLocationInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RobberLocationInfoModelImplCopyWith<_$RobberLocationInfoModelImpl>
  get copyWith =>
      __$$RobberLocationInfoModelImplCopyWithImpl<
        _$RobberLocationInfoModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RobberLocationInfoModelImplToJson(this);
  }
}

abstract class _RobberLocationInfoModel implements RobberLocationInfoModel {
  const factory _RobberLocationInfoModel({
    required final int participantId,
    required final String nickname,
    required final double latitude,
    required final double longitude,
  }) = _$RobberLocationInfoModelImpl;

  factory _RobberLocationInfoModel.fromJson(Map<String, dynamic> json) =
      _$RobberLocationInfoModelImpl.fromJson;

  @override
  int get participantId;
  @override
  String get nickname;
  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of RobberLocationInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RobberLocationInfoModelImplCopyWith<_$RobberLocationInfoModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GameStateModel _$GameStateModelFromJson(Map<String, dynamic> json) {
  return _GameStateModel.fromJson(json);
}

/// @nodoc
mixin _$GameStateModel {
  List<RobberLocationInfoModel> get robberLocations =>
      throw _privateConstructorUsedError;
  List<ParticipantInfoModel> get participants =>
      throw _privateConstructorUsedError;

  /// Serializes this GameStateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateModelCopyWith<GameStateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateModelCopyWith<$Res> {
  factory $GameStateModelCopyWith(
    GameStateModel value,
    $Res Function(GameStateModel) then,
  ) = _$GameStateModelCopyWithImpl<$Res, GameStateModel>;
  @useResult
  $Res call({
    List<RobberLocationInfoModel> robberLocations,
    List<ParticipantInfoModel> participants,
  });
}

/// @nodoc
class _$GameStateModelCopyWithImpl<$Res, $Val extends GameStateModel>
    implements $GameStateModelCopyWith<$Res> {
  _$GameStateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? robberLocations = null, Object? participants = null}) {
    return _then(
      _value.copyWith(
            robberLocations: null == robberLocations
                ? _value.robberLocations
                : robberLocations // ignore: cast_nullable_to_non_nullable
                      as List<RobberLocationInfoModel>,
            participants: null == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as List<ParticipantInfoModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameStateModelImplCopyWith<$Res>
    implements $GameStateModelCopyWith<$Res> {
  factory _$$GameStateModelImplCopyWith(
    _$GameStateModelImpl value,
    $Res Function(_$GameStateModelImpl) then,
  ) = __$$GameStateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<RobberLocationInfoModel> robberLocations,
    List<ParticipantInfoModel> participants,
  });
}

/// @nodoc
class __$$GameStateModelImplCopyWithImpl<$Res>
    extends _$GameStateModelCopyWithImpl<$Res, _$GameStateModelImpl>
    implements _$$GameStateModelImplCopyWith<$Res> {
  __$$GameStateModelImplCopyWithImpl(
    _$GameStateModelImpl _value,
    $Res Function(_$GameStateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? robberLocations = null, Object? participants = null}) {
    return _then(
      _$GameStateModelImpl(
        robberLocations: null == robberLocations
            ? _value._robberLocations
            : robberLocations // ignore: cast_nullable_to_non_nullable
                  as List<RobberLocationInfoModel>,
        participants: null == participants
            ? _value._participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as List<ParticipantInfoModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStateModelImpl implements _GameStateModel {
  const _$GameStateModelImpl({
    final List<RobberLocationInfoModel> robberLocations = const [],
    final List<ParticipantInfoModel> participants = const [],
  }) : _robberLocations = robberLocations,
       _participants = participants;

  factory _$GameStateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStateModelImplFromJson(json);

  final List<RobberLocationInfoModel> _robberLocations;
  @override
  @JsonKey()
  List<RobberLocationInfoModel> get robberLocations {
    if (_robberLocations is EqualUnmodifiableListView) return _robberLocations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_robberLocations);
  }

  final List<ParticipantInfoModel> _participants;
  @override
  @JsonKey()
  List<ParticipantInfoModel> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  String toString() {
    return 'GameStateModel(robberLocations: $robberLocations, participants: $participants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateModelImpl &&
            const DeepCollectionEquality().equals(
              other._robberLocations,
              _robberLocations,
            ) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_robberLocations),
    const DeepCollectionEquality().hash(_participants),
  );

  /// Create a copy of GameStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateModelImplCopyWith<_$GameStateModelImpl> get copyWith =>
      __$$GameStateModelImplCopyWithImpl<_$GameStateModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStateModelImplToJson(this);
  }
}

abstract class _GameStateModel implements GameStateModel {
  const factory _GameStateModel({
    final List<RobberLocationInfoModel> robberLocations,
    final List<ParticipantInfoModel> participants,
  }) = _$GameStateModelImpl;

  factory _GameStateModel.fromJson(Map<String, dynamic> json) =
      _$GameStateModelImpl.fromJson;

  @override
  List<RobberLocationInfoModel> get robberLocations;
  @override
  List<ParticipantInfoModel> get participants;

  /// Create a copy of GameStateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateModelImplCopyWith<_$GameStateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
