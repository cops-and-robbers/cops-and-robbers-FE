import 'dart:async';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/user/data/datasources/user_remote_datasource.dart';
import 'package:cops_and_robbers/features/user/data/models/my_page_response_model.dart';
import 'package:cops_and_robbers/features/user/data/models/profile_icon_update_request_model.dart';
import 'package:cops_and_robbers/features/user/presentation/providers/profile_icon_provider.dart';
import 'package:cops_and_robbers/features/user/presentation/providers/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kMyUserId = 1;
const _kMyStorageKey = 'profile_icon_id_$_kMyUserId';

/// 시스템 경계(HTTP)만 대역으로 세운다 — Repository·Notifier는 진짜 코드가 돈다.
class _FakeUserRemoteDataSource implements UserRemoteDataSource {
  _FakeUserRemoteDataSource({
    this.serverIcon = kDefaultProfileIconId,
    this.myPageGate,
  });

  final int serverIcon;

  /// 서버 응답이 언제 도착할지 테스트가 직접 정할 때 쓴다.
  /// 실제 지연(`Future.delayed`)을 쓰면 이벤트 큐를 몇 번 돌리느냐에 결과가 걸려
  /// 응답이 아예 도착하지 않는 채로 통과해 버린다.
  final Completer<void>? myPageGate;

  ProfileIconUpdateRequestModel? lastProfileIconRequest;
  Object? updateErrorToThrow;
  Object? myPageErrorToThrow;

  @override
  Future<MyPageResponseModel> getMyPage() async {
    if (myPageGate != null) await myPageGate!.future;
    if (myPageErrorToThrow != null) throw myPageErrorToThrow!;
    return MyPageResponseModel(
      userId: _kMyUserId,
      nickname: '홍길동',
      socialPlatform: 'GOOGLE',
      allowGamePush: true,
      allowMarketingPush: false,
      profileIcon: serverIcon,
    );
  }

  @override
  Future<void> updateProfileIcon(ProfileIconUpdateRequestModel request) async {
    lastProfileIconRequest = request;
    if (updateErrorToThrow != null) throw updateErrorToThrow!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/api/user/me/profile-icon'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/user/me/profile-icon'),
    statusCode: statusCode,
    data: {
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': '/api/user/me/profile-icon',
    },
  ),
  type: DioExceptionType.badResponse,
);

