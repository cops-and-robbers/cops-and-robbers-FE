import 'package:cops_and_robbers/features/lobby/data/models/lobby_event_dto.dart';
import 'package:cops_and_robbers/features/session/presentation/widgets/team_section.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트용 참가자 생성 헬퍼
LobbyParticipantInfo _p(int id, {String team = 'POLICE'}) =>
    LobbyParticipantInfo(
      participantId: id,
      nickname: 'user$id',
      team: team,
      isReady: false,
    );

/// participantId만 순서대로 뽑아 비교용으로 반환
List<int> _ids(List<LobbyParticipantInfo> list) =>
    list.map((p) => p.participantId).toList();

void main() {
  group('sortParticipantsForDisplay', () {
    test('putsHostFirst_thenMe_thenOthers_inReceivedOrder', () {
      // 수신 순서: 2, 1(방장), 3, 4(나)
      final members = [_p(2), _p(1), _p(3), _p(4)];
      final sorted = sortParticipantsForDisplay(
        members,
        hostParticipantId: 1,
        myParticipantId: 4,
      );
      expect(_ids(sorted), [1, 4, 2, 3]);
    });

    test('putsHostFirst_withoutDuplicatingMe_whenIAmHost', () {
      // 내가 방장인 경우 방장 그룹에 한 번만 들어가야 함 (중복 방지)
      final members = [_p(2), _p(1), _p(3)];
      final sorted = sortParticipantsForDisplay(
        members,
        hostParticipantId: 1,
        myParticipantId: 1,
      );
      expect(_ids(sorted), [1, 2, 3]);
      expect(sorted.length, 3);
    });

    test('placesHostFirst_withoutMe_whenIAmInOpponentTeam', () {
      // 상대 팀 섹션에는 본인이 없으므로 방장만 맨 앞
      final members = [_p(2), _p(1), _p(3)];
      final sorted = sortParticipantsForDisplay(
        members,
        hostParticipantId: 1,
        myParticipantId: 99, // 이 팀에 없는 id
      );
      expect(_ids(sorted), [1, 2, 3]);
    });

    test('preservesReceivedOrder_whenHostIsNull', () {
      // 방장 정보 로딩 전: 본인 우선만 적용, 방장 조건 skip
      final members = [_p(2), _p(1), _p(3)];
      final sorted = sortParticipantsForDisplay(
        members,
        hostParticipantId: null,
        myParticipantId: 3,
      );
      expect(_ids(sorted), [3, 2, 1]);
    });

    test('preservesReceivedOrder_whenMyIdIsNull', () {
      // 참가자 정보 로딩 전: 방장만 맨 앞으로
      final members = [_p(2), _p(1), _p(3)];
      final sorted = sortParticipantsForDisplay(
        members,
        hostParticipantId: 1,
        myParticipantId: null,
      );
      expect(_ids(sorted), [1, 2, 3]);
    });

    test('keepsStableOrder_forNonHostNonMeMembers', () {
      // 5명 중 방장=3, 나=5 → 나머지(1, 2, 4)는 수신 순서 보존되어야 함
      final members = [_p(1), _p(2), _p(3), _p(4), _p(5)];
      final sorted = sortParticipantsForDisplay(
        members,
        hostParticipantId: 3,
        myParticipantId: 5,
      );
      expect(_ids(sorted), [3, 5, 1, 2, 4]);
    });

    test('returnsEmpty_whenMembersEmpty', () {
      final sorted = sortParticipantsForDisplay(
        const [],
        hostParticipantId: 1,
        myParticipantId: 2,
      );
      expect(sorted, isEmpty);
    });
  });
}
