import 'dart:ui';

import 'tutorial_camera.dart';
import 'tutorial_stage.dart';

/// 방 입장 튜토리얼의 게임 모드.
enum TutorialMode { classic, tag }

/// 시간과 좌표는 #663 승인 시안의 값이다. 바꾸면 시안과 함께 봐야 한다.
enum TutorialScene {
  zoneIn,
  flat,
  chase,
  showQr,
  scan,
  jail,
  rescue,
  escape,
  out,
  shrink,
  radio,
  grid,
  community,
  pick,
  friends,
  guide,
  record,
}

List<TutorialScene> tutorialScenes(TutorialMode mode) => switch (mode) {
  TutorialMode.classic => const [
    TutorialScene.zoneIn,
    TutorialScene.flat,
    TutorialScene.chase,
    TutorialScene.showQr,
    TutorialScene.scan,
    TutorialScene.jail,
    TutorialScene.rescue,
    TutorialScene.escape,
    TutorialScene.shrink,
    TutorialScene.radio,
    TutorialScene.grid,
    TutorialScene.community,
  ],
  // 술래잡기도 QR 스캔으로 잡는다. 감옥만 없어 스캔 뒤 바로 탈락(out)으로 간다.
  TutorialMode.tag => const [
    TutorialScene.zoneIn,
    TutorialScene.flat,
    TutorialScene.chase,
    TutorialScene.showQr,
    TutorialScene.scan,
    TutorialScene.out,
    TutorialScene.shrink,
    TutorialScene.radio,
    TutorialScene.grid,
    TutorialScene.community,
  ],
};

/// 몰라도 게임은 되는 추가 기능(무전·좌표)이 시작되는 장면 번호 (#719)
///
/// 처음 볼 때는 앞의 필수 규칙을 건너뛸 수 없고, 여기부터 건너뛸 수 있다.
int tutorialFirstExtraIndex(TutorialMode mode) =>
    tutorialScenes(mode).indexOf(TutorialScene.radio);

/// 첫 실행 온보딩. 로그인 전이라 모드와 역할을 모르므로 앱이 뭔지만 보여 준다.
const List<TutorialScene> onboardingScenes = [
  TutorialScene.zoneIn,
  TutorialScene.pick,
  TutorialScene.friends,
  TutorialScene.guide,
  TutorialScene.record,
  TutorialScene.community,
];

void playScene(TutorialScene scene, TutorialStage s) {
  switch (scene) {
    case TutorialScene.zoneIn:
      s.timeline.to(s.cam, TutorialCamera.wide3dValues, 1400);
    case TutorialScene.flat:
      _flat(s);
    case TutorialScene.chase:
      _chase(s);
    case TutorialScene.showQr:
      _showQr(s);
    case TutorialScene.scan:
      _scan(s);
    case TutorialScene.jail:
      _jail(s);
    case TutorialScene.rescue:
      _rescue(s);
    case TutorialScene.escape:
      _escape(s);
    case TutorialScene.out:
      _out(s);
    case TutorialScene.shrink:
      _shrink(s, hasJail: !_isTagRun(s));
    case TutorialScene.radio:
      _radio(s);
    case TutorialScene.grid:
      _grid(s);
    case TutorialScene.community:
      _community(s);
    case TutorialScene.pick:
      _pick(s);
    case TutorialScene.friends:
      _friends(s);
    case TutorialScene.guide:
      _guide(s);
    case TutorialScene.record:
      _record(s);
  }
}

/// 감옥을 지난 판인지로 모드를 가른다. 술래잡기에는 감옥 장면이 없다.
bool _isTagRun(TutorialStage s) => s.view['jail'] == 0;

