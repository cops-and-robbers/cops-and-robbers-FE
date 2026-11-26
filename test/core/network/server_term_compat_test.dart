import 'dart:convert';
import 'dart:typed_data';

import 'package:cops_and_robbers/core/network/api_error_response.dart';
import 'package:cops_and_robbers/core/network/server_term_compat.dart';
import 'package:cops_and_robbers/features/game/data/models/arrest_request_model.dart';
import 'package:cops_and_robbers/features/game/data/models/game_event_model.dart';
import 'package:cops_and_robbers/features/game/data/models/game_result_response_model.dart';
import 'package:cops_and_robbers/features/session/data/models/game_create_request_model.dart';
import 'package:cops_and_robbers/features/session/data/models/in_game_participants_response.dart';
import 'package:cops_and_robbers/features/session/data/models/team_change_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 서버 팀 용어 변경(BE #254) 대응. 서버는 세 가지 모습으로 응답한다.
/// - 옛 서버(운영 v3.13.0): 옛 값, 옛 키만
/// - 1단계 서버(dev v4.5.0): 옛 값 + 옛 키와 새 키를 함께
/// - 4단계 서버(강제 업데이트 뒤): 새 값, 새 키만
void main() {
  Map<String, dynamic> compat(Map<String, dynamic> json) =>
      toAppTerms(json)! as Map<String, dynamic>;

  group('게임 결과 응답', () {
    test('parses_winner_and_mvp_when_stage4_server_sends_only_new_names', () {
      // 술래잡기 한 판이 끝나 술래 팀이 이겼고, 서버가 옛 이름을 지운 뒤다.
      final model = GameResultResponseModel.fromJson(
        compat({
          'winnerTeam': 'CHASER',
          'durationSeconds': 1800,
          'totalArrestCount': 4,
          'remainingRunnerCount': 1,
          'chaserMvp': {'nickname': '번개경찰'},
          'runnerMvp': {'nickname': '그림자'},
        }),
      );

      expect(model.winnerTeam, 'POLICE');
      expect(model.remainingRobberCount, 1);
      expect(model.policeMvp?.nickname, '번개경찰');
      expect(model.robberMvp?.nickname, '그림자');
    });

    test('reads_new_key_when_stage1_server_sends_both_keys', () {
      // 실제 1단계 서버는 두 키에 같은 값을 싣는다. 어느 키를 읽는지 가리려고
      // 일부러 다른 값을 넣었다.
      final model = GameResultResponseModel.fromJson(
        compat({
          'winnerTeam': 'ROBBER',
          'durationSeconds': 600,
          'totalArrestCount': 0,
          'remainingRobberCount': 9,
          'remainingRunnerCount': 3,
        }),
      );

      expect(model.remainingRobberCount, 3);
    });

    test('parses_unchanged_when_old_server_sends_only_old_names', () {
      final model = GameResultResponseModel.fromJson(
        compat({
          'winnerTeam': 'ROBBER',
          'durationSeconds': 600,
          'totalArrestCount': 2,
          'remainingRobberCount': 3,
          'robberMvp': {'nickname': '그림자'},
        }),
      );

      expect(model.winnerTeam, 'ROBBER');
      expect(model.remainingRobberCount, 3);
      expect(model.robberMvp?.nickname, '그림자');
    });
  });

  group('참가자 목록 응답', () {
    test('parses_both_teams_when_stage4_server_sends_chasers_and_runners', () {
      final model = InGameParticipantsResponse.fromJson(
        compat({
          'chasers': [
            {'participantId': 1, 'nickname': '경찰1', 'status': 'CHASER_WAITING'},
          ],
          'runners': [
            {'participantId': 2, 'nickname': '도둑1', 'status': 'ALIVE'},
          ],
        }),
      );

      expect(model.police.single.status, 'POLICE_WAITING');
      expect(model.robbers.single.nickname, '도둑1');
    });

    test('keeps_nickname_when_player_is_named_like_a_team_value', () {
      // 닉네임을 "RUNNER"로 지은 사람이 도둑 팀에 있다. 닉네임은 팀 값이 아니다.
      final model = InGameParticipantsResponse.fromJson(
        compat({
          'chasers': <Map<String, dynamic>>[],
          'runners': [
            {'participantId': 7, 'nickname': 'RUNNER', 'status': 'ALIVE'},
          ],
        }),
      );

      expect(model.robbers.single.nickname, 'RUNNER');
    });
  });

  group('시스템 이벤트', () {
    test('parses_arrest_when_stage4_server_sends_chaser_and_runner', () {
      final event = GameEventModel.fromJson(
        compat({
          'eventId': 'e1',
          'type': 'ARREST',
          'timestamp': '2026-11-26T12:00:00',
          'data': {
            'chaser': {'participantId': 1, 'nickname': '경찰1', 'team': 'CHASER'},
            'runner': {'participantId': 2, 'nickname': '도둑1', 'team': 'RUNNER'},
            'remainingRunners': 3,
          },
        }),
      );

      expect(event.type, GameEventType.arrest);
      expect((event.data['police'] as Map)['nickname'], '경찰1');
      expect((event.data['robber'] as Map)['participantId'], 2);
      expect((event.data['robber'] as Map)['team'], 'ROBBER');
      expect(event.data['remainingThieves'], 3);
    });

    test('parses_move_start_when_stage4_server_sends_new_type', () {
      final event = GameEventModel.fromJson(
        compat({'type': 'CHASER_MOVE_START', 'data': <String, dynamic>{}}),
      );

      expect(event.type, GameEventType.policeMoveStart);
    });

    test('parses_location_reveal_when_stage4_server_sends_new_type', () {
      final event = GameEventModel.fromJson(
        compat({'type': 'RUNNER_LOCATION_REVEAL', 'data': <String, dynamic>{}}),
      );

      expect(event.type, GameEventType.robberLocationReveal);
    });

    test('parses_escape_when_stage4_server_sends_escaped_runner', () {
      final event = GameEventModel.fromJson(
        compat({
          'type': 'ESCAPE',
          'data': {
            'escapedRunner': {'participantId': 2, 'nickname': '도둑1'},
            'remainingRunners': 4,
          },
        }),
      );

      expect((event.data['escapedThief'] as Map)['participantId'], 2);
      expect(event.data['remainingThieves'], 4);
    });

    test('parses_forfeit_reason_when_stage4_server_ends_game_by_forfeit', () {
      // 술래 팀이 모두 나가 몰수패로 끝났다.
      final event = GameEventModel.fromJson(
        compat({
          'type': 'GAME_OVER',
          'data': {'winnerTeam': 'RUNNER', 'reason': 'CHASER_FORFEITED'},
        }),
      );

      expect(event.data['winnerTeam'], 'ROBBER');
      expect(event.data['reason'], 'POLICE_FORFEITED');
    });
  });

  group('게임 상태·체포 응답', () {
    test('reads_runner_locations_when_stage4_server_sends_game_state', () {
      // 위치 공개 뒤 앱을 다시 열어 게임 상태를 복구한다.
      final json = compat({
        'runnerLocations': [
          {
            'participantId': 2,
            'nickname': '도둑1',
            'latitude': 37.5,
            'longitude': 127.0,
          },
        ],
      });

      expect((json['robberLocations'] as List).single['nickname'], '도둑1');
    });

    test('reads_arrested_nickname_when_stage4_server_answers_arrest', () {
      final json = compat({'runnerNickname': '도둑1', 'remainingRunners': 2});

      expect(json['robberNickname'], '도둑1');
      expect(json['remainingThieves'], 2);
    });

    test('reads_forfeit_reason_when_all_runners_leave_on_stage4_server', () {
      expect(
        compat({'reason': 'RUNNER_FORFEITED'})['reason'],
        'ROBBER_FORFEITED',
      );
    });
  });

  group('JSON이 아닌 응답', () {
    test('passes_bytes_through_when_response_is_binary', () {
      // 이미지 같은 바이트 응답은 JSON 배열이 아니다.
      final bytes = Uint8List.fromList([1, 2, 3]);

      expect(toAppTerms(bytes), same(bytes));
    });
  });

  group('채팅', () {
    test('keeps_message_text_when_user_types_a_team_value', () {
      // 누가 채팅에 "RUNNER"라고 쳤다. 본문은 건드리면 안 된다.
      final json = compat({
        'content': 'RUNNER',
        'sender': {'participantId': 5, 'nickname': '창희도둑', 'team': 'RUNNER'},
      });

      expect(json['content'], 'RUNNER');
      expect((json['sender'] as Map)['team'], 'ROBBER');
    });
  });

  group('에러 코드', () {
    test('maps_to_known_code_when_stage4_server_rejects_arrest_by_runner', () {
      // 도둑이 체포를 시도해 서버가 거절했다. 앱 문구 매핑은 옛 코드로 걸려 있다.
      final error = ApiErrorResponse.tryParse(
        compat({
          'errorCode': 'ONLY_CHASER_CAN_ARREST',
          'title': '경찰만이 체포 가능',
          'status': 400,
          'detail': '경찰 팀만 도둑을 체포할 수 있습니다.',
          'instance': '/api/games/1/arrest',
        }),
      );

      expect(error!.errorCode, 'ONLY_POLICE_CAN_ARREST');
    });

    test('maps_every_renamed_code', () {
      const renamed = {
        'INVALID_CHASER_WAIT_TIME': 'INVALID_POLICE_WAIT_TIME',
        'NOT_RUNNER_TEAM': 'NOT_ROBBER_TEAM',
        'ONLY_CHASER_CAN_ARREST': 'ONLY_POLICE_CAN_ARREST',
        'ONLY_RUNNER_CAN_BE_ARRESTED': 'ONLY_ROBBER_CAN_BE_ARRESTED',
        'ONLY_RUNNER_CAN_ESCAPE': 'ONLY_ROBBER_CAN_ESCAPE',
        'CHASER_WAITING_TIME': 'POLICE_WAITING_TIME',
        'ONLY_CHASER_CAN_USE_RADIO': 'ONLY_POLICE_CAN_USE_RADIO',
        'RADIO_CHASER_WAITING_TIME': 'RADIO_POLICE_WAITING_TIME',
      };

      for (final entry in renamed.entries) {
        expect(compat({'errorCode': entry.key})['errorCode'], entry.value);
      }
    });

    test('keeps_code_when_it_was_not_renamed', () {
      expect(
        compat({'errorCode': 'RADIO_SERVER_BUSY'})['errorCode'],
        'RADIO_SERVER_BUSY',
      );
    });
  });

  group('FCM type', () {
    test('maps_new_event_type_to_the_one_the_app_knows', () {
      expect(toAppTerm('RUNNER_LOCATION_REVEAL'), 'ROBBER_LOCATION_REVEAL');
      expect(toAppTerm('CHASER_MOVE_START'), 'POLICE_MOVE_START');
      expect(toAppTerm('ARREST'), 'ARREST');
    });
  });

  group('HTTP 응답 경계', () {
    Dio dioAnswering(int status, Map<String, dynamic> body) => Dio()
      ..httpClientAdapter = _JsonAdapter(status, body)
      ..interceptors.add(ServerTermCompatInterceptor());

    test(
      'response_reaches_caller_in_app_terms_when_server_sends_new_names',
      () async {
        final response = await dioAnswering(200, {
          'gameId': 1,
          'chaserWaitMinutes': 3,
        }).get<Map<String, dynamic>>('https://example.test/api/games/1');

        expect(response.data!['policeWaitMinutes'], 3);
      },
    );

    test(
      'error_reaches_caller_with_known_code_when_server_sends_new_code',
      () async {
        // 출동 대기 중에 무전 토큰을 요청해 거절됐다.
        final call =
            dioAnswering(400, {
              'errorCode': 'RADIO_CHASER_WAITING_TIME',
              'title': '경찰 대기 시간',
              'status': 400,
              'detail': '경찰은 대기 시간 동안 무전을 사용할 수 없습니다.',
              'instance': '/api/games/1/radio/token',
            }).get<Map<String, dynamic>>(
              'https://example.test/api/games/1/radio/token',
            );

        await expectLater(
          call,
          throwsA(
            isA<DioException>().having(
              (e) => (e.response!.data as Map)['errorCode'],
              'errorCode',
              'RADIO_POLICE_WAITING_TIME',
            ),
          ),
        );
      },
    );
  });

  group('보내는 이름', () {
    test('settings_request_sends_chaser_wait_minutes', () {
      // 방장이 출동 대기 3분으로 방을 만든다.
      final json = const GameSettingsRequestModel(
        roundDurationMinutes: 30,
        locationRevealIntervalMinutes: 3,
        policeWaitMinutes: 3,
        maxParticipants: 10,
      ).toJson();

      expect(json['chaserWaitMinutes'], 3);
      expect(json.containsKey('policeWaitMinutes'), isFalse);
    });

    test('arrest_request_sends_runner_participant_id', () {
      final json = const ArrestRequestModel(robberParticipantId: 12).toJson();

      expect(json, {'runnerParticipantId': 12});
    });

    test('team_change_request_sends_new_team_value', () {
      // 대기방에서 경찰 팀으로 옮긴다.
      expect(const TeamChangeRequest(targetTeam: 'POLICE').toJson(), {
        'targetTeam': 'CHASER',
      });
      expect(const TeamChangeRequest(targetTeam: 'ROBBER').toJson(), {
        'targetTeam': 'RUNNER',
      });
    });

    test('team_channel_uses_new_path_segment', () {
      // 앱 안의 팀 키는 에셋 경로와 같이 쓰는 police / robber 다.
      expect(teamChannelSegment('police'), 'chaser');
      expect(teamChannelSegment('robber'), 'runner');
    });
  });
}

/// 정해 둔 상태 코드와 JSON 본문으로 답하는 HTTP 어댑터 (시스템 경계).
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this._status, this._body);

  final int _status;
  final Map<String, dynamic> _body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(_body),
    _status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
