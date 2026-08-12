import 'package:cops_and_robbers/features/user/presentation/providers/profile_icon_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns_default_icon_when_nothing_stored', () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(profileIconProvider), kDefaultProfileIconId);
  });

  test('persists_selected_icon_to_storage', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(profileIconProvider.notifier).select(2);

    expect(container.read(profileIconProvider), 2);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('profile_icon_id'), 2);
  });

  test('ignores_selection_of_unknown_icon_id', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(profileIconProvider.notifier).select(99);

    expect(container.read(profileIconProvider), kDefaultProfileIconId);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('profile_icon_id'), isNull);
  });
}
