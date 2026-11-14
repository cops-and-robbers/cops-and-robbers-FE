import '../../../core/constants/game_mode.dart';
import '../../game/domain/entities/area_shape.dart';

/// 모드를 바꿀 때 서버로 보낼 구역.
///
/// 서버는 모드와 구역이 어긋나면 거절한다(JAIL_AREA_NOT_ALLOWED / JAIL_AREA_REQUIRED).
/// 술래잡기는 감옥을 떼고, 경찰과 도둑은 방금 그린 [newJail]을 붙인다.
GameAreaEntity areaForMode(
  GameAreaEntity current,
  GameMode target, {
  AreaShape? newJail,
}) {
  if (!target.usesJail) return GameAreaEntity(playground: current.playground);
  if (newJail == null) {
    throw ArgumentError.notNull('newJail');
  }
  return GameAreaEntity(playground: current.playground, jail: newJail);
}
