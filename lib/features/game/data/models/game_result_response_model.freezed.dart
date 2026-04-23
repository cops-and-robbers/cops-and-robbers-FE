// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_result_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameResultResponseModel _$GameResultResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _GameResultResponseModel.fromJson(json);
}

/// @nodoc
mixin _$GameResultResponseModel {
  /// 승리 팀 ("POLICE" | "ROBBER")
  String get winnerTeam => throw _privateConstructorUsedError;

  /// 게임 진행 시간(초)
  int get durationSeconds => throw _privateConstructorUsedError;

  /// 총 체포 횟수
  int get totalArrestCount => throw _privateConstructorUsedError;

  /// 남은 도둑 수
  int get remainingRobberCount => throw _privateConstructorUsedError;

  /// Serializes this GameResultResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameResultResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameResultResponseModelCopyWith<GameResultResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameResultResponseModelCopyWith<$Res> {
  factory $GameResultResponseModelCopyWith(
    GameResultResponseModel value,
    $Res Function(GameResultResponseModel) then,
  ) = _$GameResultResponseModelCopyWithImpl<$Res, GameResultResponseModel>;
  @useResult
  $Res call({
    String winnerTeam,
    int durationSeconds,
    int totalArrestCount,
    int remainingRobberCount,
  });
}

/// @nodoc
class _$GameResultResponseModelCopyWithImpl<
  $Res,
  $Val extends GameResultResponseModel
>
    implements $GameResultResponseModelCopyWith<$Res> {
  _$GameResultResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameResultResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? winnerTeam = null,
    Object? durationSeconds = null,
    Object? totalArrestCount = null,
    Object? remainingRobberCount = null,
  }) {
    return _then(
      _value.copyWith(
            winnerTeam: null == winnerTeam
                ? _value.winnerTeam
                : winnerTeam // ignore: cast_nullable_to_non_nullable
                      as String,
            durationSeconds: null == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            totalArrestCount: null == totalArrestCount
                ? _value.totalArrestCount
                : totalArrestCount // ignore: cast_nullable_to_non_nullable
                      as int,
            remainingRobberCount: null == remainingRobberCount
                ? _value.remainingRobberCount
                : remainingRobberCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameResultResponseModelImplCopyWith<$Res>
    implements $GameResultResponseModelCopyWith<$Res> {
  factory _$$GameResultResponseModelImplCopyWith(
    _$GameResultResponseModelImpl value,
    $Res Function(_$GameResultResponseModelImpl) then,
  ) = __$$GameResultResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String winnerTeam,
    int durationSeconds,
    int totalArrestCount,
    int remainingRobberCount,
  });
}

/// @nodoc
class __$$GameResultResponseModelImplCopyWithImpl<$Res>
    extends
        _$GameResultResponseModelCopyWithImpl<
          $Res,
          _$GameResultResponseModelImpl
        >
    implements _$$GameResultResponseModelImplCopyWith<$Res> {
  __$$GameResultResponseModelImplCopyWithImpl(
    _$GameResultResponseModelImpl _value,
    $Res Function(_$GameResultResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameResultResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? winnerTeam = null,
    Object? durationSeconds = null,
    Object? totalArrestCount = null,
    Object? remainingRobberCount = null,
  }) {
    return _then(
      _$GameResultResponseModelImpl(
        winnerTeam: null == winnerTeam
            ? _value.winnerTeam
            : winnerTeam // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        totalArrestCount: null == totalArrestCount
            ? _value.totalArrestCount
            : totalArrestCount // ignore: cast_nullable_to_non_nullable
                  as int,
        remainingRobberCount: null == remainingRobberCount
            ? _value.remainingRobberCount
            : remainingRobberCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameResultResponseModelImpl implements _GameResultResponseModel {
  const _$GameResultResponseModelImpl({
    required this.winnerTeam,
    required this.durationSeconds,
    required this.totalArrestCount,
    required this.remainingRobberCount,
  });

  factory _$GameResultResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameResultResponseModelImplFromJson(json);

  /// 승리 팀 ("POLICE" | "ROBBER")
  @override
  final String winnerTeam;

  /// 게임 진행 시간(초)
  @override
  final int durationSeconds;

  /// 총 체포 횟수
  @override
  final int totalArrestCount;

  /// 남은 도둑 수
  @override
  final int remainingRobberCount;

  @override
  String toString() {
    return 'GameResultResponseModel(winnerTeam: $winnerTeam, durationSeconds: $durationSeconds, totalArrestCount: $totalArrestCount, remainingRobberCount: $remainingRobberCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameResultResponseModelImpl &&
            (identical(other.winnerTeam, winnerTeam) ||
                other.winnerTeam == winnerTeam) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.totalArrestCount, totalArrestCount) ||
                other.totalArrestCount == totalArrestCount) &&
            (identical(other.remainingRobberCount, remainingRobberCount) ||
                other.remainingRobberCount == remainingRobberCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    winnerTeam,
    durationSeconds,
    totalArrestCount,
    remainingRobberCount,
  );

  /// Create a copy of GameResultResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameResultResponseModelImplCopyWith<_$GameResultResponseModelImpl>
  get copyWith =>
      __$$GameResultResponseModelImplCopyWithImpl<
        _$GameResultResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameResultResponseModelImplToJson(this);
  }
}

abstract class _GameResultResponseModel implements GameResultResponseModel {
  const factory _GameResultResponseModel({
    required final String winnerTeam,
    required final int durationSeconds,
    required final int totalArrestCount,
    required final int remainingRobberCount,
  }) = _$GameResultResponseModelImpl;

  factory _GameResultResponseModel.fromJson(Map<String, dynamic> json) =
      _$GameResultResponseModelImpl.fromJson;

  /// 승리 팀 ("POLICE" | "ROBBER")
  @override
  String get winnerTeam;

  /// 게임 진행 시간(초)
  @override
  int get durationSeconds;

  /// 총 체포 횟수
  @override
  int get totalArrestCount;

  /// 남은 도둑 수
  @override
  int get remainingRobberCount;

  /// Create a copy of GameResultResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameResultResponseModelImplCopyWith<_$GameResultResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
