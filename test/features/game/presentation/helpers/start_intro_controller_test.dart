import 'package:cops_and_robbers/features/game/domain/start_flow.dart';
import 'package:cops_and_robbers/features/game/presentation/helpers/start_intro_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'police_sees_countdown_over_wait_screen_then_hint_when_five_seconds_before_dispatch',
    () {
      final c = StartIntroController(
        steps: const [StartIntroStep.roleBanner, StartIntroStep.policeWait],
        hasPoliceWait: true,
      );
      expect(c.showRoleBanner, isTrue);
      expect(c.showPoliceWait, isFalse); // 역할 배너가 끝난 뒤에
      c.roleBannerDone();
      expect(c.showPoliceWait, isTrue);
      c.dispatchCountdownStarted(); // 출동 5초 전
      expect(c.showDispatchCountdown, isTrue);
      expect(c.showPoliceWait, isTrue); // 대기 화면은 카운팅 아래 그대로
      c.policeReleased(inForeground: true);
      expect(c.showPoliceWait, isFalse);
      expect(c.showDispatchCountdown, isTrue); // "출동!"과 원형 열기가 남았다
      expect(c.hintDue, isFalse);
      c.dispatchCountdownDone();
      expect(c.showDispatchCountdown, isFalse);
      expect(c.hintDue, isTrue);
    },
  );

  test(
    'robber_sees_explainer_after_role_banner_and_hint_when_robber_taps_it_away',
    () {
      final c = StartIntroController(
        steps: const [
          StartIntroStep.roleBanner,
          StartIntroStep.robberExplainer,
        ],
        hasPoliceWait: true,
      );
      c.roleBannerDone();
      expect(c.showRobberExplainer, isTrue);
      c.robberExplainerClosed();
      expect(c.showRobberExplainer, isFalse);
      expect(c.hintDue, isTrue);
      c.dispatchCountdownStarted(); // 지도를 보던 중 출동 5초 전
      expect(c.showDispatchCountdown, isTrue);
    },
  );

  // 시안처럼 띠가 빠지는 도중(3.7초)에 대기 장면이 아래에서 먼저 뜬다
  test(
    'wait_screen_appears_under_leaving_role_banner_when_banner_starts_to_leave',
    () {
      final c = StartIntroController(
        steps: const [StartIntroStep.roleBanner, StartIntroStep.policeWait],
        hasPoliceWait: true,
      );
      c.roleBannerLeaving();
      expect(c.showRoleBanner, isTrue); // 띠는 아직 빠지는 중
      expect(c.showPoliceWait, isTrue);
      c.roleBannerDone();
      expect(c.showRoleBanner, isFalse);
      expect(c.showPoliceWait, isTrue);
    },
  );

  // 도둑이 설명 화면이 뜨자마자(띠가 다 빠지기 전) 탭해 닫아도 다시 열리지 않는다
  test(
    'robber_explainer_stays_closed_when_robber_taps_it_before_role_banner_finishes',
    () {
      final c = StartIntroController(
        steps: const [
          StartIntroStep.roleBanner,
          StartIntroStep.robberExplainer,
        ],
        hasPoliceWait: true,
      );
      c.roleBannerLeaving();
      c.robberExplainerClosed();
      c.roleBannerDone();
      expect(c.showRobberExplainer, isFalse);
    },
  );

  test('countdown_never_shows_when_app_returns_after_dispatch_time', () {
    final c = StartIntroController(
      steps: const [StartIntroStep.policeWait],
      hasPoliceWait: true,
    );
    expect(c.showPoliceWait, isTrue); // 다시 켠 앱: 역할 배너 없이 바로
    c.policeReleased(inForeground: false);
    expect(c.showPoliceWait, isFalse);
    expect(c.showDispatchCountdown, isFalse);
    c.dispatchCountdownStarted(); // 지난 출동은 다시 세지 않는다
    expect(c.showDispatchCountdown, isFalse);
  });

  // 카운팅을 보던 중 화면을 끄고 출동 시각을 넘겨 돌아왔다
  test('countdown_closes_when_app_returns_late_from_background', () {
    final c = StartIntroController(
      steps: const [StartIntroStep.policeWait],
      hasPoliceWait: true,
    );
    c.dispatchCountdownStarted();
    c.policeReleased(inForeground: false);
    expect(c.showDispatchCountdown, isFalse);
  });

  test(
    'countdown_keeps_running_when_server_dispatch_arrives_before_device_clock',
    () {
      final c = StartIntroController(
        steps: const [StartIntroStep.policeWait],
        hasPoliceWait: true,
      );
      var notifications = 0;
      c.addListener(() => notifications++);
      c.dispatchCountdownStarted();
      c.policeReleased(inForeground: true); // 서버 POLICE_MOVE_START가 먼저 옴
      expect(c.showDispatchCountdown, isTrue);
      c.policeReleased(inForeground: true); // 기기 시계 타이머가 뒤늦게 옴
      c.dispatchCountdownDone();
      expect(c.showDispatchCountdown, isFalse);
      expect(notifications, 3);
    },
  );

  test('countdown_starts_once_when_five_second_mark_is_hit_twice', () {
    final c = StartIntroController(
      steps: const [StartIntroStep.policeWait],
      hasPoliceWait: true,
    );
    var notifications = 0;
    c.addListener(() => notifications++);
    c.dispatchCountdownStarted(); // 타이머
    c.dispatchCountdownStarted(); // 앱이 다시 보이면서 한 번 더
    expect(notifications, 1);
  });

  test('countdown_does_not_start_when_room_has_no_police_wait', () {
    final c = StartIntroController(
      steps: const [StartIntroStep.roleBanner],
      hasPoliceWait: false,
    );
    c.roleBannerDone();
    expect(c.hintDue, isTrue);
    c.dispatchCountdownStarted();
    expect(c.showDispatchCountdown, isFalse);
  });

  test('countdown_closes_when_game_ends_during_countdown', () {
    final c = StartIntroController(
      steps: const [StartIntroStep.roleBanner, StartIntroStep.policeWait],
      hasPoliceWait: true,
    );
    c.roleBannerDone();
    c.dispatchCountdownStarted();
    c.gameOver();
    c.policeReleased(inForeground: true);
    expect([
      c.showRoleBanner,
      c.showPoliceWait,
      c.showRobberExplainer,
      c.showDispatchCountdown,
    ], everyElement(isFalse));
  });

  // 카운팅 도중 화면을 끄고 늦게 돌아와 카운팅이 잘려도 ⓘ 안내는 이번 게임에 뜬다
  test('hint_becomes_due_when_countdown_is_cut_by_late_return', () {
    final c = StartIntroController(
      steps: const [StartIntroStep.policeWait],
      hasPoliceWait: true,
    );
    c.dispatchCountdownStarted();
    c.policeReleased(inForeground: false);
    expect(c.hintDue, isTrue);
  });

  // 시작 직후 앱을 내렸다가 출동 직전에 돌아오면 멈췄던 역할 배너가 카운팅을 가린다
  test('role_banner_closes_when_countdown_starts_while_banner_is_shown', () {
    final c = StartIntroController(
      steps: const [StartIntroStep.roleBanner, StartIntroStep.policeWait],
      hasPoliceWait: true,
    );
    c.dispatchCountdownStarted();
    expect(c.showRoleBanner, isFalse);
    expect(c.showDispatchCountdown, isTrue);
  });
}