void _flat(TutorialStage s) {
  final t = s.timeline;
  t.to(s.q, {'hand': 0}, 200);
  t.to(s.view, {'dim': 1}, 500);
  t.to(s.jailed, {'op': 0}, 200);
  t.to(s.caught, {'op': 0}, 200);
  t.to(s.cam, TutorialCamera.flatValues, 1100);
  t.after(1100, () {
    t.to(s.cop, {'sc': .1, 'op': 0}, 450);
    t.to(s.rob, {'sc': .1, 'op': 0}, 450);
    s.dot['x'] = -60;
    s.dot['y'] = -30;
    s.paw['x'] = s.rob['x'];
    s.paw['y'] = s.rob['y'];
    s.dot['sc'] = 0;
    s.dot['op'] = 1;
    t.after(250, () => t.to(s.dot, {'sc': 1}, 250));
    t.after(500, s.startBlink);
  });
}

// 1인칭: 내가 쫓는 쪽이라 내 그림은 보이지 않고, 달아나는 쪽이 점점 가까워진다.
void _chase(TutorialStage s) {
  final t = s.timeline;
  s.stopBlink();
  t.to(s.paw, {'op': 0}, 200);
  t.to(s.dot, {'op': 0}, 200);
  s.cop['op'] = 0;
  s.rob['x'] = -24;
  s.rob['y'] = 55;
  s.rob['sc'] = .3;
  t.to(s.rob, {'op': 1, 'sc': .85}, 500);
  t.to(s.view, {'dim': 0}, 800);
  s.q['hy'] = 240;
  s.q['hs'] = 1;
  t.to(s.q, {'hand': 1}, 300);
  t.to(s.q, {'hy': 0}, 1100);
  // 회전 없이 내려가기만 한다. 카메라 자리까지 구역(반경 250) 안이다.
  t.to(s.cam, {
    'tilt': 80,
    'az': tutorialHeading,
    'persp': 200,
    'scale': 2,
    'cx': 12,
    'cy': -27,
    'oy': .62,
  }, 850);
  t.after(850, () {
    t.to(s.run, {'v': 1}, 300);
    t.to(s.cam, {'cx': -84, 'cy': 190, 'persp': 170}, 1300);
    t.to(s.rob, {'x': -77, 'y': 174, 'sc': 2.3}, 1300);
  });
  t.after(2150, () {
    t.to(s.run, {'v': 0}, 150);
    s.run['sh'] = 1;
    t.to(s.run, {'sh': 0}, 300);
    t.to(s.rob, {'sc': 2.6}, 120);
    // 술래잡기는 터치가 아니라 스캔(arrest)에서 잡히므로 터치 말풍선이 없다
    if (!s.tag) s.say(TutorialCallout.touch, 650);
  });
  t.after(2270, () => t.to(s.rob, {'sc': 2.3}, 160));
}

// 도둑 차례: 실제 플로팅 메뉴처럼 + → 내 QR을 눌러 QR을 꺼낸다.
void _showQr(TutorialStage s) {
  final t = s.timeline;
  final at = s.cameraFrame().project(s.rob['x'], s.rob['y']);
  s.scanned = false;
  s.targetCaught = false;
  s.holdSeconds = 0;
  s.qrGoalX = 196;
  s.qrX = 196;
  s.qrGoalY = 230;
  s.qrY = 230;
  t.to(s.q, {'hand': 0}, 200);
  s.setTheme(true, at.x, at.y - 40);
  t.to(s.cop, {'op': 0}, 200);
  t.to(s.rob, {'op': 0}, 300);
  t.to(s.cam, {
    'tilt': 76,
    'az': tutorialHeading,
    'persp': 260,
    'scale': 1.7,
    'cx': s.rob['x'],
    'cy': s.rob['y'],
    'oy': .62,
  }, 800);
  // 실제 메뉴처럼 + 버튼이 먼저 나오고, 눌리면 어두워지며 항목이 펼쳐지고 X로 돌아간다
  t.after(500, () => t.to(s.q, {'fab': 1}, 150));
  t.after(800, () => t.to(s.q, {'item': 1, 'bar': 1, 'fabOpen': 1}, 300));
  t.after(1400, () {
    t.to(s.q, {'myQrPress': 1}, 90);
    t.after(130, () => t.to(s.q, {'myQrPress': 0}, 170));
  });
  t.after(1650, () {
    t.to(s.q, {'item': 0, 'fab': 0}, 250);
    s.qrY = 380;
    s.qrGoalY = 380;
    s.qrX = 196;
    s.qrGoalX = 196;
    t.to(s.q, {'tg': 1}, 400);
    t.to(s.q, {'qy': 230}, 1000);
  });
}

