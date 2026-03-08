// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_system_api_datasource.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ArrestRequestModel _$ArrestRequestModelFromJson(Map<String, dynamic> json) {
  return _ArrestRequestModel.fromJson(json);
}

/// @nodoc
mixin _$ArrestRequestModel {
  int get robberParticipantId => throw _privateConstructorUsedError;

  /// Serializes this ArrestRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArrestRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArrestRequestModelCopyWith<ArrestRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArrestRequestModelCopyWith<$Res> {
  factory $ArrestRequestModelCopyWith(
    ArrestRequestModel value,
    $Res Function(ArrestRequestModel) then,
  ) = _$ArrestRequestModelCopyWithImpl<$Res, ArrestRequestModel>;
  @useResult
  $Res call({int robberParticipantId});
}

/// @nodoc
class _$ArrestRequestModelCopyWithImpl<$Res, $Val extends ArrestRequestModel>
    implements $ArrestRequestModelCopyWith<$Res> {
  _$ArrestRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArrestRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? robberParticipantId = null}) {
    return _then(
      _value.copyWith(
            robberParticipantId: null == robberParticipantId
                ? _value.robberParticipantId
                : robberParticipantId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArrestRequestModelImplCopyWith<$Res>
    implements $ArrestRequestModelCopyWith<$Res> {
  factory _$$ArrestRequestModelImplCopyWith(
    _$ArrestRequestModelImpl value,
    $Res Function(_$ArrestRequestModelImpl) then,
  ) = __$$ArrestRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int robberParticipantId});
}

/// @nodoc
class __$$ArrestRequestModelImplCopyWithImpl<$Res>
    extends _$ArrestRequestModelCopyWithImpl<$Res, _$ArrestRequestModelImpl>
    implements _$$ArrestRequestModelImplCopyWith<$Res> {
  __$$ArrestRequestModelImplCopyWithImpl(
    _$ArrestRequestModelImpl _value,
    $Res Function(_$ArrestRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArrestRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? robberParticipantId = null}) {
    return _then(
      _$ArrestRequestModelImpl(
        robberParticipantId: null == robberParticipantId
            ? _value.robberParticipantId
            : robberParticipantId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArrestRequestModelImpl implements _ArrestRequestModel {
  const _$ArrestRequestModelImpl({required this.robberParticipantId});

  factory _$ArrestRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArrestRequestModelImplFromJson(json);

  @override
  final int robberParticipantId;

  @override
  String toString() {
    return 'ArrestRequestModel(robberParticipantId: $robberParticipantId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArrestRequestModelImpl &&
            (identical(other.robberParticipantId, robberParticipantId) ||
                other.robberParticipantId == robberParticipantId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, robberParticipantId);

  /// Create a copy of ArrestRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArrestRequestModelImplCopyWith<_$ArrestRequestModelImpl> get copyWith =>
      __$$ArrestRequestModelImplCopyWithImpl<_$ArrestRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ArrestRequestModelImplToJson(this);
  }
}

abstract class _ArrestRequestModel implements ArrestRequestModel {
  const factory _ArrestRequestModel({required final int robberParticipantId}) =
      _$ArrestRequestModelImpl;

  factory _ArrestRequestModel.fromJson(Map<String, dynamic> json) =
      _$ArrestRequestModelImpl.fromJson;

  @override
  int get robberParticipantId;

  /// Create a copy of ArrestRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArrestRequestModelImplCopyWith<_$ArrestRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ArrestResponseModel _$ArrestResponseModelFromJson(Map<String, dynamic> json) {
  return _ArrestResponseModel.fromJson(json);
}

/// @nodoc
mixin _$ArrestResponseModel {
  String get robberNickname => throw _privateConstructorUsedError;
  int get remainingThieves => throw _privateConstructorUsedError;

  /// Serializes this ArrestResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArrestResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArrestResponseModelCopyWith<ArrestResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArrestResponseModelCopyWith<$Res> {
  factory $ArrestResponseModelCopyWith(
    ArrestResponseModel value,
    $Res Function(ArrestResponseModel) then,
  ) = _$ArrestResponseModelCopyWithImpl<$Res, ArrestResponseModel>;
  @useResult
  $Res call({String robberNickname, int remainingThieves});
}

/// @nodoc
class _$ArrestResponseModelCopyWithImpl<$Res, $Val extends ArrestResponseModel>
    implements $ArrestResponseModelCopyWith<$Res> {
  _$ArrestResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArrestResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? robberNickname = null, Object? remainingThieves = null}) {
    return _then(
      _value.copyWith(
            robberNickname: null == robberNickname
                ? _value.robberNickname
                : robberNickname // ignore: cast_nullable_to_non_nullable
                      as String,
            remainingThieves: null == remainingThieves
                ? _value.remainingThieves
                : remainingThieves // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArrestResponseModelImplCopyWith<$Res>
    implements $ArrestResponseModelCopyWith<$Res> {
  factory _$$ArrestResponseModelImplCopyWith(
    _$ArrestResponseModelImpl value,
    $Res Function(_$ArrestResponseModelImpl) then,
  ) = __$$ArrestResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String robberNickname, int remainingThieves});
}

/// @nodoc
class __$$ArrestResponseModelImplCopyWithImpl<$Res>
    extends _$ArrestResponseModelCopyWithImpl<$Res, _$ArrestResponseModelImpl>
    implements _$$ArrestResponseModelImplCopyWith<$Res> {
  __$$ArrestResponseModelImplCopyWithImpl(
    _$ArrestResponseModelImpl _value,
    $Res Function(_$ArrestResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArrestResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? robberNickname = null, Object? remainingThieves = null}) {
    return _then(
      _$ArrestResponseModelImpl(
        robberNickname: null == robberNickname
            ? _value.robberNickname
            : robberNickname // ignore: cast_nullable_to_non_nullable
                  as String,
        remainingThieves: null == remainingThieves
            ? _value.remainingThieves
            : remainingThieves // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArrestResponseModelImpl implements _ArrestResponseModel {
  const _$ArrestResponseModelImpl({
    this.robberNickname = '',
    this.remainingThieves = 0,
  });

  factory _$ArrestResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArrestResponseModelImplFromJson(json);

  @override
  @JsonKey()
  final String robberNickname;
  @override
  @JsonKey()
  final int remainingThieves;

  @override
  String toString() {
    return 'ArrestResponseModel(robberNickname: $robberNickname, remainingThieves: $remainingThieves)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArrestResponseModelImpl &&
            (identical(other.robberNickname, robberNickname) ||
                other.robberNickname == robberNickname) &&
            (identical(other.remainingThieves, remainingThieves) ||
                other.remainingThieves == remainingThieves));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, robberNickname, remainingThieves);

  /// Create a copy of ArrestResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArrestResponseModelImplCopyWith<_$ArrestResponseModelImpl> get copyWith =>
      __$$ArrestResponseModelImplCopyWithImpl<_$ArrestResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ArrestResponseModelImplToJson(this);
  }
}

abstract class _ArrestResponseModel implements ArrestResponseModel {
  const factory _ArrestResponseModel({
    final String robberNickname,
    final int remainingThieves,
  }) = _$ArrestResponseModelImpl;

  factory _ArrestResponseModel.fromJson(Map<String, dynamic> json) =
      _$ArrestResponseModelImpl.fromJson;

  @override
  String get robberNickname;
  @override
  int get remainingThieves;

  /// Create a copy of ArrestResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArrestResponseModelImplCopyWith<_$ArrestResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
