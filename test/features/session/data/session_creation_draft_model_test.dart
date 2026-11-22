import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/session/data/models/session_creation_draft_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  test('draft_roundtrips_polygon_pin_fields_through_json', () {
    const draft = SessionCreationDraftModel(
      areaType: GameAreaType.polygon,
      playgroundPinPoints: [
        LatLng(37.5685, 126.976),
        LatLng(37.5685, 126.980),
        LatLng(37.5645, 126.978),
      ],
      jailPinPoints: [LatLng(37.567, 126.9775)],
    );

    final restored = SessionCreationDraftModel.fromJson(draft.toJson());

    expect(restored.areaType, GameAreaType.polygon);
    expect(restored.playgroundPinPoints, draft.playgroundPinPoints);
    expect(restored.jailPinPoints, draft.jailPinPoints);
  });

  test('draft_defaults_to_circle_area_type_for_legacy_json', () {
    // 기존 사용자 로컬에 남아있는 구버전 draft JSON 호환
    final restored = SessionCreationDraftModel.fromJson(const {});
    expect(restored.areaType, GameAreaType.circle);
  });

  test('draft_keeps_shrink_on_when_host_leaves_and_comes_back', () {
    // 확인 화면에서 구역 축소를 켜 두고 앱을 나갔다 돌아와도 켜져 있어야 한다 (#668)
    const draft = SessionCreationDraftModel(shrinkEnabled: true);
    expect(
      SessionCreationDraftModel.fromJson(draft.toJson()).shrinkEnabled,
      isTrue,
    );
  });

  test('legacy_draft_without_shrink_field_starts_with_shrink_off', () {
    expect(SessionCreationDraftModel.fromJson(const {}).shrinkEnabled, isFalse);
  });

  test('draft_keeps_radio_on_when_host_leaves_creation_and_comes_back', () {
    // 확인 화면에서 무전을 켜 두고 앱을 나갔다 돌아와도 켜져 있어야 한다 (#723)
    const draft = SessionCreationDraftModel(radioEnabled: true);
    expect(
      SessionCreationDraftModel.fromJson(draft.toJson()).radioEnabled,
      isTrue,
    );
  });

  test('legacy_draft_without_radio_field_starts_with_radio_off', () {
    expect(SessionCreationDraftModel.fromJson(const {}).radioEnabled, isFalse);
  });

  test('draft_keeps_hide_and_seek_when_host_leaves_and_comes_back', () {
    const draft = SessionCreationDraftModel(gameMode: 'TAG');
    final restored = SessionCreationDraftModel.fromJson(draft.toJson());
    expect(GameMode.fromJson(restored.gameMode), GameMode.hideAndSeek);
  });

  // 모드가 생기기 전 앱이 저장한 초안은 경찰과 도둑 방으로 이어진다
  test(
    'draft_restores_cops_and_robbers_when_saved_by_older_app_without_mode',
    () {
      final restored = SessionCreationDraftModel.fromJson(const {});
      expect(restored.gameMode, isNull);
      expect(GameMode.fromJson(restored.gameMode), GameMode.copsAndRobbers);
    },
  );
}