// 경찰 차례: 들고 있던 폰이 올라와 카메라 틀이 되고, 폰을 움직여 QR을 찍는다.
void _scan(TutorialStage s) {
  final t = s.timeline;
  s.setTheme(false, 60, 420);
  t.to(s.q, {'bar': 0}, 300);
  s.q['tg'] = 1;
  s.q['hs'] = 1;
  s.q['hand'] = 1;
  s.q['hy'] = 240;
  t.to(s.q, {'hy': 0}, 800);
  t.after(250, () {
    s.qrGoalX = 305;
    s.qrGoalY = 395;
  });
  t.after(900, () => t.to(s.q, {'hs': 3.4, 'hand': 0}, 700));
  t.after(1250, () => t.to(s.q, {'fr': 1, 'tilt': 1}, 350));
  t.after(1600, s.startScanning);
}

void _jail(TutorialStage s) {
  const jx = TutorialStage.jailX;
  const jy = TutorialStage.jailY;
  final t = s.timeline;
  t.to(s.q, {'hand': 0}, 200);
  t.to(s.view, {'dim': 1}, 500);
  t.to(s.caught, {'op': 0}, 200);
  s.jailed['x'] = jx;
  s.jailed['y'] = jy;
  s.stopBlink();
  t.to(s.paw, {'op': 0}, 200);
  t.to(s.dot, {'op': 0}, 200);
  t.to(s.cam, {
    'tilt': 0,
    'az': tutorialHeading,
    'persp': 1100,
    'scale': 2.1,
    'cx': jx,
    'cy': jy,
    'oy': .5,
  }, 900);
  t.to(s.view, {'jail': 1}, 700);
  t.to(s.dot, {'x': jx - 62, 'y': jy - 20}, 1100);
  t.to(s.rob, {'op': 0}, 150);
  // 감옥 밖에서 경찰이 달려와 붙잡고, 잡힌 도둑이 걸어 들어와 갇힌다
  t.after(500, () {
    s.rob['x'] = jx + 62;
    s.rob['y'] = jy - 62;
    s.rob['sc'] = .6;
    t.to(s.rob, {'op': 1, 'sc': 1}, 300);
    s.cop['x'] = jx - 50;
    s.cop['y'] = jy - 95;
    s.cop['sc'] = 1;
    t.to(s.cop, {'op': 1}, 200);
    t.to(s.cop, {'x': jx + 18, 'y': jy - 72}, 800);
  });
  t.after(1300, () => t.to(s.rob, {'sc': 1.15}, 120));
  t.after(1420, () => t.to(s.rob, {'sc': 1}, 160));
  t.after(1500, () {
    final at = s.cameraFrame().project(s.rob['x'], s.rob['y']);
    s.setTheme(true, at.x, at.y - 40);
    s.caught['x'] = s.rob['x'];
    s.caught['y'] = s.rob['y'];
    s.caught['sc'] = 1;
    t.to(s.rob, {'op': 0}, 120);
    t.to(s.caught, {'op': 1}, 120);
    t.to(s.caught, {'x': jx, 'y': jy}, 1100);
    s.view['trA'] = 1;
    s.view['tr'] = 0;
    t.to(s.view, {'tr': 1}, 1100);
  });
  t.after(2650, () {
    s.jailed['sc'] = .8;
    t.to(s.caught, {'op': 0}, 150);
    t.to(s.jailed, {'op': 1, 'sc': 1}, 300);
    s.view['pul'] = 1;
    t.to(s.view, {'pul': 0}, 450);
    t.to(s.view, {'trA': 0}, 350);
    t.to(s.cop, {'op': 0}, 300);
  });
}

