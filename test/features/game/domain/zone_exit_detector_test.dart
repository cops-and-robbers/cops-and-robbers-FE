import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/game/domain/zone_exit_detector.dart';

void main() {
  late ZoneExitDetector detector;
  late List<String> callLog;

  setUp(() {
    callLog = [];
    detector = ZoneExitDetector(
      onExitZone: () => callLog.add('exit'),
      onEnterZone: () => callLog.add('enter'),
    );
  });

  group('ZoneExitDetector', () {
    test('구역 밖으로 나가면 onExitZone 콜백 호출', () {
      detector.update(isOutside: true);

      expect(callLog, ['exit']);
    });

    test('구역 안으로 돌아오면 onEnterZone 콜백 호출', () {
      detector.update(isOutside: true); // 밖으로
      callLog.clear();

      detector.update(isOutside: false); // 안으로

      expect(callLog, ['enter']);
    });

    test('밖 → 안 → 밖 → 안 반복 시 콜백 정확히 호출', () {
      detector.update(isOutside: true); // exit
      detector.update(isOutside: false); // enter
      detector.update(isOutside: true); // exit
      detector.update(isOutside: false); // enter

      expect(callLog, ['exit', 'enter', 'exit', 'enter']);
    });

    test('구역 밖에서 계속 있으면 onExitZone 중복 호출 안 됨', () {
      detector.update(isOutside: true);
      detector.update(isOutside: true);
      detector.update(isOutside: true);

      expect(callLog, ['exit']);
    });

    test('구역 안에서 계속 있으면 콜백 호출 없음', () {
      detector.update(isOutside: false);
      detector.update(isOutside: false);
      detector.update(isOutside: false);

      expect(callLog, isEmpty);
    });

    test('초기 상태는 구역 안 (isOutside == false)', () {
      expect(detector.isOutside, isFalse);
    });

    test('update 후 isOutside 상태 정확히 반영', () {
      detector.update(isOutside: true);
      expect(detector.isOutside, isTrue);

      detector.update(isOutside: false);
      expect(detector.isOutside, isFalse);
    });
  });
}
