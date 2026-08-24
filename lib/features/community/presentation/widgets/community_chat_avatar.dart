import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../user/presentation/providers/profile_icon_provider.dart';

/// 채팅 아바타 — 앱 내장 프로필 아이콘 (`assets/profiles/<id>.svg`)
///
/// 서버가 채팅 응답에 아바타 정보를 아직 안 내려줘서 전원 기본 아이콘(1)로
/// 그린다. 응답에 프로필 id가 실리기 시작하면 호출부가 [iconId]만 넘기면 된다 —
/// 댓글 목록(`community_comment_list.dart`)이 이미 같은 에셋을 쓴다.
class CommunityChatAvatar extends StatelessWidget {
  const CommunityChatAvatar({
    this.iconId = kDefaultProfileIconId,
    this.size = 36,
    super.key,
  });

  final int iconId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      profileIconAsset(iconId),
      width: size.w,
      height: size.w,
    );
  }
}
