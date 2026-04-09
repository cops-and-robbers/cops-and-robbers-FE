import 'package:cops_and_robbers/features/lobby/data/models/lobby_event_dto.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/waiting_room_participants_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  /// 테스트마다 독립된 컨테이너 생성
  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  /// 3명의 참가자로 초기화하는 헬퍼
  void initThreeParticipants() {
    container
        .read(waitingRoomParticipantsProvider.notifier)
        .initFromApi(
          participants: const [
            LobbyParticipantInfo(
              participantId: 1,
              nickname: '경찰1',
              team: 'POLICE',
              isReady: true,
            ),
            LobbyParticipantInfo(
              participantId: 2,
              nickname: '도둑1',
              team: 'ROBBER',
              isReady: true,
            ),
            LobbyParticipantInfo(
              participantId: 3,
              nickname: '도둑2',
              team: 'ROBBER',
              isReady: false,
            ),
          ],
          hostParticipantId: 1,
        );
  }

  group('KICKED 이벤트 핸들러', () {
    test('해당 참가자를 목록에서 제거한다', () {
      // arrange: 3명 초기화
      initThreeParticipants();

      // act: participantId=2 강퇴
      container
          .read(waitingRoomParticipantsProvider.notifier)
          .handleLobbyEvent(
            const LobbyEventDto(
              eventId: 'evt-1',
              gameId: 1,
              type: LobbyEventType.kicked,
              timestamp: '2026-04-09T12:00:00',
              data: {'kickedParticipantId': 2, 'nickname': '도둑1'},
            ),
          );

      // assert: 2명만 남음
      final state = container.read(waitingRoomParticipantsProvider);
      expect(state.participants.length, equals(2));
      expect(state.participants.any((p) => p.participantId == 2), isFalse);
    });

    test('존재하지 않는 participantId면 목록이 변경되지 않는다', () {
      // arrange
      initThreeParticipants();

      // act: 없는 id=99 강퇴
      container
          .read(waitingRoomParticipantsProvider.notifier)
          .handleLobbyEvent(
            const LobbyEventDto(
              eventId: 'evt-2',
              gameId: 1,
              type: LobbyEventType.kicked,
              timestamp: '2026-04-09T12:00:00',
              data: {'kickedParticipantId': 99, 'nickname': '없는유저'},
            ),
          );

      // assert: 여전히 3명
      final state = container.read(waitingRoomParticipantsProvider);
      expect(state.participants.length, equals(3));
    });

    test('kickedParticipantId가 null이면 목록이 변경되지 않는다', () {
      // arrange
      initThreeParticipants();

      // act: kickedParticipantId 없이 이벤트 전달
      container
          .read(waitingRoomParticipantsProvider.notifier)
          .handleLobbyEvent(
            const LobbyEventDto(
              eventId: 'evt-3',
              gameId: 1,
              type: LobbyEventType.kicked,
              timestamp: '2026-04-09T12:00:00',
              data: {'nickname': '도둑1'},
            ),
          );

      // assert: 변경 없음
      final state = container.read(waitingRoomParticipantsProvider);
      expect(state.participants.length, equals(3));
    });

    test('마지막 참가자를 kick하면 빈 목록이 된다', () {
      // arrange: 1명만 초기화
      container
          .read(waitingRoomParticipantsProvider.notifier)
          .initFromApi(
            participants: const [
              LobbyParticipantInfo(
                participantId: 1,
                nickname: '혼자남은유저',
                team: 'POLICE',
                isReady: false,
              ),
            ],
            hostParticipantId: 1,
          );

      // act
      container
          .read(waitingRoomParticipantsProvider.notifier)
          .handleLobbyEvent(
            const LobbyEventDto(
              eventId: 'evt-4',
              gameId: 1,
              type: LobbyEventType.kicked,
              timestamp: '2026-04-09T12:00:00',
              data: {'kickedParticipantId': 1, 'nickname': '혼자남은유저'},
            ),
          );

      // assert: 빈 목록
      final state = container.read(waitingRoomParticipantsProvider);
      expect(state.participants, isEmpty);
    });
  });
}
