import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/community_post_entity.dart';

part 'community_feed_state.freezed.dart';

/// 무한 스크롤 목록의 누적 상태
///
/// `CommunityPostPageEntity`(서버 응답 한 장)와 달리 [items]는 페이지를 거듭할수록
/// 쌓인다. [isLoadingMore]는 하단 인디케이터 표시와 중복 요청 차단을 겸한다.
@freezed
class CommunityFeedState with _$CommunityFeedState {
  const factory CommunityFeedState({
    required List<CommunityPostEntity> items,

    /// 다음 요청에 그대로 실을 커서. 첫 페이지만 받은 직후에는 서버가 준
    /// `nextCursor`가 들어 있고, 더 없으면 null이다.
    required String? nextCursor,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _CommunityFeedState;
}
