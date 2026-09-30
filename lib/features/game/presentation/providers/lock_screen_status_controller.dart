import 'dart:async';

import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/participant_status.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/services/background/background_service_provider.dart';
import '../../../../core/services/background/lock_screen_status.dart';
import '../../../../core/utils/iso_timestamp_parser.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../session/presentation/providers/game_participant_provider.dart';
import '../../domain/robber_count.dart';
import 'game_event_provider.dart';
import 'lock_screen_status_builder.dart';

part 'lock_screen_status_controller.g.dart';

/// 게임 상태를 잠금 화면 현황으로 바꿔 BackgroundService에 보낸다.
///
/// 게임 화면이 watch해 게임 화면 수명 동안만 산다. 값이 바뀔 때만 보내고,
/// 다음 위치 공개 시각에만 깨어난다(매초 타이머 없음 — 초는 OS가 그린다).
///
/// 네트워크를 쓰지 않는다. 도둑 명단은 게임 화면의 참가자 동기화(소켓 연결·재연결 때)가
/// 상태에 남긴 것을 쓰고, 그 위에 체포·탈옥·퇴장 집합을 얹어 센다.
/// 따로 조회하면 백그라운드에서 토큰 만료 시 강제 로그아웃될 수 있고(ISS-0096),
/// 같은 조회 provider를 동기화와 함께 새로고침해 서로 간섭한다.
@riverpod
class LockScreenStatusController extends _$LockScreenStatusController {
  Timer? _revealTimer;
  LockScreenStatus? _lastSent;
  bool _disposed = false;

  /// 게임 화면이 구독 중인지. 구독이 끊기면 autoDispose 정리 전이라도 바로 멈춘다 —
  /// 화면이 없는데 타이머가 남아 있으면 안 된다(위젯 테스트의 타이머 불변식도 이것을 검사한다).
  bool _listening = true;

  @override
  void build() {
    ref.onDispose(() {
      _disposed = true;
      _revealTimer?.cancel();
    });
    ref.onCancel(() {
      _listening = false;
      _revealTimer?.cancel();
    });
    ref.onResume(() {
      _listening = true;
      _push();
    });

    ref.listen(
      gameEventNotifierProvider.select(
        (s) => (
          s.robberParticipantIds,
          s.arrestedParticipantIds,
          s.escapedParticipantIds,
          s.leftParticipantIds,
          s.gameStartTime,
          s.isGameOver,
        ),
      ),
      (_, _) => _push(),
    );
    ref.listen(
      gameParticipantNotifierProvider,
      (_, _) => _push(),
      fireImmediately: true,
    );
  }

  void _push() {
    if (_disposed || !_listening) return;
    final game = ref.read(gameEventNotifierProvider);
    if (game.isGameOver) {
      // 종료 뒤 보내면 다음 게임 시작 때 이전 게임 값이 재생된다. 표시 제거는 기존 stop 경로가 한다.
      _revealTimer?.cancel();
      return;
    }
    final info = ref.read(gameParticipantNotifierProvider);
    // 게임 화면 타이머(_buildAppBar)와 같은 우선순위: STOMP START → 대기실 응답
    final start =
        game.gameStartTime ?? IsoTimestampParser.parse(info?.gameStartTime);
    final round = info?.roundTimeMinutes;
    if (info == null || start == null || round == null) return;

    // 동기화 뒤 나간 도둑은 명단에서 뺀다(다음 동기화 결과에는 원래 없다).
    final robbers = game.robberParticipantIds
        ?.difference(game.leftParticipantIds);
    final now = clock.now();
    final status = buildLockScreenStatus(
      start: start,
      roundMinutes: round,
      policeWaitMinutes: info.policeWaitMinutes,
      intervalMinutes: info.locationRevealIntervalMinutes,
      now: now,
      // 수감 여부는 집합들이 담는다(동기화가 서버 JAILED를 수감 집합에 합친다).
      aliveRobbers: robbers == null
          ? null
          : countAliveRobbers(
              robberStatuses: {
                for (final id in robbers) id: ParticipantStatus.alive,
              },
              arrestedIds: game.arrestedParticipantIds,
              escapedIds: game.escapedParticipantIds,
            ),
      totalRobbers: robbers?.length,
      isEventGame: info.isEventGame,
      isRobberTeam: GameTeam.isRobber(info.team),
      l10n: lookupAppLocalizations(ref.read(appLocaleProvider).locale),
    );
    _scheduleRevealTimer(status.nextRevealAt, now);

    if (status == _lastSent) return;
    _lastSent = status;
    ref.read(backgroundServiceProvider).update(status);
  }

  void _scheduleRevealTimer(DateTime? nextReveal, DateTime now) {
    _revealTimer?.cancel();
    if (nextReveal == null) return;
    // ponytail: 공개 시각 "직후"(1초 뒤)에 다시 계산한다. 정확히 그 시각에는 nextRevealAt이
    // 같은 시각을 돌려주므로(게임 화면 00:00과 일치) 1초 뒤에야 다음 공개로 넘어간다.
    _revealTimer = Timer(
      nextReveal.difference(now) + const Duration(seconds: 1),
      _push,
    );
  }
}
