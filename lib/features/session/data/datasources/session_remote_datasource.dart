import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/create_session_response.dart';
import '../models/game_create_request_model.dart';
import '../models/game_settings_response.dart';
import '../../../game/data/models/game_area_model.dart';
import '../models/in_game_participants_response.dart';
import '../models/join_game_request.dart';
import '../models/join_game_response.dart';
import '../models/leave_game_response.dart';
import '../models/lobby_info_response.dart';
import '../models/ready_request.dart';
import '../models/team_change_request.dart';
import '../models/user_game_status_model.dart';

part 'session_remote_datasource.g.dart';

/// Session 백엔드 API 클라이언트
///
/// Retrofit 기반으로 Game/Session API를 호출합니다.
///
/// **엔드포인트**:
/// - `POST /api/games` - 게임 방 생성 (JWT 필요)
/// - `DELETE /api/games/{gameId}/participants` - 게임 방 퇴장
@RestApi()
abstract class SessionRemoteDataSource {
  factory SessionRemoteDataSource(Dio dio) = _SessionRemoteDataSource;

  /// 게임 방 생성
  ///
  /// 새로운 게임 방을 생성하고 초대 코드를 발급받습니다.
  /// 방을 생성한 사용자는 자동으로 방장이 됩니다.
  ///
  /// - 201: 생성 성공 (gameId, inviteCode, ...)
  /// - 400: 유효성 검증 실패
  /// - 401: 인증 실패
  /// - 409: 이미 활성 게임 참여 중
  @POST(ApiEndpoints.createGame)
  Future<CreateSessionResponse> createGame(
    @Body() GameCreateRequestModel request,
  );

  /// 게임 방 퇴장
  ///
  /// 현재 참여 중인 게임 방에서 퇴장합니다.
  /// 방장이 퇴장하면 가장 먼저 참여한 참여자에게 방장 권한이 이전됩니다.
  /// 마지막 참여자가 퇴장하면 게임 방이 자동으로 삭제됩니다.
  ///
  /// - 200: 퇴장 성공
  /// - 401: 인증 실패
  /// - 404: 게임 또는 참여 정보를 찾을 수 없음
  @DELETE('/api/games/{gameId}/leave')
  Future<LeaveGameResponse> leaveGame(@Path('gameId') int gameId);

  /// 게임 시작
  ///
  /// 대기 중인 게임을 시작합니다.
  /// - 방장(Host)만 시작 가능
  /// - 경찰/도둑 팀 각각 1명 이상 필요
  /// - 모든 참가자가 준비(Ready) 상태여야 함
  ///
  /// - 204: 게임 시작 성공
  /// - 400: 방장이 아님 / 준비 조건 미충족
  /// - 401: 인증 실패
  /// - 404: 게임 또는 참여 정보 없음
  @POST('/api/games/{gameId}/lobby/start')
  Future<void> startGame(@Path('gameId') int gameId);

  /// 준비 상태 변경
  ///
  /// 대기 상태(WAITING)에서 준비 상태를 변경합니다.
  ///
  /// - 204: 준비 상태 변경 성공
  /// - 400: 요청 바디 검증 실패
  /// - 401: 인증 실패
  /// - 404: 게임 또는 참여 정보 없음
  @PATCH('/api/games/{gameId}/lobby/ready')
  Future<void> updateReady(
    @Path('gameId') int gameId,
    @Body() ReadyRequest request,
  );

  /// 팀 변경
  ///
  /// 대기 상태(WAITING)에서 팀을 변경합니다.
  /// 팀 변경 시 해당 유저의 준비 상태는 해제됩니다.
  ///
  /// - 204: 팀 변경 성공
  /// - 400: 요청 바디 검증 실패
  /// - 401: 인증 실패
  /// - 404: 게임 또는 참여 정보 없음
  @PATCH('/api/games/{gameId}/lobby/team')
  Future<void> changeTeam(
    @Path('gameId') int gameId,
    @Body() TeamChangeRequest request,
  );

