import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/notice/domain/entities/notice_entity.dart';
import 'package:cops_and_robbers/features/notice/presentation/widgets/notice_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// 번역 대체 안내의 노출 조건 검증.
///
/// 검증 대상 행동:
/// - 요청한 언어의 번역이 없어 서버가 대체한 공지를 펼치면 안내가 보인다
/// - 요청한 언어 그대로 내려온 공지에는 안내가 없다
/// - 접힌 상태에서는 안내를 띄우지 않는다 (목록이 안내로 뒤덮이지 않게)
void main() {
  final l10n = lookupAppLocalizations(const Locale('ko'));

  NoticeEntity notice({required bool isTranslationFallback}) => NoticeEntity(
    id: 1,
    title: '공지 제목',
    content: '공지 본문',
    pinned: false,
    createdAt: DateTime(2026, 8, 30),
    isTranslationFallback: isTranslationFallback,
  );

  Widget harness({required NoticeEntity item, required bool isExpanded}) {
    return ScreenUtilInit(
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
        home: Scaffold(
          body: NoticeCard(
            notice: item,
            isExpanded: isExpanded,
            onTap: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows_fallback_hint_when_expanded_notice_was_substituted', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(item: notice(isTranslationFallback: true), isExpanded: true),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.noticeTranslationFallback), findsOneWidget);
  });

  testWidgets('hides_fallback_hint_when_requested_language_was_served', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(item: notice(isTranslationFallback: false), isExpanded: true),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.noticeTranslationFallback), findsNothing);
  });

  testWidgets('hides_fallback_hint_when_card_is_collapsed', (tester) async {
    // ja/en 번역이 채워지기 전에는 거의 모든 공지가 대체된다. 헤더에 띄우면
    // 목록 전체가 안내로 덮이므로, 본문을 펼쳤을 때만 보여준다.
    await tester.pumpWidget(
      harness(item: notice(isTranslationFallback: true), isExpanded: false),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.noticeTranslationFallback), findsNothing);
    expect(find.text('공지 본문'), findsNothing);
  });
}
