import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/game_area_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'game_system_api_datasource.freezed.dart';
part 'game_system_api_datasource.g.dart';

/// 체포 요청 바디
@freezed
class ArrestRequestModel with _$ArrestRequestModel {
  const factory ArrestRequestModel({required int robberParticipantId}) =
      _ArrestRequestModel;

  factory ArrestRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ArrestRequestModelFromJson(json);
}

/// 체포 응답 바디
@freezed
class ArrestResponseModel with _$ArrestResponseModel {
  const factory ArrestResponseModel({
    @Default('') String robberNickname,
    @Default(0) int remainingThieves,
  }) = _ArrestResponseModel;

  factory ArrestResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ArrestResponseModelFromJson(json);
}

/// 게임 시스템 REST API 클라이언트
///
/// - `POST /api/games/{gameId}/system/arrest` — 도둑 체포 (경찰만)
/// - `POST /api/games/{gameId}/system/escape` — 탈옥 (수감된 도둑만)
/// - `GET  /api/games/{gameId}/area` — 맵 영역 조회
@RestApi()
abstract class GameSystemApi {
  factory GameSystemApi(Dio dio) = _GameSystemApi;

  /// 도둑 체포
  @POST('/api/games/{gameId}/system/arrest')
  Future<ArrestResponseModel> arrest(
    @Path('gameId') int gameId,
    @Body() ArrestRequestModel body,
  );

  /// 탈옥
  @POST('/api/games/{gameId}/system/escape')
  Future<void> escape(@Path('gameId') int gameId);

  /// 맵 영역 조회
  @GET('/api/games/{gameId}/area')
  Future<GameAreaModel> getArea(@Path('gameId') int gameId);
}

/// GameSystemApi Provider
@riverpod
GameSystemApi gameSystemApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return GameSystemApi(dio);
}
