/// 참가자 캐릭터 SVG 에셋 경로를 생성한다.
///
/// 규칙: `assets/characters/{team}/{skinId}/{state}.svg`
///
/// 현재 스킨은 `default` 하나뿐이라 경로에 고정해 두었다.
/// 스킨을 추가할 때는 `assets/characters/{team}/{skinId}/` 폴더를 만들어
/// `pubspec.yaml` 의 `flutter.assets:` 에 등록하고, 이 함수에 `skinId` 인자를 되살린다.
///
/// - [team]  팀 식별자. 예: `"police"`, `"robber"`
/// - [state] 상태 식별자. 기본값 `"default"` (예: `"jailed"`)
String characterAssetPath({
  required String team,
  String state = 'default',
}) {
  return 'assets/characters/$team/default/$state.svg';
}

/// 게임 결과 화면 캐릭터 SVG 경로를 생성한다.
///
/// 규칙: `assets/characters/{team}/result/{skinId}/{result}_{part}.svg`
///
/// 스킨 추가 시 대응 방법은 [characterAssetPath] 문서를 따른다.
///
/// - [team]   `'police'` | `'robber'`
/// - [result] `'win'` | `'lose'`
/// - [part]   `'body'` | `'arm_left'` | `'arm_right'`
String resultCharacterAssetPath({
  required String team,
  required String result,
  required String part,
}) {
  return 'assets/characters/$team/result/default/${result}_$part.svg';
}
