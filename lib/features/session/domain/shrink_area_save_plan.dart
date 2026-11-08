import '../../game/domain/entities/area_shape.dart';
import '../../game/domain/shrink_schedule.dart';

enum SaveStep { settings, area }

class SaveStepCall {
  const SaveStepCall(this.step, [this.finalRadius]);

  final SaveStep step;

  /// settings 단계에서 보낼 최종 반경. null이면 축소 끔.
  final int? finalRadius;
}

class ShrinkAreaSavePlan {
  const ShrinkAreaSavePlan({
    required this.order,
    required this.newFinalRadius,
    required this.turnedOff,
  });

  final List<SaveStepCall> order;
  final int? newFinalRadius;

  /// 새 구역에서 축소를 쓸 수 없어 껐다 — 방장에게 알린다.
  final bool turnedOff;
}

/// 대기방에서 구역을 고칠 때 `PUT /settings`와 `PUT /area`를 보낼 순서 (#668).
///
/// 서버는 각 요청을 **저장된 다른 쪽 값**과 `감옥 < 최종 < 시작`으로 검사하므로(BE PR #231),
/// 그 시점에 통과하는 요청부터 보낸다. 둘 다 통과하지 못하면 껐다가 구역을 바꾸고 다시 켠다.
ShrinkAreaSavePlan planShrinkAreaSave({
  required GameAreaEntity oldArea,
  required GameAreaEntity newArea,
  required int? currentFinalRadius,
}) {
  if (currentFinalRadius == null) {
    return const ShrinkAreaSavePlan(
      order: [SaveStepCall(SaveStep.area)],
      newFinalRadius: null,
      turnedOff: false,
    );
  }
  final newZone = _circle(newArea);
  if (shrinkLockFor(newArea) != ShrinkLock.none || newZone == null) {
    return const ShrinkAreaSavePlan(
      order: [SaveStepCall(SaveStep.settings), SaveStepCall(SaveStep.area)],
      newFinalRadius: null,
      turnedOff: true,
    );
  }
  final next = computeShrinkFinalRadius(
    startRadius: newZone.start,
    jailRadius: newZone.jail,
  );
  final oldZone = _circle(oldArea);
  final List<SaveStepCall> order;
  if (oldZone != null && oldZone.accepts(next)) {
    order = [
      SaveStepCall(SaveStep.settings, next),
      const SaveStepCall(SaveStep.area),
    ];
  } else if (newZone.accepts(currentFinalRadius)) {
    order = [
      const SaveStepCall(SaveStep.area),
      SaveStepCall(SaveStep.settings, next),
    ];
  } else {
    order = [
      const SaveStepCall(SaveStep.settings),
      const SaveStepCall(SaveStep.area),
      SaveStepCall(SaveStep.settings, next),
    ];
  }
  return ShrinkAreaSavePlan(
    order: order,
    newFinalRadius: next,
    turnedOff: false,
  );
}

/// 계획대로 보낸다. 중간에 실패하면 이미 보낸 단계를 역순으로 이전 값으로 되돌리고
/// 원래 예외를 다시 던진다 — 축소만 꺼지거나 구역만 바뀐 채 남지 않게.
Future<void> runShrinkAreaSave(
  ShrinkAreaSavePlan plan, {
  required Future<void> Function(int? finalRadius) putSettings,
  required Future<void> Function() putArea,
  required int? previousFinalRadius,
  required Future<void> Function() putPreviousArea,
}) async {
  final done = <SaveStep>[];
  for (final call in plan.order) {
    try {
      if (call.step == SaveStep.settings) {
        await putSettings(call.finalRadius);
      } else {
        await putArea();
      }
    } catch (_) {
      for (final step in done.reversed) {
        try {
          if (step == SaveStep.settings) {
            await putSettings(previousFinalRadius);
          } else {
            await putPreviousArea();
          }
        } catch (_) {
          // 되돌리기도 실패하면 호출부가 서버 값을 다시 조회한다
        }
      }
      rethrow;
    }
    done.add(call.step);
  }
}

typedef _Zone = ({int start, int jail});

_Zone? _circle(GameAreaEntity area) {
  final p = area.playground;
  if (p is! CircleShape) return null;
  final j = area.jail;
  return (
    start: p.radiusInMeters.round(),
    jail: j is CircleShape ? j.radiusInMeters.round() : 0,
  );
}

extension on _Zone {
  bool accepts(int finalRadius) => jail < finalRadius && finalRadius < start;
}
