// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_settings_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameSettingsResponse _$GameSettingsResponseFromJson(Map<String, dynamic> json) {
  return _GameSettingsResponse.fromJson(json);
}

/// @nodoc
mixin _$GameSettingsResponse {
  /// 라운드 시간 (분)
  int get roundDurationMinutes => throw _privateConstructorUsedError;

  /// 위치 공개 주기 (분)
  int get locationRevealIntervalMinutes => throw _privateConstructorUsedError;

  /// 경찰 대기 시간 (분)
  int get policeWaitMinutes => throw _privateConstructorUsedError;

  /// 최대 참가자 수
  int get maxParticipants => throw _privateConstructorUsedError;

  /// Serializes this GameSettingsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSettingsResponseCopyWith<GameSettingsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSettingsResponseCopyWith<$Res> {
  factory $GameSettingsResponseCopyWith(
    GameSettingsResponse value,
    $Res Function(GameSettingsResponse) then,
  ) = _$GameSettingsResponseCopyWithImpl<$Res, GameSettingsResponse>;
  @useResult
  $Res call({
    int roundDurationMinutes,
    int locationRevealIntervalMinutes,
    int policeWaitMinutes,
    int maxParticipants,
  });
}

/// @nodoc
class _$GameSettingsResponseCopyWithImpl<
  $Res,
  $Val extends GameSettingsResponse
>
    implements $GameSettingsResponseCopyWith<$Res> {
  _$GameSettingsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roundDurationMinutes = null,
    Object? locationRevealIntervalMinutes = null,
    Object? policeWaitMinutes = null,
    Object? maxParticipants = null,
  }) {
    return _then(
      _value.copyWith(
            roundDurationMinutes: null == roundDurationMinutes
                ? _value.roundDurationMinutes
                : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            locationRevealIntervalMinutes: null == locationRevealIntervalMinutes
                ? _value.locationRevealIntervalMinutes
                : locationRevealIntervalMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            policeWaitMinutes: null == policeWaitMinutes
                ? _value.policeWaitMinutes
                : policeWaitMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            maxParticipants: null == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameSettingsResponseImplCopyWith<$Res>
    implements $GameSettingsResponseCopyWith<$Res> {
  factory _$$GameSettingsResponseImplCopyWith(
    _$GameSettingsResponseImpl value,
    $Res Function(_$GameSettingsResponseImpl) then,
  ) = __$$GameSettingsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int roundDurationMinutes,
    int locationRevealIntervalMinutes,
    int policeWaitMinutes,
    int maxParticipants,
  });
}

/// @nodoc
class __$$GameSettingsResponseImplCopyWithImpl<$Res>
    extends _$GameSettingsResponseCopyWithImpl<$Res, _$GameSettingsResponseImpl>
    implements _$$GameSettingsResponseImplCopyWith<$Res> {
  __$$GameSettingsResponseImplCopyWithImpl(
    _$GameSettingsResponseImpl _value,
    $Res Function(_$GameSettingsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roundDurationMinutes = null,
    Object? locationRevealIntervalMinutes = null,
    Object? policeWaitMinutes = null,
    Object? maxParticipants = null,
  }) {
    return _then(
      _$GameSettingsResponseImpl(
        roundDurationMinutes: null == roundDurationMinutes
            ? _value.roundDurationMinutes
            : roundDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        locationRevealIntervalMinutes: null == locationRevealIntervalMinutes
            ? _value.locationRevealIntervalMinutes
            : locationRevealIntervalMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        policeWaitMinutes: null == policeWaitMinutes
            ? _value.policeWaitMinutes
            : policeWaitMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        maxParticipants: null == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSettingsResponseImpl implements _GameSettingsResponse {
  const _$GameSettingsResponseImpl({
    required this.roundDurationMinutes,
    required this.locationRevealIntervalMinutes,
    required this.policeWaitMinutes,
    required this.maxParticipants,
  });

  factory _$GameSettingsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSettingsResponseImplFromJson(json);

  /// 라운드 시간 (분)
  @override
  final int roundDurationMinutes;

  /// 위치 공개 주기 (분)
  @override
  final int locationRevealIntervalMinutes;

  /// 경찰 대기 시간 (분)
  @override
  final int policeWaitMinutes;

  /// 최대 참가자 수
  @override
  final int maxParticipants;

  @override
  String toString() {
    return 'GameSettingsResponse(roundDurationMinutes: $roundDurationMinutes, locationRevealIntervalMinutes: $locationRevealIntervalMinutes, policeWaitMinutes: $policeWaitMinutes, maxParticipants: $maxParticipants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSettingsResponseImpl &&
            (identical(other.roundDurationMinutes, roundDurationMinutes) ||
                other.roundDurationMinutes == roundDurationMinutes) &&
            (identical(
                  other.locationRevealIntervalMinutes,
                  locationRevealIntervalMinutes,
                ) ||
                other.locationRevealIntervalMinutes ==
                    locationRevealIntervalMinutes) &&
            (identical(other.policeWaitMinutes, policeWaitMinutes) ||
                other.policeWaitMinutes == policeWaitMinutes) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    roundDurationMinutes,
    locationRevealIntervalMinutes,
    policeWaitMinutes,
    maxParticipants,
  );

  /// Create a copy of GameSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSettingsResponseImplCopyWith<_$GameSettingsResponseImpl>
  get copyWith =>
      __$$GameSettingsResponseImplCopyWithImpl<_$GameSettingsResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSettingsResponseImplToJson(this);
  }
}

abstract class _GameSettingsResponse implements GameSettingsResponse {
  const factory _GameSettingsResponse({
    required final int roundDurationMinutes,
    required final int locationRevealIntervalMinutes,
    required final int policeWaitMinutes,
    required final int maxParticipants,
  }) = _$GameSettingsResponseImpl;

  factory _GameSettingsResponse.fromJson(Map<String, dynamic> json) =
      _$GameSettingsResponseImpl.fromJson;

  /// 라운드 시간 (분)
  @override
  int get roundDurationMinutes;

  /// 위치 공개 주기 (분)
  @override
  int get locationRevealIntervalMinutes;

  /// 경찰 대기 시간 (분)
  @override
  int get policeWaitMinutes;

  /// 최대 참가자 수
  @override
  int get maxParticipants;

  /// Create a copy of GameSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSettingsResponseImplCopyWith<_$GameSettingsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
