import 'package:flutter/painting.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

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
    profileAssets: [
      'assets/credits/DESIGN-YOON1.jpeg',
      'assets/credits/DESIGN-YOON2.jpeg',
    ],
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
  CreditMember(
    name: '김다임',
    role: 'Design',
    profileAssets: [
      'assets/credits/DESIGN-KIM1.png',
      'assets/credits/DESIGN-KIM2.jpeg',
    ],
    links: [
      SocialLink(
        type: SocialType.instagram,
        url: 'https://www.instagram.com/daimmmmi',
      ),
      SocialLink(
        type: SocialType.linkedin,
        url: 'https://www.linkedin.com/in/daim-kim',
      ),
    ],
  ),
];

/// 도움 준 사람 정보
class CreditHelper {
  const CreditHelper({
    required this.name,
    required this.role,
    required this.tier,
    this.participationCount = 1,
  });

  final String name;
  final String role;

  /// 표시 등급 — 색상/굵기를 결정하는 단일 진실(single source of truth).
  final ContributionTier tier;

  /// 참여 횟수 메타데이터 (현재 표시에는 영향 없음).
  ///
  /// 자동 계산이 아니라 데이터 입력 시점에 사람이 명시한다.
  /// 미래에 통계, 정렬, 툴팁 등에 활용 가능.
  final int participationCount;
}

/// 크레딧 기여도 티어 (5단계)
///
/// - tier1~3: QA 참여 횟수 기반 (1회 / 2회 / 3회+) — 데이터 입력 시점에 수동 분류
/// - tier4~5: 인프라 제공·후원 등 큰 도움 — 수동 지정
///
/// 자동 카운트 로직을 두지 않는다. 4·5단계는 어차피 수동이라 두 로직이 섞이면 복잡.
enum ContributionTier { tier1, tier2, tier3, tier4, tier5 }

/// 티어별 텍스트 색상 (`SocialType.tintColor` 패턴과 동일하게 enum extension)
///
/// 검은 배경(`AppColors.black`) 기준 perceived brightness가 단조 증가하도록 매핑.
/// (134 → 171 → 196 → 220 → 227)
extension ContributionTierColor on ContributionTier {
  Color get color => switch (this) {
    ContributionTier.tier1 => AppColors.black500, // #76899E (134) — 회색
    ContributionTier.tier2 => AppColors.green, // #38F55B (171) — 비비드 초록
    ContributionTier.tier3 => AppColors.green800, // #7AF391 (196) — 밝은 초록
    ContributionTier.tier4 => AppColors.yellow, // #F5EF38 (220) — 선명 노랑
    ContributionTier.tier5 => AppColors.yellow900, // #F7F260 (227) — 가장 밝은 노랑
  };
}

/// 멤버 이름 → 다국어 표시명 변환
///
/// const list 안의 [CreditMember.name] / [CreditHelper.name]은 한국어 상수이므로
/// UI 렌더링 시점에 이 함수로 다국어 텍스트로 변환한다.
/// 매핑이 없는 이름은 원본 그대로 반환 (fallback).
String localizedMemberName(AppLocalizations l10n, String name) {
  return switch (name) {
    '홍의민' => l10n.creditMemberHongEuiMin,
    '박찬빈' => l10n.creditMemberParkChanBin,
    '이창희' => l10n.creditMemberLeeChangHee,
    '정상희' => l10n.creditMemberJeongSangHee,
    '황혜림' => l10n.creditMemberHwangHyeRim,
    '윤지희' => l10n.creditMemberYoonJiHee,
    '김다임' => l10n.creditMemberKimDaim,
    '신지훈' => l10n.creditMemberShinJiHoon,
    '남해윤' => l10n.creditMemberNamHaeYoon,
    '송혜정' => l10n.creditMemberSongHyeJung,
    '이진' => l10n.creditMemberLeeJin,
    '안금서' => l10n.creditMemberAhnGeumSeo,
    '손건우' => l10n.creditMemberSonGeonWoo,
    '신혜빈' => l10n.creditMemberShinHyeBin,
    '정창우' => l10n.creditMemberJeongChangWoo,
    '허석준' => l10n.creditMemberHeoSeokJun,
    '서현진' => l10n.creditMemberSeoHyunJin,
    '오동현' => l10n.creditMemberOhDongHyun,
    '최승훈' => l10n.creditMemberChoiSeungHoon,
    '김민욱' => l10n.creditMemberKimMinWook,
    '정명준' => l10n.creditMemberJeongMyeongJun,
    '강대현' => l10n.creditMemberKangDaeHyun,
    '심 혁' => l10n.creditMemberSimHyuk,
    _ => name,
  };
}

/// 도움 준 사람들 목록 (unique union — 중복 이름은 한 번만, 횟수는 메타로 보존)
///
/// 마키 노출 우선순위를 위해 **티어 높은 순**으로 정렬 (tier4 → tier2 → tier1).
/// 같은 티어 안에서는 명단 입력 순서를 유지한다.
const List<CreditHelper> creditHelpers = [
  // 인프라 제공 (tier4) — 가장 높은 강조
  CreditHelper(
    name: '신지훈',
    role: 'Infra Provision',
    tier: ContributionTier.tier4,
    participationCount: 1,
  ),
  // 2회 참여 QA (tier2)
  CreditHelper(
    name: '남해윤',
    role: 'QA',
    tier: ContributionTier.tier2,
    participationCount: 2,
  ),
  CreditHelper(
    name: '송혜정',
    role: 'QA',
    tier: ContributionTier.tier2,
    participationCount: 2,
  ),
  CreditHelper(
    name: '이진',
    role: 'QA',
    tier: ContributionTier.tier2,
    participationCount: 2,
  ),
  // 1회 참여 QA (tier1) — 12명
  CreditHelper(
    name: '안금서',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '손건우',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '신혜빈',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '정창우',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '허석준',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '서현진',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '오동현',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '최승훈',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '김민욱',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '정명준',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '강대현',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
  CreditHelper(
    name: '심 혁',
    role: 'QA',
    tier: ContributionTier.tier1,
    participationCount: 1,
  ),
];
