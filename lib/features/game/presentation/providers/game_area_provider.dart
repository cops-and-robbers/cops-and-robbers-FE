import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/game_area_model.dart';
import '../../domain/entities/area_shape.dart';
import 'game_event_provider.dart';

part 'game_area_provider.g.dart';

/// 게임 맵 영역 FutureProvider
///
/// `GET /api/games/{gameId}/area` 응답을 도메인 엔티티로 변환해 캐시합니다.
/// GamePage 진입 시 트리거하여 플레이그라운드·감옥 구역을 지도에 표시합니다.
@riverpod
Future<GameAreaEntity> gameArea(Ref ref, int gameId) async {
  final model = await ref.read(gameSystemApiProvider).getArea(gameId);
  return model.toEntity();
}
