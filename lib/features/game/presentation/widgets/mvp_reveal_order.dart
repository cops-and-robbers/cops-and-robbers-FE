import '../../../../core/constants/game_team.dart';

/// 공개할 MVP 한 명 — 팀(`GameTeam.police`/`robber`)과 닉네임.
typedef MvpReveal = ({String team, String nickname});

/// 팀 MVP 공개 순서 — 진 팀 MVP 먼저, 이긴 팀 MVP 마지막 (DEC-0093 ⑤).
/// 후보가 없던 팀(null)은 빠진다. 둘 다 없으면 빈 목록이다.
List<MvpReveal> mvpRevealOrder({
  required String winnerTeam,
  String? policeMvpNickname,
  String? robberMvpNickname,
}) {
  final police = policeMvpNickname == null
      ? null
      : (team: GameTeam.police, nickname: policeMvpNickname);
  final robber = robberMvpNickname == null
      ? null
      : (team: GameTeam.robber, nickname: robberMvpNickname);
  final ordered = GameTeam.isPolice(winnerTeam)
      ? [robber, police]
      : [police, robber];
  return ordered.whereType<MvpReveal>().toList();
}
