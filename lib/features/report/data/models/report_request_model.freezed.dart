// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReportRequestModel _$ReportRequestModelFromJson(Map<String, dynamic> json) {
  return _ReportRequestModel.fromJson(json);
}

/// @nodoc
mixin _$ReportRequestModel {
  int get gameId => throw _privateConstructorUsedError;
  int get reportedParticipantId => throw _privateConstructorUsedError;
  String get messageContent => throw _privateConstructorUsedError;
  String get reportType => throw _privateConstructorUsedError;
  String? get etcReason => throw _privateConstructorUsedError;

  /// Serializes this ReportRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportRequestModelCopyWith<ReportRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportRequestModelCopyWith<$Res> {
  factory $ReportRequestModelCopyWith(
    ReportRequestModel value,
    $Res Function(ReportRequestModel) then,
  ) = _$ReportRequestModelCopyWithImpl<$Res, ReportRequestModel>;
  @useResult
  $Res call({
    int gameId,
    int reportedParticipantId,
    String messageContent,
    String reportType,
    String? etcReason,
  });
}

/// @nodoc
class _$ReportRequestModelCopyWithImpl<$Res, $Val extends ReportRequestModel>
    implements $ReportRequestModelCopyWith<$Res> {
  _$ReportRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? reportedParticipantId = null,
    Object? messageContent = null,
    Object? reportType = null,
    Object? etcReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as int,
            reportedParticipantId: null == reportedParticipantId
                ? _value.reportedParticipantId
                : reportedParticipantId // ignore: cast_nullable_to_non_nullable
                      as int,
            messageContent: null == messageContent
                ? _value.messageContent
                : messageContent // ignore: cast_nullable_to_non_nullable
                      as String,
            reportType: null == reportType
                ? _value.reportType
                : reportType // ignore: cast_nullable_to_non_nullable
                      as String,
            etcReason: freezed == etcReason
                ? _value.etcReason
                : etcReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReportRequestModelImplCopyWith<$Res>
    implements $ReportRequestModelCopyWith<$Res> {
  factory _$$ReportRequestModelImplCopyWith(
    _$ReportRequestModelImpl value,
    $Res Function(_$ReportRequestModelImpl) then,
  ) = __$$ReportRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int gameId,
    int reportedParticipantId,
    String messageContent,
    String reportType,
    String? etcReason,
  });
}