  /// 게임 방 참여
  ///
  /// 초대 코드를 사용하여 게임 방에 참여합니다.
  ///
  /// - 200: 참여 성공 (gameId, participantId 반환)
  /// - 400: 초대 코드 누락 / 유효하지 않음
  /// - 401: 인증 실패
  /// - 409: 이미 다른 활성 게임에 참여 중
  @POST('/api/games/join')
  Future<JoinGameResponse> joinGame(@Body() JoinGameRequest request);

  /// 로비 조회
  ///
  /// 대기실 초기 상태(참가자 목록, myParticipantId, 게임 설정)를 반환합니다.
  ///
  /// - 200: 조회 성공
  /// - 401: 인증 실패
  /// - 404: 게임 또는 참여 정보 없음
  @GET('/api/games/{gameId}/lobby')
  Future<LobbyInfoResponse> fetchLobbyInfo(@Path('gameId') int gameId);

  /// 게임 설정 조회
  ///
  /// 게임 방의 기본 설정(라운드 시간, 위치 공개 주기 등)을 반환합니다.
  ///
  /// - 200: 조회 성공
  /// - 401: 인증 실패
  /// - 404: 게임 없음
  @GET('/api/games/{gameId}')
  Future<GameSettingsResponse> fetchGameSettings(@Path('gameId') int gameId);

  /// 인게임 참가자 목록 조회
  ///
  /// 게임 진행 중 경찰/도둑 참가자 목록과 상태를 반환합니다.
  ///
  /// - 200: 조회 성공
  /// - 401: 인증 실패
  /// - 404: 게임 또는 참여 정보 없음
  @GET('/api/games/{gameId}/participants')
  Future<InGameParticipantsResponse> fetchGameParticipants(
    @Path('gameId') int gameId,
  );

  /// 게임 영역 조회
  ///
  /// 플레이그라운드·감옥 중심 좌표 및 반경을 반환합니다.
  ///
  /// - 200: 조회 성공
  /// - 401: 인증 실패
  /// - 404: 게임 없음
  @GET('/api/games/{gameId}/area')
  Future<GameAreaModel> fetchGameArea(@Path('gameId') int gameId);

  /// 게임 설정 수정
  ///
  /// 라운드 시간, 위치 공개 주기, 경찰 대기 시간, 최대 참여 인원을 수정합니다.
  ///
  /// - 200: 수정 성공
  /// - 400: 유효성 검증 실패
  /// - 401: 인증 실패
  /// - 403: 방장만 수정 가능
  /// - 404: 게임 없음
  @PUT('/api/games/{gameId}/settings')
  Future<GameSettingsResponse> updateGameSettings(
    @Path('gameId') int gameId,
    @Body() GameSettingsRequestModel request,
  );

  /// 게임 영역 수정
  ///
  /// 플레이그라운드·감옥 중심 좌표 및 반경을 수정합니다.
  ///
  /// - 200: 수정 성공
  /// - 400: 유효성 검증 실패
  /// - 401: 인증 실패
  /// - 403: 방장만 수정 가능
  /// - 404: 게임 없음
  @PUT('/api/games/{gameId}/area')
  Future<GameAreaModel> updateGameArea(
    @Path('gameId') int gameId,
    @Body() GameAreaRequestModel request,
  );

  /// 멤버 강제 퇴장 (방장 전용)
  ///
  /// 대기실에서 특정 참가자를 강제 퇴장시킵니다.
  ///
  /// - 204: 강제 퇴장 성공
  /// - 400: 자기 자신 강퇴 불가 / 이미 시작된 게임
  /// - 403: 방장 권한 필요
  /// - 404: 게임 또는 참가자 없음
  @DELETE('/api/games/{gameId}/lobby/{participantId}')
  Future<void> kickMember(
    @Path('gameId') int gameId,
    @Path('participantId') int participantId,
  );

  /// 참여 중인 게임 정보 조회
  ///
  /// 로그인한 사용자가 현재 참여 중인 게임 정보를 반환합니다.
  /// 참여 중인 게임이 없으면 [UserGameStatusModel.participationInfo]가 null.
  ///
  /// - 200: 조회 성공
  /// - 401: 인증 실패
  @GET('/api/user/me/game')
  Future<UserGameStatusModel> getMyActiveGame();
}
