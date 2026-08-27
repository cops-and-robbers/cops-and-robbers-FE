import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_post_entity.dart';
import '../community_chat_time_format.dart';
import '../providers/community_chat_room_provider.dart';
import '../providers/community_chat_rooms_provider.dart';

/// 모임 정보 — 채팅방 상단 모임 카드를 누르면 전체 화면으로 연다
///
/// 시안은 방장이 쓰는 채팅방 공지였는데 **서버에 저장할 곳이 없다** — 공지 조회·
/// 등록 API가 없고 백엔드 이슈도 없다. 저장되지 않는 입력창을 방장에게 보여주는
/// 대신, 모집글 단건 조회에 이미 있는 값(모임 일시·장소·본문)과 채팅방 인원으로
/// 채운다. 공지 API가 생기면 이 화면에 절을 더한다.
class CommunityChatMeetingInfoPage extends ConsumerWidget {
  const CommunityChatMeetingInfoPage({required this.postId, super.key});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final post = ref.watch(communityChatPostProvider(postId)).valueOrNull;
    // 헤더가 쓰는 것과 같은 값이다 — 시스템 메시지로 실시간 보정된 인원수라
    // 두 화면이 서로 다른 숫자를 보이지 않는다.
    final memberCount = ref
        .watch(communityChatRoomNotifierProvider(postId))
        .valueOrNull
        ?.memberCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: l10n.communityChatMeetingInfoTitle,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: post == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: AppPadding.horizontal16,
                child: _body(l10n, post, memberCount),
              ),
      ),
    );
  }

  Widget _body(
    AppLocalizations l10n,
    CommunityPostEntity post,
    int? memberCount,
  ) {
    final label = post.locationLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSpacing.vertical20),
        Text(
          post.title,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
        SizedBox(height: AppSpacing.vertical16),
        _row(formatCommunityMeetingAt(l10n, post.meetingAt)),
        // 지역·장소명이 둘 다 없으면 남는 건 좌표뿐이라 행을 숨긴다(상세와 같은 판단).
        if (label != null) ...[
          SizedBox(height: AppSpacing.vertical8),
          _row(label),
        ],
        SizedBox(height: AppSpacing.vertical8),
        _row(
          // 인원을 모르면 "-"다 — "0/10명"은 아무도 안 모인 것으로 오독된다.
          l10n.communityChatMeetingMembers(
            memberCount?.toString() ?? '-',
            post.maxParticipants,
          ),
        ),
        SizedBox(height: AppSpacing.vertical20),
        Text(
          post.content,
          style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black800),
        ),
        SizedBox(height: AppSpacing.vertical24),
      ],
    );
  }

  Widget _row(String text) => Text(
    text,
    style: AppTextStyles.tag_14.copyWith(color: AppColors.black600),
  );
}
