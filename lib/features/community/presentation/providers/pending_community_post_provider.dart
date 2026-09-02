import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'pending_community_post_provider.g.dart';

/// 미로그인 상태에서 들어온 모집글 딥링크의 글 id 를 임시 보존.
///
/// 진입 절차(약관 동의, 닉네임 설정)까지 끝난 시점에 root widget 이 읽어
/// 상세로 보낸다. 초대 코드 보존(pending_invite_provider)과 같은 자리이지만
/// 예외를 던지지 않는다 — 초대는 join 흐름이 실패를 사용자에게 안내해야
/// 하지만, 글 열람 링크는 저장이 실패하면 조용히 포기하고 홈으로 여는 편이
/// 안내 팝업보다 자연스럽다.
@Riverpod(keepAlive: true)
class PendingCommunityPost extends _$PendingCommunityPost {
  // SharedPreferences 저장 키
  static const _key = 'pending_community_post_id';

  @override
  Future<int?> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_key);
    } catch (e) {
      debugPrint('[DeepLink] 보존된 모집글 id 읽기 실패(포기): $e');
      return null;
    }
  }

  /// 딥링크로 받은 글 id 를 저장하고 상태를 즉시 갱신한다.
  Future<void> save(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, postId);
      state = AsyncValue.data(postId);
    } catch (e) {
      debugPrint('[DeepLink] 모집글 id 저장 실패(포기): $e');
    }
  }

  /// 저장된 글 id 를 삭제하고 상태를 null 로 초기화한다.
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      // 삭제 실패는 다음 실행에서 한 번 더 상세가 열릴 뿐이므로 무시
      debugPrint('[DeepLink] 모집글 id 삭제 실패(무시): $e');
    }
    state = const AsyncValue.data(null);
  }
}
