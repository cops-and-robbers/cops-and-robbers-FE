import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_exception_handler.dart';
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
    }
  }
}
