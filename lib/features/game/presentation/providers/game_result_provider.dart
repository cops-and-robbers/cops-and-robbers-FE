import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/network/required_terms_interceptor.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../data/datasources/game_result_api_datasource.dart';
import '../../domain/entities/game_result_entity.dart';

part 'game_result_provider.g.dart';

/// 게임 결과 조회 전용 Dio.
///
/// 게임 종료 결과 통계는 부가 정보이므로, 이 요청의 401이 앱 전체 강제 로그아웃으로
/// 이어지면 안 된다. 전역 [dioProvider]의 AuthInterceptor를 사용하지 않고 저장된
/// access token만 수동 첨부해 실패를 [AsyncValue.error]로 제한한다.
final gameResultDioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(secureTokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await tokenStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ),
  );

  // 전역 Dio를 안 쓰는 대가로 필수 약관 미동의 처리도 빠진다.
  // `/api/game-results/**`는 BE 제외 목록에 없어 재동의 상태면 400이 오므로,
  // 여기서도 약관 화면으로 갈 길을 만들어 준다. 위 주석의 "401을 전역
  // 강제 로그아웃으로 번지게 하지 않는다"와는 다른 관심사다.
  dio.interceptors.add(
    RequiredTermsInterceptor(
      onRequiredTermsNotAgreed: () => notifyRequiredTermsNotAgreed(ref),
    ),
  );

  return dio;
});

/// GameResultApi Retrofit 인스턴스 Provider
@riverpod
GameResultApi gameResultApi(Ref ref) {
  final dio = ref.watch(gameResultDioProvider);
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
///
/// `keepAlive: true` — GAME_OVER 직후 pre-trigger 후 1단계 AppPopup(3초)이 떠있는 동안
/// provider 구독자가 없어 autoDispose가 발동하면 다이얼로그 열릴 때 재요청이 발생한다.
/// 세션당 gameResultId는 소수라 메모리 영향 미미.
@Riverpod(keepAlive: true)
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
