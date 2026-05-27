/// 참가자 캐릭터 SVG 에셋 경로를 생성한다.
///
/// 규칙: `assets/characters/{team}/{skinId}/{state}.svg`
///
/// 새 스킨 추가 시 `pubspec.yaml` 의 `flutter.assets:` 항목에
/// `assets/characters/{team}/{skinId}/` 경로를 함께 등록해야 한다.
///
/// - [team]   팀 식별자. 예: `"police"`, `"robber"`
/// - [skinId] 스킨 식별자. 기본값 `"default"`
/// - [state]  상태 식별자. 기본값 `"default"` (예: `"jailed"`)
String characterAssetPath({
  required String team,
  String skinId = 'default',
  String state = 'default',
}) {
  return 'assets/characters/$team/$skinId/$state.svg';
}

/// 게임 결과 화면 캐릭터 SVG 경로를 생성한다.
///
/// 규칙: `assets/characters/{team}/result/{skinId}/{result}_{part}.svg`
///
/// - [team]   `'police'` | `'robber'`
/// - [skinId] 스킨 식별자. 기본값 `'default'`
/// - [result] `'win'` | `'lose'`
/// - [part]   `'body'` | `'arm_left'` | `'arm_right'`
String resultCharacterAssetPath({
  required String team,
  String skinId = 'default',
  required String result,
  required String part,
}) {
  return 'assets/characters/$team/result/$skinId/${result}_$part.svg';
}
