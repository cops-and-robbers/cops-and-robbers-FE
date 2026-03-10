// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameEventModel _$GameEventModelFromJson(Map<String, dynamic> json) {
  return _GameEventModel.fromJson(json);
}

/// @nodoc
mixin _$GameEventModel {
  String get eventId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: GameEventType.unknown)
  GameEventType get type => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;

  /// Serializes this GameEventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameEventModelCopyWith<GameEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameEventModelCopyWith<$Res> {
  factory $GameEventModelCopyWith(
    GameEventModel value,
    $Res Function(GameEventModel) then,
  ) = _$GameEventModelCopyWithImpl<$Res, GameEventModel>;
  @useResult
  $Res call({
    String eventId,
    @JsonKey(unknownEnumValue: GameEventType.unknown) GameEventType type,
    String timestamp,
    Map<String, dynamic> data,
  });
}

/// @nodoc
class _$GameEventModelCopyWithImpl<$Res, $Val extends GameEventModel>
    implements $GameEventModelCopyWith<$Res> {
  _$GameEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? type = null,
    Object? timestamp = null,
    Object? data = null,
  }) {
    return _then(
      _value.copyWith(
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as GameEventType,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameEventModelImplCopyWith<$Res>
    implements $GameEventModelCopyWith<$Res> {
  factory _$$GameEventModelImplCopyWith(
    _$GameEventModelImpl value,
    $Res Function(_$GameEventModelImpl) then,
  ) = __$$GameEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String eventId,
    @JsonKey(unknownEnumValue: GameEventType.unknown) GameEventType type,
    String timestamp,
    Map<String, dynamic> data,
  });
}

/// @nodoc
class __$$GameEventModelImplCopyWithImpl<$Res>
    extends _$GameEventModelCopyWithImpl<$Res, _$GameEventModelImpl>
    implements _$$GameEventModelImplCopyWith<$Res> {
  __$$GameEventModelImplCopyWithImpl(
    _$GameEventModelImpl _value,
    $Res Function(_$GameEventModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? type = null,
    Object? timestamp = null,
    Object? data = null,
  }) {
    return _then(
      _$GameEventModelImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as GameEventType,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameEventModelImpl implements _GameEventModel {
  const _$GameEventModelImpl({
    this.eventId = '',
    @JsonKey(unknownEnumValue: GameEventType.unknown) required this.type,
    this.timestamp = '',
    final Map<String, dynamic> data = const {},
  }) : _data = data;

  factory _$GameEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameEventModelImplFromJson(json);

  @override
  @JsonKey()
  final String eventId;
  @override
  @JsonKey(unknownEnumValue: GameEventType.unknown)
  final GameEventType type;
  @override
  @JsonKey()
  final String timestamp;
  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  String toString() {
    return 'GameEventModel(eventId: $eventId, type: $type, timestamp: $timestamp, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameEventModelImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventId,
    type,
    timestamp,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of GameEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameEventModelImplCopyWith<_$GameEventModelImpl> get copyWith =>
      __$$GameEventModelImplCopyWithImpl<_$GameEventModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameEventModelImplToJson(this);
  }
}

abstract class _GameEventModel implements GameEventModel {
  const factory _GameEventModel({
    final String eventId,
    @JsonKey(unknownEnumValue: GameEventType.unknown)
    required final GameEventType type,
    final String timestamp,
    final Map<String, dynamic> data,
  }) = _$GameEventModelImpl;

  factory _GameEventModel.fromJson(Map<String, dynamic> json) =
      _$GameEventModelImpl.fromJson;

  @override
  String get eventId;
  @override
  @JsonKey(unknownEnumValue: GameEventType.unknown)
  GameEventType get type;
  @override
  String get timestamp;
  @override
  Map<String, dynamic> get data;

  /// Create a copy of GameEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameEventModelImplCopyWith<_$GameEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
