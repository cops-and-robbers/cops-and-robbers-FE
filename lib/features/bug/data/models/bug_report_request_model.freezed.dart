// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bug_report_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BugReportRequestModel _$BugReportRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _BugReportRequestModel.fromJson(json);
}

/// @nodoc
mixin _$BugReportRequestModel {
  String get content => throw _privateConstructorUsedError;

  /// Serializes this BugReportRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BugReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BugReportRequestModelCopyWith<BugReportRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BugReportRequestModelCopyWith<$Res> {
  factory $BugReportRequestModelCopyWith(
    BugReportRequestModel value,
    $Res Function(BugReportRequestModel) then,
  ) = _$BugReportRequestModelCopyWithImpl<$Res, BugReportRequestModel>;
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$BugReportRequestModelCopyWithImpl<
  $Res,
  $Val extends BugReportRequestModel
>
    implements $BugReportRequestModelCopyWith<$Res> {
  _$BugReportRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BugReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null}) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BugReportRequestModelImplCopyWith<$Res>
    implements $BugReportRequestModelCopyWith<$Res> {
  factory _$$BugReportRequestModelImplCopyWith(
    _$BugReportRequestModelImpl value,
    $Res Function(_$BugReportRequestModelImpl) then,
  ) = __$$BugReportRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String content});
}

/// @nodoc
class __$$BugReportRequestModelImplCopyWithImpl<$Res>
    extends
        _$BugReportRequestModelCopyWithImpl<$Res, _$BugReportRequestModelImpl>
    implements _$$BugReportRequestModelImplCopyWith<$Res> {
  __$$BugReportRequestModelImplCopyWithImpl(
    _$BugReportRequestModelImpl _value,
    $Res Function(_$BugReportRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BugReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null}) {
    return _then(
      _$BugReportRequestModelImpl(
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BugReportRequestModelImpl implements _BugReportRequestModel {
  const _$BugReportRequestModelImpl({required this.content});

  factory _$BugReportRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BugReportRequestModelImplFromJson(json);

  @override
  final String content;

  @override
  String toString() {
    return 'BugReportRequestModel(content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BugReportRequestModelImpl &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content);

  /// Create a copy of BugReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BugReportRequestModelImplCopyWith<_$BugReportRequestModelImpl>
  get copyWith =>
      __$$BugReportRequestModelImplCopyWithImpl<_$BugReportRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BugReportRequestModelImplToJson(this);
  }
}

abstract class _BugReportRequestModel implements BugReportRequestModel {
  const factory _BugReportRequestModel({required final String content}) =
      _$BugReportRequestModelImpl;

  factory _BugReportRequestModel.fromJson(Map<String, dynamic> json) =
      _$BugReportRequestModelImpl.fromJson;

  @override
  String get content;

  /// Create a copy of BugReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BugReportRequestModelImplCopyWith<_$BugReportRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
