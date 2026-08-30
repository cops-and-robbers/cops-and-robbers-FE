// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notice_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$NoticeEntity {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// 상단 고정 여부. true면 백엔드가 정렬 시 우선 노출하며,
  /// UI에서는 제목 앞에 아이콘을 표시한다.
  bool get pinned => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 요청한 언어의 번역이 없어 서버가 다른 언어로 대체했는지 여부.
  /// 언어 코드 두 개를 도메인까지 끌지 않고 판정 결과만 넘긴다.
  bool get isTranslationFallback => throw _privateConstructorUsedError;

  /// Create a copy of NoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoticeEntityCopyWith<NoticeEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoticeEntityCopyWith<$Res> {
  factory $NoticeEntityCopyWith(
    NoticeEntity value,
    $Res Function(NoticeEntity) then,
  ) = _$NoticeEntityCopyWithImpl<$Res, NoticeEntity>;
  @useResult
  $Res call({
    int id,
    String title,
    String content,
    bool pinned,
    DateTime createdAt,
    bool isTranslationFallback,
  });
}

/// @nodoc
class _$NoticeEntityCopyWithImpl<$Res, $Val extends NoticeEntity>
    implements $NoticeEntityCopyWith<$Res> {
  _$NoticeEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? pinned = null,
    Object? createdAt = null,
    Object? isTranslationFallback = null,
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
            pinned: null == pinned
                ? _value.pinned
                : pinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isTranslationFallback: null == isTranslationFallback
                ? _value.isTranslationFallback
                : isTranslationFallback // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NoticeEntityImplCopyWith<$Res>
    implements $NoticeEntityCopyWith<$Res> {
  factory _$$NoticeEntityImplCopyWith(
    _$NoticeEntityImpl value,
    $Res Function(_$NoticeEntityImpl) then,
  ) = __$$NoticeEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String content,
    bool pinned,
    DateTime createdAt,
    bool isTranslationFallback,
  });
}

