import 'package:cops_and_robbers/core/widgets/buttons/app_button.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_chat_meeting_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

CommunityPostEntity _post() => CommunityPostEntity(
  id: 1,
  writerId: 7,
  title: '퇴근하고 한 판! 초보 환영~',
  content: '본문',
  meetingAt: DateTime(2026, 9, 10, 18, 0),
  latitude: 37.4979,
  longitude: 127.0276,
  maxParticipants: 10,
  status: CommunityPostStatus.recruiting,
  createdAt: DateTime(2026, 9, 1),
  likeCount: 0,
  isLiked: false,
  scrapCount: 0,
  isScrapped: false,
);

Widget _wrap(Widget child) => ScreenUtilInit(
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
);

void main() {
  testWidgets('hides_start_game_button_when_onStartGame_is_null', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CommunityChatMeetingCard(
          post: _post(),
          memberCount: 3,
          onViewLocation: () {},
          onOpenMeetingInfo: () {},
        ),
      ),
    );

    expect(find.text('게임 시작'), findsNothing);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('shows_start_game_button_and_taps_through', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _wrap(
        CommunityChatMeetingCard(
          post: _post(),
          memberCount: 3,
          onViewLocation: () {},
          onOpenMeetingInfo: () {},
          onStartGame: () => tapped++,
        ),
      ),
    );

    expect(find.text('게임 시작'), findsOneWidget);
    await tester.tap(find.text('게임 시작'));
    expect(tapped, 1);
  });
}
