import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 소셜 링크 타입
///
/// SVG 아이콘이 있는 타입은 svgAsset 경로 제공, 없는 타입은 FontAwesome IconData 제공.
enum SocialType {
  github,
  instagram,
  discord,
  linkedin,
  youtube,
  email,
  website;

  /// UI에 표시할 라벨
  String get label => switch (this) {
    SocialType.github => 'GitHub',
    SocialType.instagram => 'Instagram',
    SocialType.discord => 'Discord',
    SocialType.linkedin => 'LinkedIn',
    SocialType.youtube => 'YouTube',
    SocialType.email => 'Email',
    SocialType.website => 'Website',
  };

  /// SVG 에셋 경로 (null이면 FontAwesome IconData 사용)
  String? get svgAsset => switch (this) {
    SocialType.github => 'assets/icons/github.svg',
    SocialType.instagram => 'assets/icons/instagram.svg',
    SocialType.discord => 'assets/icons/discord.svg',
    SocialType.linkedin => 'assets/icons/linkedin.svg',
    SocialType.youtube => 'assets/icons/youtube.svg',
    SocialType.email => null,
    SocialType.website => null,
  };

  /// FontAwesome fallback 아이콘 (SVG가 없는 타입용)
  IconData get iconData => switch (this) {
    SocialType.email => IconData(
      FontAwesomeIcons.envelope.codePoint,
      fontFamily: 'FontAwesomeSolid',
      fontPackage: 'font_awesome_flutter',
    ),
    SocialType.website => IconData(
      FontAwesomeIcons.blog.codePoint,
      fontFamily: 'FontAwesomeSolid',
      fontPackage: 'font_awesome_flutter',
    ),
    // SVG 아이콘이 있는 타입은 iconData를 사용하지 않음
    _ => Icons.link,
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
      'assets/credits/FE-Hong2.JPG',
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
    profileAssets: ['assets/credits/member4.png'],
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
    profileAssets: ['assets/credits/member5.png'],
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
    profileAssets: ['assets/credits/member6.png'],
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/jihee127'),
      SocialLink(
        type: SocialType.instagram,
        url: 'https://www.instagram.com/jihee_o4',
      ),
      SocialLink(
        type: SocialType.website,
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
///
/// TODO: 실제 이름/역할로 교체 필요
const List<CreditHelper> creditHelpers = [
  CreditHelper(name: '정상희', role: '사장?'),
  CreditHelper(name: '황혜림', role: '부사장..?'),
  CreditHelper(name: '이지은', role: '기획 자문'),
  CreditHelper(name: '박준혁', role: '인프라'),
  CreditHelper(name: '최민정', role: 'QA'),
];
