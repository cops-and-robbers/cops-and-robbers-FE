// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_info_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PageInfoModel _$PageInfoModelFromJson(Map<String, dynamic> json) {
  return _PageInfoModel.fromJson(json);
}

/// @nodoc
mixin _$PageInfoModel {
  int get size => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  int get totalElements => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  /// Serializes this PageInfoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageInfoModelCopyWith<PageInfoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageInfoModelCopyWith<$Res> {
  factory $PageInfoModelCopyWith(
    PageInfoModel value,
    $Res Function(PageInfoModel) then,
  ) = _$PageInfoModelCopyWithImpl<$Res, PageInfoModel>;
  @useResult
  $Res call({int size, int number, int totalElements, int totalPages});
}

/// @nodoc
class _$PageInfoModelCopyWithImpl<$Res, $Val extends PageInfoModel>
    implements $PageInfoModelCopyWith<$Res> {
  _$PageInfoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
    Object? number = null,
    Object? totalElements = null,
    Object? totalPages = null,
  }) {
    return _then(
      _value.copyWith(
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
            number: null == number
                ? _value.number
                : number // ignore: cast_nullable_to_non_nullable
                      as int,
            totalElements: null == totalElements
                ? _value.totalElements
                : totalElements // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PageInfoModelImplCopyWith<$Res>
    implements $PageInfoModelCopyWith<$Res> {
  factory _$$PageInfoModelImplCopyWith(
    _$PageInfoModelImpl value,
    $Res Function(_$PageInfoModelImpl) then,
  ) = __$$PageInfoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int size, int number, int totalElements, int totalPages});
}

/// @nodoc
class __$$PageInfoModelImplCopyWithImpl<$Res>
    extends _$PageInfoModelCopyWithImpl<$Res, _$PageInfoModelImpl>
    implements _$$PageInfoModelImplCopyWith<$Res> {
  __$$PageInfoModelImplCopyWithImpl(
    _$PageInfoModelImpl _value,
    $Res Function(_$PageInfoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PageInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
    Object? number = null,
    Object? totalElements = null,
    Object? totalPages = null,
  }) {
    return _then(
      _$PageInfoModelImpl(
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
        number: null == number
            ? _value.number
            : number // ignore: cast_nullable_to_non_nullable
                  as int,
        totalElements: null == totalElements
            ? _value.totalElements
            : totalElements // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PageInfoModelImpl implements _PageInfoModel {
  const _$PageInfoModelImpl({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory _$PageInfoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageInfoModelImplFromJson(json);

  @override
  final int size;
  @override
  final int number;
  @override
  final int totalElements;
  @override
  final int totalPages;

  @override
  String toString() {
    return 'PageInfoModel(size: $size, number: $number, totalElements: $totalElements, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageInfoModelImpl &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.totalElements, totalElements) ||
                other.totalElements == totalElements) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, size, number, totalElements, totalPages);

  /// Create a copy of PageInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageInfoModelImplCopyWith<_$PageInfoModelImpl> get copyWith =>
      __$$PageInfoModelImplCopyWithImpl<_$PageInfoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PageInfoModelImplToJson(this);
  }
}

abstract class _PageInfoModel implements PageInfoModel {
  const factory _PageInfoModel({
    required final int size,
    required final int number,
    required final int totalElements,
    required final int totalPages,
  }) = _$PageInfoModelImpl;

  factory _PageInfoModel.fromJson(Map<String, dynamic> json) =
      _$PageInfoModelImpl.fromJson;

  @override
  int get size;
  @override
  int get number;
  @override
  int get totalElements;
  @override
  int get totalPages;

  /// Create a copy of PageInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageInfoModelImplCopyWith<_$PageInfoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
