import 'dart:async';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/user/data/datasources/user_remote_datasource.dart';
import 'package:cops_and_robbers/features/user/data/models/community_push_agreement_model.dart';
import 'package:cops_and_robbers/features/user/presentation/providers/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시스템 경계(HTTP)만 대역으로 세운다 — Repository·Notifier는 진짜 코드가 돈다.
class _FakeUserRemoteDataSource implements UserRemoteDataSource {
  _FakeUserRemoteDataSource({this.serverValue = true});

  final bool serverValue;

  /// 업데이트 응답이 언제 도착할지 테스트가 정한다 — "응답 전에 뒤집혔는지"를
  /// 보려면 응답을 붙들고 있어야 한다.
  final updateGate = Completer<void>();
  CommunityPushAgreementRequestModel? lastRequest;

  @override
  Future<CommunityPushAgreementResponseModel> getCommunityPushAgreement() async =>
      CommunityPushAgreementResponseModel(allowCommunityPush: serverValue);

  @override
  Future<void> updateCommunityPushAgreement(
    CommunityPushAgreementRequestModel request,
  ) async {
    lastRequest = request;
    await updateGate.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/api/user/agreements/community-push'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/user/agreements/community-push'),
    statusCode: statusCode,
    data: {
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': '/api/user/agreements/community-push',
    },
  ),
  type: DioExceptionType.badResponse,
);

ProviderContainer _container(_FakeUserRemoteDataSource fake) {
  final container = ProviderContainer(
    overrides: [userRemoteDataSourceProvider.overrideWithValue(fake)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('서버가 준 동의 여부로 시작한다', () async {
    final container = _container(_FakeUserRemoteDataSource(serverValue: false));

    expect(await container.read(communityPushNotifierProvider.future), isFalse);
  });

  test('토글하면 서버 응답 전에 먼저 뒤집히고, 뒤집힌 값을 보낸다', () async {
    final fake = _FakeUserRemoteDataSource(serverValue: true);
    final container = _container(fake);
    await container.read(communityPushNotifierProvider.future);

    final pending = container
        .read(communityPushNotifierProvider.notifier)
        .toggle();

    expect(container.read(communityPushNotifierProvider).valueOrNull, isFalse);
    expect(fake.lastRequest?.allowCommunityPush, isFalse);

    fake.updateGate.complete();
    await pending;

    expect(container.read(communityPushNotifierProvider).valueOrNull, isFalse);
  });

  test('서버가 거절하면 원래 값으로 돌아오고 예외를 다시 던진다', () async {
    final fake = _FakeUserRemoteDataSource(serverValue: true);
    final container = _container(fake);
    await container.read(communityPushNotifierProvider.future);

    final pending = container
        .read(communityPushNotifierProvider.notifier)
        .toggle();
    expect(container.read(communityPushNotifierProvider).valueOrNull, isFalse);

    fake.updateGate.completeError(_dioError(400));

    await expectLater(pending, throwsA(isA<AppException>()));
    expect(container.read(communityPushNotifierProvider).valueOrNull, isTrue);
  });
}
