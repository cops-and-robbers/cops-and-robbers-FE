import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_branch_index_provider.g.dart';

/// 현재 선택된 바텀 네비 브랜치 인덱스.
///
/// `MainScaffold`가 브랜치 전환을 감지해 발행하고, 탭 화면이 "내가 다시 보이게
/// 됐다"를 판정하는 데 쓴다. 상세·검색처럼 셸 **위에** 뜨는 화면은 이 값을
/// 바꾸지 않으므로, 그런 이동에는 반응하지 않는다 — 글 하나를 오래 읽고 나와도
/// 목록이 초기화되지 않는 것이 이 신호를 고른 이유다.
///
/// 앱 셸이 살아 있는 동안 유지된다. 셸이 쓰고 탭 화면이 읽는 값이라 그 사이
/// 리스너가 잠깐 비어도 0으로 되돌아가면 안 된다.
@Riverpod(keepAlive: true)
class CurrentBranchIndex extends _$CurrentBranchIndex {
  @override
  int build() => 0;

  /// 메서드 이름이 `select`인 것은 `SelectedCommunityScope`·`SelectedCommunitySort`와
  /// 맞춘 것이다. `set`은 Dart의 setter 문법과 충돌한다.
  void select(int index) => state = index;
}
