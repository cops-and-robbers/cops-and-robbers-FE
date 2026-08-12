import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_icon_provider.g.dart';

/// 선택 가능한 프로필 아이콘 id 목록
///
/// `assets/profiles/<id>.svg` 와 1:1 대응. 에셋 추가 시 이 리스트만 갱신한다.
const List<int> kProfileIconIds = [1, 2];

/// 기본 프로필 아이콘 id
const int kDefaultProfileIconId = 1;

/// SharedPreferences 키 — 선택된 프로필 아이콘 id
const String _kStorageKey = 'profile_icon_id';

/// 프로필 아이콘 에셋 경로
String profileIconAsset(int id) => 'assets/profiles/$id.svg';

/// 선택된 프로필 아이콘 상태
///
/// 서버에 프로필 아이콘 API가 아직 없어 로컬(SharedPreferences)에만 저장한다.
/// API가 생기면 이 notifier 내부의 저장·조회만 원격 호출로 바꾸면 되고,
/// 소비 측(`ref.watch(profileIconProvider)`)은 수정할 필요가 없다.
///
/// 사용 예:
/// ```dart
/// final iconId = ref.watch(profileIconProvider);
/// await ref.read(profileIconProvider.notifier).select(2);
/// ```
@Riverpod(keepAlive: true)
class ProfileIcon extends _$ProfileIcon {
  @override
  int build() {
    // SharedPreferences는 비동기라 build 동기 흐름에 직접 못 넣음.
    // 첫 프레임은 기본값으로, 저장값이 있으면 다음 프레임에서 덮어씀.
    Future.microtask(_loadFromStorage);
    return kDefaultProfileIconId;
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_kStorageKey);
    if (stored == null) return;
    // 에셋이 제거된 id가 남아있으면 무시하고 기본값 유지
    if (!kProfileIconIds.contains(stored)) {
      await prefs.remove(_kStorageKey);
      return;
    }
    if (stored != state) state = stored;
  }

  /// 사용자가 아이콘 선택 — 즉시 반영 + 영속 저장
  Future<void> select(int id) async {
    if (!kProfileIconIds.contains(id)) return;
    state = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStorageKey, id);
  }
}
