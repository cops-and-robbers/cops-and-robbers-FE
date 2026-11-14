import 'dart:convert';

import 'package:cops_and_robbers/features/radio/data/models/radio_token_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// 서버가 서명한 것처럼 보이는 토큰 — 앱은 서명을 검증하지 않고 payload만 읽는다
String _jwt(Map<String, Object> payload) {
  String part(Object json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part(payload)}.signature';
}

void main() {
  test('parses_issue_response_when_police_requests_radio_token', () {
    // BE PR #239 응답 예시 그대로
    final model = RadioTokenModel.fromJson({
      'url': 'wss://cops-and-robbers-dev-rahmyete.livekit.cloud',
      'room': 'game-1-police',
      'identity': '101',
      'token': _jwt({'iat': 1000, 'exp': 1120}),
      'expiresAt': '2026-11-09T21:30:00+09:00',
    });

    expect(model.identity, '101');
    expect(model.room, 'game-1-police');
  });

  test('token_lifetime_is_two_minutes_when_server_signs_exp_120s_after_iat', () {
    final model = RadioTokenModel(
      url: 'wss://x',
      room: 'game-1-police',
      identity: '101',
      token: _jwt({'iat': 1762690080, 'exp': 1762690200}),
      expiresAt: '2026-11-09T21:30:00+09:00',
    );

    expect(model.lifetime, const Duration(seconds: 120));
  });
}
