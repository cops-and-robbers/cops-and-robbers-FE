import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/data/datasources/session_remote_datasource.dart';
import 'package:cops_and_robbers/features/session/data/models/create_session_response.dart';
import 'package:cops_and_robbers/features/session/data/models/game_create_request_model.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:cops_and_robbers/features/session/data/models/in_game_participants_response.dart';
import 'package:cops_and_robbers/features/session/data/models/join_game_request.dart';
import 'package:cops_and_robbers/features/session/data/models/join_game_response.dart';
import 'package:cops_and_robbers/features/session/data/models/leave_game_response.dart';
import 'package:cops_and_robbers/features/session/data/models/lobby_info_response.dart';
import 'package:cops_and_robbers/features/session/data/models/ready_request.dart';
import 'package:cops_and_robbers/features/session/data/models/team_change_request.dart';
import 'package:cops_and_robbers/features/session/data/models/user_game_status_model.dart';
import 'package:cops_and_robbers/features/session/data/repositories/session_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// `SessionRemoteDataSource`의 메서드 중 `createGame`만 실제 구현하고
/// 나머지는 본 테스트에서 미사용이므로 `UnimplementedError`를 던진다.
class _FakeSessionRemoteDataSource implements SessionRemoteDataSource {
  CreateSessionResponse? responseToReturn;
  Object? errorToThrow;
  GameCreateRequestModel? lastRequest;

  @override
  Future<CreateSessionResponse> createGame(
    GameCreateRequestModel request,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastRequest = request;
    return responseToReturn!;
  }

  @override
  Future<LeaveGameResponse> leaveGame(int gameId) => throw UnimplementedError();

  @override
  Future<void> startGame(int gameId) => throw UnimplementedError();

  @override
  Future<void> updateReady(int gameId, ReadyRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> changeTeam(int gameId, TeamChangeRequest request) =>
      throw UnimplementedError();

  @override
  Future<JoinGameResponse> joinGame(JoinGameRequest request) =>
      throw UnimplementedError();

  @override
  Future<LobbyInfoResponse> fetchLobbyInfo(int gameId) =>
      throw UnimplementedError();

  @override
  Future<GameSettingsResponse> fetchGameSettings(int gameId) =>
      throw UnimplementedError();

  @override
  Future<InGameParticipantsResponse> fetchGameParticipants(int gameId) =>
      throw UnimplementedError();

  @override
  Future<GameAreaModel> fetchGameArea(int gameId) => throw UnimplementedError();

  @override
  Future<GameSettingsResponse> updateGameSettings(
    int gameId,
    GameSettingsRequestModel request,
  ) => throw UnimplementedError();

  @override
  Future<GameAreaModel> updateGameArea(
    int gameId,
    GameAreaRequestModel request,
  ) => throw UnimplementedError();

  @override
  Future<void> kickMember(int gameId, int participantId) =>
      throw UnimplementedError();

  @override
  Future<UserGameStatusModel> getMyActiveGame() => throw UnimplementedError();
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/api/games'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/games'),
    statusCode: statusCode,
    data: {
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': '/api/games',
    },
  ),
  type: DioExceptionType.badResponse,
);

/// 테스트용 createGame 호출 헬퍼 (필수 인자 보일러플레이트 줄이기).
Future<dynamic> _callCreateGame(SessionRepositoryImpl repo) => repo.createGame(
  area: const GameAreaEntity(
    playground: AreaShape.circle(
      center: GeoPoint(latitude: 37.5, longitude: 127.0),
      radiusInMeters: 500,
    ),
    jail: AreaShape.circle(
      center: GeoPoint(latitude: 37.5, longitude: 127.0),
      radiusInMeters: 50,
    ),
  ),
  roundDurationMinutes: 30,
  locationRevealIntervalMinutes: 5,
  policeWaitMinutes: 3,
  maxParticipants: 10,
);

CreateSessionResponse _createSessionResponse() =>
    CreateSessionResponse.fromJson({
      'gameId': 1,
      'inviteCode': 'ABC123',
      'status': 'WAITING',
      'roundDurationMinutes': 30,
      'locationRevealIntervalMinutes': 5,
      'policeWaitMinutes': 3,
      'maxParticipants': 10,
      'createdAt': '2026-01-16T01:25:37+09:00',
    });