/// @nodoc
class __$$ReportRequestModelImplCopyWithImpl<$Res>
    extends _$ReportRequestModelCopyWithImpl<$Res, _$ReportRequestModelImpl>
    implements _$$ReportRequestModelImplCopyWith<$Res> {
  __$$ReportRequestModelImplCopyWithImpl(
    _$ReportRequestModelImpl _value,
    $Res Function(_$ReportRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? reportedParticipantId = null,
    Object? messageContent = null,
    Object? reportType = null,
    Object? etcReason = freezed,
  }) {
    return _then(
      _$ReportRequestModelImpl(
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as int,
        reportedParticipantId: null == reportedParticipantId
            ? _value.reportedParticipantId
            : reportedParticipantId // ignore: cast_nullable_to_non_nullable
                  as int,
        messageContent: null == messageContent
            ? _value.messageContent
            : messageContent // ignore: cast_nullable_to_non_nullable
                  as String,
        reportType: null == reportType
            ? _value.reportType
            : reportType // ignore: cast_nullable_to_non_nullable
                  as String,
        etcReason: freezed == etcReason
            ? _value.etcReason
            : etcReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportRequestModelImpl implements _ReportRequestModel {
  const _$ReportRequestModelImpl({
    required this.gameId,
    required this.reportedParticipantId,
    required this.messageContent,
    required this.reportType,
    this.etcReason,
  });

  factory _$ReportRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportRequestModelImplFromJson(json);

  @override
  final int gameId;
  @override
  final int reportedParticipantId;
  @override
  final String messageContent;
  @override
  final String reportType;
  @override
  final String? etcReason;

  @override
  String toString() {
    return 'ReportRequestModel(gameId: $gameId, reportedParticipantId: $reportedParticipantId, messageContent: $messageContent, reportType: $reportType, etcReason: $etcReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportRequestModelImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.reportedParticipantId, reportedParticipantId) ||
                other.reportedParticipantId == reportedParticipantId) &&
            (identical(other.messageContent, messageContent) ||
                other.messageContent == messageContent) &&
            (identical(other.reportType, reportType) ||
                other.reportType == reportType) &&
            (identical(other.etcReason, etcReason) ||
                other.etcReason == etcReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gameId,
    reportedParticipantId,
    messageContent,
    reportType,
    etcReason,
  );

  /// Create a copy of ReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportRequestModelImplCopyWith<_$ReportRequestModelImpl> get copyWith =>
      __$$ReportRequestModelImplCopyWithImpl<_$ReportRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportRequestModelImplToJson(this);
  }
}

abstract class _ReportRequestModel implements ReportRequestModel {
  const factory _ReportRequestModel({
    required final int gameId,
    required final int reportedParticipantId,
    required final String messageContent,
    required final String reportType,
    final String? etcReason,
  }) = _$ReportRequestModelImpl;

  factory _ReportRequestModel.fromJson(Map<String, dynamic> json) =
      _$ReportRequestModelImpl.fromJson;

  @override
  int get gameId;
  @override
  int get reportedParticipantId;
  @override
  String get messageContent;
  @override
  String get reportType;
  @override
  String? get etcReason;

  /// Create a copy of ReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportRequestModelImplCopyWith<_$ReportRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommunityPostReportRequestModel _$CommunityPostReportRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityPostReportRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CommunityPostReportRequestModel {
  int get postId => throw _privateConstructorUsedError;
  String get reportType => throw _privateConstructorUsedError;
  String? get etcReason => throw _privateConstructorUsedError;

  /// Serializes this CommunityPostReportRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPostReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostReportRequestModelCopyWith<CommunityPostReportRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostReportRequestModelCopyWith<$Res> {
  factory $CommunityPostReportRequestModelCopyWith(
    CommunityPostReportRequestModel value,
    $Res Function(CommunityPostReportRequestModel) then,
  ) =
      _$CommunityPostReportRequestModelCopyWithImpl<
        $Res,
        CommunityPostReportRequestModel
      >;
  @useResult
  $Res call({int postId, String reportType, String? etcReason});
}

/// @nodoc
class _$CommunityPostReportRequestModelCopyWithImpl<
  $Res,
  $Val extends CommunityPostReportRequestModel
>
    implements $CommunityPostReportRequestModelCopyWith<$Res> {
  _$CommunityPostReportRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPostReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? reportType = null,
    Object? etcReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            postId: null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as int,
            reportType: null == reportType
                ? _value.reportType
                : reportType // ignore: cast_nullable_to_non_nullable
                      as String,
            etcReason: freezed == etcReason
                ? _value.etcReason
                : etcReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityPostReportRequestModelImplCopyWith<$Res>
    implements $CommunityPostReportRequestModelCopyWith<$Res> {
  factory _$$CommunityPostReportRequestModelImplCopyWith(
    _$CommunityPostReportRequestModelImpl value,
    $Res Function(_$CommunityPostReportRequestModelImpl) then,
  ) = __$$CommunityPostReportRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int postId, String reportType, String? etcReason});
}

/// @nodoc
class __$$CommunityPostReportRequestModelImplCopyWithImpl<$Res>
    extends
        _$CommunityPostReportRequestModelCopyWithImpl<
          $Res,
          _$CommunityPostReportRequestModelImpl
        >
    implements _$$CommunityPostReportRequestModelImplCopyWith<$Res> {
  __$$CommunityPostReportRequestModelImplCopyWithImpl(
    _$CommunityPostReportRequestModelImpl _value,
    $Res Function(_$CommunityPostReportRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPostReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? reportType = null,
    Object? etcReason = freezed,
  }) {
    return _then(
      _$CommunityPostReportRequestModelImpl(
        postId: null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as int,
        reportType: null == reportType
            ? _value.reportType
            : reportType // ignore: cast_nullable_to_non_nullable
                  as String,
        etcReason: freezed == etcReason
            ? _value.etcReason
            : etcReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityPostReportRequestModelImpl
    implements _CommunityPostReportRequestModel {
  const _$CommunityPostReportRequestModelImpl({
    required this.postId,
    required this.reportType,
    this.etcReason,
  });

  factory _$CommunityPostReportRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityPostReportRequestModelImplFromJson(json);

  @override
  final int postId;
  @override
  final String reportType;
  @override
  final String? etcReason;

  @override
  String toString() {
    return 'CommunityPostReportRequestModel(postId: $postId, reportType: $reportType, etcReason: $etcReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostReportRequestModelImpl &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.reportType, reportType) ||
                other.reportType == reportType) &&
            (identical(other.etcReason, etcReason) ||
                other.etcReason == etcReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, postId, reportType, etcReason);

  /// Create a copy of CommunityPostReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostReportRequestModelImplCopyWith<
    _$CommunityPostReportRequestModelImpl
  >
  get copyWith =>
      __$$CommunityPostReportRequestModelImplCopyWithImpl<
        _$CommunityPostReportRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPostReportRequestModelImplToJson(this);
  }
}

abstract class _CommunityPostReportRequestModel
    implements CommunityPostReportRequestModel {
  const factory _CommunityPostReportRequestModel({
    required final int postId,
    required final String reportType,
    final String? etcReason,
  }) = _$CommunityPostReportRequestModelImpl;

  factory _CommunityPostReportRequestModel.fromJson(Map<String, dynamic> json) =
      _$CommunityPostReportRequestModelImpl.fromJson;

  @override
  int get postId;
  @override
  String get reportType;
  @override
  String? get etcReason;

  /// Create a copy of CommunityPostReportRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostReportRequestModelImplCopyWith<
    _$CommunityPostReportRequestModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
