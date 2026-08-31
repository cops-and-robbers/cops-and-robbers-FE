import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/session/presentation/providers/game_participant_provider.dart';
import '../constants/game_team.dart';

part 'role_theme_provider.g.dart';

/// 역할 기반 다크/라이트 모드
///
/// - `true` = 다크 모드 (도둑으로 게임에 참가 중)
/// - `false` = 라이트 모드 (경찰이거나, 게임에 참가 중이 아님 — 기본값)
///
/// **참가 정보에서 파생한다.** 별도 플래그로 두고 대기방에서 손으로 맞추던 때는,
/// 퇴장 시 참가 정보만 `clear()`되고 플래그가 `true`로 남아 다음 게임 생성 화면이
/// 다크로 뜨는 버그가 있었다(#520). 플래그의 쓰기는 대기방 4곳뿐인데 참가 정보를
/// 비우는 곳은 9곳이라, 미러가 원본의 소멸을 따라가지 못했다.
///
/// 이제 팀이 바뀌거나 게임을 떠나면 여기가 자동으로 따라간다 — 되돌리는 코드를
/// 퇴장 경로마다 심을 필요가 없다.
///
/// ```dart
/// final isDark = ref.watch(roleThemeProvider);
/// ```
@Riverpod(keepAlive: true)
bool roleTheme(Ref ref) {
  final info = ref.watch(gameParticipantNotifierProvider);
  return GameTeam.isRobber(info?.team);
}
