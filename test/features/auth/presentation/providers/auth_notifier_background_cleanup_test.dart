import 'package:cops_and_robbers/core/services/background/background_service_provider.dart';
import 'package:cops_and_robbers/core/services/background/method_channel_background_service.dart';
import 'package:cops_and_robbers/core/storage/secure_token_storage.dart';
import 'package:cops_and_robbers/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cops_and_robbers/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Firebase extends Mock implements FirebaseAuthDataSource {}

class _Storage extends Mock implements SecureTokenStorage {}

class _Remote extends Mock implements AuthRemoteDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(MethodChannelBackgroundService.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late ProviderContainer container;
  late _Firebase firebase;
  late bool cardVisible;
  late void Function() closeAuthSubscription;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    firebase = _Firebase();
    final storage = _Storage();
    when(() => firebase.currentUser).thenReturn(null);
    when(() => firebase.signOut()).thenAnswer((_) async {});
    when(() => storage.getRefreshToken()).thenAnswer((_) async => null);
    when(() => storage.clearTokens()).thenAnswer((_) async {});
    // Dart 재실행 뒤 OS에만 남은 카드를 플랫폼 채널 경계에서 재현한다.
    cardVisible = true;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'stop') cardVisible = false;
      return null;
    });
    container = ProviderContainer(
      overrides: [
        firebaseAuthDataSourceProvider.overrideWithValue(firebase),
        secureTokenStorageProvider.overrideWithValue(storage),
        authRemoteDataSourceProvider.overrideWithValue(_Remote()),
        backgroundServiceProvider.overrideWithValue(
          MethodChannelBackgroundService(channel: channel),
        ),
      ],
    );
    closeAuthSubscription = container
        .listen(authNotifierProvider, (_, _) {})
        .close;
    await container.read(authNotifierProvider.future);
  });

  tearDown(() async {
    closeAuthSubscription();
    await container.pump();
    container.dispose();
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('retained_card_is_removed_when_user_signs_out', () async {
    await container.read(authNotifierProvider.notifier).signOut();
    await container.pump();

    expect(cardVisible, isFalse);
    expect(container.read(authNotifierProvider).requireValue, isNull);
  });

  test('retained_card_is_removed_when_session_is_revoked', () async {
    container.read(authNotifierProvider.notifier).forceLogout();
    await container.pump();

    expect(cardVisible, isFalse);
    expect(container.read(authNotifierProvider).requireValue, isNull);
  });

  test('retained_card_is_removed_when_deleted_account_cleanup_fails', () async {
    when(() => firebase.signOut()).thenThrow(Exception('Firebase unavailable'));

    await expectLater(
      container
          .read(authNotifierProvider.notifier)
          .cleanupAfterAccountDeletion(),
      throwsException,
    );

    expect(cardVisible, isFalse);
  });
}
