import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/create_session_result.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_datasource.dart';
import '../models/game_create_request_model.dart';

/// Session Repository 구현체
///
/// [SessionRemoteDataSource]를 통해 백엔드 Game API를 호출합니다.
/// Data DTO → Domain Entity 변환을 담당합니다.
class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource _dataSource;

  SessionRepositoryImpl(this._dataSource);

  @override
  Future<CreateSessionResult> createGame({
    required double playgroundLatitude,
    required double playgroundLongitude,
    required int playgroundRadiusInMeters,
    required double jailLatitude,
    required double jailLongitude,
    required int jailRadiusInMeters,
    required int roundDurationMinutes,
    required int locationRevealIntervalMinutes,
    required int policeWaitMinutes,
    required int maxParticipants,
  }) async {
    try {
      final request = GameCreateRequestModel(
        area: AreaRequestModel(
          playgroundCenter: CoordinatesRequestModel(
            latitude: playgroundLatitude,
            longitude: playgroundLongitude,
          ),
          playgroundRadiusInMeters: playgroundRadiusInMeters,
          jailCenter: CoordinatesRequestModel(
            latitude: jailLatitude,
            longitude: jailLongitude,
          ),
          jailRadiusInMeters: jailRadiusInMeters,
        ),
        settings: GameSettingsRequestModel(
          roundDurationMinutes: roundDurationMinutes,
          locationRevealIntervalMinutes: locationRevealIntervalMinutes,
          policeWaitMinutes: policeWaitMinutes,
          maxParticipants: maxParticipants,
        ),
      );

      final response = await _dataSource.createGame(request);

      if (kDebugMode) {
        debugPrint(
          '✅ 게임 방 생성 성공: gameId=${response.gameId}, '
          'inviteCode=${response.inviteCode}',
        );
      }

      // Data DTO → Domain Entity 변환
      return CreateSessionResult(
        gameId: response.gameId,
        inviteCode: response.inviteCode,
        status: response.status,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '게임 방 생성 중 예기치 않은 오류가 발생했습니다.',
        originalException: e,
      );
    }
  }
}
