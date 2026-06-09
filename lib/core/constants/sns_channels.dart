/// 공식 SNS 홍보 채널 정보
///
/// 설정 화면 하단 아이콘 행에서 사용한다. 균일한 슬레이트 톤 원 배경 위에
/// 슬레이트색 단색 글리프를 얹는 방식이라, [svgAsset]은 단색(검정) 글리프를 가리킨다.
class SnsChannel {
  const SnsChannel({
    required this.svgAsset,
    required this.label,
    required this.url,
  });

  /// 단색 글리프 SVG 경로 (원 안에서 슬레이트색으로 colorFilter 적용)
  final String svgAsset;

  /// 스크린리더용 채널명 (시각적 라벨은 없음)
  final String label;

  /// 탭 시 외부 브라우저로 열 채널 URL
  final String url;
}

/// 설정 화면에 노출할 공식 채널 목록 (좌 → 우 순서)
const List<SnsChannel> officialSnsChannels = [
  SnsChannel(
    svgAsset: 'assets/icons/instagram_black.svg',
    label: 'Instagram',
    url: 'https://www.instagram.com/cops._.robbers',
  ),
  SnsChannel(
    svgAsset: 'assets/icons/youtube_black.svg',
    label: 'YouTube',
    url: 'https://www.youtube.com/@cops._.nrobbers',
  ),
  SnsChannel(
    svgAsset: 'assets/icons/tiktok_black.svg',
    label: 'TikTok',
    url: 'https://www.tiktok.com/@cops._.robbers',
  ),
];
