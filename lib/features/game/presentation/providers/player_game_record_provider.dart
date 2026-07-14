import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/game_area_model.dart';
import 'player_game_record.dart';

export 'player_game_record.dart';

part 'player_game_record_provider.g.dart';

/// 2m 미만 이동은 GPS 노이즈로 보고 경로에 추가하지 않는다.
const double _kMinPointDistanceMeters = 2.0;

/// 게임 중 내 활동(경로·거리·개인 카운트)을 누적하는 휘발성 Notifier.
///
/// `keepAlive: true` — 게임 종료 정리 시 위치 스트림이 결과 다이얼로그보다 먼저
/// 종료되므로(game_page `_prepareGameOverPresentation`), 누적값을 이 provider에
/// 담아 다이얼로그가 읽을 수 있게 한다. 다음 게임 진입(GamePage initState)에서 [reset].
@Riverpod(keepAlive: true)
class PlayerGameRecordNotifier extends _$PlayerGameRecordNotifier {
  LatLngModel? _last;

  @override
  PlayerGameRecord build() => const PlayerGameRecord();

  /// 새 게임 시작 시 호출 — 모든 누적값 초기화.
  void reset() {
    _last = null;
    state = const PlayerGameRecord();
  }

  /// 위치 틱마다 호출. 직전 점과 2m 이상 벌어졌을 때만 경로·거리에 반영.
  void addPoint(LatLngModel p) {
    final last = _last;
    if (last == null) {
      state = state.copyWith(route: [...state.route, p]);
      _last = p;
      return;
    }
    final d = Geolocator.distanceBetween(
      last.latitude,
      last.longitude,
      p.latitude,
      p.longitude,
    );
    if (d < _kMinPointDistanceMeters) return;
    state = state.copyWith(
      route: [...state.route, p],
      distanceMeters: state.distanceMeters + d,
    );
    _last = p;
  }

  /// 경찰: 내가 도둑을 잡았을 때(STOMP 확정).
  ///
  /// 카운트와 함께 잡은 위치(현재까지 기록된 마지막 경로점)를 남겨, 결과 카드에서
  /// "어디서 잡았는지" 마커로 표시한다. 아직 경로점이 없으면 위치만 생략.
  void incrementArrest() {
    final loc = _last;
    state = state.copyWith(
      myArrestCount: state.myArrestCount + 1,
      arrestLocations: loc == null
          ? state.arrestLocations
          : [...state.arrestLocations, loc],
    );
  }

  /// 도둑: 내가 탈옥했을 때(STOMP 확정). 횟수만 집계한다
  /// (탈옥은 항상 감옥에서 일어나므로 위치 표시는 불필요).
  void incrementEscape() {
    state = state.copyWith(myEscapeCount: state.myEscapeCount + 1);
  }

  /// 도둑: 내가 잡혔을 때(STOMP 확정). 잡힌 위치를 결과 카드 마커로 표시한다.
  ///
  /// 카운트는 경찰 쪽 통계라 증가시키지 않고 위치만 기록한다.
  void recordCaught() {
    final loc = _last;
    if (loc == null) return;
    state = state.copyWith(caughtLocations: [...state.caughtLocations, loc]);
  }

  /// 게임 종료 시각 기록 (위치 스트림 cancel 직전 호출).
  void markEnd(DateTime t) {
    state = state.copyWith(endedAt: t);
  }
}
