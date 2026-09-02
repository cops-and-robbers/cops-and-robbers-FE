import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_notification_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_notification_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

CommunityNotificationEntity _notification({
  CommunityNotificationType type = CommunityNotificationType.comment,
  bool read = false,
  DateTime? createdAt,
}) => CommunityNotificationEntity(
  id: 1,
  type: type,
  communityPostId: 7,
  postTitle: '퇴근하고 한 판! 초보 환영~',
  content: '저녁 9시도 하시나요?',
  read: read,
  createdAt: createdAt ?? DateTime.now(),
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
  testWidgets('shows_unread_background_when_notification_is_unread', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CommunityNotificationCard(
          notification: _notification(read: false),
          onTap: () {},
        ),
      ),
    );

    // 카드 안의 첫 Container(배경)로 좁힌다 — 트리에 Container가 하나 더 생기면
    // find.byType(Container) 단독은 "Too many elements"로 깨진다.
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(CommunityNotificationCard),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.blueVer2_70);
  });

  testWidgets('shows_white_background_when_notification_is_read', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CommunityNotificationCard(
          notification: _notification(read: true),
          onTap: () {},
        ),
      ),
    );

    // 카드 안의 첫 Container(배경)로 좁힌다 — 트리에 Container가 하나 더 생기면
    // find.byType(Container) 단독은 "Too many elements"로 깨진다.
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(CommunityNotificationCard),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.white);
  });

  testWidgets('shows_reply_label_when_notification_type_is_reply', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CommunityNotificationCard(
          notification: _notification(type: CommunityNotificationType.reply),
          onTap: () {},
        ),
      ),
    );

    expect(find.textContaining('새 대댓글'), findsOneWidget);
    expect(find.textContaining('새 댓글'), findsNothing);
  });

  testWidgets('invokes_on_tap_callback_when_card_is_tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        CommunityNotificationCard(
          notification: _notification(),
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(CommunityNotificationCard));

    expect(tapped, isTrue);
  });
}
