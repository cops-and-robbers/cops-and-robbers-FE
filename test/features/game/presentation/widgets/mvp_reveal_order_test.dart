import 'package:cops_and_robbers/features/game/presentation/widgets/mvp_reveal_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mvpRevealOrder', () {
    // 진 팀 MVP를 먼저, 이긴 팀 MVP를 마지막에 보여준다 (DEC-0093 ⑤).
    test('orders_robber_mvp_first_when_police_won', () {
      expect(
        mvpRevealOrder(
          winnerTeam: 'POLICE',
          policeMvpNickname: '번개경찰',
          robberMvpNickname: '그림자',
        ),
        [(team: 'ROBBER', nickname: '그림자'), (team: 'POLICE', nickname: '번개경찰')],
      );
    });

    test('orders_police_mvp_first_when_robbers_won', () {
      expect(
        mvpRevealOrder(
          winnerTeam: 'ROBBER',
          policeMvpNickname: '번개경찰',
          robberMvpNickname: '그림자',
        ),
        [(team: 'POLICE', nickname: '번개경찰'), (team: 'ROBBER', nickname: '그림자')],
      );
    });

    // 도둑이 전원 중도 퇴장하면 서버는 도둑 MVP만 null로 준다.
    test('reveals_only_police_mvp_when_every_robber_left', () {
      expect(mvpRevealOrder(winnerTeam: 'POLICE', policeMvpNickname: '번개경찰'), [
        (team: 'POLICE', nickname: '번개경찰'),
      ]);
    });

    // BE #212 배포 전 서버는 두 필드를 주지 않는다 → 공개 화면을 건너뛴다.
    test('reveals_nobody_when_server_predates_mvp_fields', () {
      expect(mvpRevealOrder(winnerTeam: 'POLICE'), isEmpty);
    });
  });
}