/// @nodoc
class __$$NoticeEntityImplCopyWithImpl<$Res>
    extends _$NoticeEntityCopyWithImpl<$Res, _$NoticeEntityImpl>
    implements _$$NoticeEntityImplCopyWith<$Res> {
  __$$NoticeEntityImplCopyWithImpl(
    _$NoticeEntityImpl _value,
    $Res Function(_$NoticeEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? pinned = null,
    Object? createdAt = null,
    Object? isTranslationFallback = null,
  }) {
    return _then(
      _$NoticeEntityImpl(
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
        pinned: null == pinned
            ? _value.pinned
            : pinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isTranslationFallback: null == isTranslationFallback
            ? _value.isTranslationFallback
            : isTranslationFallback // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$NoticeEntityImpl implements _NoticeEntity {
  const _$NoticeEntityImpl({
    required this.id,
    required this.title,
    required this.content,
    required this.pinned,
    required this.createdAt,
    this.isTranslationFallback = false,
  });

  @override
  final int id;
  @override
  final String title;
  @override
  final String content;

  /// 상단 고정 여부. true면 백엔드가 정렬 시 우선 노출하며,
  /// UI에서는 제목 앞에 아이콘을 표시한다.
  @override
  final bool pinned;
  @override
  final DateTime createdAt;

  /// 요청한 언어의 번역이 없어 서버가 다른 언어로 대체했는지 여부.
  /// 언어 코드 두 개를 도메인까지 끌지 않고 판정 결과만 넘긴다.
  @override
  @JsonKey()
  final bool isTranslationFallback;

  @override
  String toString() {
    return 'NoticeEntity(id: $id, title: $title, content: $content, pinned: $pinned, createdAt: $createdAt, isTranslationFallback: $isTranslationFallback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoticeEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isTranslationFallback, isTranslationFallback) ||
                other.isTranslationFallback == isTranslationFallback));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    content,
    pinned,
    createdAt,
    isTranslationFallback,
  );

  /// Create a copy of NoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoticeEntityImplCopyWith<_$NoticeEntityImpl> get copyWith =>
      __$$NoticeEntityImplCopyWithImpl<_$NoticeEntityImpl>(this, _$identity);
}

abstract class _NoticeEntity implements NoticeEntity {
  const factory _NoticeEntity({
    required final int id,
    required final String title,
    required final String content,
    required final bool pinned,
    required final DateTime createdAt,
    final bool isTranslationFallback,
  }) = _$NoticeEntityImpl;

  @override
  int get id;
  @override
  String get title;
  @override
  String get content;

  /// 상단 고정 여부. true면 백엔드가 정렬 시 우선 노출하며,
  /// UI에서는 제목 앞에 아이콘을 표시한다.
  @override
  bool get pinned;
  @override
  DateTime get createdAt;

  /// 요청한 언어의 번역이 없어 서버가 다른 언어로 대체했는지 여부.
  /// 언어 코드 두 개를 도메인까지 끌지 않고 판정 결과만 넘긴다.
  @override
  bool get isTranslationFallback;

  /// Create a copy of NoticeEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoticeEntityImplCopyWith<_$NoticeEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NoticePageEntity {
  List<NoticeEntity> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  /// Create a copy of NoticePageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoticePageEntityCopyWith<NoticePageEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoticePageEntityCopyWith<$Res> {
  factory $NoticePageEntityCopyWith(
    NoticePageEntity value,
    $Res Function(NoticePageEntity) then,
  ) = _$NoticePageEntityCopyWithImpl<$Res, NoticePageEntity>;
  @useResult
  $Res call({List<NoticeEntity> items, int currentPage, int totalPages});
}

/// @nodoc
class _$NoticePageEntityCopyWithImpl<$Res, $Val extends NoticePageEntity>
    implements $NoticePageEntityCopyWith<$Res> {
  _$NoticePageEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoticePageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<NoticeEntity>,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
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
abstract class _$$NoticePageEntityImplCopyWith<$Res>
    implements $NoticePageEntityCopyWith<$Res> {
  factory _$$NoticePageEntityImplCopyWith(
    _$NoticePageEntityImpl value,
    $Res Function(_$NoticePageEntityImpl) then,
  ) = __$$NoticePageEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<NoticeEntity> items, int currentPage, int totalPages});
}

/// @nodoc
class __$$NoticePageEntityImplCopyWithImpl<$Res>
    extends _$NoticePageEntityCopyWithImpl<$Res, _$NoticePageEntityImpl>
    implements _$$NoticePageEntityImplCopyWith<$Res> {
  __$$NoticePageEntityImplCopyWithImpl(
    _$NoticePageEntityImpl _value,
    $Res Function(_$NoticePageEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoticePageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
  }) {
    return _then(
      _$NoticePageEntityImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<NoticeEntity>,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
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

class _$NoticePageEntityImpl implements _NoticePageEntity {
  const _$NoticePageEntityImpl({
    required final List<NoticeEntity> items,
    required this.currentPage,
    required this.totalPages,
  }) : _items = items;

  final List<NoticeEntity> _items;
  @override
  List<NoticeEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int currentPage;
  @override
  final int totalPages;

  @override
  String toString() {
    return 'NoticePageEntity(items: $items, currentPage: $currentPage, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoticePageEntityImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    currentPage,
    totalPages,
  );

  /// Create a copy of NoticePageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoticePageEntityImplCopyWith<_$NoticePageEntityImpl> get copyWith =>
      __$$NoticePageEntityImplCopyWithImpl<_$NoticePageEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _NoticePageEntity implements NoticePageEntity {
  const factory _NoticePageEntity({
    required final List<NoticeEntity> items,
    required final int currentPage,
    required final int totalPages,
  }) = _$NoticePageEntityImpl;

  @override
  List<NoticeEntity> get items;
  @override
  int get currentPage;
  @override
  int get totalPages;

  /// Create a copy of NoticePageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoticePageEntityImplCopyWith<_$NoticePageEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
