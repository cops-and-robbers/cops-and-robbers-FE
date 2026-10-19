import 'package:cops_and_robbers/features/game/domain/start_flow.dart';
import 'package:cops_and_robbers/features/game/presentation/helpers/start_intro_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'police_goes_from_role_banner_to_wait_screen_to_dispatch_banner_when_waiting_five_minutes',
    () {
      final c = StartIntroController(
        steps: const [StartIntroStep.roleBanner, StartIntroStep.policeWait],
        hasPoliceWait: true,
      );
      expect(c.showRoleBanner, isTrue);
      expect(c.showPoliceWait, isFalse); // 역할 배너가 끝난 뒤에
      c.roleBannerDone();
      expect(c.showPoliceWait, isTrue);
      c.policeReleased(inForeground: true);
      expect(c.showPoliceWait, isFalse);
      expect(c.showDispatchBanner, isTrue);
      expect(c.hintDue, isFalse);
      c.dispatchBannerDone();
      expect(c.showDispatchBanner, isFalse);
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
      c.policeReleased(inForeground: true);
      expect(c.showDispatchBanner, isTrue);
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

  test(
    'dispatch_banner_waits_for_role_banner_when_release_arrives_during_it',
    () {
      final c = StartIntroController(
        steps: const [StartIntroStep.roleBanner, StartIntroStep.policeWait],
        hasPoliceWait: true,
      );
      c.policeReleased(inForeground: true);
      expect(c.showRoleBanner, isTrue);
      expect(c.showDispatchBanner, isFalse);
      c.roleBannerDone();
      expect(c.showPoliceWait, isFalse); // 대기 화면을 건너뛴다
      expect(c.showDispatchBanner, isTrue);
    },
  );

  test(
    'wait_screen_closes_without_banner_when_release_passed_while_app_in_background',
    () {
      final c = StartIntroController(
        steps: const [StartIntroStep.policeWait],
        hasPoliceWait: true,
      );
      expect(c.showPoliceWait, isTrue); // 다시 켠 앱: 역할 배너 없이 바로
      c.policeReleased(inForeground: false);
      expect(c.showPoliceWait, isFalse);
      expect(c.showDispatchBanner, isFalse);
    },
  );

  test(
    'dispatch_banner_shows_once_when_timer_and_server_event_both_arrive',
    () {
      final c = StartIntroController(
        steps: const [StartIntroStep.policeWait],
        hasPoliceWait: true,
      );
      var notifications = 0;
      c.addListener(() => notifications++);
      c.policeReleased(inForeground: true);
      c.dispatchBannerDone();
      c.policeReleased(inForeground: true); // 서버 POLICE_MOVE_START가 뒤늦게 옴
      expect(c.showDispatchBanner, isFalse);
      expect(notifications, 2);
    },
  );

  test('hint_is_due_after_role_banner_when_room_has_no_police_wait', () {
    final c = StartIntroController(
      steps: const [StartIntroStep.roleBanner],
      hasPoliceWait: false,
    );
    c.roleBannerDone();
    expect(c.hintDue, isTrue);
    c.policeReleased(inForeground: true); // 대기 없는 방엔 출동 배너도 없다
    expect(c.showDispatchBanner, isFalse);
  });

  test('everything_closes_when_game_ends_during_police_wait', () {
    final c = StartIntroController(
      steps: const [StartIntroStep.roleBanner, StartIntroStep.policeWait],
      hasPoliceWait: true,
    );
    c.roleBannerDone();
    c.gameOver();
    c.policeReleased(inForeground: true);
    expect([
      c.showRoleBanner,
      c.showPoliceWait,
      c.showRobberExplainer,
      c.showDispatchBanner,
    ], everyElement(isFalse));
  });
}
