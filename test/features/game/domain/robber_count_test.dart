import 'package:cops_and_robbers/core/constants/participant_status.dart';
import 'package:cops_and_robbers/features/game/domain/robber_count.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const statuses = {
    1: ParticipantStatus.alive,
    2: ParticipantStatus.alive,
    3: ParticipantStatus.jailed,
  };

  test('alive_count_excludes_server_jailed_robbers_when_no_local_changes', () {
    expect(
      countAliveRobbers(
        robberStatuses: statuses,
        arrestedIds: {},
        escapedIds: {},
      ),
      2,
    );
  });

  test(
    'alive_count_excludes_locally_arrested_robber_when_server_still_alive',
    () {
      expect(
        countAliveRobbers(
          robberStatuses: statuses,
          arrestedIds: {1},
          escapedIds: {},
        ),
        1,
      );
    },
  );

  test('alive_count_includes_escaped_robber_when_also_marked_arrested', () {
    // 탈옥이 체포·서버 JAILED보다 우선 (participant_overlay의 기존 정의)
    expect(
      countAliveRobbers(
        robberStatuses: statuses,
        arrestedIds: {3},
        escapedIds: {3},
      ),
      3,
    );
  });

  test('alive_count_is_zero_when_no_robbers', () {
    expect(
      countAliveRobbers(
        robberStatuses: const {},
        arrestedIds: {},
        escapedIds: {},
      ),
      0,
    );
  });
}
