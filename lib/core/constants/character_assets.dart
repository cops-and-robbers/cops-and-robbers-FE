/// 참가자 캐릭터 SVG 에셋 경로를 생성한다.
///
/// 반환 경로: `assets/characters/{team}/default/{state}.svg`
///
/// 에셋 폴더는 `assets/characters/{team}/{skinId}/{state}.svg` 규칙을 따르지만
/// 현재 스킨이 `default` 하나뿐이라 스킨 자리를 고정해 두었다. 스킨을 추가할 때는
/// `assets/characters/{team}/{skinId}/` 폴더를 만들어 `pubspec.yaml` 의
/// `flutter.assets:` 에 등록하고, 이 함수에 `skinId` 인자를 되살린다.
///
/// - [team]  팀 식별자. 예: `"police"`, `"robber"`
/// - [state] 상태 식별자. 기본값 `"default"` (예: `"jailed"`)
String characterAssetPath({required String team, String state = 'default'}) {
  return 'assets/characters/$team/default/$state.svg';
}

/// 게임 결과 화면 캐릭터 SVG 경로를 생성한다.
///
/// 반환 경로: `assets/characters/{team}/result/default/{result}_{part}.svg`
///
/// 폴더 규칙(`.../result/{skinId}/...`)과 스킨 추가 시 대응 방법은
/// [characterAssetPath] 문서를 따른다.
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

/// MVP 공개 화면 캐릭터 SVG 경로.
///
/// - [team] `'police'` | `'robber'`
// ponytail: 디자이너 MVP 에셋 전까지 홈 전신 그림을 쓴다. 오면
// 'assets/characters/$team/mvp/default/mvp.svg'로 바꾸고 pubspec.yaml에 폴더를 등록한다.
String mvpCharacterAssetPath({required String team}) =>
    characterAssetPath(team: team, state: 'home');

/// 게임 시작 화면(역할 배너·대기 장면·출동 배너) 캐릭터 SVG 경로.
///
/// 원본(`home.svg`·온보딩 그림)을 복사해 둔 시작 화면 전용 칸이다. 디자이너가
/// 시작 화면 그림만 바꿀 때 이 폴더의 파일만 갈아 끼우면 된다.
/// - [team] `'police'` | `'robber'`
String startRoleCharacterAssetPath({required String team}) =>
    'assets/characters/$team/start/default/role.svg';

/// 쫓고 쫓기는 장면 캐릭터 — 경찰은 고양이, 도둑은 쥐.
/// - [team] `'police'` | `'robber'`
String startChaseCharacterAssetPath({required String team}) =>
    'assets/characters/$team/start/default/chase.svg';

/// 대기·설명 장면 배경 PNG(1179×2562). 경찰은 낮, 도둑은 밤 그림.
/// - [scene] `'hills'` | `'town'` | `'city'`
String startWaitBackgroundAssetPath({
  required String scene,
  required bool isNight,
}) =>
    'assets/backgrounds/start_wait/start_wait_${scene}_${isNight ? 'night' : 'day'}.png';
