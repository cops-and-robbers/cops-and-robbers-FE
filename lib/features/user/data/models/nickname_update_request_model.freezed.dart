// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nickname_update_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NicknameUpdateRequestModel _$NicknameUpdateRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _NicknameUpdateRequestModel.fromJson(json);
}

/// @nodoc
mixin _$NicknameUpdateRequestModel {
  /// 변경할 닉네임 (최대 10자)
  String get nickname => throw _privateConstructorUsedError;

  /// Serializes this NicknameUpdateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NicknameUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NicknameUpdateRequestModelCopyWith<NicknameUpdateRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NicknameUpdateRequestModelCopyWith<$Res> {
  factory $NicknameUpdateRequestModelCopyWith(
    NicknameUpdateRequestModel value,
    $Res Function(NicknameUpdateRequestModel) then,
  ) =
      _$NicknameUpdateRequestModelCopyWithImpl<
        $Res,
        NicknameUpdateRequestModel
      >;
  @useResult
  $Res call({String nickname});
}

/// @nodoc
class _$NicknameUpdateRequestModelCopyWithImpl<
  $Res,
  $Val extends NicknameUpdateRequestModel
>
    implements $NicknameUpdateRequestModelCopyWith<$Res> {
  _$NicknameUpdateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NicknameUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nickname = null}) {
    return _then(
      _value.copyWith(
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NicknameUpdateRequestModelImplCopyWith<$Res>
    implements $NicknameUpdateRequestModelCopyWith<$Res> {
  factory _$$NicknameUpdateRequestModelImplCopyWith(
    _$NicknameUpdateRequestModelImpl value,
    $Res Function(_$NicknameUpdateRequestModelImpl) then,
  ) = __$$NicknameUpdateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String nickname});
}

/// @nodoc
class __$$NicknameUpdateRequestModelImplCopyWithImpl<$Res>
    extends
        _$NicknameUpdateRequestModelCopyWithImpl<
          $Res,
          _$NicknameUpdateRequestModelImpl
        >
    implements _$$NicknameUpdateRequestModelImplCopyWith<$Res> {
  __$$NicknameUpdateRequestModelImplCopyWithImpl(
    _$NicknameUpdateRequestModelImpl _value,
    $Res Function(_$NicknameUpdateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NicknameUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nickname = null}) {
    return _then(
      _$NicknameUpdateRequestModelImpl(
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NicknameUpdateRequestModelImpl implements _NicknameUpdateRequestModel {
  const _$NicknameUpdateRequestModelImpl({required this.nickname});

  factory _$NicknameUpdateRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$NicknameUpdateRequestModelImplFromJson(json);

  /// 변경할 닉네임 (최대 10자)
  @override
  final String nickname;

  @override
  String toString() {
    return 'NicknameUpdateRequestModel(nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NicknameUpdateRequestModelImpl &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nickname);

  /// Create a copy of NicknameUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NicknameUpdateRequestModelImplCopyWith<_$NicknameUpdateRequestModelImpl>
  get copyWith =>
      __$$NicknameUpdateRequestModelImplCopyWithImpl<
        _$NicknameUpdateRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NicknameUpdateRequestModelImplToJson(this);
  }
}

abstract class _NicknameUpdateRequestModel
    implements NicknameUpdateRequestModel {
  const factory _NicknameUpdateRequestModel({required final String nickname}) =
      _$NicknameUpdateRequestModelImpl;

  factory _NicknameUpdateRequestModel.fromJson(Map<String, dynamic> json) =
      _$NicknameUpdateRequestModelImpl.fromJson;

  /// 변경할 닉네임 (최대 10자)
  @override
  String get nickname;

  /// Create a copy of NicknameUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NicknameUpdateRequestModelImplCopyWith<_$NicknameUpdateRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
