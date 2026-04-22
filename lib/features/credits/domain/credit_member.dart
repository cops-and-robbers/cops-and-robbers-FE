import 'package:flutter/painting.dart';

/// 소셜 링크 타입
///
/// 모든 타입은 SVG 에셋을 사용한다. (tree-shake-icons 최적화 충돌 방지)
enum SocialType {
  github,
  instagram,
  discord,
  linkedin,
  youtube,
  website,
  blog;

  /// UI에 표시할 라벨
  String get label => switch (this) {
    SocialType.github => 'GitHub',
    SocialType.instagram => 'Instagram',
    SocialType.discord => 'Discord',
    SocialType.linkedin => 'LinkedIn',
    SocialType.youtube => 'YouTube',
    SocialType.website => 'Website',
    SocialType.blog => 'Blog',
  };

  /// SVG 에셋 경로
  String get svgAsset => switch (this) {
    SocialType.github => 'assets/icons/github.svg',
    SocialType.instagram => 'assets/icons/instagram.svg',
    SocialType.discord => 'assets/icons/discord.svg',
    SocialType.linkedin => 'assets/icons/linkedin.svg',
    SocialType.youtube => 'assets/icons/youtube.svg',
    SocialType.website => 'assets/icons/website.svg',
    SocialType.blog => 'assets/icons/blog.svg',
  };

  /// 타입별 고유 색상 (null이면 기본 white 사용)
  ///
  /// website/blog는 stroke 기반 SVG라 tint 적용이 가능하다.
  /// github/instagram 등 브랜드 SVG는 원본 색을 유지하므로 null.
  Color? get tintColor => switch (this) {
    SocialType.website => const Color(0xFF4A90E2), // 스카이블루 — 웹/인터넷
    SocialType.blog => const Color(0xFF03C75A), // 네이버 그린
    _ => null,
  };
}

/// 소셜 링크 정보
class SocialLink {
  const SocialLink({required this.type, required this.url});

  final SocialType type;
  final String url;
}

/// 크레딧 멤버 정보
class CreditMember {
  const CreditMember({
    required this.name,
    required this.role,
    required this.profileAssets,
    required this.links,
  });

  final String name;
  final String role;

  /// 프로필 이미지 에셋 경로 목록 (2개 이상이면 동전 뒤집기 애니메이션, 비면 fallback 표시)
  final List<String> profileAssets;
  final List<SocialLink> links;
}

/// 크레딧에 표시할 멤버 목록
///
/// TODO: 소셜 링크 URL을 실제 값으로 교체 필요
const List<CreditMember> creditMembers = [
  CreditMember(
    name: '홍의민',
    role: 'Frontend',
    profileAssets: [
      'assets/credits/FE-Hong1.jpeg',
      'assets/credits/FE-Hong2.jpg',
    ],
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/EM-H20'),
      SocialLink(
        type: SocialType.instagram,
        url: 'https://www.instagram.com/e_m_hong',
      ),
      SocialLink(
        type: SocialType.linkedin,
        url: 'https://www.linkedin.com/in/eui-min-hong',
      ),
    ],
  ),
  CreditMember(
    name: '박찬빈',
    role: 'Frontend',
    profileAssets: [
      'assets/credits/FE-Park1.jpeg',
      'assets/credits/FE-Park2.jpeg',
      'assets/credits/FE-Park3.jpeg',
      'assets/credits/FE-Park4.jpeg',
    ],
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/INSANE-P'),
    ],
  ),
  CreditMember(
    name: '이창희',
    role: 'Backend',
    profileAssets: ['assets/credits/BE-Lee.jpeg'],
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/chxghee'),
      SocialLink(
        type: SocialType.instagram,
        url: 'https://www.instagram.com/chxghee',
      ),
    ],
  ),
  CreditMember(
    name: '정상희',
    role: 'Backend',
    profileAssets: ['assets/credits/BE-JEONG.jpeg'],
    links: [
      SocialLink(
        type: SocialType.github,
        url: 'https://github.com/SANGHEEJEONG',
      ),
      SocialLink(
        type: SocialType.instagram,
        url: 'https://www.instagram.com/shar_o.o_',
      ),
    ],
  ),
  CreditMember(
    name: '황혜림',
    role: 'Backend',
    profileAssets: ['assets/credits/BE-HWANG.png'],
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/HyerimH'),
      SocialLink(
        type: SocialType.instagram,
        url: 'https://www.instagram.com/h._xelim',
      ),
    ],
  ),
  CreditMember(
    name: '윤지희',
    role: 'Design',
    profileAssets: ['assets/credits/default.png'],
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/jihee127'),
      SocialLink(
        type: SocialType.instagram,
        url: 'https://www.instagram.com/jihee_o4',
      ),
      SocialLink(
        type: SocialType.blog,
        url: 'https://m.blog.naver.com/chic_sara',
      ),
    ],
  ),
];

/// 도움 준 사람 정보
class CreditHelper {
  const CreditHelper({required this.name, required this.role});

  final String name;
  final String role;
}

/// 도움 준 사람들 목록
const List<CreditHelper> creditHelpers = [
  CreditHelper(name: '안금서', role: 'QA'),
  CreditHelper(name: '남해윤', role: 'QA'),
  CreditHelper(name: '손건우', role: 'QA'),
  CreditHelper(name: '송혜정', role: 'QA'),
  CreditHelper(name: '신혜빈', role: 'QA'),
  CreditHelper(name: '이진', role: 'QA'),
  CreditHelper(name: '정창우', role: 'QA'),
  CreditHelper(name: '허석준', role: 'QA'),
];
