// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SessionSettings {
  int get maxPlayers => throw _privateConstructorUsedError;
  int get roundTimeMinutes => throw _privateConstructorUsedError;
  int get locationShareMinutes => throw _privateConstructorUsedError;
  int get policeStartDelayMinutes => throw _privateConstructorUsedError;

  /// Create a copy of SessionSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionSettingsCopyWith<SessionSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionSettingsCopyWith<$Res> {
  factory $SessionSettingsCopyWith(
    SessionSettings value,
    $Res Function(SessionSettings) then,
  ) = _$SessionSettingsCopyWithImpl<$Res, SessionSettings>;
  @useResult
  $Res call({
    int maxPlayers,
    int roundTimeMinutes,
    int locationShareMinutes,
    int policeStartDelayMinutes,
  });
}

/// @nodoc
class _$SessionSettingsCopyWithImpl<$Res, $Val extends SessionSettings>
    implements $SessionSettingsCopyWith<$Res> {
  _$SessionSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxPlayers = null,
    Object? roundTimeMinutes = null,
    Object? locationShareMinutes = null,
    Object? policeStartDelayMinutes = null,
  }) {
    return _then(
      _value.copyWith(
            maxPlayers: null == maxPlayers
                ? _value.maxPlayers
                : maxPlayers // ignore: cast_nullable_to_non_nullable
                      as int,
            roundTimeMinutes: null == roundTimeMinutes
                ? _value.roundTimeMinutes
                : roundTimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            locationShareMinutes: null == locationShareMinutes
                ? _value.locationShareMinutes
                : locationShareMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            policeStartDelayMinutes: null == policeStartDelayMinutes
                ? _value.policeStartDelayMinutes
                : policeStartDelayMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionSettingsImplCopyWith<$Res>
    implements $SessionSettingsCopyWith<$Res> {
  factory _$$SessionSettingsImplCopyWith(
    _$SessionSettingsImpl value,
    $Res Function(_$SessionSettingsImpl) then,
  ) = __$$SessionSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int maxPlayers,
    int roundTimeMinutes,
    int locationShareMinutes,
    int policeStartDelayMinutes,
  });
}

/// @nodoc
class __$$SessionSettingsImplCopyWithImpl<$Res>
    extends _$SessionSettingsCopyWithImpl<$Res, _$SessionSettingsImpl>
    implements _$$SessionSettingsImplCopyWith<$Res> {
  __$$SessionSettingsImplCopyWithImpl(
    _$SessionSettingsImpl _value,
    $Res Function(_$SessionSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxPlayers = null,
    Object? roundTimeMinutes = null,
    Object? locationShareMinutes = null,
    Object? policeStartDelayMinutes = null,
  }) {
    return _then(
      _$SessionSettingsImpl(
        maxPlayers: null == maxPlayers
            ? _value.maxPlayers
            : maxPlayers // ignore: cast_nullable_to_non_nullable
                  as int,
        roundTimeMinutes: null == roundTimeMinutes
            ? _value.roundTimeMinutes
            : roundTimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        locationShareMinutes: null == locationShareMinutes
            ? _value.locationShareMinutes
            : locationShareMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        policeStartDelayMinutes: null == policeStartDelayMinutes
            ? _value.policeStartDelayMinutes
            : policeStartDelayMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$SessionSettingsImpl extends _SessionSettings {
  const _$SessionSettingsImpl({
    required this.maxPlayers,
    required this.roundTimeMinutes,
    required this.locationShareMinutes,
    required this.policeStartDelayMinutes,
  }) : super._();

  @override
  final int maxPlayers;
  @override
  final int roundTimeMinutes;
  @override
  final int locationShareMinutes;
  @override
  final int policeStartDelayMinutes;

  @override
  String toString() {
    return 'SessionSettings(maxPlayers: $maxPlayers, roundTimeMinutes: $roundTimeMinutes, locationShareMinutes: $locationShareMinutes, policeStartDelayMinutes: $policeStartDelayMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionSettingsImpl &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.roundTimeMinutes, roundTimeMinutes) ||
                other.roundTimeMinutes == roundTimeMinutes) &&
            (identical(other.locationShareMinutes, locationShareMinutes) ||
                other.locationShareMinutes == locationShareMinutes) &&
            (identical(
                  other.policeStartDelayMinutes,
                  policeStartDelayMinutes,
                ) ||
                other.policeStartDelayMinutes == policeStartDelayMinutes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    maxPlayers,
    roundTimeMinutes,
    locationShareMinutes,
    policeStartDelayMinutes,
  );

  /// Create a copy of SessionSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionSettingsImplCopyWith<_$SessionSettingsImpl> get copyWith =>
      __$$SessionSettingsImplCopyWithImpl<_$SessionSettingsImpl>(
        this,
        _$identity,
      );
}

abstract class _SessionSettings extends SessionSettings {
  const factory _SessionSettings({
    required final int maxPlayers,
    required final int roundTimeMinutes,
    required final int locationShareMinutes,
    required final int policeStartDelayMinutes,
  }) = _$SessionSettingsImpl;
  const _SessionSettings._() : super._();

  @override
  int get maxPlayers;
  @override
  int get roundTimeMinutes;
  @override
  int get locationShareMinutes;
  @override
  int get policeStartDelayMinutes;

  /// Create a copy of SessionSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionSettingsImplCopyWith<_$SessionSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
