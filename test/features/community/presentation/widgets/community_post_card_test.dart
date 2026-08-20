import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_post_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CommunityPostEntity _post({
  CommunityPostStatus status = CommunityPostStatus.recruiting,
  String? placeName,
  String? region,
  int? currentParticipants,
  int? likeCount,
  int? bookmarkCount,
}) => CommunityPostEntity(
  id: 1,
  writerId: 7,
  title: '나랑 경도하자',
  content: '본문',
  meetingAt: DateTime(2026, 9, 10, 18, 0),
  latitude: 37.4979,
  longitude: 127.0276,
  maxParticipants: 10,
  status: status,
  createdAt: DateTime(2026, 9, 1),
  placeName: placeName,
  region: region,
  currentParticipants: currentParticipants,
  likeCount: likeCount,
  bookmarkCount: bookmarkCount,
);

/// 카드 안의 더보기 메뉴가 로그인 사용자 id를 watch 하므로 ProviderScope가 필요하다.
/// [currentUserId]로 내 글/남의 글/비로그인 분기를 바꿔 검증한다.
Widget _wrap(Widget child, {int? currentUserId}) => ProviderScope(
  overrides: [currentUserIdProvider.overrideWithValue(currentUserId)],
  child: ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, _) => MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  ),
);

void main() {
  group('CommunityPostCard', () {
    testWidgets('hides_location_row_when_no_place_or_region', (tester) async {
      // 지역·장소명이 둘 다 null인 글. 좌표 문자열은 사용자에게 무의미하므로
      // 행을 숨긴다.
      await tester.pumpWidget(
        _wrap(CommunityPostCard(onMenuAction: (_) {}, post: _post())),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(CommunityPostCard.locationRowKey), findsNothing);
    });

    testWidgets('shows_region_and_place_name_together_when_both_present', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CommunityPostCard(
            onMenuAction: (_) {},
            post: _post(
              region: '서울특별시 광진구 군자동',
              placeName: '세종대학교 정문',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('서울특별시 광진구 군자동 · 세종대학교 정문'), findsOneWidget);
      expect(find.byKey(CommunityPostCard.locationRowKey), findsOneWidget);
    });

    testWidgets('shows_capacity_only_when_current_headcount_is_unknown', (
      tester,
    ) async {
      // "0/10명"은 아무도 안 모인 것으로 오독된다.
      await tester.pumpWidget(
        _wrap(CommunityPostCard(onMenuAction: (_) {}, post: _post())),
      );
      await tester.pumpAndSettle();

      expect(find.text('정원 10명'), findsOneWidget);
      expect(find.text('0/10명'), findsNothing);
      // meetingAt: DateTime(2026, 9, 10) → weekday 4(목) 회귀 방지.
      expect(find.text('9/10 (목) 18:00'), findsOneWidget);
    });

    testWidgets('shows_current_over_max_when_headcount_is_known', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CommunityPostCard(
            onMenuAction: (_) {},
            post: _post(currentParticipants: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2/10명'), findsOneWidget);
    });

    testWidgets('renders_zero_counts_when_like_and_bookmark_are_unknown', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(CommunityPostCard(onMenuAction: (_) {}, post: _post())),
      );
      await tester.pumpAndSettle();

      // 좋아요·스크랩 자리는 지금부터 표시한다 (탭은 받지 않는다).
      expect(find.text('0'), findsNWidgets(2));
    });

    testWidgets('dims_content_when_post_is_completed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CommunityPostCard(
            onMenuAction: (_) {},
            post: _post(status: CommunityPostStatus.completed),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(
        find.byKey(CommunityPostCard.contentOpacityKey),
      );
      expect(opacity.opacity, 0.6);
    });

    testWidgets('keeps_content_fully_opaque_when_post_is_recruiting', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(CommunityPostCard(onMenuAction: (_) {}, post: _post())),
      );
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(
        find.byKey(CommunityPostCard.contentOpacityKey),
      );
      expect(opacity.opacity, 1.0);
    });

    testWidgets('shows_closed_label_when_post_is_completed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CommunityPostCard(
            onMenuAction: (_) {},
            post: _post(status: CommunityPostStatus.completed),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('마감'), findsOneWidget);
      expect(find.text('모집중'), findsNothing);
    });
  });
}
