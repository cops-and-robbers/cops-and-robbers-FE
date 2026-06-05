import 'package:cops_and_robbers/features/game/data/datasources/game_event_stomp_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

/// subscribeEvents가 (gameId, team)으로 호출되는지 관찰하는 fake.
class _FakeDatasource extends GameEventStompDatasource {
  (int, String)? lastSubscribe;

  @override
  void subscribeEvents(int gameId, {required String team}) {
    lastSubscribe = (gameId, team);
  }

  @override
  void connect(String wsUrl, String accessToken) {
    // no-op (실제 WS 연결 차단)
  }
}

void main() {
  test('subscribeEvents_receives_team_argument', () {
    final fake = _FakeDatasource();
    addTearDown(fake.dispose);
    // 시그니처가 {required String team}이므로 team 누락은 컴파일 에러.
    fake.subscribeEvents(1, team: 'police');
    expect(fake.lastSubscribe, (1, 'police'));
  });
}
