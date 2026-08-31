import 'package:cops_and_robbers/features/community/presentation/widgets/community_chat_invite_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

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

Widget _card({required VoidCallback onJoin}) => CommunityChatInviteCard(
  nickname: '경도매우러버',
  roomTitle: '나랑 경도하자!!!!!',
  inviteCode: 'A1B2C3',
  onJoin: onJoin,
);

void main() {
  testWidgets('shows_invite_dialog_instead_of_joining_directly', (
    tester,
  ) async {
    var joined = 0;
    await tester.pumpWidget(_wrap(_card(onJoin: () => joined++)));

    await tester.tap(find.text('게임 참여'));
    await tester.pumpAndSettle();

    expect(joined, 0, reason: '탭 즉시 참가하지 않고 다이얼로그를 먼저 띄운다');
    expect(find.text('게임 초대장'), findsOneWidget);
    expect(find.text('방 코드'), findsOneWidget);
    expect(find.text('A1B2C3'), findsWidgets); // 카드 + 다이얼로그
  });

  testWidgets('joins_when_enter_is_tapped', (tester) async {
    var joined = 0;
    await tester.pumpWidget(_wrap(_card(onJoin: () => joined++)));

    await tester.tap(find.text('게임 참여'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('입장'));
    await tester.pumpAndSettle();

    expect(joined, 1);
    expect(find.text('게임 초대장'), findsNothing);
  });

  testWidgets('does_not_join_when_declined', (tester) async {
    var joined = 0;
    await tester.pumpWidget(_wrap(_card(onJoin: () => joined++)));

    await tester.tap(find.text('게임 참여'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('거절'));
    await tester.pumpAndSettle();

    expect(joined, 0);
    expect(find.text('게임 초대장'), findsNothing);
  });
}
