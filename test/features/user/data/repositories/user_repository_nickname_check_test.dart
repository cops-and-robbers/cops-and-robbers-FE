import 'package:cops_and_robbers/features/user/data/datasources/user_remote_datasource.dart';
import 'package:cops_and_robbers/features/user/data/models/nickname_check_response_model.dart';
import 'package:cops_and_robbers/features/user/data/repositories/user_repository_impl.dart';
import 'package:cops_and_robbers/features/user/domain/entities/nickname_check_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시스템 경계(HTTP)만 대역으로 세운다 — 서버가 준 JSON을 실제 모델 파싱부터 통과시킨다.
class _FakeUserRemoteDataSource implements UserRemoteDataSource {
  _FakeUserRemoteDataSource(this.json);

  final Map<String, dynamic> json;

  @override
  Future<NicknameCheckResponseModel> checkNickname(String nickname) async =>
      NicknameCheckResponseModel.fromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<NicknameCheckResult> _check(Map<String, dynamic> json) =>
    UserRepositoryImpl(_FakeUserRemoteDataSource(json)).checkNickname('경찰왕');

void main() {
  group('UserRepositoryImpl.checkNickname', () {
    test(
      'checkNickname_returns_bannedWord_when_server_flags_banned_word',
      () async {
        // 금칙어가 들어간 닉네임 — BE #248 이후 서버 응답
        final result = await _check({
          'isAvailable': false,
          'code': 'BANNED_WORD_NICKNAME',
          'message': '닉네임에 부적절한 표현이 포함되어 있습니다.',
        });

        expect(result, NicknameCheckResult.bannedWord);
      },
    );

    test(
      'checkNickname_returns_duplicated_when_server_flags_duplicate',
      () async {
        final result = await _check({
          'isAvailable': false,
          'code': 'DUPLICATED_NICKNAME',
          'message': '이미 사용 중인 닉네임입니다.',
        });

        expect(result, NicknameCheckResult.duplicated);
      },
    );

    test(
      'checkNickname_returns_available_when_server_says_available',
      () async {
        final result = await _check({
          'isAvailable': true,
          'code': 'AVAILABLE',
          'message': '사용 가능한 닉네임 입니다!',
        });

        expect(result, NicknameCheckResult.available);
      },
    );

    test(
      'checkNickname_returns_duplicated_when_current_server_omits_code_and_rejects',
      () async {
        // BE #248 배포 전 서버 — code 없이 isAvailable만 온다
        final result = await _check({
          'isAvailable': false,
          'message': '이미 사용 중인 닉네임입니다.',
        });

        expect(result, NicknameCheckResult.duplicated);
      },
    );

    test(
      'checkNickname_returns_available_when_current_server_omits_code_and_accepts',
      () async {
        final result = await _check({
          'isAvailable': true,
          'message': '사용 가능한 닉네임입니다.',
        });

        expect(result, NicknameCheckResult.available);
      },
    );

    test(
      'checkNickname_falls_back_to_isAvailable_when_code_is_unknown',
      () async {
        // 서버가 앱이 모르는 새 코드를 추가한 경우 — 지금처럼 isAvailable로 판단한다
        final result = await _check({
          'isAvailable': false,
          'code': 'TOO_LONG_NICKNAME',
          'message': '닉네임이 너무 깁니다.',
        });

        expect(result, NicknameCheckResult.duplicated);
      },
    );
  });
}
