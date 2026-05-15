import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/create_session_result.dart';
import '../../domain/entities/user_game_status_entity.dart';
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
        maxParticipants: response.maxParticipants,
        locationRevealIntervalMinutes: response.locationRevealIntervalMinutes,
        // v2.7.0부터 +09:00 suffix가 포함되어 DateTime이 UTC로 파싱된다.
        // UI는 단말 local 기준 시각을 기대하므로 Entity 경계에서 정규화.
        createdAt: response.createdAt.toLocal(),
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

  @override
  Future<UserGameStatusEntity> getMyActiveGame() async {
    try {
      final response = await _dataSource.getMyActiveGame();
      return UserGameStatusEntity(
        isParticipating: response.isParticipating,
        participationInfo: response.participationInfo == null
            ? null
            : UserGameParticipationEntity(
                gameId: response.participationInfo!.gameId,
                participantId: response.participationInfo!.participantId,
                gameStatus: response.participationInfo!.gameStatus,
                team: response.participationInfo!.team,
              ),
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '참여 중인 게임 조회 중 예기치 않은 오류가 발생했습니다.',
        originalException: e,
      );
    }
  }
}
