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
  const SocialLink({
    required this.type,
    required this.url,
  });

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
const List<CreditMember> creditMembers = [
  CreditMember(
    name: '멤버1',
    role: 'Backend',
    profileAsset: 'assets/images/credits/member1.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member1'),
    ],
  ),
  CreditMember(
    name: '멤버2',
    role: 'Backend',
    profileAsset: 'assets/images/credits/member2.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member2'),
      SocialLink(
        type: SocialType.linkedin,
        url: 'https://linkedin.com/in/member2',
      ),
    ],
  ),
  CreditMember(
    name: '멤버3',
    role: 'Flutter',
    profileAsset: 'assets/images/credits/member3.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member3'),
    ],
  ),
  CreditMember(
    name: '멤버4',
    role: 'Flutter',
    profileAsset: 'assets/images/credits/member4.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member4'),
      SocialLink(
        type: SocialType.email,
        url: 'mailto:member4@example.com',
      ),
    ],
  ),
  CreditMember(
    name: '멤버5',
    role: 'Design',
    profileAsset: 'assets/images/credits/member5.png',
    links: [
      SocialLink(
        type: SocialType.instagram,
        url: 'https://instagram.com/member5',
      ),
    ],
  ),
  CreditMember(
    name: '멤버6',
    role: 'PM',
    profileAsset: 'assets/images/credits/member6.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member6'),
    ],
  ),
];
