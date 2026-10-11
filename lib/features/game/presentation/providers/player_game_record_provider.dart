import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/game_record_local_datasource.dart';
import '../../data/models/game_area_model.dart';
import 'player_game_record.dart';

export 'player_game_record.dart';

part 'player_game_record_provider.g.dart';

/// 2m 미만 이동은 GPS 노이즈로 보고 경로에 추가하지 않는다.
const double _kMinPointDistanceMeters = 2.0;

/// 진행 중 게임 기록 파일을 두는 디렉터리 (테스트에서 임시 디렉터리로 교체).
@Riverpod(keepAlive: true)
Future<Directory> gameRecordDir(Ref ref) => getApplicationSupportDirectory();

/// 게임 중 내 활동(경로·거리)을 누적하는 Notifier.
///
/// `keepAlive: true` — 게임 종료 정리 시 위치 스트림이 결과 다이얼로그보다 먼저
/// 종료되므로(game_page `_prepareGameOverPresentation`), 누적값을 이 provider에
/// 담아 다이얼로그가 읽을 수 있게 한다.
///
/// 누적과 동시에 기기 파일에도 남겨, 앱이 죽었다가 같은 게임에 재진입하면 [begin]이 복원한다.
@Riverpod(keepAlive: true)
class PlayerGameRecordNotifier extends _$PlayerGameRecordNotifier {
  LatLngModel? _last;
  GameRecordLocalDatasource? _store;

  @override
  PlayerGameRecord build() => const PlayerGameRecord();

  /// 게임 화면 진입 시 호출 — 같은 게임의 저장 기록이 있으면 복원, 없으면 새로 시작.
  ///
  /// 복원 후 첫 점은 새 구간으로 시작한다. 앱이 꺼져 있던 동안의 이동은 알 수 없으므로
  /// 거리에 넣지 않고 지도에서도 잇지 않는다.
  Future<void> begin(int gameId) async {
    _last = null;
    _store = null;
    state = const PlayerGameRecord();
    try {
      final dir = await ref.read(gameRecordDirProvider.future);
      final store = GameRecordLocalDatasource(
        File('${dir.path}/game_record.txt'),
      );
      final saved = store.openForGame(gameId);
      if (saved != null) {
        for (final e in saved) {
          _apply(e);
        }
        _last = null;
        store.append((type: GameRecordEventType.resume, location: null));
      }
      _store = store;
    } catch (e) {
      // 파일 저장은 보조 수단 — 실패해도 메모리 누적은 그대로 동작해야 한다.
      debugPrint('[PlayerGameRecord] 기록 파일 열기 실패: $e');
    }
  }

  /// 위치 틱마다 호출. 직전 점과 2m 이상 벌어졌을 때만 경로·거리에 반영.
  void addPoint(LatLngModel p) {
    if (_apply((type: GameRecordEventType.point, location: p))) {
      _persist((type: GameRecordEventType.point, location: p));
    }
  }

  /// 경찰: 내가 도둑을 잡았을 때(STOMP 확정). 잡은 위치(현재까지 기록된 마지막 경로점)를
  /// 남겨, 결과 카드에서 "어디서 잡았는지" 마커로 표시한다. 아직 경로점이 없으면 기록하지 않는다.
  ///
  /// 개인 체포 횟수는 서버 `/api/game-results/{id}/me`가 주므로 여기서 세지 않는다.
  void recordArrest() {
    final loc = _last;
    if (loc == null) return;
    _apply((type: GameRecordEventType.arrest, location: loc));
    _persist((type: GameRecordEventType.arrest, location: loc));
  }

  /// 도둑: 내가 잡혔을 때(STOMP 확정). 잡힌 위치를 결과 카드 마커로 표시한다.
  ///
  /// 카운트는 경찰 쪽 통계라 증가시키지 않고 위치만 기록한다.
  void recordCaught() {
    final loc = _last;
    if (loc == null) return;
    _apply((type: GameRecordEventType.caught, location: loc));
    _persist((type: GameRecordEventType.caught, location: loc));
  }

  /// 게임 종료 시각 기록 (위치 스트림 cancel 직전 호출).
  ///
  /// 게임이 끝나면 재진입할 일이 없으므로 기기 기록 파일을 지운다.
  /// 결과 다이얼로그는 메모리 상태를 읽으므로 영향 없다.
  void markEnd(DateTime t) {
    state = state.copyWith(endedAt: t);
    try {
      _store?.clear();
    } catch (e) {
      debugPrint('[PlayerGameRecord] 기록 파일 삭제 실패: $e');
    }
    _store = null;
  }

  /// 이벤트 하나를 메모리 상태에 반영한다 (실시간 누적·파일 복원 공용).
  /// 점이 노이즈로 걸러지면 false.
  bool _apply(GameRecordEvent e) {
    final p = e.location;
    switch (e.type) {
      case GameRecordEventType.resume:
        _last = null;
      case GameRecordEventType.arrest:
        state = state.copyWith(arrestLocations: [...state.arrestLocations, p!]);
      case GameRecordEventType.caught:
        state = state.copyWith(caughtLocations: [...state.caughtLocations, p!]);
      case GameRecordEventType.point:
        final last = _last;
        if (last == null) {
          // 이어지는 직전 점이 없으면 새 구간 (첫 점은 구간 경계로 세지 않는다).
          state = state.copyWith(
            route: [...state.route, p!],
            segmentStarts: state.route.isEmpty
                ? state.segmentStarts
                : [...state.segmentStarts, state.route.length],
          );
          _last = p;
          return true;
        }
        final d = Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          p!.latitude,
          p.longitude,
        );
        if (d < _kMinPointDistanceMeters) return false;
        state = state.copyWith(
          route: [...state.route, p],
          distanceMeters: state.distanceMeters + d,
        );
        _last = p;
    }
    return true;
  }

  void _persist(GameRecordEvent e) {
    try {
      _store?.append(e);
    } catch (err) {
      debugPrint('[PlayerGameRecord] 기록 파일 쓰기 실패: $err');
    }
  }
}
