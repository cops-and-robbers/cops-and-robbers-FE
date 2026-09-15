import 'dart:async';

import 'package:cops_and_robbers/core/network/dio_client.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_feed_list.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_native_ad.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final fails in [false, true]) {
    testWidgets(
      'sort_menu_allows_reselection_when_popular_is_${fails ? 'failed' : 'empty'}',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final response = Completer<void>();
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
        addTearDown(() => dio.close(force: true));
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              if (options.queryParameters['sort'] == 'POPULAR') {
                await response.future;
                if (fails) {
                  handler.reject(
                    DioException(
                      requestOptions: options,
                      type: DioExceptionType.connectionError,
                    ),
                  );
                  return;
                }
              }
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'content': <Object>[],
                    'cursor': {'nextCursor': null, 'hasNext': false},
                  },
                ),
              );
            },
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              dioProvider.overrideWithValue(dio),
              communityCountryCodeProvider.overrideWith((ref) async => 'KR'),
            ],
            child: ScreenUtilInit(
              designSize: const Size(393, 852),
              builder: (_, _) => MaterialApp(
                locale: const Locale('ko'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: Consumer(
                    builder: (context, ref, _) {
                      return CommunityFeedList(
                        scope: CommunityScope.all,
                        sort: ref.watch(selectedCommunitySortProvider),
                        showAds: true,
                        emptyMessage: 'empty feed',
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('empty feed'), findsOneWidget);
        await tester.tap(find.text('최신순'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('인기순'));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        expect(find.text('인기순').hitTestable(), findsOneWidget);

        response.complete();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('empty feed'), fails ? findsNothing : findsOneWidget);
        if (!fails) {
          expect(
            find.byType(CommunityNativeAd, skipOffstage: false),
            findsOneWidget,
          );
        }
        expect(find.text('인기순').hitTestable(), findsOneWidget);
        await tester.tap(find.text('인기순'));
        await tester.pumpAndSettle();
        expect(find.text('거리순'), findsOneWidget);
        expect(find.text('마감 임박순'), findsOneWidget);
        await tester.tap(find.text('최신순'));
        await tester.pumpAndSettle();
        expect(find.text('최신순').hitTestable(), findsOneWidget);
        expect(find.text('empty feed'), findsOneWidget);
      },
    );
  }
}
