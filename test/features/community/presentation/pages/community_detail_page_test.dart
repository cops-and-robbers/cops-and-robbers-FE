import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_comment_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_comment_repository.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_reaction_repository.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_detail_page.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_comment_list.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_post_menu.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_fakes.dart';

const _postId = 7;

const _region = '서울특별시 광진구 화양동';
const _placeName = '어린이대공원 정문';

/// 화면에 보이는 라벨 — `region · placeName`.
const _label = '$_region · $_placeName';

/// 복사돼야 하는 값 — 번지까지 붙은 지번 주소.
const _lotAddress = '서울특별시 광진구 화양동 164-2';

CommunityPostEntity _post({
  String? address,
  String? region = _region,
  CommunityPostStatus status = CommunityPostStatus.recruiting,
  int likeCount = 0,
  bool isLiked = false,
}) => CommunityPostEntity(
  id: _postId,
  writerId: 1,
  title: '같이 하실 분',
  content: '본문',
  meetingAt: DateTime(2026, 9, 10, 18),
  latitude: 37.5502,
  longitude: 127.0736,
  maxParticipants: 10,
  status: status,
  createdAt: DateTime(2026, 8, 20),
  region: region,
  placeName: _placeName,
  address: address,
  likeCount: likeCount,
  isLiked: isLiked,
  scrapCount: 0,
  isScrapped: false,
);

/// 본문 조회와 작성자 동작(마감·삭제)에 응답하는 Repository.
///
/// [getFailure]·[writeFailure]로 서버 거절을 주입한다 — 다른 사용자가 먼저 글을
/// 지운 상황(404 `POST_NOT_FOUND`)을 재현하는 통로다.
class _DetailRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs {
  _DetailRepository(this.post, {this.getFailure, this.writeFailure});

  final CommunityPostEntity post;
  final AppException? getFailure;
  final AppException? writeFailure;

  @override
  Future<CommunityPostEntity> getPost(int postId) async {
    if (getFailure != null) throw getFailure!;
    return post;
  }

  @override
  Future<CommunityPostEntity> updateStatus({
    required int postId,
    required CommunityPostStatus status,
  }) async {
    if (writeFailure != null) throw writeFailure!;
    return post.copyWith(status: status);
  }

  @override
  Future<void> deletePost(int postId) async {
    if (writeFailure != null) throw writeFailure!;
  }
}

/// 남이 이미 지운 글을 만졌을 때 서버가 주는 응답 (404 `POST_NOT_FOUND`).
const _gone = ServerException(
  message: 'not found',
  messageKey: 'errorTemporaryRetry',
  code: 'POST_NOT_FOUND',
);

Widget _wrap(_DetailRepository repo) =>
    _app(repo, const CommunityDetailPage(postId: _postId));

/// 상세를 push로 열어, 사라진 글을 만났을 때 실제로 닫히는지 볼 수 있게
/// 아래에 목록 자리를 하나 깔아 둔다.
Widget _wrapPushedDetail(_DetailRepository repo) => _app(
  repo,
  Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CommunityDetailPage(postId: _postId),
            ),
          ),
          child: const Text('상세 열기'),
        ),
      ),
    ),
  ),
);