// 동료의 터치는 현장 규칙이다. 앱이 판정하지 않는다(LSN-0096).
void _rescue(TutorialStage s) {
  const jx = TutorialStage.jailX;
  const jy = TutorialStage.jailY;
  final t = s.timeline;
  s.ally['x'] = jx - 95;
  s.ally['y'] = jy - 60;
  s.ally['sc'] = 1;
  t.to(s.ally, {'op': 1}, 250);
  t.to(s.cop, {'op': 0}, 150);
  t.after(150, () => t.to(s.ally, {'x': jx - 38, 'y': jy - 14}, 900));
  t.after(1050, () {
    final at = s.cameraFrame().project(jx - 14, jy - 14);
    s.q['rx'] = at.x - 28;
    s.q['ry'] = at.y - 28;
    s.q['rip'] = .9;
    t.to(s.q, {'rip': 0}, 450);
    s.view['pul'] = 1;
    t.to(s.view, {'pul': 0}, 450);
    t.to(s.jailed, {'sc': 1.12}, 120);
  });
  t.after(1170, () => t.to(s.jailed, {'sc': 1}, 140));
  t.after(1500, () {
    t.to(s.jailed, {'op': 0}, 200);
    s.rob['x'] = jx;
    s.rob['y'] = jy;
    s.rob['sc'] = .8;
    t.to(s.rob, {'op': 1, 'sc': 1}, 250);
  });
}

void _escape(TutorialStage s) {
  final t = s.timeline;
  t.to(s.ally, {'op': 0}, 300);
  t.to(s.cop, {'op': 0}, 200);
  t.to(s.view, {'dim': 1}, 500);
  t.to(s.cam, {
    ...TutorialCamera.flatValues,
    'scale': 1.7,
    'cx': TutorialStage.jailX,
    'cy': TutorialStage.jailY,
  }, 900);
  t.to(s.dot, {'op': 1}, 300);
  s.escaping = true;
  s.escape['p'] = 0;
  t.after(200, () => t.to(s.escape, {'p': 1}, 1500));
}

// 술래잡기: 잡는 장면은 스캔(scan)에서 이미 끝났다. 여기서는 감옥 없이 그 자리에서
// 탈락(관전)으로 바뀌는 결과만 보여 주고, 다시 잡는 연출은 하지 않는다.
void _out(TutorialStage s) {
  final t = s.timeline;
  final x = s.rob['x'];
  final y = s.rob['y'];
  t.to(s.q, {'hand': 0}, 200);
  t.to(s.view, {'dim': 1}, 500);
  t.to(s.rob, {'op': 0}, 150);
  t.to(s.cop, {'op': 0}, 200);
  s.stopBlink();
  t.to(s.paw, {'op': 0}, 200);
  t.to(s.dot, {'op': 0}, 200);
  // 스캔을 건너뛴 경우에도 잡힌 모습이 보이도록 도망자 자리에 둔다
  s.caught['x'] = x;
  s.caught['y'] = y;
  s.caught['sc'] = 1;
  t.to(s.caught, {'op': 1}, 200);
  t.to(s.cam, {
    'tilt': 0,
    'az': tutorialHeading,
    'persp': 1100,
    'scale': 2.1,
    'cx': x,
    'cy': y,
    'oy': .5,
  }, 900);
  t.after(950, () {
    final at = s.cameraFrame().project(x, y);
    s.setTheme(true, at.x, at.y - 40);
  });
  t.after(1700, () {
    s.outed['x'] = x;
    s.outed['y'] = y;
    s.outed['sc'] = 1;
    t.to(s.caught, {'op': 0}, 300);
    t.to(s.outed, {'op': 1}, 300);
  });
  t.after(2050, () => t.to(s.outed, {'sc': .82}, 450));
}

