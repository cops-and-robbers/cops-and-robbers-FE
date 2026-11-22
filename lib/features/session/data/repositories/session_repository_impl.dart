import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/game_mode.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../game/domain/entities/area_shape.dart';
import '../../domain/entities/create_session_result.dart';
import '../../domain/entities/game_join_result.dart';
import '../../domain/entities/user_game_status_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_datasource.dart';
import '../models/game_create_request_model.dart';
import '../models/game_mode_update_request_model.dart';
import '../models/join_game_request.dart';

/// Session Repository 구현체
///
/// [SessionRemoteDataSource]를 통해 백엔드 Game API를 호출합니다.
/// Data DTO → Domain Entity 변환을 담당합니다.
class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource _dataSource;

  SessionRepositoryImpl(this._dataSource);

  @override
  Future<CreateSessionResult> createGame({
    required GameMode gameMode,
    required GameAreaEntity area,
    required int roundDurationMinutes,
    required int locationRevealIntervalMinutes,
    required int policeWaitMinutes,
    required int maxParticipants,

    /// 구역 축소 최종 반경(m). null이면 꺼짐 (#668)
    int? shrinkFinalRadiusInMeters,

    /// 방장이 무전을 켰는지. 기본 꺼짐 (#723)
    bool radioEnabled = false,
  }) async {
    // unknown은 서버가 모르는 값이다. toJson의 assert는 release에서 빠지므로 여기서 막는다.
    if (gameMode == GameMode.unknown) {
      throw ArgumentError.value(gameMode, 'gameMode', '서버로 보낼 수 없는 모드');
    }
    final areaRequest = area.toRequestModel();

    try {
      final request = GameCreateRequestModel(
        gameMode: gameMode,
        area: areaRequest,
        settings: GameSettingsRequestModel(
          roundDurationMinutes: roundDurationMinutes,
          locationRevealIntervalMinutes: locationRevealIntervalMinutes,
          policeWaitMinutes: policeWaitMinutes,
          maxParticipants: maxParticipants,
          shrinkFinalRadiusInMeters: shrinkFinalRadiusInMeters,
          radioEnabled: radioEnabled,
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
        messageKey: 'errorGameRoomCreateUnexpected',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateGameMode(
    int gameId, {
    required GameMode mode,
    required GameAreaEntity area,
  }) async {
    // createGame과 같은 이유로 unknown은 요청 전에 막는다.
    if (mode == GameMode.unknown) {
      throw ArgumentError.value(mode, 'mode', '서버로 보낼 수 없는 모드');
    }
    final areaRequest = area.toRequestModel();

    try {
      await _dataSource.updateGameMode(
        gameId,
        GameModeUpdateRequestModel(gameMode: mode, area: areaRequest),
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '게임 모드 변경 중 예기치 않은 오류가 발생했습니다.',
        messageKey: 'errorGameModeUpdateUnexpected',
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
        messageKey: 'errorActiveGameFetchUnexpected',
        originalException: e,
      );
    }
  }

  @override
  Future<GameJoinResult> joinGameByInvite({required String inviteCode}) async {
    try {
      final response = await _dataSource.joinGame(
        JoinGameRequest(inviteCode: inviteCode),
      );
      return GameJoinResult(
        gameId: response.gameId,
        participantId: response.participantId,
        isEventGame: response.isEventGame,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '게임 방 참여 중 예기치 않은 오류가 발생했습니다.',
        messageKey: 'errorGameJoinUnexpected',
        originalException: e,
      );
    }
  }
}
