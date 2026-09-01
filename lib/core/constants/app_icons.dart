/// 아이콘 SVG 에셋 경로 상수
///
/// `assets/icons/` 아래 SVG 경로를 한곳에 모은다. 호출부는 경로 리터럴 대신 이
/// 클래스를 참조한다 — 다국어에서 문구를 `AppLocalizations` 키로 뽑아 쓰는 것과
/// 같은 구조다. 오타가 빌드를 통과해 화면을 열어야 드러나는 일을 없애는 것이 목적이다.
///
/// **새 아이콘을 추가할 때**: `assets/icons/` 에 파일을 넣고 여기에 상수를 한 줄
/// 추가한다(알파벳순). `pubspec.yaml` 은 `assets/icons/` 를 디렉터리째 등록하므로
/// 손댈 필요가 없다. 호출부에 경로 리터럴을 직접 쓰면
/// `test/core/constants/app_icons_test.dart` 의 가드 테스트가 실패한다.
///
/// **상수 이름은 올바른 표기, 값은 실제 파일명 그대로다.** [wrongMark] · [checkMark]
/// (파일명에 공백) 와 [setting2] (`settiing` 오타) 가 그 예다. 에셋 파일명 교정은
/// 별도 작업이며, 그때 고칠 곳은 이 파일의 값 한 줄뿐이다.
abstract final class AppIcons {
  static const String apple = 'assets/icons/icon_apple.svg';
  static const String arrow = 'assets/icons/icon_arrow.svg';
  static const String bell = 'assets/icons/icon_bell.svg';
  static const String bellBlock = 'assets/icons/icon_bell_block.svg';
  static const String block = 'assets/icons/icon_block.svg';
  static const String blog = 'assets/icons/blog.svg';
  static const String camera = 'assets/icons/icon_camera.svg';
  static const String change = 'assets/icons/icon_change.svg';
  static const String chatBellOff = 'assets/icons/icon_chat_bell_off.svg';
  static const String chatBellOn = 'assets/icons/icon_chat_bell_on.svg';
  static const String check = 'assets/icons/icon_check.svg';
  static const String checkCircleFalse = 'assets/icons/check_circle_false.svg';
  static const String checkCircleTrue = 'assets/icons/check_circle_true.svg';
  static const String checkMark = 'assets/icons/icon_check mark.svg';
  static const String comment = 'assets/icons/icon_comment.svg';
  static const String commuActive = 'assets/icons/icon_commu_active.svg';
  static const String commuInactive = 'assets/icons/icon_commu_inactive.svg';
  static const String copy = 'assets/icons/icon_copy.svg';
  static const String crown = 'assets/icons/icon_crown.svg';
  static const String date = 'assets/icons/icon_date.svg';
  static const String defaultLight = 'assets/icons/icon_default_light.svg';
  static const String delete = 'assets/icons/icon_delete.svg';
  static const String discord = 'assets/icons/discord.svg';
  static const String down = 'assets/icons/icon_down.svg';
  static const String exclamationMark =
      'assets/icons/icon_exclamation_mark.svg';
  static const String exit = 'assets/icons/icon_exit.svg';
  static const String gameConsole = 'assets/icons/icon_game_console.svg';
  static const String gameNotification =
      'assets/icons/icon_game_notification.svg';
  static const String gameOut = 'assets/icons/icon_gameout.svg';
  static const String github = 'assets/icons/github.svg';
  static const String google = 'assets/icons/icon_google.svg';
  static const String hamburger = 'assets/icons/icon_hamburger.svg';
  static const String headcount = 'assets/icons/icon_headcount.svg';
  static const String homeActive = 'assets/icons/icon_home_active.svg';
  static const String homeInactive = 'assets/icons/icon_home_inactive.svg';
  static const String info = 'assets/icons/icon_info.svg';
  static const String instagram = 'assets/icons/instagram.svg';
  static const String instagramBlack = 'assets/icons/instagram_black.svg';
  static const String joiningGame = 'assets/icons/icon_joining_game.svg';
  static const String language = 'assets/icons/icon_language.svg';
  static const String likeOff = 'assets/icons/icon_like_off.svg';
  static const String likeOn = 'assets/icons/icon_like_on.svg';
  static const String linkedin = 'assets/icons/linkedin.svg';
  static const String location = 'assets/icons/icon_location.svg';
  static const String locationPin = 'assets/icons/icon_location_pin.svg';
  static const String loudspeaker = 'assets/icons/Loudspeaker.svg';
  static const String mageLocationFill = 'assets/icons/mage_location-fill.svg';
  static const String map = 'assets/icons/icon_map.svg';
  static const String meatballs = 'assets/icons/icon_meatballs.svg';
  static const String mypageActive = 'assets/icons/icon_mypage_active.svg';
  static const String mypageInactive = 'assets/icons/icon_mypage_inactive.svg';
  static const String next = 'assets/icons/icon_next.svg';
  static const String nickname = 'assets/icons/icon_nickname.svg';
  static const String notFound = 'assets/icons/icon_not_found.svg';
  static const String noti = 'assets/icons/icon_noti.svg';
  static const String notice = 'assets/icons/icon_notice.svg';
  static const String notification = 'assets/icons/icon_notification.svg';
  static const String person = 'assets/icons/icon_person.svg';
  static const String pin = 'assets/icons/icon_pin.svg';
  static const String polygonPin = 'assets/icons/polygon_pin.svg';
  static const String post = 'assets/icons/icon_post.svg';
  static const String previous = 'assets/icons/icon_previous.svg';
  static const String qrCode = 'assets/icons/icon_qr_code.svg';
  static const String qrScan = 'assets/icons/icon_qr_scan.svg';
  static const String reply = 'assets/icons/icon_reply.svg';
  static const String saveOff = 'assets/icons/icon_save_off.svg';
  static const String saveOn = 'assets/icons/icon_save_on.svg';
  static const String search = 'assets/icons/icon_search.svg';
  static const String sending = 'assets/icons/icon_sending.svg';
  static const String setting2 = 'assets/icons/icon_settiing_2.svg';
  static const String shoeprint = 'assets/icons/shoeprint.svg';
  static const String siren = 'assets/icons/icon_siren.svg';
  static const String sort = 'assets/icons/icon_sort.svg';
  static const String speechBubble = 'assets/icons/icon_speech_bubble.svg';
  static const String tiktokBlack = 'assets/icons/tiktok_black.svg';
  static const String trash = 'assets/icons/icon_trash.svg';
  static const String upload = 'assets/icons/icon_upload.svg';
  static const String warningLight = 'assets/icons/icon_warning_light.svg';
  static const String website = 'assets/icons/website.svg';
  static const String write = 'assets/icons/icon_write.svg';
  static const String wrongMark = 'assets/icons/icon_wrong mark.svg';
  static const String youtube = 'assets/icons/youtube.svg';
  static const String youtubeBlack = 'assets/icons/youtube_black.svg';
  static const String zoneExit = 'assets/icons/icon_zone_exit.svg';

