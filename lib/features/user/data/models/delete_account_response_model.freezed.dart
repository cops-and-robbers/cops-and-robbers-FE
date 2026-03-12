// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_account_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DeleteAccountResponseModel _$DeleteAccountResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _DeleteAccountResponseModel.fromJson(json);
}

/// @nodoc
mixin _$DeleteAccountResponseModel {
  /// 결과 메시지
  String get message => throw _privateConstructorUsedError;

  /// Serializes this DeleteAccountResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeleteAccountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeleteAccountResponseModelCopyWith<DeleteAccountResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeleteAccountResponseModelCopyWith<$Res> {
  factory $DeleteAccountResponseModelCopyWith(
    DeleteAccountResponseModel value,
    $Res Function(DeleteAccountResponseModel) then,
  ) =
      _$DeleteAccountResponseModelCopyWithImpl<
        $Res,
        DeleteAccountResponseModel
      >;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$DeleteAccountResponseModelCopyWithImpl<
  $Res,
  $Val extends DeleteAccountResponseModel
>
    implements $DeleteAccountResponseModelCopyWith<$Res> {
  _$DeleteAccountResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeleteAccountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeleteAccountResponseModelImplCopyWith<$Res>
    implements $DeleteAccountResponseModelCopyWith<$Res> {
  factory _$$DeleteAccountResponseModelImplCopyWith(
    _$DeleteAccountResponseModelImpl value,
    $Res Function(_$DeleteAccountResponseModelImpl) then,
  ) = __$$DeleteAccountResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$DeleteAccountResponseModelImplCopyWithImpl<$Res>
    extends
        _$DeleteAccountResponseModelCopyWithImpl<
          $Res,
          _$DeleteAccountResponseModelImpl
        >
    implements _$$DeleteAccountResponseModelImplCopyWith<$Res> {
  __$$DeleteAccountResponseModelImplCopyWithImpl(
    _$DeleteAccountResponseModelImpl _value,
    $Res Function(_$DeleteAccountResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeleteAccountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$DeleteAccountResponseModelImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeleteAccountResponseModelImpl implements _DeleteAccountResponseModel {
  const _$DeleteAccountResponseModelImpl({required this.message});

  factory _$DeleteAccountResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$DeleteAccountResponseModelImplFromJson(json);

  /// 결과 메시지
  @override
  final String message;

  @override
  String toString() {
    return 'DeleteAccountResponseModel(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteAccountResponseModelImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of DeleteAccountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteAccountResponseModelImplCopyWith<_$DeleteAccountResponseModelImpl>
  get copyWith =>
      __$$DeleteAccountResponseModelImplCopyWithImpl<
        _$DeleteAccountResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeleteAccountResponseModelImplToJson(this);
  }
}

abstract class _DeleteAccountResponseModel
    implements DeleteAccountResponseModel {
  const factory _DeleteAccountResponseModel({required final String message}) =
      _$DeleteAccountResponseModelImpl;

  factory _DeleteAccountResponseModel.fromJson(Map<String, dynamic> json) =
      _$DeleteAccountResponseModelImpl.fromJson;

  /// 결과 메시지
  @override
  String get message;

  /// Create a copy of DeleteAccountResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteAccountResponseModelImplCopyWith<_$DeleteAccountResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
