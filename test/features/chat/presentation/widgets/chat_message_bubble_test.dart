import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/features/chat/data/models/chat_message_dto.dart';
import 'package:cops_and_robbers/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessageDto _dto({String team = 'POLICE', int participantId = 3}) =>
    ChatMessageDto(
      id: 'm1',
      gameId: 1,
      sender: ChatSenderDto(
        participantId: participantId,
        nickname: '경찰이',
        team: team,
      ),
      message: '여기로 와',
      timestamp: '2026-08-24T17:34:00+09:00',
      scope: 'ALL',
    );

Widget _wrap(Widget child) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
);

Finder _bubbleWithColor(Color color) => find.byWidgetPredicate(
  (w) => w is Container && (w.decoration as BoxDecoration?)?.color == color,
);

void main() {
  group('ChatMessageBubble', () {
    testWidgets(
      'shows_nickname_time_and_white_bubble_when_other_in_light_mode',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ChatMessageBubble(message: _dto(), isMe: false, myTeam: 'POLICE'),
          ),
        );

        expect(find.text('경찰이'), findsOneWidget);
        // 시각은 단말 타임존으로 바뀌므로 DTO가 계산한 값과 비교한다
        expect(find.text(_dto().formattedTimeLocal), findsOneWidget);
        expect(find.text('여기로 와'), findsOneWidget);
        expect(_bubbleWithColor(AppColors.white), findsOneWidget);
      },
    );

    testWidgets('hides_nickname_and_time_when_flags_are_false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ChatMessageBubble(
            message: _dto(),
            isMe: true,
            myTeam: 'POLICE',
            showNickname: false,
            showTime: false,
          ),
        ),
      );

      expect(find.text('경찰이'), findsNothing);
      expect(find.text(_dto().formattedTimeLocal), findsNothing);
      expect(find.text('여기로 와'), findsOneWidget);
    });

    testWidgets('uses_black_bubble_when_dark_mode', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ChatMessageBubble(
            message: _dto(),
            isMe: false,
            myTeam: 'ROBBER',
            isDarkMode: true,
          ),
        ),
      );

      expect(_bubbleWithColor(AppColors.black), findsOneWidget);
    });

    testWidgets('renders_system_message_without_bubble_when_sender_is_system', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ChatMessageBubble(
            message: _dto(team: 'SYSTEM', participantId: 0),
            isMe: false,
            myTeam: 'POLICE',
          ),
        ),
      );

      // 시스템 메시지는 아이콘 span 파싱 때문에 RichText로 그린다 — 일반 find.text는 못 찾는다
      expect(find.text('여기로 와', findRichText: true), findsOneWidget);
      expect(_bubbleWithColor(AppColors.white), findsNothing);
    });
  });
}
