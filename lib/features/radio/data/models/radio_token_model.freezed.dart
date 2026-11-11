// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radio_token_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RadioTokenModel _$RadioTokenModelFromJson(Map<String, dynamic> json) {
  return _RadioTokenModel.fromJson(json);
}

/// @nodoc
mixin _$RadioTokenModel {
  String get url => throw _privateConstructorUsedError;
  String get room => throw _privateConstructorUsedError;
  String get identity => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this RadioTokenModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RadioTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RadioTokenModelCopyWith<RadioTokenModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RadioTokenModelCopyWith<$Res> {
  factory $RadioTokenModelCopyWith(
    RadioTokenModel value,
    $Res Function(RadioTokenModel) then,
  ) = _$RadioTokenModelCopyWithImpl<$Res, RadioTokenModel>;
  @useResult
  $Res call({
    String url,
    String room,
    String identity,
    String token,
    String expiresAt,
  });
}

/// @nodoc
class _$RadioTokenModelCopyWithImpl<$Res, $Val extends RadioTokenModel>
    implements $RadioTokenModelCopyWith<$Res> {
  _$RadioTokenModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RadioTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? room = null,
    Object? identity = null,
    Object? token = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            room: null == room
                ? _value.room
                : room // ignore: cast_nullable_to_non_nullable
                      as String,
            identity: null == identity
                ? _value.identity
                : identity // ignore: cast_nullable_to_non_nullable
                      as String,
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RadioTokenModelImplCopyWith<$Res>
    implements $RadioTokenModelCopyWith<$Res> {
  factory _$$RadioTokenModelImplCopyWith(
    _$RadioTokenModelImpl value,
    $Res Function(_$RadioTokenModelImpl) then,
  ) = __$$RadioTokenModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String url,
    String room,
    String identity,
    String token,
    String expiresAt,
  });
}

/// @nodoc
class __$$RadioTokenModelImplCopyWithImpl<$Res>
    extends _$RadioTokenModelCopyWithImpl<$Res, _$RadioTokenModelImpl>
    implements _$$RadioTokenModelImplCopyWith<$Res> {
  __$$RadioTokenModelImplCopyWithImpl(
    _$RadioTokenModelImpl _value,
    $Res Function(_$RadioTokenModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RadioTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? room = null,
    Object? identity = null,
    Object? token = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$RadioTokenModelImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        room: null == room
            ? _value.room
            : room // ignore: cast_nullable_to_non_nullable
                  as String,
        identity: null == identity
            ? _value.identity
            : identity // ignore: cast_nullable_to_non_nullable
                  as String,
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RadioTokenModelImpl extends _RadioTokenModel {
  const _$RadioTokenModelImpl({
    required this.url,
    required this.room,
    required this.identity,
    required this.token,
    required this.expiresAt,
  }) : super._();

  factory _$RadioTokenModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RadioTokenModelImplFromJson(json);

  @override
  final String url;
  @override
  final String room;
  @override
  final String identity;
  @override
  final String token;
  @override
  final String expiresAt;

  @override
  String toString() {
    return 'RadioTokenModel(url: $url, room: $room, identity: $identity, token: $token, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RadioTokenModelImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.room, room) || other.room == room) &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, url, room, identity, token, expiresAt);

  /// Create a copy of RadioTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RadioTokenModelImplCopyWith<_$RadioTokenModelImpl> get copyWith =>
      __$$RadioTokenModelImplCopyWithImpl<_$RadioTokenModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RadioTokenModelImplToJson(this);
  }
}

abstract class _RadioTokenModel extends RadioTokenModel {
  const factory _RadioTokenModel({
    required final String url,
    required final String room,
    required final String identity,
    required final String token,
    required final String expiresAt,
  }) = _$RadioTokenModelImpl;
  const _RadioTokenModel._() : super._();

  factory _RadioTokenModel.fromJson(Map<String, dynamic> json) =
      _$RadioTokenModelImpl.fromJson;

  @override
  String get url;
  @override
  String get room;
  @override
  String get identity;
  @override
  String get token;
  @override
  String get expiresAt;

  /// Create a copy of RadioTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RadioTokenModelImplCopyWith<_$RadioTokenModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
