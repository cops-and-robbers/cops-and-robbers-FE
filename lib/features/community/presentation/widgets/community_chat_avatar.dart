import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../user/presentation/providers/profile_icon_provider.dart';

/// 채팅 아바타 — 앱 내장 프로필 아이콘 (`assets/profiles/<id>.svg`)
///
/// [iconId]가 null이면 기본 아이콘이다. 구버전 서버 응답처럼 번호가 없을 때만
/// 그렇고, 탈퇴한 사람은 서버가 기본값을 채워 준다(DEC-0041).
/// 댓글 목록(`community_comment_list.dart`)이 이미 같은 에셋을 쓴다.
class CommunityChatAvatar extends StatelessWidget {
  const CommunityChatAvatar({this.iconId, this.size = 36, super.key});

  final int? iconId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      profileIconAsset(iconId ?? kDefaultProfileIconId),
      width: size.w,
      height: size.w,
    );
  }
}
