import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/user/data/datasources/user_remote_datasource.dart';
import 'package:cops_and_robbers/features/user/data/models/agreement_request_model.dart';
import 'package:cops_and_robbers/features/user/data/models/agreement_response_model.dart';
import 'package:cops_and_robbers/features/user/data/models/delete_account_response_model.dart';
import 'package:cops_and_robbers/features/user/data/models/game_push_agreement_model.dart';
import 'package:cops_and_robbers/features/user/data/models/my_page_response_model.dart';
import 'package:cops_and_robbers/features/user/data/models/nickname_check_response_model.dart';
import 'package:cops_and_robbers/features/user/data/models/nickname_update_request_model.dart';
import 'package:cops_and_robbers/features/user/data/models/profile_icon_update_request_model.dart';
import 'package:cops_and_robbers/features/user/data/repositories/user_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUserRemoteDataSource implements UserRemoteDataSource {
  AgreementResponseModel? responseToReturn;
  AgreementRequestModel? lastUpdateRequest;
  Object? errorToThrow;

  @override
  Future<AgreementResponseModel> getAgreements() async {
    if (errorToThrow != null) throw errorToThrow!;
    return responseToReturn!;
  }

  @override
  Future<void> updateAgreements(AgreementRequestModel request) async {
    lastUpdateRequest = request;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<NicknameCheckResponseModel> checkNickname(String nickname) =>
      throw UnimplementedError();

  @override
  Future<void> updateNickname(NicknameUpdateRequestModel request) =>
      throw UnimplementedError();

  @override
  Future<MyPageResponseModel> getMyPage() => throw UnimplementedError();

  @override
  Future<void> updateProfileIcon(ProfileIconUpdateRequestModel request) =>
      throw UnimplementedError();

  @override
  Future<DeleteAccountResponseModel> deleteAccount() =>
      throw UnimplementedError();

  @override
  Future<GamePushAgreementResponseModel> getGamePushAgreement() =>
      throw UnimplementedError();

  @override
  Future<void> updateGamePushAgreement(GamePushAgreementRequestModel request) =>
      throw UnimplementedError();
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/api/user/agreements'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/user/agreements'),
    statusCode: statusCode,
    data: {
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': '/api/user/agreements',
    },
  ),
  type: DioExceptionType.badResponse,
);

void main() {
  group('UserRepositoryImpl.getAgreements', () {
    test('성공 시 AgreementStatusEntity를 반환한다', () async {
      final fake = _FakeUserRemoteDataSource()
        ..responseToReturn = const AgreementResponseModel(
          termsOfServiceAgreed: true,
          privacyPolicyAgreed: true,
          locationTermsAgreed: true,
          marketingAgreed: false,
        );
      final repo = UserRepositoryImpl(fake);

      final result = await repo.getAgreements();

      expect(result.termsOfService, true);
      expect(result.privacyPolicy, true);
      expect(result.locationTerms, true);
      expect(result.marketing, false);
      expect(result.hasAllRequired, true);
    });

    test('DioException은 AppException으로 변환된다', () async {
      final fake = _FakeUserRemoteDataSource()..errorToThrow = _dioError(401);
      final repo = UserRepositoryImpl(fake);

      expect(() => repo.getAgreements(), throwsA(isA<AppException>()));
    });
  });

  group('UserRepositoryImpl.updateAgreements', () {
    test('필수 3종은 항상 true로 고정되고 marketing만 사용자 값이 반영된다', () async {
      final fake = _FakeUserRemoteDataSource();
      final repo = UserRepositoryImpl(fake);

      await repo.updateAgreements(marketing: true);

      expect(fake.lastUpdateRequest, isNotNull);
      expect(fake.lastUpdateRequest!.termsOfService, true);
      expect(fake.lastUpdateRequest!.privacyPolicy, true);
      expect(fake.lastUpdateRequest!.locationTerms, true);
      expect(fake.lastUpdateRequest!.marketing, true);
    });

    test('marketing=false도 정상 전달된다', () async {
      final fake = _FakeUserRemoteDataSource();
      final repo = UserRepositoryImpl(fake);

      await repo.updateAgreements(marketing: false);

      expect(fake.lastUpdateRequest!.marketing, false);
    });

    test('DioException은 AppException으로 변환된다', () async {
      final fake = _FakeUserRemoteDataSource()..errorToThrow = _dioError(400);
      final repo = UserRepositoryImpl(fake);

      expect(
        () => repo.updateAgreements(marketing: false),
        throwsA(isA<AppException>()),
      );
    });
  });
}
