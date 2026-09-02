import 'package:cops_and_robbers/core/constants/api_endpoints.dart';
import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/user/data/datasources/user_remote_datasource.dart';
import 'package:cops_and_robbers/features/user/data/models/my_page_response_model.dart';
import 'package:cops_and_robbers/features/user/data/models/profile_icon_update_request_model.dart';
import 'package:cops_and_robbers/features/user/data/repositories/user_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시스템 경계(HTTP)만 대역으로 세운다 — 그 안쪽 Repository는 진짜 코드다.
class _FakeUserRemoteDataSource implements UserRemoteDataSource {
  ProfileIconUpdateRequestModel? lastProfileIconRequest;
  MyPageResponseModel? myPageToReturn;
  Object? errorToThrow;

  @override
  Future<MyPageResponseModel> getMyPage() async {
    if (errorToThrow != null) throw errorToThrow!;
    return myPageToReturn!;
  }

  @override
  Future<void> updateProfileIcon(ProfileIconUpdateRequestModel request) async {
    lastProfileIconRequest = request;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: ApiEndpoints.updateProfileIcon),
  response: Response(
    requestOptions: RequestOptions(path: ApiEndpoints.updateProfileIcon),
    statusCode: statusCode,
    data: {
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': ApiEndpoints.updateProfileIcon,
    },
  ),
  type: DioExceptionType.badResponse,
);

void main() {
  group('UserRepositoryImpl.updateProfileIcon', () {
    test('선택한 아이콘 번호를 그대로 서버에 보낸다', () async {
      final fake = _FakeUserRemoteDataSource();
      final repo = UserRepositoryImpl(fake);

      await repo.updateProfileIcon(2);

      expect(fake.lastProfileIconRequest?.profileIcon, 2);
    });

    test('DioException은 AppException으로 변환된다', () async {
      final fake = _FakeUserRemoteDataSource()..errorToThrow = _dioError(400);
      final repo = UserRepositoryImpl(fake);

      expect(() => repo.updateProfileIcon(2), throwsA(isA<AppException>()));
    });
  });

  group('UserRepositoryImpl.getMyProfile', () {
    test('서버가 준 프로필 아이콘 번호를 담아 돌려준다', () async {
      final fake = _FakeUserRemoteDataSource()
        ..myPageToReturn = const MyPageResponseModel(
          userId: 1,
          nickname: '홍길동',
          socialPlatform: 'GOOGLE',
          allowGamePush: true,
          allowMarketingPush: false,
          profileIcon: 2,
        );
      final repo = UserRepositoryImpl(fake);

      final profile = await repo.getMyProfile();

      expect(profile.profileIcon, 2);
    });
  });
}
