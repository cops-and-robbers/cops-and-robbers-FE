import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../../../core/utils/iso_timestamp_parser.dart';
import 'entities/area_shape.dart';

/// 구역 축소(#668) 공식과 차수 계산.
///
/// 서버는 최종 반경 하나만 저장한다(DEC-0145). 축소 시각·현재 원은 매번 이 함수로
/// 다시 계산하고 저장하지 않는다(DEC-0149). 방 생성·대기방·게임 화면이 같은 규칙을 쓴다.

/// 감옥을 품고도 남길 최소 여유(m).
const int _jailMargin = 100;

/// 최종 반경 = floor(max(감옥 + 100, min(시작 × 40%, 200))). 감옥이 없으면 0으로 넣는다.
int computeShrinkFinalRadius({
  required int startRadius,
  required int jailRadius,
}) {
  final byRatio = math.min(startRadius * 0.4, 200.0);
  return math.max((jailRadius + _jailMargin).toDouble(), byRatio).floor();
}

enum ShrinkLock { none, tooSmall, notCircle }

/// 구역 축소를 켤 수 있는지. 반경은 서버에 round()해서 저장되므로 같은 값으로 판정한다.
ShrinkLock shrinkLockFor(GameAreaEntity area) {
  final playground = area.playground;
  if (playground is! CircleShape) return ShrinkLock.notCircle;
  final jail = area.jail;
  final jailRadius = jail is CircleShape ? jail.radiusInMeters.round() : 0;
  return playground.radiusInMeters.round() <= jailRadius + _jailMargin
      ? ShrinkLock.tooSmall
      : ShrinkLock.none;
}

class ShrinkState {
  const ShrinkState({
    required this.stage,
    required this.current,
    required this.nextAt,
    required this.next,
  });

  /// 0 = 아직 안 줄어듦, 4 = 최종 구역
  final int stage;
  final CircleShape current;

  /// 다음 축소 시각. 최종 구역이거나 축소할 수 없으면 null.
  final DateTime? nextAt;
  final CircleShape? next;
}

/// [now]의 축소 차수와 원.
///
/// 1차 = 시작 + 경찰 대기 + 간격, 간격 = (게임 시간 − 경찰 대기) ÷ 5. 경계 시각과 같으면 새 차수.
/// 감옥이 중심에 없으면 최종 원이 감옥을 품도록 중심을 필요한 만큼만 옮기고, 4번에 나눠 옮긴다.
ShrinkState shrinkStateAt({
  required DateTime start,
  required int roundDurationMinutes,
  required int policeWaitMinutes,
  required CircleShape playground,
  required CircleShape? jail,
  required int finalRadius,
  required DateTime now,
}) {
  final intervalMs = (roundDurationMinutes - policeWaitMinutes) * 60000 ~/ 5;
  if (intervalMs <= 0) {
    return ShrinkState(stage: 0, current: playground, nextAt: null, next: null);
  }
  final firstAt = start.add(
    Duration(minutes: policeWaitMinutes, milliseconds: intervalMs),
  );
  final elapsed = now.difference(firstAt).inMilliseconds;
  final stage = elapsed < 0 ? 0 : math.min(4, elapsed ~/ intervalMs + 1);

  final finalCenter = _finalCenter(playground, jail, finalRadius);
  CircleShape circleAt(int k) {
    final f = k / 4;
    return AreaShape.circle(
          center: GeoPoint(
            latitude:
                playground.center.latitude +
                (finalCenter.latitude - playground.center.latitude) * f,
            longitude:
                playground.center.longitude +
                (finalCenter.longitude - playground.center.longitude) * f,
          ),
          radiusInMeters:
              playground.radiusInMeters -
              (playground.radiusInMeters - finalRadius) * f,
        )
        as CircleShape;
  }

  return ShrinkState(
    stage: stage,
    current: circleAt(stage),
    nextAt: stage < 4
        ? firstAt.add(Duration(milliseconds: intervalMs * stage))
        : null,
    next: stage < 4 ? circleAt(stage + 1) : null,
  );
}

GeoPoint _finalCenter(
  CircleShape playground,
  CircleShape? jail,
  int finalRadius,
) {
  if (jail == null) return playground.center;
  final d = Geolocator.distanceBetween(
    playground.center.latitude,
    playground.center.longitude,
    jail.center.latitude,
    jail.center.longitude,
  );
  final shift = math.max(0.0, d + jail.radiusInMeters - finalRadius);
  if (d == 0 || shift == 0) return playground.center;
  // 게임 구역(수 km 이하)에서는 위경도 선형 보간으로 충분하다
  final f = math.min(1.0, shift / d);
  return GeoPoint(
    latitude:
        playground.center.latitude +
        (jail.center.latitude - playground.center.latitude) * f,
    longitude:
        playground.center.longitude +
        (jail.center.longitude - playground.center.longitude) * f,
  );
}

/// 게임 하나의 축소 시계. 축소를 쓰지 않거나 계산할 수 없으면 null — 원래 구역으로 판정한다.
///
/// [finalRadius]는 게임 정보 조회(`GET /api/games/{id}`) 값을 그대로 쓴다. 대기방을 거쳐
/// 들어온 사람은 참가자 상태에 이 값이 없으므로 조회값이 기준이다. 시작 시각을 모르면
/// 잘못 줄인 원으로 억울하게 강제 체포되지 않도록 축소하지 않는다(DEC-0149).
ShrinkState Function(DateTime now)? shrinkClockFor({
  required GameAreaEntity area,
  required int? finalRadius,
  required DateTime? start,
  required int? roundDurationMinutes,
  required int? policeWaitMinutes,
}) {
  final playground = area.playground;
  final jail = area.jail;
  if (finalRadius == null ||
      start == null ||
      roundDurationMinutes == null ||
      policeWaitMinutes == null ||
      playground is! CircleShape) {
    return null;
  }
  return (now) => shrinkStateAt(
    start: start,
    roundDurationMinutes: roundDurationMinutes,
    policeWaitMinutes: policeWaitMinutes,
    playground: playground,
    jail: jail is CircleShape ? jail : null,
    finalRadius: finalRadius,
    now: now,
  );
}

/// 축소 계산에 쓸 시작 시각·게임 시간·경찰 시작 시간을 고른다.
///
/// 시작 시각은 START 이벤트 → 참가자 상태 → 게임 정보 조회 순(앱바와 같은 우선순위).
/// 앱을 다시 켜면 참가자 상태는 설정 조회가 끝나기 전까지 비어 있으므로, 게임 정보
/// 응답 값을 대체값으로 써야 그 폰만 축소가 꺼지는 일이 없다.
({DateTime? start, int? round, int? wait}) resolveShrinkInputs({
  required DateTime? eventStart,
  required String? participantStart,
  required int? participantRound,
  required int? participantWait,
  required String? infoStart,
  required int? infoRound,
  required int? infoWait,
}) => (
  start:
      eventStart ??
      IsoTimestampParser.parse(participantStart) ??
      IsoTimestampParser.parse(infoStart),
  round: participantRound ?? infoRound,
  wait: participantWait ?? infoWait,
);
