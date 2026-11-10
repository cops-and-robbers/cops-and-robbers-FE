import 'dart:math';

/// 무전은 경찰만(DEC-0114), 이벤트 게임은 서버가 막고, 방장이 끈 방도 쓰지 않는다.
bool radioAvailable({
  required bool isPolice,
  required bool isEventGame,
  required bool isRadioEnabled,
}) => isPolice && !isEventGame && isRadioEnabled;

/// 토큰 재발급까지 기다릴 시간 — 수명의 70~90% 사이에서 고른다.
///
/// 경찰이 다 같이 출동해 첫 발급 시각이 같아서, 고정 비율이면 재발급이 매번 한꺼번에 몰린다.
Duration radioRefreshDelay(Duration lifetime, Random random) =>
    lifetime * (0.70 + 0.20 * random.nextDouble());

/// PTT 발언권 — mute를 푼 순서대로 줄을 세워 맨 앞 사람이 갖는다.
///
/// 누른 시점과 맞는 트랙 mute 이벤트로만 판정한다(음량 기반 ActiveSpeakers는 늦고 조용한 사람을 놓친다).
class RadioFloor {
  const RadioFloor([this._order = const []]);

  final List<String> _order;

  /// 지금 말하는 사람의 identity(참가자 ID). 아무도 안 말하면 null.
  String? get holder => _order.isEmpty ? null : _order.first;

  RadioFloor onUnmuted(String identity) =>
      _order.contains(identity) ? this : RadioFloor([..._order, identity]);

  RadioFloor onMuted(String identity) =>
      RadioFloor([for (final id in _order) if (id != identity) id]);

  bool lockedFor(String me) => holder != null && holder != me;
}

/// 방장이 무전을 켰는지 — 방 설정(게임 모드처럼 켜고 끄기)이 서버에 생기면 그 값으로 바꾼다.
/// 지금은 모든 일반 게임에서 켠다 (#697).
const kRadioEnabledDefault = true;