/// 댓글은 실서버로 옮겨 갔다. 덮지 않으면 Retrofit이 실제 Dio를 타므로,
/// 이 화면과 무관한 이유로 깨진다. 예전 메모리 목이 심던 것과 같은 모양
/// (원댓글 + 답글 한 겹)을 돌려줘 답글 모드 테스트가 그대로 성립하게 한다.
class _FakeCommentRepository implements CommunityCommentRepository {
  List<CommunityCommentEntity> comments = [
    CommunityCommentEntity(
      id: 1,
      writerId: 101,
      writerNickname: '날쌘도둑',
      writerProfileIconId: 2,
      content: '저 참여하고 싶어요! 초보도 괜찮나요?',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      replies: [
        CommunityCommentEntity(
          id: 2,
          parentId: 1,
          writerId: 7,
          writerNickname: '무서운경찰관',
          writerProfileIconId: 1,
          content: '그럼요, 규칙은 현장에서 알려드려요',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
  ];

  @override
  Future<List<CommunityCommentEntity>> getComments(int postId) async =>
      comments;

  @override
  Future<CommunityCommentEntity> addComment({
    required int postId,
    required String content,
    int? parentId,
  }) async => CommunityCommentEntity(
    id: 999,
    parentId: parentId,
    writerId: 1,
    writerNickname: '나',
    writerProfileIconId: 1,
    content: content,
    createdAt: DateTime.now(),
  );

  @override
  Future<void> deleteComment(int commentId) async {
    comments = const [];
  }
}

/// 좋아요·스크랩 반응 Repository. [error]가 있으면 매번 그 예외를 던진다 —
/// 롤백 테스트가 서버 거절을 재현하는 통로다.
class _FakeReactionRepository implements CommunityReactionRepository {
  _FakeReactionRepository({this.error});

  final AppException? error;

  @override
  Future<void> like(int postId) => _respond();

  @override
  Future<void> unlike(int postId) => _respond();

  @override
  Future<void> scrap(int postId) => _respond();

  @override
  Future<void> unscrap(int postId) => _respond();

  Future<void> _respond() async {
    if (error == null) return;
    // 실패만 한 틱 늦춘다. 지연 없이 즉시 던지면 낙관적 갱신과 롤백이 같은
    // 마이크로태스크 틱에 몰려 처리돼, 첫 pump()에서 이미 롤백까지 끝난 상태가
    // 그려진다 — "뒤집혔다 돌아옴"과 "애초에 안 뒤집힘"을 테스트가 구분할 수
    // 없게 된다. 성공 경로까지 늦추면 되돌릴 상태가 없어 의미도 없을뿐더러,
    // pump() 한 번으로 끝나고 settle하지 않는 성공 테스트에 이 타이머가 그대로
    // 남아 "A Timer is still pending"으로 깨진다.
    await Future<void>.delayed(const Duration(milliseconds: 1));
    throw error!;
  }
}

Widget _app(
  _DetailRepository repo,
  Widget home, {
  AppException? reactionError,
}) => ProviderScope(
  overrides: [
    communityRepositoryProvider.overrideWithValue(repo),
    communityCommentRepositoryProvider.overrideWithValue(
      _FakeCommentRepository(),
    ),
    communityReactionRepositoryProvider.overrideWithValue(
      _FakeReactionRepository(error: reactionError),
    ),
    // 더보기 메뉴가 로그인 사용자 id를 watch 한다. 덮지 않으면 실제 AuthNotifier가
    // Firebase까지 끌고 들어와, 이 화면과 무관한 이유로 깨진다.
    currentUserIdProvider.overrideWithValue(1),
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
      home: home,
    ),
  ),
);

/// 복사 스낵바가 스스로 사라질 때까지 기다린다.
///
/// 3초 타이머를 남긴 채 테스트가 끝나면 "A Timer is still pending"으로 깨진다 —
/// 스낵바는 Overlay라 화면 dispose로는 정리되지 않는다.
Future<void> _letSnackbarExpire(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// 상세를 띄우고 초기 로딩이 끝날 때까지 기다린다.
Future<void> _pumpDetail(
  WidgetTester tester, {
  required CommunityPostEntity post,
  AppException? reactionError,
}) async {
  await tester.pumpWidget(
    _app(
      _DetailRepository(post),
      const CommunityDetailPage(postId: _postId),
      reactionError: reactionError,
    ),
  );
  await tester.pumpAndSettle();
}

/// 상세를 띄우고 [label]이 적힌 장소 행을 탭한다.
Future<void> _tapLocation(
  WidgetTester tester,
  _DetailRepository repo, {
  String label = _label,
}) async {
  await tester.pumpWidget(_wrap(repo));
  await tester.pumpAndSettle();

  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  await _letSnackbarExpire(tester);
}

void main() {
  /// 클립보드는 플랫폼 채널이라 테스트에서 실물이 없다. 담긴 값을 보려면
  /// 채널을 가로채는 수밖에 없다.
  late List<String> copied;

  setUp(() {
    copied = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('CommunityDetailPage 장소 복사', () {
    testWidgets('copies_lot_address_not_the_displayed_label_when_tapped', (
      tester,
    ) async {
      final repo = _DetailRepository(_post(address: _lotAddress));

      await _tapLocation(tester, repo);

      // 화면에 보이는 건 동 단위 라벨, 담기는 건 번지까지 붙은 주소다.
      expect(find.text(_label), findsOneWidget);
      expect(copied, [_lotAddress]);
    });

    testWidgets('copies_region_only_when_server_omits_the_lot_address', (
      tester,
    ) async {
      // 백엔드가 아직 address를 안 싣는 동안의 동작. 장소명은 빼고 지역만 담는다 —
      // "화양동 · 어린이대공원 정문"을 지도 앱에 붙여넣으면 검색이 깨진다.
      final repo = _DetailRepository(_post());

      await _tapLocation(tester, repo);

      expect(copied, [_region]);
    });

    testWidgets('copies_place_name_when_reverse_geocoding_left_no_region', (
      tester,
    ) async {
      final repo = _DetailRepository(_post(region: null));

      await _tapLocation(tester, repo, label: _placeName);

      expect(copied, [_placeName]);
    });
  });

  group('CommunityDetailPage 사라진 글', () {
    testWidgets('shows_deleted_notice_without_retry_when_the_post_is_gone', (
      tester,
    ) async {
      // 남이 먼저 지운 글의 링크로 들어온 경우. "다시 시도"는 몇 번을 눌러도
      // 404라 사용자를 화면에 가둔다 — 나가는 길을 줘야 한다.
      await tester.pumpWidget(
        _wrap(_DetailRepository(_post(), getFailure: _gone)),
      );
      await tester.pumpAndSettle();

      expect(find.text('이미 삭제된 모집글이에요'), findsOneWidget);
      expect(find.text('다시 시도'), findsNothing);
      expect(find.text('목록으로 돌아가기'), findsOneWidget);
      // 사라진 글에는 손댈 메뉴가 없다.
      expect(find.byType(CommunityPostMenu), findsNothing);
    });

    testWidgets('leaves_the_detail_when_marking_completed_finds_it_gone', (
      tester,
    ) async {
      // 상세를 보고 있는 사이 작성자가 글을 지운 경우. 알리기만 하고 화면에
      // 남겨 두면 무엇을 눌러도 실패하는 유령 화면이 된다.
      await tester.pumpWidget(
        _wrapPushedDetail(_DetailRepository(_post(), writeFailure: _gone)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('상세 열기'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CommunityPostMenu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('마감하기'));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityDetailPage), findsNothing);
      expect(find.text('이미 삭제된 모집글이에요'), findsOneWidget);

      await _letSnackbarExpire(tester);
    });
  });

  group('CommunityDetailPage 종료 상태', () {
    testWidgets('hides_status_toggle_in_detail_menu_when_post_is_ended', (
      tester,
    ) async {
      // 종료 글은 상태를 바꿔도 서버가 조회 시 다시 ENDED로 판정한다 — 메뉴
      // 자체에서 상태 변경 항목을 감춰야 눌러도 아무 일 없는 버그처럼 보이지 않는다.
      await tester.pumpWidget(
        _wrapPushedDetail(
          _DetailRepository(_post(status: CommunityPostStatus.ended)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('상세 열기'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CommunityPostMenu));
      await tester.pumpAndSettle();

      // 수정·삭제는 그대로, 상태 변경(마감하기/다시 모집하기)만 사라진다.
      expect(find.text('수정하기'), findsOneWidget);
      expect(find.text('삭제하기'), findsOneWidget);
      expect(find.text('마감하기'), findsNothing);
      expect(find.text('다시 모집하기'), findsNothing);
    });
  });

  group('CommunityDetailPage 답글 모드', () {
    /// 첫 댓글의 답글(말풍선) 버튼을 누른다.
    ///
    /// 댓글은 화면 한참 아래라 그냥 tap하면 좌표가 뷰포트 밖이라 빗나간다.
    Future<void> tapReply(WidgetTester tester) async {
      final button = find.byKey(CommunityCommentList.replyButtonKey).first;
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('marks_reply_mode_without_a_banner_when_reply_is_tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_DetailRepository(_post())));
      await tester.pumpAndSettle();

      await tapReply(tester);

      // 안내 배너 없이 힌트 문구와 대상 댓글 하이라이트로만 알린다 — 배너는
      // 입력창 위 한 줄을 늘 차지해 정작 댓글을 밀어냈다.
      expect(find.text('답글을 남겨보세요'), findsOneWidget);
      expect(find.textContaining('답글 남기는 중'), findsNothing);
    });

    testWidgets('clears_the_reply_target_when_the_body_is_tapped', (
      tester,
    ) async {
      // 배너의 ×를 없앴으니 빠져나갈 길이 있어야 한다 — 본문 빈 곳을 누르면
      // 풀린다.
      await tester.pumpWidget(_wrap(_DetailRepository(_post())));
      await tester.pumpAndSettle();

      await tapReply(tester);
      expect(find.text('답글을 남겨보세요'), findsOneWidget);

      // 글 본문 — 아무 동작도 걸려 있지 않은 영역이다. 답글 버튼을 누르느라
      // 아래로 스크롤한 상태라 다시 올려야 좌표가 뷰포트 안에 든다.
      await tester.ensureVisible(find.text('본문'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('본문'));
      await tester.pumpAndSettle();

      expect(find.text('댓글을 남겨보세요'), findsOneWidget);
      expect(find.text('답글을 남겨보세요'), findsNothing);
    });

    testWidgets('drops_the_keyboard_when_the_body_is_tapped', (tester) async {
      // 답글 달기는 입력창에 포커스를 준다. 본문을 눌러 빠져나올 때 키보드가
      // 남아 있으면 화면 절반이 가려진 채로 글을 읽게 된다.
      await tester.pumpWidget(_wrap(_DetailRepository(_post())));
      await tester.pumpAndSettle();

      await tapReply(tester);
      expect(_commentFieldHasFocus(tester), isTrue);

      await tester.ensureVisible(find.text('본문'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('본문'));
      await tester.pumpAndSettle();

      expect(_commentFieldHasFocus(tester), isFalse);
    });
  });

  group('CommunityDetailPage 좋아요', () {
    testWidgets('flips_the_heart_before_the_server_answers', (tester) async {
      // 낙관적 갱신 — 응답을 기다리지 않고 먼저 뒤집는다.
      await _pumpDetail(tester, post: _post(likeCount: 6, isLiked: false));

      await tester.tap(find.byKey(const Key('community_detail_like')));
      await tester.pump();

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('rolls_the_heart_back_when_the_server_rejects', (tester) async {
      await _pumpDetail(
        tester,
        post: _post(likeCount: 6, isLiked: false),
        reactionError: ServerException(message: 'x', messageKey: 'y'),
      );

      await tester.tap(find.byKey(const Key('community_detail_like')));
      await tester.pump();

      // 뒤집혔다가 돌아오는지 확인하려면 뒤집힌 중간 상태부터 잡아야 한다 —
      // 안 그러면 "애초에 안 뒤집힘"과 구분이 안 된다.
      expect(find.text('7'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('6'), findsOneWidget);

      // 실패는 스낵바로도 알린다 — 3초 타이머가 남은 채 테스트가 끝나면
      // "A Timer is still pending"으로 깨진다 (위 _letSnackbarExpire 참고).
      await _letSnackbarExpire(tester);
    });
  });
}

/// 댓글 입력창이 포커스를 쥐고 있는지 — 키보드가 떠 있는지를 이걸로 읽는다.
bool _commentFieldHasFocus(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus;
