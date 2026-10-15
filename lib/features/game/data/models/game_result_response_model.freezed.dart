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

  /// 팀 MVP (BE #212). 팀당 1명이고, 후보가 없거나(전원 중도 퇴장)
  /// 필드가 없는 구버전 서버 응답이면 null이다.
  GameMvpModel? get policeMvp => throw _privateConstructorUsedError;
  GameMvpModel? get robberMvp => throw _privateConstructorUsedError;

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
    GameMvpModel? policeMvp,
    GameMvpModel? robberMvp,
  });

  $GameMvpModelCopyWith<$Res>? get policeMvp;
  $GameMvpModelCopyWith<$Res>? get robberMvp;
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
    Object? policeMvp = freezed,
    Object? robberMvp = freezed,
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
            policeMvp: freezed == policeMvp
                ? _value.policeMvp
                : policeMvp // ignore: cast_nullable_to_non_nullable
                      as GameMvpModel?,
            robberMvp: freezed == robberMvp
                ? _value.robberMvp
                : robberMvp // ignore: cast_nullable_to_non_nullable
                      as GameMvpModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameResultResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameMvpModelCopyWith<$Res>? get policeMvp {
    if (_value.policeMvp == null) {
      return null;
    }

    return $GameMvpModelCopyWith<$Res>(_value.policeMvp!, (value) {
      return _then(_value.copyWith(policeMvp: value) as $Val);
    });
  }

  /// Create a copy of GameResultResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameMvpModelCopyWith<$Res>? get robberMvp {
    if (_value.robberMvp == null) {
      return null;
    }

    return $GameMvpModelCopyWith<$Res>(_value.robberMvp!, (value) {
      return _then(_value.copyWith(robberMvp: value) as $Val);
    });
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
    GameMvpModel? policeMvp,
    GameMvpModel? robberMvp,
  });

  @override
  $GameMvpModelCopyWith<$Res>? get policeMvp;
  @override
  $GameMvpModelCopyWith<$Res>? get robberMvp;
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
    Object? policeMvp = freezed,
    Object? robberMvp = freezed,
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
        policeMvp: freezed == policeMvp
            ? _value.policeMvp
            : policeMvp // ignore: cast_nullable_to_non_nullable
                  as GameMvpModel?,
        robberMvp: freezed == robberMvp
            ? _value.robberMvp
            : robberMvp // ignore: cast_nullable_to_non_nullable
                  as GameMvpModel?,
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
    this.policeMvp,
    this.robberMvp,
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

  /// 팀 MVP (BE #212). 팀당 1명이고, 후보가 없거나(전원 중도 퇴장)
  /// 필드가 없는 구버전 서버 응답이면 null이다.
  @override
  final GameMvpModel? policeMvp;
  @override
  final GameMvpModel? robberMvp;

  @override
  String toString() {
    return 'GameResultResponseModel(winnerTeam: $winnerTeam, durationSeconds: $durationSeconds, totalArrestCount: $totalArrestCount, remainingRobberCount: $remainingRobberCount, policeMvp: $policeMvp, robberMvp: $robberMvp)';
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
                other.remainingRobberCount == remainingRobberCount) &&
            (identical(other.policeMvp, policeMvp) ||
                other.policeMvp == policeMvp) &&
            (identical(other.robberMvp, robberMvp) ||
                other.robberMvp == robberMvp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    winnerTeam,
    durationSeconds,
    totalArrestCount,
    remainingRobberCount,
    policeMvp,
    robberMvp,
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
    final GameMvpModel? policeMvp,
    final GameMvpModel? robberMvp,
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

  /// 팀 MVP (BE #212). 팀당 1명이고, 후보가 없거나(전원 중도 퇴장)
  /// 필드가 없는 구버전 서버 응답이면 null이다.
  @override
  GameMvpModel? get policeMvp;
  @override
  GameMvpModel? get robberMvp;

  /// Create a copy of GameResultResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameResultResponseModelImplCopyWith<_$GameResultResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GameMvpModel _$GameMvpModelFromJson(Map<String, dynamic> json) {
  return _GameMvpModel.fromJson(json);
}

/// @nodoc
mixin _$GameMvpModel {
  String get nickname => throw _privateConstructorUsedError;

  /// Serializes this GameMvpModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameMvpModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameMvpModelCopyWith<GameMvpModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameMvpModelCopyWith<$Res> {
  factory $GameMvpModelCopyWith(
    GameMvpModel value,
    $Res Function(GameMvpModel) then,
  ) = _$GameMvpModelCopyWithImpl<$Res, GameMvpModel>;
  @useResult
  $Res call({String nickname});
}

/// @nodoc
class _$GameMvpModelCopyWithImpl<$Res, $Val extends GameMvpModel>
    implements $GameMvpModelCopyWith<$Res> {
  _$GameMvpModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameMvpModel
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
abstract class _$$GameMvpModelImplCopyWith<$Res>
    implements $GameMvpModelCopyWith<$Res> {
  factory _$$GameMvpModelImplCopyWith(
    _$GameMvpModelImpl value,
    $Res Function(_$GameMvpModelImpl) then,
  ) = __$$GameMvpModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String nickname});
}

/// @nodoc
class __$$GameMvpModelImplCopyWithImpl<$Res>
    extends _$GameMvpModelCopyWithImpl<$Res, _$GameMvpModelImpl>
    implements _$$GameMvpModelImplCopyWith<$Res> {
  __$$GameMvpModelImplCopyWithImpl(
    _$GameMvpModelImpl _value,
    $Res Function(_$GameMvpModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameMvpModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nickname = null}) {
    return _then(
      _$GameMvpModelImpl(
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
class _$GameMvpModelImpl implements _GameMvpModel {
  const _$GameMvpModelImpl({required this.nickname});

  factory _$GameMvpModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameMvpModelImplFromJson(json);

  @override
  final String nickname;

  @override
  String toString() {
    return 'GameMvpModel(nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameMvpModelImpl &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nickname);

  /// Create a copy of GameMvpModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameMvpModelImplCopyWith<_$GameMvpModelImpl> get copyWith =>
      __$$GameMvpModelImplCopyWithImpl<_$GameMvpModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameMvpModelImplToJson(this);
  }
}

abstract class _GameMvpModel implements GameMvpModel {
  const factory _GameMvpModel({required final String nickname}) =
      _$GameMvpModelImpl;

  factory _GameMvpModel.fromJson(Map<String, dynamic> json) =
      _$GameMvpModelImpl.fromJson;

  @override
  String get nickname;

  /// Create a copy of GameMvpModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameMvpModelImplCopyWith<_$GameMvpModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
