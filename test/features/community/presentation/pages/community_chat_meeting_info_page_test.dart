import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_chat_meeting_info_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';
import '../../community_fakes.dart';

const _postId = 42;

/// 모임 정보 화면이 쓰는 건 단건 조회 하나뿐이다 — 좋아요·댓글은 안 부른다.
class _PostRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _PostRepository({
    this.region = '서울특별시 광진구 군자동',
    this.placeName = '어린이대공원 정문',
  });

  final String? region;
  final String? placeName;

  @override
  Future<CommunityPostEntity> getPost(int postId) async {
    return CommunityPostEntity(
      id: _postId,
      writerId: 7,
      title: '나랑 경도하자!!!!!',
      content: '20시에 정문에서 모여요. 편한 신발 신고 오세요',
      meetingAt: DateTime(2026, 9, 1, 20),
      latitude: 37.5,
      longitude: 127.0,
      region: region,
      placeName: placeName,
      maxParticipants: 10,
      status: CommunityPostStatus.recruiting,
      createdAt: DateTime(2026, 8, 1),
    );
  }
}

Widget _wrap(FakeCommunityChatRepository chatRepo, CommunityRepository repo) =>
    ProviderScope(
      overrides: [
        communityChatRepositoryProvider.overrideWithValue(chatRepo),
        communityRepositoryProvider.overrideWithValue(repo),
        currentUserIdProvider.overrideWithValue(2),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        child: MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CommunityChatMeetingInfoPage(postId: _postId),
        ),
      ),
    );

void main() {
  testWidgets('shows_meeting_time_place_headcount_and_body_from_the_post', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(FakeCommunityChatRepository(), _PostRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('서울특별시 광진구 군자동 · 어린이대공원 정문'), findsOneWidget);
    expect(find.text('20시에 정문에서 모여요. 편한 신발 신고 오세요'), findsOneWidget);
    // 인원은 채팅방 목록에서 온다 — 기본 가짜가 42번 방을 8명으로 준다.
    expect(find.text('현재 인원 8/10명'), findsOneWidget);
  });

  testWidgets('hides_place_row_when_reverse_geocoding_left_no_label', (
    tester,
  ) async {
    // 역지오코딩이 실패하고 장소명도 없으면 보여 줄 게 좌표뿐이다 — 사용자에게
    // 무의미하므로 행 자체를 숨긴다(상세 화면과 같은 판단).
    await tester.pumpWidget(
      _wrap(
        FakeCommunityChatRepository(),
        _PostRepository(region: null, placeName: null),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('20시에 정문에서 모여요. 편한 신발 신고 오세요'), findsOneWidget);
    expect(find.textContaining('어린이대공원'), findsNothing);
  });

  testWidgets('shows_dash_for_headcount_when_room_list_has_no_entry', (
    tester,
  ) async {
    // 방금 참여해 목록 캐시에 없는 방. "0/10명"은 아무도 안 모인 것으로 오독된다.
    final chatRepo = FakeCommunityChatRepository()..rooms = [];

    await tester.pumpWidget(_wrap(chatRepo, _PostRepository()));
    await tester.pumpAndSettle();

    expect(find.text('현재 인원 -/10명'), findsOneWidget);
  });

  testWidgets('does_not_offer_an_editor_because_the_server_stores_no_notice', (
    tester,
  ) async {
    // 방장이 쓰는 채팅방 공지는 서버에 저장할 곳이 없다 — 저장 안 되는 입력창을
    // 방장에게 보여주지 않는다.
    await tester.pumpWidget(
      _wrap(FakeCommunityChatRepository(), _PostRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });
}