void _shrink(TutorialStage s, {required bool hasJail}) {
  final t = s.timeline;
  t.to(s.caught, {'op': 0}, 200);
  s.setTheme(false, 196, 240);
  s.stopBlink();
  t.to(s.paw, {'op': 0}, 200);
  t.to(s.dot, {'op': 0}, 200);
  t.to(s.rob, {'op': 0}, 200);
  t.to(s.outed, {'op': 0}, 200);
  t.to(s.view, {'dim': 1, 'jail': hasJail ? 1 : 0}, 400);
  t.to(s.cam, TutorialCamera.wide3dValues, 900);
  final endPlay = hasJail ? 120.0 : 140.0;
  final endX = hasJail ? TutorialStage.jailX : 0.0;
  final endY = hasJail ? TutorialStage.jailY : 0.0;
  t.after(250, () {
    s.rob['x'] = 215;
    s.rob['y'] = -120;
    s.rob['sc'] = .8;
    t.to(s.rob, {'op': 1}, 300);
  });
  // 구역 축소(#668)의 4단계: 다음 경계를 점선으로 보여 준 뒤 그 자리로 줄어든다
  for (var i = 1; i <= 4; i++) {
    final f = i / 4;
    final play =
        TutorialStage.playRadius + (endPlay - TutorialStage.playRadius) * f;
    final px = endX * f;
    final py = endY * f;
    final begin = 650 + (i - 1) * 430;
    t.after(begin, () {
      s.view['nr'] = play;
      s.view['nx'] = px;
      s.view['ny'] = py;
      t.to(s.view, {'na': 1}, 120);
    });
    t.after(begin + 260, () {
      t.to(s.view, {'play': play, 'px': px, 'py': py}, 140);
      if (i == 4) t.to(s.view, {'na': 0}, 140);
    });
  }
  for (final warnAt in const [2500, 2950]) {
    t.after(warnAt, () {
      s.view['wa'] = 1;
      t.to(s.view, {'wa': 0}, 520);
    });
  }
  t.after(3400, () {
    s.caught['x'] = s.rob['x'];
    s.caught['y'] = s.rob['y'];
    s.caught['sc'] = .8;
    t.to(s.rob, {'op': 0}, 150);
    t.to(s.caught, {'op': 1}, 150);
  });
}

// 경찰 무전: 축소된 구역을 위에서 내려다보며, 무전 버튼을 누르는 동안 말하고
// 동료가 먼저 말하면 "OO 무전 중"이 뜨고 내 버튼이 잠긴다. 게임 화면의 무전과 같은 모습이다.
void _radio(TutorialStage s) {
  final t = s.timeline;
  final px = s.view['px'];
  final py = s.view['py'];
  s.setTheme(false, 196, 240);
  t.to(s.caught, {'op': 0}, 200);
  t.to(s.rob, {'op': 0}, 200);
  t.to(s.outed, {'op': 0}, 200);
  // 감옥 원이 구역 한가운데를 가려 좌표 칸이 안 보인다. 이 두 장면에서는 뺀다
  t.to(s.view, {'jail': 0, 'dim': 1}, 400);
  t.to(s.cam, {
    ...TutorialCamera.flatValues,
    'cx': px,
    'cy': py,
    // 줄어든 구역이 무대 폭의 절반쯤 되도록 키운다
    'scale': 100 / s.view['play'],
  }, 900);
  s.dot['x'] = px - s.view['play'] * .45;
  s.dot['y'] = py;
  s.dot['sc'] = 1;
  t.to(s.dot, {'op': 1}, 300);
  t.after(900, () => t.to(s.q, {'radio': 1}, 250));
  t.after(1300, () => t.to(s.q, {'ptt': 1}, 90));
  t.after(2500, () => t.to(s.q, {'ptt': 0}, 150));
  t.after(2900, () => t.to(s.q, {'pill': 1, 'lock': 1}, 250));
}

// 좌표: QR 체포 장면처럼 + 메뉴를 열어 좌표를 켜고, 칸을 길게 눌러 발견 핑을 찍으면
// 칸 이름이 팀 채팅으로도 간다(DEC-0100).
void _grid(TutorialStage s) {
  final t = s.timeline;
  t.to(s.q, {'fab': 1}, 150);
  t.after(400, () => t.to(s.q, {'gmenu': 1, 'bar': 1, 'fabOpen': 1}, 300));
  t.after(1000, () {
    t.to(s.q, {'gpress': 1}, 90);
    t.after(130, () => t.to(s.q, {'gpress': 0}, 170));
  });
  t.after(1300, () {
    t.to(s.q, {'gmenu': 0, 'bar': 0, 'fabOpen': 0}, 250);
    t.to(s.view, {'grid': 1}, 400);
  });
  // 길게 누른 자리에 물결이 퍼지고 핑 카드가 뜬다
  t.after(2000, () {
    final at = tutorialPingPoint(s);
    s.q['rx'] = at.dx - 28;
    s.q['ry'] = at.dy - 28;
    s.q['rip'] = .9;
    t.to(s.q, {'rip': 0}, 500);
  });
  t.after(2400, () => t.to(s.q, {'pcard': 1}, 200));
  t.after(3300, () {
    t.to(s.q, {'pcard': 0}, 150);
    t.to(s.q, {'ping': 1}, 200);
    t.to(s.q, {'chat': 1}, 250);
  });
}

