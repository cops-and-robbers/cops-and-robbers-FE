import 'package:cops_and_robbers/core/storage/secure_token_storage.dart';
import 'package:cops_and_robbers/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cops_and_robbers/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:cops_and_robbers/features/auth/data/models/logout_request_model.dart';
import 'package:cops_and_robbers/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 시스템 경계만 모킹 (Agents.md): Firebase SDK, SecureStorage(플랫폼 채널), 백엔드 API
class _MockFirebaseAuthDataSource extends Mock
    implements FirebaseAuthDataSource {}

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LogoutRequestModel(refreshToken: ''));
  });

  late _MockFirebaseAuthDataSource firebase;
  late _MockAuthRemoteDataSource remote;
  late _MockSecureTokenStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    firebase = _MockFirebaseAuthDataSource();
    remote = _MockAuthRemoteDataSource();
    storage = _MockSecureTokenStorage();
    repository = AuthRepositoryImpl(
      firebaseAuthDataSource: firebase,
      authRemoteDataSource: remote,
      tokenStorage: storage,
    );
  });

  test('signOut_clearsTokens_when_firebaseSignOutThrows', () async {
    when(
      () => storage.getRefreshToken(),
    ).thenAnswer((_) async => 'refresh-token');
    when(() => remote.logout(any())).thenAnswer((_) async {});
    when(() => firebase.signOut()).thenThrow(Exception('firebase down'));
    when(() => storage.clearTokens()).thenAnswer((_) async {});

    // Firebase 로그아웃이 실패해도 signOut은 예외 없이 완료된다 (성공 스낵바의 근거)
    await expectLater(repository.signOut(), completes);

    // 그리고 로컬 토큰은 반드시 삭제된다 (재시작 시 세션 부활 방지)
    verify(() => storage.clearTokens()).called(1);
  });
}
