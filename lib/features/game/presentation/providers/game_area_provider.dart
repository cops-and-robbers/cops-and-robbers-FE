import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/game_system_api_datasource.dart';
import '../../data/models/game_area_model.dart';

part 'game_area_provider.g.dart';

/// 게임 맵 영역 FutureProvider
///
/// `GET /api/games/{gameId}/area` 응답을 캐시합니다.
/// GamePage 진입 시 트리거하여 플레이그라운드·감옥 원을 지도에 표시합니다.
@riverpod
Future<GameAreaModel> gameArea(Ref ref, int gameId) async {
  return await ref.read(gameSystemApiProvider).getArea(gameId);
}
