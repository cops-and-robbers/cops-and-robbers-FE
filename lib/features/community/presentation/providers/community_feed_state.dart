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

    /// 거리순 조회에 쓴 기준 좌표. 첫 페이지에서 한 번 구해 `loadMore`가
    /// 그대로 재사용한다 — 페이지를 넘길 때마다 GPS를 켜지 않기 위해서다.
    /// 서버가 커서에 좌표를 담지 않으므로(사용자가 이동해도 커서가 막히지
    /// 않게) 같은 값을 계속 써도 계약에 어긋나지 않는다.
    /// 거리순이 아니면 null이다.
    double? latitude,
    double? longitude,

    /// 이 목록을 서버에서 받아온 시각.
    ///
    /// 유효 시간이 지났는지 판정하는 기준이다. `loadMore`로 페이지를 이어붙이는
    /// 것은 "다시 받아온 것"이 아니므로 갱신하지 않는다.
    required DateTime fetchedAt,
  }) = _CommunityFeedState;
}
