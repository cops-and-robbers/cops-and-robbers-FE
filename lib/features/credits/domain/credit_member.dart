import 'package:flutter/material.dart';

/// 소셜 링크 타입
///
/// 각 타입별 표시 라벨과 아이콘을 제공한다.
enum SocialType {
  github,
  instagram,
  email,
  linkedin;

  /// UI에 표시할 라벨
  String get label => switch (this) {
    SocialType.github => 'GitHub',
    SocialType.instagram => 'Instagram',
    SocialType.email => 'Email',
    SocialType.linkedin => 'LinkedIn',
  };

  /// SVG 아이콘 대신 Material Icon 사용 (소셜 SVG 미보유)
  IconData get iconData => switch (this) {
    SocialType.github => Icons.code,
    SocialType.instagram => Icons.camera_alt,
    SocialType.email => Icons.email,
    SocialType.linkedin => Icons.work,
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
    required this.profileAsset,
    required this.links,
  });

  final String name;
  final String role;

  /// 프로필 이미지 에셋 경로 (없으면 fallback 표시)
  final String profileAsset;
  final List<SocialLink> links;
}

/// 크레딧에 표시할 멤버 목록
///
/// TODO: 소셜 링크 URL을 실제 값으로 교체 필요
const List<CreditMember> creditMembers = [
  CreditMember(
    name: '홍의민',
    role: 'Frontend',
    profileAsset: 'assets/credits/member1.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/EM-H20'),
    ],
  ),
  CreditMember(
    name: '박찬빈',
    role: 'Frontend',
    profileAsset: 'assets/credits/member2.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/chanbin'),
    ],
  ),
  CreditMember(
    name: '이창희',
    role: 'Backend',
    profileAsset: 'assets/credits/member3.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/changhee'),
    ],
  ),
  CreditMember(
    name: '정상희',
    role: 'Backend',
    profileAsset: 'assets/credits/member4.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/sanghee'),
    ],
  ),
  CreditMember(
    name: '황혜림',
    role: 'Backend',
    profileAsset: 'assets/credits/member5.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/hyerim'),
    ],
  ),
  CreditMember(
    name: '윤지희',
    role: 'Design',
    profileAsset: 'assets/credits/member6.png',
    links: [
      SocialLink(
        type: SocialType.instagram,
        url: 'https://instagram.com/jihee',
      ),
    ],
  ),
];

/// 도움 준 사람 정보
class CreditHelper {
  const CreditHelper({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;
}

/// 도움 준 사람들 목록
///
/// TODO: 실제 이름/역할로 교체 필요
const List<CreditHelper> creditHelpers = [
  CreditHelper(name: '서창희', role: '멘토'),
  CreditHelper(name: '김영수', role: 'QA'),
  CreditHelper(name: '이지은', role: '기획 자문'),
  CreditHelper(name: '박준혁', role: '인프라'),
  CreditHelper(name: '최민정', role: 'QA'),
];