  // ═══════════════════════════════════════════════════════════════════════
  // 조합 경로 — 파일명이 종류·테마로 갈리는 아이콘
  //
  // 상수로 두면 조합 수만큼 늘어나는 데다, 호출부가 문자열을 이어 붙이면 완성된
  // 파일명으로는 검색되지 않아 에셋 사용 여부를 정적으로 판정할 수 없게 된다.
  // `character_assets.dart` 와 같은 경로 생성 함수 방식으로 통일한다.
  // ═══════════════════════════════════════════════════════════════════════

  /// 지도에 찍히는 핑 마커 — `icon_ping_{type}_marker_{theme}.svg`
  ///
  /// - [type] `PingType.name` — `'found'` | `'suspect'`
  static String pingMarker({required String type, required bool isDark}) =>
      'assets/icons/icon_ping_${type}_marker_${_theme(isDark)}.svg';

  /// 핑 선택 카드의 종류 셀 — `icon_ping_{type}_select_{theme}.svg`
  ///
  /// - [type] `PingType.name` — `'found'` | `'suspect'`
  static String pingSelect({required String type, required bool isDark}) =>
      'assets/icons/icon_ping_${type}_select_${_theme(isDark)}.svg';

  /// 핑 선택 카드 하단 핀 꼬리 — `icon_ping_pin_{theme}.svg`
  static String pingPin({required bool isDark}) =>
      'assets/icons/icon_ping_pin_${_theme(isDark)}.svg';

  /// 참가자 역할(경찰/도둑) 아이콘
  ///
  /// 두 파일의 접두어가 서로 다르다(`icon_police_` / `mdi_robber_`). 호출부가 그
  /// 불일치를 알 필요가 없도록 여기서 흡수한다.
  static String role({required bool isPolice, required bool isDark}) => isPolice
      ? 'assets/icons/icon_police_${_theme(isDark)}.svg'
      : 'assets/icons/mdi_robber_${_theme(isDark)}.svg';

  /// 파일명에 들어가는 테마 조각 (색상 테마가 아니라 에셋 명명 규칙)
  static String _theme(bool isDark) => isDark ? 'darkmode' : 'lightmode';
}