void main() {
  group('SessionRepositoryImpl.createGame', () {
    test('circle_area_is_mapped_to_request_when_game_is_created', () async {
      final fake = _FakeSessionRemoteDataSource()
        ..responseToReturn = _createSessionResponse();
      final repo = SessionRepositoryImpl(fake);

      await _callCreateGame(repo);

      expect(
        fake.lastRequest?.area,
        const GameAreaRequestModel(
          areaType: GameAreaType.circle,
          circle: CircleAreaRequestModel(
            playgroundCenter: CoordinatesRequestModel(
              latitude: 37.5,
              longitude: 127.0,
            ),
            playgroundRadiusInMeters: 500,
            jailCenter: CoordinatesRequestModel(
              latitude: 37.5,
              longitude: 127.0,
            ),
            jailRadiusInMeters: 50,
          ),
        ),
      );
    });

    test('polygon_area_is_mapped_to_request_model', () {
      const area = GameAreaEntity(
        playground: AreaShape.polygon(
          points: [
            GeoPoint(latitude: 37.5685, longitude: 126.9760),
            GeoPoint(latitude: 37.5685, longitude: 126.9800),
            GeoPoint(latitude: 37.5645, longitude: 126.9780),
          ],
        ),
        jail: AreaShape.polygon(
          points: [
            GeoPoint(latitude: 37.5670, longitude: 126.9775),
            GeoPoint(latitude: 37.5670, longitude: 126.9785),
            GeoPoint(latitude: 37.5660, longitude: 126.9780),
          ],
        ),
      );

      final request = area.toRequestModel();

      expect(
        request,
        const GameAreaRequestModel(
          areaType: GameAreaType.polygon,
          polygon: PolygonAreaRequestModel(
            playgroundPolygon: [
              CoordinatesRequestModel(latitude: 37.5685, longitude: 126.9760),
              CoordinatesRequestModel(latitude: 37.5685, longitude: 126.9800),
              CoordinatesRequestModel(latitude: 37.5645, longitude: 126.9780),
            ],
            jailPolygon: [
              CoordinatesRequestModel(latitude: 37.5670, longitude: 126.9775),
              CoordinatesRequestModel(latitude: 37.5670, longitude: 126.9785),
              CoordinatesRequestModel(latitude: 37.5660, longitude: 126.9780),
            ],
          ),
        ),
      );
    });

    test(
      'createdAt_is_normalized_to_local_datetime_when_response_has_kst_offset',
      () async {
        // v2.7.0부터 백엔드가 "2026-01-16T01:25:37+09:00" 형식으로 보낸다.
        // DateTime.parse는 UTC로 저장하므로 Entity 경계에서 toLocal()로 정규화 필요.
        final raw = CreateSessionResponse.fromJson({
          'gameId': 1,
          'inviteCode': 'ABC123',
          'status': 'WAITING',
          'roundDurationMinutes': 30,
          'locationRevealIntervalMinutes': 5,
          'policeWaitMinutes': 3,
          'maxParticipants': 10,
          'createdAt': '2026-01-16T01:25:37+09:00',
        });
        final fake = _FakeSessionRemoteDataSource()..responseToReturn = raw;
        final repo = SessionRepositoryImpl(fake);

        final result = await _callCreateGame(repo);

        expect(result.createdAt.isUtc, false);
        // KST 01:25:37 = UTC 2026-01-15 16:25:37
        expect(
          result.createdAt.isAtSameMomentAs(
            DateTime.utc(2026, 1, 15, 16, 25, 37),
          ),
          true,
        );
      },
    );

    test(
      'non_temporal_fields_are_mapped_to_entity_when_response_parsed',
      () async {
        final raw = CreateSessionResponse.fromJson({
          'gameId': 42,
          'inviteCode': 'XYZ789',
          'status': 'WAITING',
          'roundDurationMinutes': 30,
          'locationRevealIntervalMinutes': 7,
          'policeWaitMinutes': 3,
          'maxParticipants': 20,
          'createdAt': '2026-01-16T01:25:37+09:00',
        });
        final fake = _FakeSessionRemoteDataSource()..responseToReturn = raw;
        final repo = SessionRepositoryImpl(fake);

        final result = await _callCreateGame(repo);

        expect(result.gameId, 42);
        expect(result.inviteCode, 'XYZ789');
        expect(result.status, 'WAITING');
        expect(result.maxParticipants, 20);
        expect(result.locationRevealIntervalMinutes, 7);
      },
    );

    test(
      'dio_exception_is_converted_to_app_exception_when_remote_throws',
      () async {
        final fake = _FakeSessionRemoteDataSource()
          ..errorToThrow = _dioError(409);
        final repo = SessionRepositoryImpl(fake);

        expect(() => _callCreateGame(repo), throwsA(isA<AppException>()));
      },
    );

    test(
      'non_dio_exception_is_wrapped_in_server_exception_when_remote_throws',
      () async {
        final fake = _FakeSessionRemoteDataSource()
          ..errorToThrow = const FormatException('bad json');
        final repo = SessionRepositoryImpl(fake);

        expect(() => _callCreateGame(repo), throwsA(isA<ServerException>()));
      },
    );
  });
}
