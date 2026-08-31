import 'dart:async'; // unawaited

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/community_recent_keyword_storage.dart';
import '../../domain/entities/community_scope.dart';
import '../providers/community_provider.dart';
import '../widgets/community_feed_list.dart';

/// 커뮤니티 모집글 검색 화면
///
/// 상태가 둘이다 — 입력 중에는 최근 검색어를, 검색을 실행한 뒤에는 결과 목록을
/// 보여준다. 실행된 검색어만 [_submitted]에 담아 provider의 family 키로 넘기므로,
/// 타이핑 도중에는 요청이 나가지 않는다. 서버가 `LIKE '%키워드%'`로 훑어
/// 인덱스를 타지 못해 "검색 버튼 시점에 한 번"이 백엔드 지침이다.
class CommunitySearchPage extends ConsumerStatefulWidget {
  const CommunitySearchPage({super.key});

  @override
  ConsumerState<CommunitySearchPage> createState() =>
      _CommunitySearchPageState();
}

class _CommunitySearchPageState extends ConsumerState<CommunitySearchPage> {
  final TextEditingController _controller = TextEditingController();

  /// 실행된 검색어. null이면 아직 검색하지 않았다.
  String? _submitted;

  /// 최근 검색어. 화면 진입 때 한 번 읽고 이후 갱신할 때마다 다시 읽는다.
  List<String> _recent = const [];

  /// 서버가 세는 방식과 같게 잰다 — 공백을 전부 제거하고 2자 이상.
  static bool _isLongEnough(String keyword) =>
      keyword.replaceAll(RegExp(r'\s'), '').length >= 2;

  /// 입력에 맞춰 좁힌 최근 검색어. 입력이 비면 전부 보여준다.
  ///
  /// 로컬에 이미 있는 목록을 거르는 것이라 서버 요청이 없다. 본 검색은 여전히
  /// 실행 시점에 한 번만 부른다 — 타이핑마다 부르면 인덱스를 타지 못하는
  /// 전체 스캔을 반복하게 된다(백엔드 지침).
  List<String> get _visibleRecent {
    final typed = _controller.text.trim();
    if (typed.isEmpty) return _recent;
    final lowered = typed.toLowerCase();
    return [
      for (final keyword in _recent)
        if (keyword.toLowerCase().contains(lowered)) keyword,
    ];
  }

  @override
  void initState() {
    super.initState();
    // 타이핑에 맞춰 최근 검색어를 좁혀 보여준다. 서버는 부르지 않는다.
    _controller.addListener(_onTypedChanged);
    unawaited(_loadRecent());
  }

  void _onTypedChanged() {
    // 검색을 실행한 뒤에는 화면이 결과 목록이라 최근 검색어 좁히기가 보이지
    // 않는다. 보이는 변화가 없는데 CommunityFeedList 서브트리만 매 타건마다
    // 다시 그리는 낭비를 막는다.
    if (_submitted != null) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTypedChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    // _removeRecent·_clearRecent가 자기 await 뒤에 가드 없이 바로 이 함수를
    // 부른다 — 그 사이 위젯이 dispose되면 아래 ref.read가 dispose 후 사용으로
    // 던질 수 있어 진입 시점에 먼저 막는다.
    if (!mounted) return;
    final loaded = await ref.read(communityRecentKeywordStorageProvider).load();
    if (!mounted) return;
    setState(() => _recent = loaded);
  }

  /// 검색 실행 — 2자 미만은 서버에 보내기 전에 막는다(확정 400).
  ///
  /// 서버에는 앞뒤 공백만 지운 원문을 보낸다 — [_isLongEnough] 검증에만 쓰는
  /// 전체 공백 제거본은 보내지 않는다. 나머지 정규화와 검색어 해시 생성은
  /// 서버가 한다.
  Future<void> _search(String raw) async {
    // TextField의 TextInputAction.search 제출은 Flutter가 포커스를 자동
    // 해제하지만, 앱바 돋보기 버튼 경로는 해제하지 않는다 — 여기서 맞춰 두 진입점의
    // 결과를 통일한다(안 그러면 키보드가 검색 결과를 가린다).
    FocusManager.instance.primaryFocus?.unfocus();

    final keyword = raw.trim();
    if (!_isLongEnough(keyword)) {
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).communitySearchTooShort,
      );
      return;
    }

    await ref.read(communityRecentKeywordStorageProvider).add(keyword);
    if (!mounted) return;

    _controller.text = keyword;
    setState(() => _submitted = keyword);
    await _loadRecent();
  }

  Future<void> _removeRecent(String keyword) async {
    await ref.read(communityRecentKeywordStorageProvider).remove(keyword);
    await _loadRecent();
  }

  Future<void> _clearRecent() async {
    await ref.read(communityRecentKeywordStorageProvider).clear();
    await _loadRecent();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onBack: () => context.pop(),
        // 원래 centerTitle 미지정이었고 실효값이 false다 (Android 기본,
        // iOS도 actions 2개라 false). 기본값 true와 다르므로 명시한다.
        centerTitle: false,
        titleWidget: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => unawaited(_search(value)),
          style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: l10n.communitySearchHint,
            hintStyle: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black500,
            ),
          ),
        ),
        actions: [
          IconButton(
            // 커뮤니티 목록과 같은 계산 — 24 + 아이콘 24 = 최소 폭 48.
            padding: EdgeInsets.only(left: AppSpacing.horizontal24),
            icon: SvgPicture.asset(
              'assets/icons/icon_search.svg',
              width: 24.w,
              height: 24.h,
            ),
            onPressed: () => unawaited(_search(_controller.text)),
          ),
          SizedBox(width: AppSpacing.horizontal16),
        ],
      ),
      body: _submitted == null
          ? _buildRecent(l10n)
          : Consumer(
              builder: (context, ref, _) => CommunityFeedList(
                scope: CommunityScope.all,
                sort: ref.watch(selectedCommunitySortProvider),
                keyword: _submitted,
                emptyMessage: l10n.communitySearchEmpty,
              ),
            ),
    );
  }

  Widget _buildRecent(AppLocalizations l10n) {
    final recent = _visibleRecent;
    if (recent.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: AppPadding.horizontal16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.vertical16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.communitySearchRecent,
                style: AppTextStyles.subHeading_18.copyWith(
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => unawaited(_clearRecent()),
                child: Text(
                  l10n.communitySearchClearAll,
                  style: AppTextStyles.tag_14.copyWith(
                    color: AppColors.black600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vertical12),
          Wrap(
            spacing: AppSpacing.horizontal8,
            runSpacing: AppSpacing.vertical8,
            children: [
              for (final keyword in recent)
                _RecentChip(
                  keyword: keyword,
                  onTap: () => unawaited(_search(keyword)),
                  onRemove: () => unawaited(_removeRecent(keyword)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 최근 검색어 한 칸 — 탭하면 그 말로 다시 검색하고, ✕는 그 항목만 지운다.
class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.keyword,
    required this.onTap,
    required this.onRemove,
  });

  final String keyword;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal12,
          vertical: AppSpacing.vertical8,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword,
              style: AppTextStyles.tag_14.copyWith(color: AppColors.black700),
            ),
            SizedBox(width: AppSpacing.horizontal4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: SvgPicture.asset(
                'assets/icons/icon_delete.svg',
                width: 12.w,
                height: 12.h,
                colorFilter: const ColorFilter.mode(
                  AppColors.black500,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