ProviderContainer _containerWith(
  _FakeUserRemoteDataSource fake, {
  int? userId = _kMyUserId,
}) {
  final container = ProviderContainer(
    overrides: [
      userRemoteDataSourceProvider.overrideWithValue(fake),
      currentUserIdProvider.overrideWithValue(userId),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('profileIconAsset', () {
    test('maps_known_icon_id_to_its_asset', () {
      expect(profileIconAsset(2), 'assets/profiles/2.svg');
    });

    // 서버는 아이콘 번호 상한을 검증하지 않는다 (DEC-0040). 게시글·댓글 작성자
    // 아이콘도 이 함수를 지나므로, 앱에 없는 번호가 오면 여기서 막아야 한다.
    test('falls_back_to_default_asset_when_icon_id_has_no_asset', () {
      expect(profileIconAsset(99), 'assets/profiles/1.svg');
    });
  });

  test('returns_default_icon_when_nothing_stored', () {
    SharedPreferences.setMockInitialValues({});
    final container = _containerWith(_FakeUserRemoteDataSource());

    expect(container.read(profileIconProvider), kDefaultProfileIconId);
  });

  test('persists_selected_icon_to_storage', () async {
    SharedPreferences.setMockInitialValues({});
    final container = _containerWith(_FakeUserRemoteDataSource());

    await container.read(profileIconProvider.notifier).select(2);

    expect(container.read(profileIconProvider), 2);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(_kMyStorageKey), 2);
  });

  test('ignores_selection_of_unknown_icon_id', () async {
    SharedPreferences.setMockInitialValues({});
    final container = _containerWith(_FakeUserRemoteDataSource());

    await container.read(profileIconProvider.notifier).select(99);

    expect(container.read(profileIconProvider), kDefaultProfileIconId);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(_kMyStorageKey), isNull);
  });

  test('adopts_server_icon_over_cached_icon', () async {
    SharedPreferences.setMockInitialValues({_kMyStorageKey: 1});
    final container = _containerWith(_FakeUserRemoteDataSource(serverIcon: 2));

    container.read(profileIconProvider);
    await pumpEventQueue();

    expect(container.read(profileIconProvider), 2);
    // 캐시에도 되써야 다음 콜드 스타트에서 낡은 아이콘이 번쩍이지 않는다.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(_kMyStorageKey), 2);
  });

  test('keeps_cached_icon_when_server_lookup_fails', () async {
    SharedPreferences.setMockInitialValues({_kMyStorageKey: 2});
    final container = _containerWith(
      _FakeUserRemoteDataSource()..myPageErrorToThrow = _dioError(500),
    );

    container.read(profileIconProvider);
    await pumpEventQueue();

    expect(container.read(profileIconProvider), 2);
  });

  // 서버는 아이콘 번호 상한을 검증하지 않는다 (DEC-0040). 앱에 없는 번호를
  // 상태로 들이면 그 값이 그대로 다시 저장될 수 있다.
  test('keeps_default_when_server_icon_has_no_asset', () async {
    SharedPreferences.setMockInitialValues({});
    final container = _containerWith(_FakeUserRemoteDataSource(serverIcon: 99));

    container.read(profileIconProvider);
    await pumpEventQueue();

    expect(container.read(profileIconProvider), kDefaultProfileIconId);
  });

  // 앱을 끄지 않고 계정을 바꾸면 이전 사용자의 캐시가 그대로 보였고, 그 상태에서
  // 아이콘을 누르면 남의 번호가 내 계정에 저장됐다. 캐시를 사용자별로 나눠 막는다.
  test('does_not_read_another_users_cached_icon', () async {
    SharedPreferences.setMockInitialValues({
      'profile_icon_id_2': 2, // 다른 계정의 캐시
      'profile_icon_id': 2, // 사용자별로 나누기 전에 쓰던 공용 키
    });
    // 서버 조회를 죽여 캐시 경로만 결과를 정하게 한다 — 서버가 값을 채워 주면
    // 캐시를 잘못 읽어도 결과가 같아져 이 테스트가 아무것도 못 잡는다.
    final container = _containerWith(
      _FakeUserRemoteDataSource()..myPageErrorToThrow = _dioError(500),
    );

    container.read(profileIconProvider);
    await pumpEventQueue();

    expect(container.read(profileIconProvider), kDefaultProfileIconId);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('profile_icon_id_2'), 2, reason: '남의 캐시는 건드리지 않는다');
  });

  test('does_not_touch_server_when_logged_out', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeUserRemoteDataSource(serverIcon: 2);
    final container = _containerWith(fake, userId: null);

    container.read(profileIconProvider);
    await pumpEventQueue();
    await container.read(profileIconProvider.notifier).select(2);

    expect(container.read(profileIconProvider), kDefaultProfileIconId);
    expect(fake.lastProfileIconRequest, isNull);
  });

  // 화면 진입 직후에 아이콘을 누르면 아직 돌던 서버 조회가 나중에 끝난다.
  // 그 응답이 사용자의 선택을 덮으면 방금 고른 아이콘이 조용히 되돌아간다.
  test('keeps_user_selection_when_server_lookup_lands_late', () async {
    SharedPreferences.setMockInitialValues({});
    final gate = Completer<void>();
    final container = _containerWith(
      _FakeUserRemoteDataSource(serverIcon: 1, myPageGate: gate),
    );
    container.read(profileIconProvider);
    await pumpEventQueue(); // 조회가 게이트 앞에서 멈춰 있게 한다

    await container.read(profileIconProvider.notifier).select(2);
    gate.complete(); // 이제서야 서버 응답이 도착한다
    await pumpEventQueue();

    expect(container.read(profileIconProvider), 2);
  });

  test('sends_selected_icon_to_server', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeUserRemoteDataSource();
    final container = _containerWith(fake);

    await container.read(profileIconProvider.notifier).select(2);

    expect(fake.lastProfileIconRequest?.profileIcon, 2);
  });

  test('reverts_to_previous_icon_when_server_rejects_selection', () async {
    SharedPreferences.setMockInitialValues({_kMyStorageKey: 1});
    final fake = _FakeUserRemoteDataSource()
      ..updateErrorToThrow = _dioError(400);
    final container = _containerWith(fake);
    container.read(profileIconProvider);
    await pumpEventQueue();

    // 마이페이지는 AppException 여부로 서버 사유와 일반 안내를 갈라 쓴다.
    // 원본 DioException이 새어 나가면 사용자는 조용히 일반 문구만 보게 된다.
    await expectLater(
      container.read(profileIconProvider.notifier).select(2),
      throwsA(isA<AppException>()),
    );

    expect(container.read(profileIconProvider), 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(_kMyStorageKey), 1);
  });
}
