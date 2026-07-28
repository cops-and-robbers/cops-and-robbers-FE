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
}
