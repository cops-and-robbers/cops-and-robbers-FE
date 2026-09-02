import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/services/lifecycle/lifecycle_provider.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_notice_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_chat_notice_edit_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';

const _postId = 42;

final _notice = CommunityChatNoticeEntity(
  id: 9,
  writerId: 7,
  writerNickname: '경도매우러버',
  writerProfileIcon: 3,
  content: '기존 공지',
  createdAt: DateTime(2026, 9, 19, 13, 24),
  updatedAt: DateTime(2026, 9, 19, 13, 24),
);

Widget _wrap(FakeCommunityChatRepository repo, {String? initialContent}) =>
    ProviderScope(
      overrides: [
        communityChatRepositoryProvider.overrideWithValue(repo),
        currentUserIdProvider.overrideWithValue(7),
        lifecycleStateProvider.overrideWith(
          (ref) => const Stream<AppLifecycleState>.empty(),
        ),
      ],
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
          home: CommunityChatNoticeEditPage(
            postId: _postId,
            initialContent: initialContent,
          ),
        ),
      ),
    );

/// 완료 글자색이 활성 여부다 — 비활성이면 `black200`.
Color _doneColor(WidgetTester tester) =>
    tester.widget<Text>(find.text('완료')).style!.color!;

void main() {
  group('CommunityChatNoticeEditPage', () {
    testWidgets('keeps_done_disabled_until_content_is_typed', (tester) async {
      final repo = FakeCommunityChatRepository();

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(_doneColor(tester), AppColors.black200);

      await tester.enterText(find.byType(TextField), '뒷풀이 있습니다');
      await tester.pump();

      expect(_doneColor(tester), AppColors.logo);
    });

    testWidgets('keeps_done_disabled_when_only_whitespace_is_typed', (
      tester,
    ) async {
      // 공백만 저장하면 서버는 받아 주지만 방에는 빈 배너가 걸린다.
      final repo = FakeCommunityChatRepository();

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      expect(_doneColor(tester), AppColors.black200);
    });

    testWidgets('registers_a_new_notice_when_opened_without_content', (
      tester,
    ) async {
      final repo = FakeCommunityChatRepository();

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '뒷풀이 있습니다');
      await tester.pump();
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      expect(repo.calls, contains('registerNotice:$_postId'));
      expect(repo.notice?.content, '뒷풀이 있습니다');
    });

    testWidgets('edits_the_existing_notice_when_opened_with_content', (
      tester,
    ) async {
      // 없는 공지에 PUT을 보내면 404 CHAT_PIN_NOT_FOUND다 — 두 경로가 갈린다.
      final repo = FakeCommunityChatRepository()..notice = _notice;

      await tester.pumpWidget(_wrap(repo, initialContent: '기존 공지'));
      await tester.pumpAndSettle();

      expect(find.text('기존 공지'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '장소가 후문으로 바뀌었어요');
      await tester.pump();
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      expect(repo.calls, contains('updateNotice:$_postId'));
      expect(repo.calls, isNot(contains('registerNotice:$_postId')));
    });
  });
}
