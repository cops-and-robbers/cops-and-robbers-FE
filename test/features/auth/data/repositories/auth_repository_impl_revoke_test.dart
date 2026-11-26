import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/storage/secure_token_storage.dart';
import 'package:cops_and_robbers/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cops_and_robbers/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:cops_and_robbers/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuthDataSource extends Mock
    implements FirebaseAuthDataSource {}

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late _MockFirebaseAuthDataSource firebase;
  late AuthRepositoryImpl repository;

  setUp(() {
    firebase = _MockFirebaseAuthDataSource();
    repository = AuthRepositoryImpl(
      firebaseAuthDataSource: firebase,
      authRemoteDataSource: _MockAuthRemoteDataSource(),
      tokenStorage: _MockSecureTokenStorage(),
    );
  });

  test('revokeAppleToken_throwsCancelled_when_userCancels', () async {
    when(
      () => firebase.revokeAppleToken(),
    ).thenThrow(FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER'));

    await expectLater(
      repository.revokeAppleToken(),
      throwsA(isA<AuthCancelledException>()),
    );
  });

  test('revokeAppleToken_throwsRevokeFailed_when_firebaseRejects', () async {
    when(
      () => firebase.revokeAppleToken(),
    ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

    await expectLater(
      repository.revokeAppleToken(),
      throwsA(
        isA<AuthException>().having(
          (e) => e.messageKey,
          'messageKey',
          'errorAppleTokenRevokeFailed',
        ),
      ),
    );
  });
}
