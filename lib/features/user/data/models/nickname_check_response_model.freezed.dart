// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nickname_check_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NicknameCheckResponseModel _$NicknameCheckResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _NicknameCheckResponseModel.fromJson(json);
}

/// @nodoc
mixin _$NicknameCheckResponseModel {
  /// 사용 가능 여부
  bool get isAvailable => throw _privateConstructorUsedError;

  /// 결과 메시지
  String get message => throw _privateConstructorUsedError;

  /// Serializes this NicknameCheckResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NicknameCheckResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NicknameCheckResponseModelCopyWith<NicknameCheckResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NicknameCheckResponseModelCopyWith<$Res> {
  factory $NicknameCheckResponseModelCopyWith(
    NicknameCheckResponseModel value,
    $Res Function(NicknameCheckResponseModel) then,
  ) =
      _$NicknameCheckResponseModelCopyWithImpl<
        $Res,
        NicknameCheckResponseModel
      >;
  @useResult
  $Res call({bool isAvailable, String message});
}

/// @nodoc
class _$NicknameCheckResponseModelCopyWithImpl<
  $Res,
  $Val extends NicknameCheckResponseModel
>
    implements $NicknameCheckResponseModelCopyWith<$Res> {
  _$NicknameCheckResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NicknameCheckResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isAvailable = null, Object? message = null}) {
    return _then(
      _value.copyWith(
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$NicknameCheckResponseModelImplCopyWith<$Res>
    implements $NicknameCheckResponseModelCopyWith<$Res> {
  factory _$$NicknameCheckResponseModelImplCopyWith(
    _$NicknameCheckResponseModelImpl value,
    $Res Function(_$NicknameCheckResponseModelImpl) then,
  ) = __$$NicknameCheckResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isAvailable, String message});
}

/// @nodoc
class __$$NicknameCheckResponseModelImplCopyWithImpl<$Res>
    extends
        _$NicknameCheckResponseModelCopyWithImpl<
          $Res,
          _$NicknameCheckResponseModelImpl
        >
    implements _$$NicknameCheckResponseModelImplCopyWith<$Res> {
  __$$NicknameCheckResponseModelImplCopyWithImpl(
    _$NicknameCheckResponseModelImpl _value,
    $Res Function(_$NicknameCheckResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NicknameCheckResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isAvailable = null, Object? message = null}) {
    return _then(
      _$NicknameCheckResponseModelImpl(
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$NicknameCheckResponseModelImpl implements _NicknameCheckResponseModel {
  const _$NicknameCheckResponseModelImpl({
    required this.isAvailable,
    required this.message,
  });

  factory _$NicknameCheckResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$NicknameCheckResponseModelImplFromJson(json);

  /// 사용 가능 여부
  @override
  final bool isAvailable;

  /// 결과 메시지
  @override
  final String message;

  @override
  String toString() {
    return 'NicknameCheckResponseModel(isAvailable: $isAvailable, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NicknameCheckResponseModelImpl &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isAvailable, message);

  /// Create a copy of NicknameCheckResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NicknameCheckResponseModelImplCopyWith<_$NicknameCheckResponseModelImpl>
  get copyWith =>
      __$$NicknameCheckResponseModelImplCopyWithImpl<
        _$NicknameCheckResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NicknameCheckResponseModelImplToJson(this);
  }
}

abstract class _NicknameCheckResponseModel
    implements NicknameCheckResponseModel {
  const factory _NicknameCheckResponseModel({
    required final bool isAvailable,
    required final String message,
  }) = _$NicknameCheckResponseModelImpl;

  factory _NicknameCheckResponseModel.fromJson(Map<String, dynamic> json) =
      _$NicknameCheckResponseModelImpl.fromJson;

  /// 사용 가능 여부
  @override
  bool get isAvailable;

  /// 결과 메시지
  @override
  String get message;

  /// Create a copy of NicknameCheckResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NicknameCheckResponseModelImplCopyWith<_$NicknameCheckResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
