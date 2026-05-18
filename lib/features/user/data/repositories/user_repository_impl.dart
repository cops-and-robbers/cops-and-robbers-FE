import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/agreement_status_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/agreement_request_model.dart';
import '../models/game_push_agreement_model.dart';
import '../models/nickname_update_request_model.dart';

/// User Repository 구현체
///
/// [UserRemoteDataSource]를 통해 백엔드 User API를 호출합니다.
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<bool> checkNickname(String nickname) async {
    try {
      final response = await _dataSource.checkNickname(nickname);

      if (kDebugMode) {
        debugPrint('✅ 닉네임 중복 확인: $nickname → ${response.isAvailable}');
      }

      return response.isAvailable;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '닉네임 확인 중 예기치 않은 오류가 발생했습니다.',
        messageKey: 'dialoguserRepositoryImplMessage',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateNickname(String nickname) async {
    try {
      await _dataSource.updateNickname(
        NicknameUpdateRequestModel(nickname: nickname),
      );

      if (kDebugMode) {
        debugPrint('✅ 닉네임 변경 성공: $nickname');
      }
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '닉네임 변경 중 예기치 않은 오류가 발생했습니다.',
        messageKey: 'dialoguserRepositoryImplMessageAc72',
        originalException: e,
      );
    }
  }

  @override
  Future<UserProfileEntity> getMyProfile() async {
    try {
      final response = await _dataSource.getMyPage();

      if (kDebugMode) {
        debugPrint('✅ 내 정보 조회 성공: ${response.nickname}');
      }

      return UserProfileEntity(
        userId: response.userId,
        nickname: response.nickname,
        socialPlatform: response.socialPlatform,
        allowGamePush: response.allowGamePush,
        allowMarketingPush: response.allowMarketingPush,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '사용자 정보 조회 중 오류가 발생했습니다.',
        messageKey: 'dialoguserRepositoryImplMessage243c',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _dataSource.deleteAccount();

      if (kDebugMode) {
        debugPrint('✅ 회원 탈퇴 성공');
      }
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '회원 탈퇴 중 예기치 않은 오류가 발생했습니다.',
        messageKey: 'dialoguserRepositoryImplMessage220e',
        originalException: e,
      );
    }
  }

  @override
  Future<AgreementStatusEntity> getAgreements() async {
    try {
      final response = await _dataSource.getAgreements();

      if (kDebugMode) {
        debugPrint(
          '✅ 약관 동의 상태 조회: '
          'terms=${response.termsOfServiceAgreed}, '
          'privacy=${response.privacyPolicyAgreed}, '
          'location=${response.locationTermsAgreed}, '
          'marketing=${response.marketingAgreed}',
        );
      }

      return AgreementStatusEntity(
        termsOfService: response.termsOfServiceAgreed,
        privacyPolicy: response.privacyPolicyAgreed,
        locationTerms: response.locationTermsAgreed,
        marketing: response.marketingAgreed,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: '약관 동의 상태 조회 중 예기치 않은 오류가 발생했습니다.',
        messageKey: 'dialoguserRepositoryImplMessage05b0',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateAgreements({required bool marketing}) async {
    try {
      await _dataSource.updateAgreements(
        AgreementRequestModel(
          termsOfService: true,
          privacyPolicy: true,
          locationTerms: true,
          marketing: marketing,
        ),
      );

      if (kDebugMode) {
        debugPrint('✅ 약관 동의 저장 성공 (marketing=$marketing)');
      }
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: '약관 동의 저장 중 예기치 않은 오류가 발생했습니다.',
        messageKey: 'dialoguserRepositoryImplMessage2357',
        originalException: e,
      );
    }
  }

  @override
  Future<bool> getGamePushAgreement() async {
    try {
      final response = await _dataSource.getGamePushAgreement();

      if (kDebugMode) {
        debugPrint('✅ 게임 푸시 알림 동의 조회: ${response.allowGamePush}');
      }

      return response.allowGamePush;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: '게임 푸시 알림 동의 조회 중 예기치 않은 오류가 발생했습니다.',
        messageKey: 'dialoguserRepositoryImplMessage3d3a',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateGamePushAgreement({required bool allowGamePush}) async {
    try {
      await _dataSource.updateGamePushAgreement(
        GamePushAgreementRequestModel(allowGamePush: allowGamePush),
      );

      if (kDebugMode) {
        debugPrint('✅ 게임 푸시 알림 동의 업데이트 성공 (allowGamePush=$allowGamePush)');
      }
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: '게임 푸시 알림 동의 업데이트 중 예기치 않은 오류가 발생했습니다.',
        messageKey: 'dialoguserRepositoryImplMessage5fe2',
        originalException: e,
      );
    }
  }
}
