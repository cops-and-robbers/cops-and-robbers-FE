import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../data/datasources/game_result_api_datasource.dart';
import '../../domain/entities/game_result_entity.dart';

part 'game_result_provider.g.dart';

/// GameResultApi Retrofit 인스턴스 Provider
@riverpod
GameResultApi gameResultApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return GameResultApi(dio);
}

/// 게임 결과 조회 FutureProvider (family by gameResultId)
///
/// `GET /api/game-results/{gameResultId}` 응답을 캐시합니다.
/// GAME_OVER 이벤트 수신 직후 `ref.read(gameResultProvider(id).future)`로
/// 사전 트리거하여, 결과 다이얼로그가 뜰 때는 이미 데이터가 준비되도록 합니다.
///
/// DTO → Entity 변환은 Provider 내부에서 직접 수행합니다
/// (프로젝트 Entity 컨벤션 — Entity는 Data Layer에 의존하지 않음).
///
/// 실패 시 `DioExceptionHandler.handle`로 AppException 변환 후 던져,
/// UI 쪽에서 AsyncValue.error로 분기됩니다.
/// (로깅은 `DioExceptionHandler` 내부에서 수행하므로 여기서는 별도 출력 없음)
@riverpod
Future<GameResultEntity> gameResult(Ref ref, int gameResultId) async {
  try {
    final response = await ref
        .read(gameResultApiProvider)
        .getGameResult(gameResultId);
    return GameResultEntity(
      winnerTeam: response.winnerTeam,
      durationSeconds: response.durationSeconds,
      totalArrestCount: response.totalArrestCount,
      remainingRobberCount: response.remainingRobberCount,
    );
  } on DioException catch (e) {
    throw DioExceptionHandler.handle(e);
  }
}
