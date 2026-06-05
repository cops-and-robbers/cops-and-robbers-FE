import 'dart:async';

import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/game_config.dart';
import '../../../../core/utils/iso_timestamp_parser.dart';
import '../../data/models/ping_message_dto.dart';
import '../../domain/entities/ping.dart';
import 'game_event_provider.dart'; // gameEventStompDatasourceProvider

part 'ping_provider.g.dart';

/// 핑 상태 관리자 (@riverpod, autoDispose)
///
/// echo 기반: [addPing]은 전송 요청만 하고, 서버가 팀 채널로 돌려준 핑을
/// [_onPingReceived]에서 수신해 표시한다. 소멸 2.5초 / rate-limit(5초 8회) 유지.
/// game_page는 build()에서 watch로 생존을 유지해야 함(autoDispose).
@riverpod
class PingNotifier extends _$PingNotifier {
  final Map<String, Timer> _timers = {};
  final List<DateTime> _recentPingTimes = [];
  DateTime? _cooldownUntil;

  @override
  List<Ping> build() {
    final datasource = ref.watch(gameEventStompDatasourceProvider);
    final sub = datasource.onPing.listen(_onPingReceived);
    ref.onDispose(() {
      sub.cancel();
      for (final t in _timers.values) {
        t.cancel();
      }
      _timers.clear();
    });
    return const [];
  }

  /// 핑 전송 요청. rate-limit 통과 + 전송 성공 시 true.
  ///
  /// 거부: 쿨다운 중이거나 윈도우 초과(→쿨다운). 연결 끊김으로 전송 실패하면
  /// rate-limit 카운트를 소모하지 않고 false(서버 Drop과 구분). 화면 표시는
  /// 서버 echo가 [_onPingReceived]에서 처리하므로 여기서 state를 건드리지 않는다.
  bool addPing({
    required PingType type,
    required double latitude,
    required double longitude,
    required int gameId,
  }) {
    final now = clock.now();

    // 1) 쿨다운 중이면 거부
    final cd = _cooldownUntil;
    if (cd != null && now.isBefore(cd)) return false;

    // 2) 윈도우 밖 기록 제거 후 한계 검사
    _recentPingTimes.removeWhere(
      (t) => now.difference(t) > GameConfig.pingRateWindow,
    );
    if (_recentPingTimes.length >= GameConfig.pingRateMaxCount) {
      _cooldownUntil = now.add(GameConfig.pingRateCooldown);
      return false;
    }

    // 3) 전송 시도 — 연결 끊김이면 카운트 소모 없이 false
    final sent = ref
        .read(gameEventStompDatasourceProvider)
        .publishPing(gameId, type, latitude, longitude);
    if (!sent) return false;

    // 4) 전송 성공 → rate-limit 카운트 1 소모
    _recentPingTimes.add(now);
    return true;
  }

  /// 수신 핑 처리 — 서버 UUID upsert + 소멸 타이머(중복 수신 시 타이머 리셋)
  void _onPingReceived(PingMessageDto dto) {
    final ping = _toPing(dto);
    if (ping == null) return; // HELP/unknown skip

    _timers.remove(ping.id)?.cancel();
    state = [...state.where((p) => p.id != ping.id), ping];

    _timers[ping.id] = Timer(GameConfig.pingLifetime, () {
      state = state.where((p) => p.id != ping.id).toList();
      _timers.remove(ping.id);
    });
  }

  /// DTO → domain Ping. FOUND/SUSPECT만 매핑, HELP·미지정은 null(skip).
  Ping? _toPing(PingMessageDto dto) {
    final type = switch (dto.pingType) {
      'FOUND' => PingType.found,
      'SUSPECT' => PingType.suspect,
      _ => null,
    };
    if (type == null) return null;
    return Ping(
      id: dto.id,
      type: type,
      latitude: dto.location.latitude,
      longitude: dto.location.longitude,
      createdAt: IsoTimestampParser.parse(dto.timestamp) ?? clock.now(),
    );
  }
}
