import 'package:cops_and_robbers/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockUser extends Mock implements User {}

class _MockUserInfo extends Mock implements UserInfo {}

void main() {
  late _MockFirebaseAuth firebaseAuth;

  FirebaseAuthDataSource dataSource({Future<String> Function()? code}) {
    return FirebaseAuthDataSource(
      firebaseAuth: firebaseAuth,
      googleSignIn: _MockGoogleSignIn(),
      requestAppleAuthorizationCode: code ?? () async => 'apple-code',
    );
  }

  void signedInWith(String providerId) {
    final user = _MockUser();
    final info = _MockUserInfo();
    when(() => info.providerId).thenReturn(providerId);
    when(() => user.providerData).thenReturn([info]);
    when(() => firebaseAuth.currentUser).thenReturn(user);
  }

  setUp(() {
    firebaseAuth = _MockFirebaseAuth();
  });

  test('isAppleUser_true_when_signedInWithApple', () {
    signedInWith('apple.com');
    expect(dataSource().isAppleUser, isTrue);
  });

  test('isAppleUser_false_when_signedInWithGoogle', () {
    signedInWith('google.com');
    expect(dataSource().isAppleUser, isFalse);
  });

  test('isAppleUser_false_when_notSignedIn', () {
    when(() => firebaseAuth.currentUser).thenReturn(null);
    expect(dataSource().isAppleUser, isFalse);
  });

  test('revokeAppleToken_usesNewAuthorizationCode', () async {
    when(
      () => firebaseAuth.revokeTokenWithAuthorizationCode(any()),
    ).thenAnswer((_) async {});

    await dataSource().revokeAppleToken();

    verify(
      () => firebaseAuth.revokeTokenWithAuthorizationCode('apple-code'),
    ).called(1);
  });

  test('revokeAppleToken_throwsAborted_when_userCancelsAppleSheet', () async {
    final source = dataSource(
      code: () async => throw const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.canceled,
        message: 'canceled',
      ),
    );

    await expectLater(
      source.revokeAppleToken(),
      throwsA(
        isA<FirebaseAuthException>().having(
          (e) => e.code,
          'code',
          'ERROR_ABORTED_BY_USER',
        ),
      ),
    );
    verifyNever(() => firebaseAuth.revokeTokenWithAuthorizationCode(any()));
  });
}
