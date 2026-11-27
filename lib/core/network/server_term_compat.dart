import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 서버 팀 용어 변경(BE #254: POLICE/ROBBER → CHASER/RUNNER) 대응.
///
/// 서버는 강제 업데이트 전까지 옛 값과 옛 키를 함께 내려주고, 그 뒤에는 새 이름만
/// 내려준다. 앱 안은 옛 이름(`GameTeam.police` 등)을 그대로 쓰므로, 응답이 들어오는
/// 경계(HTTP·STOMP·FCM)에서 한 번만 앱 이름으로 맞춘다. 모델·프로바이더·화면은
/// 서버가 어느 단계인지 몰라도 된다.

/// 서버 새 값 → 앱이 쓰는 값
const _appValues = <String, String>{
  // 팀·참가자 상태·종료 사유
  'CHASER': 'POLICE',
  'RUNNER': 'ROBBER',
  'CHASER_WAITING': 'POLICE_WAITING',
  'CHASER_FORFEITED': 'POLICE_FORFEITED',
  'RUNNER_FORFEITED': 'ROBBER_FORFEITED',
  // 시스템 이벤트 type (소켓·FCM)
  'CHASER_MOVE_START': 'POLICE_MOVE_START',
  'RUNNER_LOCATION_REVEAL': 'ROBBER_LOCATION_REVEAL',
  // 에러 코드
  'INVALID_CHASER_WAIT_TIME': 'INVALID_POLICE_WAIT_TIME',
  'NOT_RUNNER_TEAM': 'NOT_ROBBER_TEAM',
  'ONLY_CHASER_CAN_ARREST': 'ONLY_POLICE_CAN_ARREST',
  'ONLY_RUNNER_CAN_BE_ARRESTED': 'ONLY_ROBBER_CAN_BE_ARRESTED',
  'ONLY_RUNNER_CAN_ESCAPE': 'ONLY_ROBBER_CAN_ESCAPE',
  'CHASER_WAITING_TIME': 'POLICE_WAITING_TIME',
  'ONLY_CHASER_CAN_USE_RADIO': 'ONLY_POLICE_CAN_USE_RADIO',
  'RADIO_CHASER_WAITING_TIME': 'RADIO_POLICE_WAITING_TIME',
};

/// 값을 바꿔 읽는 키. 닉네임·채팅 본문처럼 사용자가 쓴 글은 건드리지 않으려고
/// 서버 enum이 실리는 키로만 좁힌다.
const _valueKeys = <String>{
  'team',
  'status',
  'winnerTeam',
  'reason',
  'type',
  'errorCode',
};

/// 서버 새 키 → 앱이 읽는 키
const _appKeys = <String, String>{
  'chaserWaitMinutes': 'policeWaitMinutes',
  'chaserMvp': 'policeMvp',
  'runnerMvp': 'robberMvp',
  'remainingRunnerCount': 'remainingRobberCount',
  'chasers': 'police',
  'runners': 'robbers',
  'runnerLocations': 'robberLocations',
  'runnerNickname': 'robberNickname',
  'remainingRunners': 'remainingThieves',
  'chaser': 'police',
  'runner': 'robber',
  'escapedRunner': 'escapedThief',
};

/// 서버 값 하나를 앱이 쓰는 값으로 바꾼다. 바뀐 적 없는 값은 그대로 돌려준다.
String toAppTerm(String value) => _appValues[value] ?? value;

/// 디코드한 서버 JSON을 앱이 쓰는 이름으로 맞춘 새 값을 돌려준다 (원본은 바꾸지 않는다).
///
/// 새 키가 있으면 그 값을 옛 키로도 읽히게 한다. 두 키가 함께 오면 새 키가 이긴다.
Object? toAppTerms(Object? json) {
  // 바이트 응답(Uint8List)도 List라서, JSON 배열만 고른다
  if (json is List && json is! TypedData) {
    return json.map(toAppTerms).toList();
  }
  if (json is! Map) return json;

  final result = <String, dynamic>{};
  for (final entry in json.entries) {
    final key = entry.key as String;
    final value = entry.value;
    result[key] = value is String && _valueKeys.contains(key)
        ? toAppTerm(value)
        : toAppTerms(value);
  }
  for (final entry in _appKeys.entries) {
    if (result.containsKey(entry.key)) result[entry.value] = result[entry.key];
  }
  return result;
}

/// 앱의 팀 키(`police`/`robber`)를 팀별 구독 경로 조각(`chaser`/`runner`)으로 바꾼다.
String teamChannelSegment(String team) => switch (team.toLowerCase()) {
  'police' => 'chaser',
  'robber' => 'runner',
  _ => team,
};

/// 앱의 팀 값(`POLICE`/`ROBBER`)을 서버에 보낼 값(`CHASER`/`RUNNER`)으로 바꾼다.
String toServerTeam(String team) => switch (team) {
  'POLICE' => 'CHASER',
  'ROBBER' => 'RUNNER',
  _ => team,
};

/// HTTP 응답과 에러 본문을 앱이 쓰는 이름으로 맞추는 인터셉터.
class ServerTermCompatInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    response.data = toAppTerms(response.data);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) response.data = toAppTerms(response.data);
    handler.next(err);
  }
}
