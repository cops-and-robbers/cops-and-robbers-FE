// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_send_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatSendRequest _$ChatSendRequestFromJson(Map<String, dynamic> json) {
  return _ChatSendRequest.fromJson(json);
}

/// @nodoc
mixin _$ChatSendRequest {
  String get message => throw _privateConstructorUsedError;

  /// "TEAM" 또는 "ALL"
  String get scope => throw _privateConstructorUsedError;

  /// Serializes this ChatSendRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatSendRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatSendRequestCopyWith<ChatSendRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatSendRequestCopyWith<$Res> {
  factory $ChatSendRequestCopyWith(
    ChatSendRequest value,
    $Res Function(ChatSendRequest) then,
  ) = _$ChatSendRequestCopyWithImpl<$Res, ChatSendRequest>;
  @useResult
  $Res call({String message, String scope});
}

/// @nodoc
class _$ChatSendRequestCopyWithImpl<$Res, $Val extends ChatSendRequest>
    implements $ChatSendRequestCopyWith<$Res> {
  _$ChatSendRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatSendRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? scope = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            scope: null == scope
                ? _value.scope
                : scope // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatSendRequestImplCopyWith<$Res>
    implements $ChatSendRequestCopyWith<$Res> {
  factory _$$ChatSendRequestImplCopyWith(
    _$ChatSendRequestImpl value,
    $Res Function(_$ChatSendRequestImpl) then,
  ) = __$$ChatSendRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String scope});
}

/// @nodoc
class __$$ChatSendRequestImplCopyWithImpl<$Res>
    extends _$ChatSendRequestCopyWithImpl<$Res, _$ChatSendRequestImpl>
    implements _$$ChatSendRequestImplCopyWith<$Res> {
  __$$ChatSendRequestImplCopyWithImpl(
    _$ChatSendRequestImpl _value,
    $Res Function(_$ChatSendRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatSendRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? scope = null}) {
    return _then(
      _$ChatSendRequestImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        scope: null == scope
            ? _value.scope
            : scope // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatSendRequestImpl implements _ChatSendRequest {
  const _$ChatSendRequestImpl({required this.message, required this.scope});

  factory _$ChatSendRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatSendRequestImplFromJson(json);

  @override
  final String message;

  /// "TEAM" 또는 "ALL"
  @override
  final String scope;

  @override
  String toString() {
    return 'ChatSendRequest(message: $message, scope: $scope)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatSendRequestImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.scope, scope) || other.scope == scope));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, scope);

  /// Create a copy of ChatSendRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatSendRequestImplCopyWith<_$ChatSendRequestImpl> get copyWith =>
      __$$ChatSendRequestImplCopyWithImpl<_$ChatSendRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatSendRequestImplToJson(this);
  }
}

abstract class _ChatSendRequest implements ChatSendRequest {
  const factory _ChatSendRequest({
    required final String message,
    required final String scope,
  }) = _$ChatSendRequestImpl;

  factory _ChatSendRequest.fromJson(Map<String, dynamic> json) =
      _$ChatSendRequestImpl.fromJson;

  @override
  String get message;

  /// "TEAM" 또는 "ALL"
  @override
  String get scope;

  /// Create a copy of ChatSendRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatSendRequestImplCopyWith<_$ChatSendRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
