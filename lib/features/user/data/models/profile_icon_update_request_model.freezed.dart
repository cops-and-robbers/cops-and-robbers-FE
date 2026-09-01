// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_icon_update_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfileIconUpdateRequestModel _$ProfileIconUpdateRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _ProfileIconUpdateRequestModel.fromJson(json);
}

/// @nodoc
mixin _$ProfileIconUpdateRequestModel {
  int get profileIcon => throw _privateConstructorUsedError;

  /// Serializes this ProfileIconUpdateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileIconUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileIconUpdateRequestModelCopyWith<ProfileIconUpdateRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileIconUpdateRequestModelCopyWith<$Res> {
  factory $ProfileIconUpdateRequestModelCopyWith(
    ProfileIconUpdateRequestModel value,
    $Res Function(ProfileIconUpdateRequestModel) then,
  ) =
      _$ProfileIconUpdateRequestModelCopyWithImpl<
        $Res,
        ProfileIconUpdateRequestModel
      >;
  @useResult
  $Res call({int profileIcon});
}

/// @nodoc
class _$ProfileIconUpdateRequestModelCopyWithImpl<
  $Res,
  $Val extends ProfileIconUpdateRequestModel
>
    implements $ProfileIconUpdateRequestModelCopyWith<$Res> {
  _$ProfileIconUpdateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileIconUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? profileIcon = null}) {
    return _then(
      _value.copyWith(
            profileIcon: null == profileIcon
                ? _value.profileIcon
                : profileIcon // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileIconUpdateRequestModelImplCopyWith<$Res>
    implements $ProfileIconUpdateRequestModelCopyWith<$Res> {
  factory _$$ProfileIconUpdateRequestModelImplCopyWith(
    _$ProfileIconUpdateRequestModelImpl value,
    $Res Function(_$ProfileIconUpdateRequestModelImpl) then,
  ) = __$$ProfileIconUpdateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int profileIcon});
}

/// @nodoc
class __$$ProfileIconUpdateRequestModelImplCopyWithImpl<$Res>
    extends
        _$ProfileIconUpdateRequestModelCopyWithImpl<
          $Res,
          _$ProfileIconUpdateRequestModelImpl
        >
    implements _$$ProfileIconUpdateRequestModelImplCopyWith<$Res> {
  __$$ProfileIconUpdateRequestModelImplCopyWithImpl(
    _$ProfileIconUpdateRequestModelImpl _value,
    $Res Function(_$ProfileIconUpdateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileIconUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? profileIcon = null}) {
    return _then(
      _$ProfileIconUpdateRequestModelImpl(
        profileIcon: null == profileIcon
            ? _value.profileIcon
            : profileIcon // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileIconUpdateRequestModelImpl
    implements _ProfileIconUpdateRequestModel {
  const _$ProfileIconUpdateRequestModelImpl({required this.profileIcon});

  factory _$ProfileIconUpdateRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ProfileIconUpdateRequestModelImplFromJson(json);

  @override
  final int profileIcon;

  @override
  String toString() {
    return 'ProfileIconUpdateRequestModel(profileIcon: $profileIcon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileIconUpdateRequestModelImpl &&
            (identical(other.profileIcon, profileIcon) ||
                other.profileIcon == profileIcon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, profileIcon);

  /// Create a copy of ProfileIconUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileIconUpdateRequestModelImplCopyWith<
    _$ProfileIconUpdateRequestModelImpl
  >
  get copyWith =>
      __$$ProfileIconUpdateRequestModelImplCopyWithImpl<
        _$ProfileIconUpdateRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileIconUpdateRequestModelImplToJson(this);
  }
}

abstract class _ProfileIconUpdateRequestModel
    implements ProfileIconUpdateRequestModel {
  const factory _ProfileIconUpdateRequestModel({
    required final int profileIcon,
  }) = _$ProfileIconUpdateRequestModelImpl;

  factory _ProfileIconUpdateRequestModel.fromJson(Map<String, dynamic> json) =
      _$ProfileIconUpdateRequestModelImpl.fromJson;

  @override
  int get profileIcon;

  /// Create a copy of ProfileIconUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileIconUpdateRequestModelImplCopyWith<
    _$ProfileIconUpdateRequestModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