/// 좌표 장면에서 길게 누르는 자리 — 가운데 칸(C3)의 아래쪽이라 칸 이름을 가리지 않는다.
Offset tutorialPingPoint(TutorialStage s) {
  final c = s.cameraFrame().project(s.view['px'], s.view['py']);
  return Offset(c.x, c.y + 14);
}

// 구역 원을 그대로 이어 쓴다: 원 안이 희게 차며 화면 밖까지 커지고 그 위로 그림이 올라온다.
// 문구는 그림이 다 올라온 뒤에 보여 준다.
void _community(TutorialStage s) {
  final t = s.timeline;
  s.view['copy'] = 0;
  t.after(1400, () => t.to(s.view, {'copy': 1}, 250));
  t.to(s.view, {'ra': 0}, 200);
  t.to(s.caught, {'op': 0}, 200);
  t.to(s.dot, {'op': 0}, 200);
  t.to(s.rob, {'op': 0}, 200);
  t.to(s.outed, {'op': 0}, 200);
  t.to(s.view, {'jail': 0}, 200);
  t.to(s.view, {'white': 1}, 250);
  // 지도는 그대로 두고 원만 키운다. 커질수록 먼 쪽 선이 지평선에 붙으므로 넉넉히 키운다
  t.after(150, () => t.to(s.view, {'play': 1700}, 1100));
  t.after(950, () {
    s.art['sc'] = .8;
    t.to(s.art, {'op': 1, 'sc': 1}, 450);
  });
}

void _pick(TutorialStage s) {
  final t = s.timeline;
  t.to(s.cam, TutorialCamera.flatValues, 1000);
  t.to(s.view, {'play': 50}, 900);
  t.after(1000, () => t.to(s.view, {'play': TutorialStage.playRadius}, 1300));
}

// 실제 초대코드 창을 띄우고 프로필이 하나씩 들어온다.
void _friends(TutorialStage s) {
  final t = s.timeline;
  t.to(s.q, {'bar': 1}, 300);
  t.after(200, () => t.to(s.q, {'inv': 1}, 300));
  t.after(900, () => t.to(s.q, {'a1': 1}, 250));
  t.after(1250, () => t.to(s.q, {'a2': 1}, 250));
  t.after(1600, () => t.to(s.q, {'a3': 1}, 250));
}

// 실제 게임처럼 시간이 흐르고, 구역을 벗어나면 이탈 배너가 뜬다.
void _guide(TutorialStage s) {
  final t = s.timeline;
  s.dot['x'] = -30;
  s.dot['y'] = 40;
  s.dot['sc'] = 0;
  s.dot['op'] = 1;
  t.to(s.dot, {'sc': 1}, 250);
  s.q['sec'] = 1500;
  t.to(s.q, {'tm': 1}, 300);
  t.to(s.q, {'sec': 1496}, 4000);
  t.after(300, () => t.to(s.dot, {'x': 264, 'y': -101}, 1500));
  t.after(1450, () => t.to(s.q, {'zb': 1}, 200));
  t.after(2600, () => t.to(s.dot, {'x': 85, 'y': 30}, 1300));
  t.after(3300, () => t.to(s.q, {'zb': 0}, 250));
}

void _record(TutorialStage s) {
  final t = s.timeline;
  t.to(s.q, {'tm': 0, 'zb': 0}, 200);
  s.view['ra'] = 1;
  s.view['rt'] = 0;
  t.to(s.view, {'rt': 1}, 2600);
}
