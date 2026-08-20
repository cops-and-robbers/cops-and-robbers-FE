import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/community_interaction_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_post_status.dart';
import '../providers/community_detail_provider.dart';
import '../widgets/community_comment_input.dart';
import '../widgets/community_comment_list.dart';
import '../widgets/community_map_preview.dart';
import '../widgets/community_post_menu.dart';

/// 모집글 상세 화면
///
/// 게시글 본문은 실서버, 좋아요·스크랩·댓글·참여 인원은 아직 목이다
/// (`community_detail_provider.dart`의 교체 지점 주석 참고).
/// 비로그인도 열람할 수 있고(DEC-0014), 쓰기 동작만 로그인을 요구한다.
class CommunityDetailPage extends ConsumerStatefulWidget {
  const CommunityDetailPage({super.key, required this.postId});

  final int postId;

  @override
  ConsumerState<CommunityDetailPage> createState() =>
      _CommunityDetailPageState();
}

class _CommunityDetailPageState extends ConsumerState<CommunityDetailPage> {
  /// 답글 대상. null이면 최상위 댓글을 쓰는 중이다.
  CommunityCommentEntity? _replyTarget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(communityDetailNotifierProvider(widget.postId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: Text(
          l10n.pageCommunityDetailTitle,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
        actions: [
          // 글을 못 불러왔으면 메뉴를 띄울 대상이 없다.
          if (detail.valueOrNull != null)
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.horizontal16),
              child: CommunityPostMenu(
                post: detail.value!.post,
                iconSize: 20,
                iconColor: AppColors.black700,
                onAction: _handleMenuAction,
              ),
            ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(l10n, error),
        data: (state) => _buildBody(l10n, state),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, Object error) {
    return Center(
      child: Padding(
        padding: AppPadding.horizontal24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error is AppException
                  ? l10n.errorByException(error)
                  : l10n.errorCommunityPostsLoadFailed,
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black600,
              ),
            ),
            SizedBox(height: AppSpacing.vertical16),
            AppButton(
              width: double.infinity,
              text: l10n.buttonRetry,
              onPressed: () => ref.invalidate(
                communityDetailNotifierProvider(widget.postId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, CommunityDetailState state) {
    final currentUserId = ref.watch(currentUserIdProvider);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌표는 항상 있다 — 주소만 역지오코딩 실패로 비어 있을 수 있다.
                CommunityMapPreview(
                  latitude: state.post.latitude,
                  longitude: state.post.longitude,
                  locationLabel: state.post.locationLabel,
                ),
                Padding(
                  padding: AppPadding.horizontal16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSpacing.vertical20),
                      _buildHeader(l10n, state),
                      SizedBox(height: AppSpacing.vertical16),
                      _buildMeta(l10n, state),
                      SizedBox(height: AppSpacing.vertical20),
                      Text(
                        state.post.content,
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black800,
                        ),
                      ),
                      SizedBox(height: AppSpacing.vertical24),
                      _buildActionRow(l10n, state.interaction),
                      SizedBox(height: AppSpacing.vertical16),
                      AppButton(
                        // 기본 폭 353은 좌우 20 패딩 기준이라 이 화면(좌우 24)에서는
                        // 8이 모자라 제약에 깎인다. 남은 폭을 그대로 쓴다.
                        width: double.infinity,
                        backgroundColor: AppColors.blue,
                        text: l10n.communityDetailJoinChat,
                        onPressed: _handleJoinChat,
                        // 에셋이 20×24라 24 정사각으로 늘리면 찌그러진다 —
                        // 높이만 24에 맞추고 폭은 원본 비율을 지킨다.
                        // 에셋 본체가 파랑(#339DFF)이라 파랑 버튼 위에서 묻힌다.
                        // 흰색으로 덧칠하면 안쪽 흰 점도 같이 흰색이 되어 통짜
                        // 실루엣으로 보인다 — 의도한 모양이다.
                        icon: SvgPicture.asset(
                          'assets/icons/icon_joining_game.svg',
                          width: 20.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        iconGap: AppSpacing.horizontal14,
                      ),
                      SizedBox(height: AppSpacing.vertical24),
                      Divider(height: 1.h, color: AppColors.black100),
                      SizedBox(height: AppSpacing.vertical16),
                      Text(
                        l10n.communityDetailCommentCount(
                          _totalComments(state.comments),
                        ),
                        style: AppTextStyles.label_16.copyWith(
                          color: AppColors.black600,
                        ),
                      ),
                    ],
                  ),
                ),
                // 목록만 좌우 패딩 밖에 둔다 — 답글 대상 댓글의 배경색이 화면
                // 끝까지 닿아야 하기 때문. 좌우 24는 타일이 직접 갖는다.
                CommunityCommentList(
                  comments: state.comments,
                  currentUserId: currentUserId,
                  onReply: (comment) => setState(() => _replyTarget = comment),
                  onDelete: _handleDeleteComment,
                  onReport: _handleReportComment,
                  replyTargetId: _replyTarget?.id,
                ),
              ],
            ),
          ),
        ),
        CommunityCommentInput(
          replyToNickname: _replyTarget?.writerNickname,
          onCancelReply: () => setState(() => _replyTarget = null),
          onSubmit: _handleSubmitComment,
        ),
      ],
    );
  }

  /// 상태 배지 + 참여 인원 + 제목
  Widget _buildHeader(AppLocalizations l10n, CommunityDetailState state) {
    final isRecruiting = state.post.status == CommunityPostStatus.recruiting;
    final participants = state.interaction.currentParticipants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal8,
                vertical: AppSpacing.vertical4,
              ),
              decoration: BoxDecoration(
                color: isRecruiting ? AppColors.logo : AppColors.black300,
                borderRadius: AppRadius.xlarge,
              ),
              child: Text(
                isRecruiting
                    ? l10n.communityStatusRecruiting
                    : l10n.communityStatusCompleted,
                style: AppTextStyles.tag_10.copyWith(color: AppColors.white),
              ),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            Text(
              // 참여 인원을 모르면 정원만 쓴다 — "0/10명"은 아무도 안 모인 것으로
              // 오독된다 (카드와 같은 판단).
              participants == null
                  ? l10n.communityHeadcountMaxOnly(state.post.maxParticipants)
                  : l10n.communityHeadcount(
                      participants,
                      state.post.maxParticipants,
                    ),
              style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.vertical12),
        Text(
          state.post.title,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ],
    );
  }

  /// 장소를 클립보드에 담는다 — 지도 앱에 붙여넣어 길찾기로 잇는 동선(DEC-0015).
  Future<void> _copyLocation(AppLocalizations l10n, String label) async {
    await Clipboard.setData(ClipboardData(text: label));
    if (!mounted) return;
    AppSnackbar.show(context, message: l10n.communityLocationCopied);
  }

  /// 장소 · 모임 일시
  Widget _buildMeta(AppLocalizations l10n, CommunityDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 지역·장소명이 둘 다 없으면 행 자체를 숨긴다 (좌표는 사용자에게 무의미).
        if (state.post.locationLabel != null) ...[
          _MetaRow(
            iconPath: 'assets/icons/icon_location.svg',
            label: state.post.locationLabel!,
            // 탭하면 복사된다 (DEC-0015) — 지도 앱에 붙여넣어 길찾기로 잇는 동선.
            onTap: () => _copyLocation(l10n, state.post.locationLabel!),
          ),
          SizedBox(height: AppSpacing.vertical8),
        ],
        _MetaRow(
          iconPath: 'assets/icons/icon_date.svg',
          label: _formatMeetingAt(l10n, state.post),
        ),
      ],
    );
  }

  /// 좋아요 · 스크랩 · 공유 — 카드형 버튼 3개, 사이 간격 18
  Widget _buildActionRow(
    AppLocalizations l10n,
    CommunityInteractionEntity interaction,
  ) {
    // 고정폭(110)이면 간격 18과 합쳐 가용폭을 넘쳐 오버플로우가 난다 —
    // Expanded로 균등 분배해 화면 폭에 맞게 비율대로 줄어들게 한다.
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            assetPath: interaction.isLiked
                ? 'assets/icons/icon_like_on.svg'
                : 'assets/icons/icon_like_off.svg',
            color: AppColors.red,
            label: '${interaction.likeCount}',
            textStyle: AppTextStyles.label16Medium,
            onTap: () => _requireLogin(
              () => _runInteraction(
                () => ref
                    .read(
                      communityDetailNotifierProvider(widget.postId).notifier,
                    )
                    .toggleLike(),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.horizontal18),
        Expanded(
          child: _ActionButton(
            assetPath: interaction.isBookmarked
                ? 'assets/icons/icon_save_on.svg'
                : 'assets/icons/icon_save_off.svg',
            color: AppColors.yellow,
            label: '${interaction.bookmarkCount}',
            textStyle: AppTextStyles.label16Medium,
            onTap: () => _requireLogin(
              () => _runInteraction(
                () => ref
                    .read(
                      communityDetailNotifierProvider(widget.postId).notifier,
                    )
                    .toggleBookmark(),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.horizontal18),
        Expanded(
          child: _ActionButton(
            assetPath: 'assets/icons/icon_upload.svg',
            color: AppColors.black700,
            label: l10n.communityDetailShare,
            textStyle: AppTextStyles.label16Medium,
            // ponytail: 공유 링크는 딥링크 경로가 정해진 뒤 붙인다.
            onTap: () =>
                AppSnackbar.show(context, message: l10n.comingSoonMessage),
          ),
        ),
      ],
    );
  }

  /// 답글 포함 총 댓글 수
  int _totalComments(List<CommunityCommentEntity> comments) =>
      comments.fold(0, (sum, c) => sum + 1 + c.replies.length);

  /// `9/10 (목) 18:00` — 카드와 같은 조립 방식.
  String _formatMeetingAt(AppLocalizations l10n, CommunityPostEntity post) {
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    final dt = post.meetingAt;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
    return l10n.communityMeetingAt(
      dt.month.toString(),
      dt.day.toString(),
      weekdays[dt.weekday - 1],
      time,
    );
  }

  // ==========================================================================
  // 동작
  // ==========================================================================

  /// 로그인이 필요한 동작을 감싼다. 비로그인이면 안내하고 로그인 화면으로 보낸다.
  void _requireLogin(VoidCallback action) {
    if (ref.read(currentUserIdProvider) == null) {
      _goLogin();
      return;
    }
    action();
  }

  void _goLogin() {
    final l10n = AppLocalizations.of(context);
    AppSnackbar.show(context, message: l10n.communityLoginRequiredMessage);
    context.push(RoutePaths.login);
  }

  /// 좋아요·스크랩처럼 실패해도 화면을 유지하는 동작.
  ///
  /// Notifier가 이미 이전 값으로 되돌린 뒤 예외를 던지므로 여기서는 알리기만 한다.
  Future<void> _runInteraction(Future<void> Function() action) async {
    VibrationService.instance().buttonTap();
    try {
      await action();
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
      );
    }
  }

  void _handleJoinChat() {
    final l10n = AppLocalizations.of(context);
    // ponytail: 게시글 단위 채팅인지 별도 채널인지 아직 확정되지 않았다.
    // 와이어프레임 확정 후 채팅방 진입으로 잇는다.
    AppSnackbar.show(context, message: l10n.comingSoonMessage);
  }

  Future<void> _handleSubmitComment(String content) async {
    final parentId = _replyTarget?.id;
    if (ref.read(currentUserIdProvider) == null) {
      _goLogin();
      return;
    }

    try {
      await ref
          .read(communityDetailNotifierProvider(widget.postId).notifier)
          .addComment(content, parentId: parentId);
      if (!mounted) return;
      setState(() => _replyTarget = null);
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
      );
    }
  }

  Future<void> _handleDeleteComment(CommunityCommentEntity comment) async {
    try {
      await ref
          .read(communityDetailNotifierProvider(widget.postId).notifier)
          .deleteComment(comment.id);
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
      );
    }
  }

  void _handleReportComment(CommunityCommentEntity comment) {
    // ponytail: 댓글 신고 API가 아직 없다. 생기면 신고 화면으로 잇는다.
    AppSnackbar.show(
      context,
      message: AppLocalizations.of(context).comingSoonMessage,
    );
  }

  void _handleMenuAction(CommunityPostMenuAction action) {
    final l10n = AppLocalizations.of(context);

    switch (action) {
      case CommunityPostMenuAction.login:
        _goLogin();
      case CommunityPostMenuAction.report:
        // ponytail: 게시글 신고 API가 아직 없다. 생기면 신고 화면으로 잇는다.
        AppSnackbar.show(context, message: l10n.comingSoonMessage);
      case CommunityPostMenuAction.edit:
        // ponytail: 수정 화면이 아직 없다 (작성 화면도 API 미연동).
        AppSnackbar.show(context, message: l10n.comingSoonMessage);
      case CommunityPostMenuAction.toggleStatus:
        _handleToggleStatus();
      case CommunityPostMenuAction.delete:
        _confirmDelete(l10n);
    }
  }

  Future<void> _handleToggleStatus() async {
    try {
      await ref
          .read(communityDetailNotifierProvider(widget.postId).notifier)
          .toggleStatus();
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
      );
    }
  }

  Future<void> _confirmDelete(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          l10n.communityDeleteConfirmTitle,
          style: AppTextStyles.label_16.copyWith(color: AppColors.black),
        ),
        content: Text(
          l10n.communityDeleteConfirmMessage,
          style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.buttonCancel,
              style: AppTextStyles.label_16.copyWith(color: AppColors.black600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.communityMenuDelete,
              style: AppTextStyles.label_16.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(communityDetailNotifierProvider(widget.postId).notifier)
          .deletePost();
      if (!mounted) return;
      // 삭제된 글의 상세에 머물 수 없다 — 목록으로 돌아간다.
      context.pop();
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
      );
    }
  }
}

/// 아이콘 + 라벨 한 줄 (장소 / 모임 일시)
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.iconPath, required this.label, this.onTap});

  final String iconPath;
  final String label;

  /// 탭 동작. 장소 행만 넘긴다 (복사).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 16.w, height: 16.h),
          SizedBox(width: AppSpacing.horizontal6),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 좋아요 · 스크랩 · 공유 버튼 하나 — h46 카드, 아이콘+텍스트 가로 배치. 폭은 부모
/// `Expanded`가 정한다.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.assetPath,
    required this.color,
    required this.label,
    required this.textStyle,
    required this.onTap,
  });

  final String assetPath;

  /// 아이콘·텍스트 공통 색 — `CommunityPostCard`와 같은 팔레트 색을 고정으로 쓴다
  /// (눌림 여부는 `assetPath`의 on/off 아이콘으로만 표현).
  final Color color;

  final String label;
  final TextStyle textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.vague,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SVG에 박힌 색이 팔레트와 미묘하게 달라 덧칠한다 (카드와 같은 이유).
            SvgPicture.asset(
              assetPath,
              width: 14.w,
              height: 14.h,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(width: AppSpacing.horizontal6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
