import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import 'user_provider.dart';

part 'profile_icon_provider.g.dart';

/// 선택 가능한 프로필 아이콘 id 목록
///
/// `assets/profiles/<id>.svg` 와 1:1 대응. 에셋 추가 시 이 리스트만 갱신한다.
const List<int> kProfileIconIds = [1, 2];

/// 기본 프로필 아이콘 id
const int kDefaultProfileIconId = 1;

/// SharedPreferences 키 — 사용자별로 나눈다.
///
/// 하나로 두면 로그아웃 후 다른 계정으로 들어왔을 때 이전 사용자의 아이콘이
/// 그려지고, 그 상태에서 아이콘을 누르면 남의 번호가 내 계정에 저장된다.
String _storageKey(int userId) => 'profile_icon_id_$userId';

/// 프로필 아이콘 에셋 경로
///
/// 서버는 아이콘 번호의 상한을 검증하지 않는다(DEC-0040). 앱에 없는 번호가
/// 그대로 흘러들면 에셋 로드에서 예외가 나므로 이 한 곳에서 막는다 —
/// 게시글·댓글 작성자 아이콘도 전부 이 함수를 지난다. 탈퇴한 작성자의
/// 기본 아이콘 처리(DEC-0041)도 여기서 함께 만족된다.
/// [id]가 null이면(삭제된 댓글처럼 서버가 비워 보내는 경우) 기본 아이콘을 쓴다.
String profileIconAsset(int? id) {
  final safeId = kProfileIconIds.contains(id) ? id! : kDefaultProfileIconId;
  return 'assets/profiles/$safeId.svg';
}

/// 선택된 프로필 아이콘 상태
///
/// 정본은 서버(`GET /api/user/me`의 `profileIcon`)다. 로컬(SharedPreferences)은
/// 첫 프레임을 그리기 위한 캐시일 뿐이라, 서버 값이 오면 덮어쓴다 — 캐시를 없애면
/// 콜드 스타트마다 기본 아이콘이 한 번 번쩍인다.
///
/// 소비 측(`ref.watch(profileIconProvider)`)은 여전히 `int` 하나만 본다.
///
/// 사용 예:
/// ```dart
/// final iconId = ref.watch(profileIconProvider);
/// await ref.read(profileIconProvider.notifier).select(2);
/// ```
@Riverpod(keepAlive: true)
class ProfileIcon extends _$ProfileIcon {
  /// 사용자가 이 세션에서 직접 아이콘을 골랐는지.
  /// 뒤늦게 도착한 조회가 그 선택을 덮어쓰지 못하게 막는 데만 쓴다.
  ///
  /// `keepAlive`라 notifier 인스턴스가 재사용되므로 rebuild 때 반드시 되돌린다 —
  /// 안 그러면 한 번 고른 세션에서는 계정을 바꿔도 동기화가 조용히 죽는다.
  bool _selectedByUser = false;

  /// 서버 저장이 도는 중인지. 겹친 PATCH의 도착 순서가 뒤집히는 것을 막는다.
  bool _saving = false;

  /// 지금 이 상태가 누구 것인지. 늦게 끝난 조회가 다른 계정에 쓰지 않게 하는 기준.
  int? _userId;

  @override
  int build() {
    _userId = ref.watch(currentUserIdProvider);
    _selectedByUser = false;

    // 저장소·서버 조회 모두 비동기라 build 동기 흐름에 직접 못 넣음.
    // 첫 프레임은 기본값으로, 캐시 → 서버 순으로 다음 프레임에서 덮어씀.
    if (_userId != null) Future.microtask(_load);
    return kDefaultProfileIconId;
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) return;
    await _loadFromStorage(userId);
    await _loadFromServer(userId);
  }

  Future<void> _loadFromStorage(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_stillCurrent(userId)) return;

    final stored = prefs.getInt(_storageKey(userId));
    if (stored == null) return;
    // 에셋이 제거된 id가 남아있으면 무시하고 기본값 유지
    if (!kProfileIconIds.contains(stored)) {
      await prefs.remove(_storageKey(userId));
      return;
    }
    if (stored != state) state = stored;
  }

  /// 서버 값으로 맞춘다. 실패해도 캐시 값으로 계속 그린다 —
  /// 아이콘 하나 때문에 화면을 막을 이유가 없다.
  Future<void> _loadFromServer(int userId) async {
    try {
      final profile = await ref.read(userRepositoryProvider).getMyProfile();
      if (!_stillCurrent(userId)) return;

      // 서버는 아이콘 번호의 상한을 검증하지 않는다(DEC-0040). 앱에 없는 번호를
      // 상태로 들이면 그 값이 그대로 다시 저장될 수 있어 여기서도 막는다.
      if (!kProfileIconIds.contains(profile.profileIcon)) {
        if (kDebugMode) {
          debugPrint('⚠️ 서버 프로필 아이콘 ${profile.profileIcon} — 대응 에셋 없음, 무시');
        }
        return;
      }

      if (profile.profileIcon != state) {
        state = profile.profileIcon;
        await _saveToStorage(userId, profile.profileIcon);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ 프로필 아이콘 서버 조회 실패 — 로컬 값 유지: $e');
      }
    }
  }

  /// 이 조회를 시작한 뒤 사용자가 직접 골랐거나 계정이 바뀌었으면 결과를 버린다.
  ///
  /// 조회가 도는 사이 누른 선택이 더 최신이고, 계정이 바뀌었으면 그 값은
  /// 아예 남의 것이다.
  bool _stillCurrent(int userId) => !_selectedByUser && _userId == userId;

  /// 사용자가 아이콘 선택 — 즉시 반영 후 서버 저장, 실패하면 되돌린다.
  ///
  /// 서버 저장이 실패했는데 화면만 바뀌어 있으면 다음 실행에서 조용히 되돌아간다.
  /// 호출부가 안내할 수 있도록 예외를 그대로 올린다.
  Future<void> select(int id) async {
    if (!kProfileIconIds.contains(id)) return;
    final userId = _userId;
    if (userId == null) return;
    // 연달아 누르면 PATCH가 겹친다. 먼저 보낸 요청이 늦게 끝나면 서버에는 이전
    // 아이콘이 남고, 그 실패 롤백이 방금 고른 값을 덮는다.
    if (_saving) return;
    _saving = true;

    _selectedByUser = true;
    final previous = state;
    state = id;
    await _saveToStorage(userId, id);

    try {
      await ref.read(userRepositoryProvider).updateProfileIcon(id);
    } catch (_) {
      state = previous;
      await _saveToStorage(userId, previous);
      rethrow;
    } finally {
      _saving = false;
    }
  }

  Future<void> _saveToStorage(int userId, int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey(userId), id);
  }
}
