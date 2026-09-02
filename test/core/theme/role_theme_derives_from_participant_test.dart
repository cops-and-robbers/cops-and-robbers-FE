import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/constants/game_team.dart';
import 'package:cops_and_robbers/core/theme/role_theme_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';

/// 역할 테마는 "지금 내가 도둑으로 게임에 참가 중인가"여야 한다.
///
/// 버그(#520 제보): 도둑으로 대기방에 들어갔다 나온 뒤 커뮤니티 채팅방에서 게임을
/// 다시 만들면 생성 화면이 다크로 떴다. 테마가 참가 정보와 분리된 별도 플래그였고,
/// 퇴장 시 참가 정보만 clear()되고 플래그는 true로 남았기 때문.
void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  GameParticipantNotifier participant() =>
      container.read(gameParticipantNotifierProvider.notifier);

  test('참가 정보 없음 → 라이트', () {
    expect(container.read(roleThemeProvider), isFalse);
  });

  test('도둑으로 참가 → 다크, 경찰로 참가 → 라이트', () {
    participant().setGameInfo(gameId: 1, nickname: 'me', team: GameTeam.robber);
    expect(container.read(roleThemeProvider), isTrue);

    participant().setTeam(GameTeam.police);
    expect(container.read(roleThemeProvider), isFalse);
  });

  test('도둑으로 참가 후 퇴장(clear) → 라이트로 돌아온다', () {
    participant().setGameInfo(gameId: 1, nickname: 'me', team: GameTeam.robber);
    expect(container.read(roleThemeProvider), isTrue);

    // 대기방 퇴장·게임 종료·강퇴가 모두 호출하는 정리 지점
    participant().clear();

    // 여기서 true로 남으면 다음 게임 생성 화면이 다크로 뜬다
    expect(container.read(roleThemeProvider), isFalse);
  });
}
