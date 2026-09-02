// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notice_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NoticeResponseModel _$NoticeResponseModelFromJson(Map<String, dynamic> json) {
  return _NoticeResponseModel.fromJson(json);
}

/// @nodoc
mixin _$NoticeResponseModel {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// 본문의 실제 언어 코드(소문자 `ko`·`ja`·`en`).
  /// 요청한 언어의 번역이 없으면 서버가 대체한 언어가 내려온다.
  String? get language => throw _privateConstructorUsedError;

  /// 요청한 언어 코드. [language]와 다르면 요청한 언어의 번역이 아직 없다는 뜻.
  String? get requestedLanguage => throw _privateConstructorUsedError;
  bool get pinned => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NoticeResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NoticeResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoticeResponseModelCopyWith<NoticeResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoticeResponseModelCopyWith<$Res> {
  factory $NoticeResponseModelCopyWith(
    NoticeResponseModel value,
    $Res Function(NoticeResponseModel) then,
  ) = _$NoticeResponseModelCopyWithImpl<$Res, NoticeResponseModel>;
  @useResult
  $Res call({
    int id,
    String title,
    String content,
    String? language,
    String? requestedLanguage,
    bool pinned,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$NoticeResponseModelCopyWithImpl<$Res, $Val extends NoticeResponseModel>
    implements $NoticeResponseModelCopyWith<$Res> {
  _$NoticeResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoticeResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? language = freezed,
    Object? requestedLanguage = freezed,
    Object? pinned = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
            requestedLanguage: freezed == requestedLanguage
                ? _value.requestedLanguage
                : requestedLanguage // ignore: cast_nullable_to_non_nullable
                      as String?,
            pinned: null == pinned
                ? _value.pinned
                : pinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NoticeResponseModelImplCopyWith<$Res>
    implements $NoticeResponseModelCopyWith<$Res> {
  factory _$$NoticeResponseModelImplCopyWith(
    _$NoticeResponseModelImpl value,
    $Res Function(_$NoticeResponseModelImpl) then,
  ) = __$$NoticeResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String content,
    String? language,
    String? requestedLanguage,
    bool pinned,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$NoticeResponseModelImplCopyWithImpl<$Res>
    extends _$NoticeResponseModelCopyWithImpl<$Res, _$NoticeResponseModelImpl>
    implements _$$NoticeResponseModelImplCopyWith<$Res> {
  __$$NoticeResponseModelImplCopyWithImpl(
    _$NoticeResponseModelImpl _value,
    $Res Function(_$NoticeResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoticeResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? language = freezed,
    Object? requestedLanguage = freezed,
    Object? pinned = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$NoticeResponseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        requestedLanguage: freezed == requestedLanguage
            ? _value.requestedLanguage
            : requestedLanguage // ignore: cast_nullable_to_non_nullable
                  as String?,
        pinned: null == pinned
            ? _value.pinned
            : pinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NoticeResponseModelImpl extends _NoticeResponseModel {
  const _$NoticeResponseModelImpl({
    required this.id,
    required this.title,
    required this.content,
    this.language,
    this.requestedLanguage,
    required this.pinned,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$NoticeResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoticeResponseModelImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String content;

  /// 본문의 실제 언어 코드(소문자 `ko`·`ja`·`en`).
  /// 요청한 언어의 번역이 없으면 서버가 대체한 언어가 내려온다.
  @override
  final String? language;

  /// 요청한 언어 코드. [language]와 다르면 요청한 언어의 번역이 아직 없다는 뜻.
  @override
  final String? requestedLanguage;
  @override
  final bool pinned;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'NoticeResponseModel(id: $id, title: $title, content: $content, language: $language, requestedLanguage: $requestedLanguage, pinned: $pinned, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoticeResponseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.requestedLanguage, requestedLanguage) ||
                other.requestedLanguage == requestedLanguage) &&
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    content,
    language,
    requestedLanguage,
    pinned,
    createdAt,
    updatedAt,
  );

  /// Create a copy of NoticeResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoticeResponseModelImplCopyWith<_$NoticeResponseModelImpl> get copyWith =>
      __$$NoticeResponseModelImplCopyWithImpl<_$NoticeResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NoticeResponseModelImplToJson(this);
  }
}

abstract class _NoticeResponseModel extends NoticeResponseModel {
  const factory _NoticeResponseModel({
    required final int id,
    required final String title,
    required final String content,
    final String? language,
    final String? requestedLanguage,
    required final bool pinned,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$NoticeResponseModelImpl;
  const _NoticeResponseModel._() : super._();

  factory _NoticeResponseModel.fromJson(Map<String, dynamic> json) =
      _$NoticeResponseModelImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get content;

  /// 본문의 실제 언어 코드(소문자 `ko`·`ja`·`en`).
  /// 요청한 언어의 번역이 없으면 서버가 대체한 언어가 내려온다.
  @override
  String? get language;

  /// 요청한 언어 코드. [language]와 다르면 요청한 언어의 번역이 아직 없다는 뜻.
  @override
  String? get requestedLanguage;
  @override
  bool get pinned;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of NoticeResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoticeResponseModelImplCopyWith<_$NoticeResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NoticeListResponseModel _$NoticeListResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _NoticeListResponseModel.fromJson(json);
}

/// @nodoc
mixin _$NoticeListResponseModel {
  List<NoticeResponseModel> get content => throw _privateConstructorUsedError;
  PageInfoModel get page => throw _privateConstructorUsedError;

  /// Serializes this NoticeListResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NoticeListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoticeListResponseModelCopyWith<NoticeListResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoticeListResponseModelCopyWith<$Res> {
  factory $NoticeListResponseModelCopyWith(
    NoticeListResponseModel value,
    $Res Function(NoticeListResponseModel) then,
  ) = _$NoticeListResponseModelCopyWithImpl<$Res, NoticeListResponseModel>;
  @useResult
  $Res call({List<NoticeResponseModel> content, PageInfoModel page});

  $PageInfoModelCopyWith<$Res> get page;
}

/// @nodoc
class _$NoticeListResponseModelCopyWithImpl<
  $Res,
  $Val extends NoticeListResponseModel
>
    implements $NoticeListResponseModelCopyWith<$Res> {
  _$NoticeListResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoticeListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null, Object? page = null}) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as List<NoticeResponseModel>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as PageInfoModel,
          )
          as $Val,
    );
  }

  /// Create a copy of NoticeListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PageInfoModelCopyWith<$Res> get page {
    return $PageInfoModelCopyWith<$Res>(_value.page, (value) {
      return _then(_value.copyWith(page: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NoticeListResponseModelImplCopyWith<$Res>
    implements $NoticeListResponseModelCopyWith<$Res> {
  factory _$$NoticeListResponseModelImplCopyWith(
    _$NoticeListResponseModelImpl value,
    $Res Function(_$NoticeListResponseModelImpl) then,
  ) = __$$NoticeListResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<NoticeResponseModel> content, PageInfoModel page});

  @override
  $PageInfoModelCopyWith<$Res> get page;
}

/// @nodoc
class __$$NoticeListResponseModelImplCopyWithImpl<$Res>
    extends
        _$NoticeListResponseModelCopyWithImpl<
          $Res,
          _$NoticeListResponseModelImpl
        >
    implements _$$NoticeListResponseModelImplCopyWith<$Res> {
  __$$NoticeListResponseModelImplCopyWithImpl(
    _$NoticeListResponseModelImpl _value,
    $Res Function(_$NoticeListResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoticeListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null, Object? page = null}) {
    return _then(
      _$NoticeListResponseModelImpl(
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as List<NoticeResponseModel>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as PageInfoModel,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NoticeListResponseModelImpl implements _NoticeListResponseModel {
  const _$NoticeListResponseModelImpl({
    required final List<NoticeResponseModel> content,
    required this.page,
  }) : _content = content;

  factory _$NoticeListResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoticeListResponseModelImplFromJson(json);

  final List<NoticeResponseModel> _content;
  @override
  List<NoticeResponseModel> get content {
    if (_content is EqualUnmodifiableListView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_content);
  }

  @override
  final PageInfoModel page;

  @override
  String toString() {
    return 'NoticeListResponseModel(content: $content, page: $page)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoticeListResponseModelImpl &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.page, page) || other.page == page));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_content),
    page,
  );

  /// Create a copy of NoticeListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoticeListResponseModelImplCopyWith<_$NoticeListResponseModelImpl>
  get copyWith =>
      __$$NoticeListResponseModelImplCopyWithImpl<
        _$NoticeListResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NoticeListResponseModelImplToJson(this);
  }
}

abstract class _NoticeListResponseModel implements NoticeListResponseModel {
  const factory _NoticeListResponseModel({
    required final List<NoticeResponseModel> content,
    required final PageInfoModel page,
  }) = _$NoticeListResponseModelImpl;

  factory _NoticeListResponseModel.fromJson(Map<String, dynamic> json) =
      _$NoticeListResponseModelImpl.fromJson;

  @override
  List<NoticeResponseModel> get content;
  @override
  PageInfoModel get page;

  /// Create a copy of NoticeListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoticeListResponseModelImplCopyWith<_$NoticeListResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
