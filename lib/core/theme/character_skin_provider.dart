import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'character_skin_provider.g.dart';

/// 글로벌 캐릭터 스킨 상태.
///
/// - `'default'` (초기값) — PR #376 신규 캐릭터
/// - `'classic'` — 이스터에그로 발견하는 클래식 캐릭터
///
/// `keepAlive: true` 로 앱 프로세스 라이프타임 동안 유지된다.
/// 영속 저장은 하지 않으므로 앱 재시작 시 자연스럽게 default 로 복귀.
///
/// ```dart
/// final skinId = ref.watch(characterSkinProvider);
/// ref.read(characterSkinProvider.notifier).toggle();
/// ```
@Riverpod(keepAlive: true)
class CharacterSkin extends _$CharacterSkin {
  @override
  String build() => 'default';

  /// default ↔ classic 토글
  void toggle() {
    state = state == 'default' ? 'classic' : 'default';
  }
}
