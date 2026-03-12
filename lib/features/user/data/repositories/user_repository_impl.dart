import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
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
        originalException: e,
      );
    }
  }
}
