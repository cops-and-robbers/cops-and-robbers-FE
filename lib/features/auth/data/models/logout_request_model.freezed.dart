// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logout_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LogoutRequestModel _$LogoutRequestModelFromJson(Map<String, dynamic> json) {
  return _LogoutRequestModel.fromJson(json);
}

/// @nodoc
mixin _$LogoutRequestModel {
  /// Refresh Token
  String get refreshToken => throw _privateConstructorUsedError;

  /// Serializes this LogoutRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LogoutRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogoutRequestModelCopyWith<LogoutRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogoutRequestModelCopyWith<$Res> {
  factory $LogoutRequestModelCopyWith(
    LogoutRequestModel value,
    $Res Function(LogoutRequestModel) then,
  ) = _$LogoutRequestModelCopyWithImpl<$Res, LogoutRequestModel>;
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class _$LogoutRequestModelCopyWithImpl<$Res, $Val extends LogoutRequestModel>
    implements $LogoutRequestModelCopyWith<$Res> {
  _$LogoutRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogoutRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? refreshToken = null}) {
    return _then(
      _value.copyWith(
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LogoutRequestModelImplCopyWith<$Res>
    implements $LogoutRequestModelCopyWith<$Res> {
  factory _$$LogoutRequestModelImplCopyWith(
    _$LogoutRequestModelImpl value,
    $Res Function(_$LogoutRequestModelImpl) then,
  ) = __$$LogoutRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class __$$LogoutRequestModelImplCopyWithImpl<$Res>
    extends _$LogoutRequestModelCopyWithImpl<$Res, _$LogoutRequestModelImpl>
    implements _$$LogoutRequestModelImplCopyWith<$Res> {
  __$$LogoutRequestModelImplCopyWithImpl(
    _$LogoutRequestModelImpl _value,
    $Res Function(_$LogoutRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LogoutRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? refreshToken = null}) {
    return _then(
      _$LogoutRequestModelImpl(
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LogoutRequestModelImpl implements _LogoutRequestModel {
  const _$LogoutRequestModelImpl({required this.refreshToken});

  factory _$LogoutRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogoutRequestModelImplFromJson(json);

  /// Refresh Token
  @override
  final String refreshToken;

  @override
  String toString() {
    return 'LogoutRequestModel(refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogoutRequestModelImpl &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, refreshToken);

  /// Create a copy of LogoutRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogoutRequestModelImplCopyWith<_$LogoutRequestModelImpl> get copyWith =>
      __$$LogoutRequestModelImplCopyWithImpl<_$LogoutRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LogoutRequestModelImplToJson(this);
  }
}

abstract class _LogoutRequestModel implements LogoutRequestModel {
  const factory _LogoutRequestModel({required final String refreshToken}) =
      _$LogoutRequestModelImpl;

  factory _LogoutRequestModel.fromJson(Map<String, dynamic> json) =
      _$LogoutRequestModelImpl.fromJson;

  /// Refresh Token
  @override
  String get refreshToken;

  /// Create a copy of LogoutRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogoutRequestModelImplCopyWith<_$LogoutRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
