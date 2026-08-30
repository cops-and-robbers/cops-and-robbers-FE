import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/user/data/datasources/user_remote_datasource.dart';
import 'package:cops_and_robbers/features/user/data/models/community_push_agreement_model.dart';
import 'package:cops_and_robbers/features/user/data/repositories/user_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시스템 경계(HTTP)만 대역으로 세운다 — Repository는 진짜 코드가 돈다.
class _FakeUserRemoteDataSource implements UserRemoteDataSource {
  CommunityPushAgreementResponseModel? responseToReturn;
  CommunityPushAgreementRequestModel? lastUpdateRequest;
  Object? errorToThrow;

  @override
  Future<CommunityPushAgreementResponseModel>
  getCommunityPushAgreement() async {
    if (errorToThrow != null) throw errorToThrow!;
    return responseToReturn!;
  }

  @override
  Future<void> updateCommunityPushAgreement(
    CommunityPushAgreementRequestModel request,
  ) async {
    lastUpdateRequest = request;
    if (errorToThrow != null) throw errorToThrow!;
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

void main() {
  group('UserRepositoryImpl.getCommunityPushAgreement', () {
    test('성공 시 동의 여부를 반환한다', () async {
      final fake = _FakeUserRemoteDataSource()
        ..responseToReturn = const CommunityPushAgreementResponseModel(
          allowCommunityPush: false,
        );
      final repo = UserRepositoryImpl(fake);

      expect(await repo.getCommunityPushAgreement(), isFalse);
    });

    test('DioException은 AppException으로 변환된다', () async {
      final fake = _FakeUserRemoteDataSource()..errorToThrow = _dioError(401);
      final repo = UserRepositoryImpl(fake);

      expect(
        () => repo.getCommunityPushAgreement(),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('UserRepositoryImpl.updateCommunityPushAgreement', () {
    test('받은 값을 요청 바디에 실어 보낸다', () async {
      final fake = _FakeUserRemoteDataSource();
      final repo = UserRepositoryImpl(fake);

      await repo.updateCommunityPushAgreement(allowCommunityPush: false);

      expect(
        fake.lastUpdateRequest,
        const CommunityPushAgreementRequestModel(allowCommunityPush: false),
      );
    });

    test('DioException은 AppException으로 변환된다', () async {
      final fake = _FakeUserRemoteDataSource()..errorToThrow = _dioError(400);
      final repo = UserRepositoryImpl(fake);

      expect(
        () => repo.updateCommunityPushAgreement(allowCommunityPush: true),
        throwsA(isA<AppException>()),
      );
    });
  });
}
