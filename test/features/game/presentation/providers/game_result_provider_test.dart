import 'package:cops_and_robbers/core/network/auth_interceptor.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/game_result_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  group('gameResultDioProvider', () {
    test('does_not_install_global_auth_interceptor', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dio = container.read(gameResultDioProvider);

      expect(dio.interceptors.whereType<AuthInterceptor>(), isEmpty);
    });
  });
}
