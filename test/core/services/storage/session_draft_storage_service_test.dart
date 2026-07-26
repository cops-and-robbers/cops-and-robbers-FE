import 'package:cops_and_robbers/core/services/storage/session_draft_storage_service.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/session/data/models/session_creation_draft_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('circle_playground_update_clears_polygon_and_jail_draft', () async {
    final service = SessionDraftStorageService();
    await service.saveDraft(
      const SessionCreationDraftModel(
        areaType: GameAreaType.polygon,
        playgroundPinPoints: [
          LatLng(37.5685, 126.9760),
          LatLng(37.5685, 126.9800),
          LatLng(37.5645, 126.9780),
        ],
        jailPinPoints: [
          LatLng(37.5670, 126.9775),
          LatLng(37.5670, 126.9785),
          LatLng(37.5660, 126.9780),
        ],
        jailCenter: LatLng(37.5665, 126.9780),
        jailRadiusInMeters: 50,
      ),
    );

    await service.updatePlaygroundZone(const LatLng(37.5665, 126.9780), 500);

    final draft = await service.loadDraft();
    expect(draft?.areaType, GameAreaType.circle);
    expect(draft?.playgroundPinPoints, isNull);
    expect(draft?.jailPinPoints, isNull);
    expect(draft?.jailCenter, isNull);
    expect(draft?.jailRadiusInMeters, isNull);
  });

  test('polygon_playground_update_clears_circle_and_jail_draft', () async {
    final service = SessionDraftStorageService();
    await service.saveDraft(
      const SessionCreationDraftModel(
        playgroundCenter: LatLng(37.5665, 126.9780),
        playgroundRadiusInMeters: 500,
        jailCenter: LatLng(37.5665, 126.9780),
        jailRadiusInMeters: 50,
      ),
    );
    const polygon = [
      LatLng(37.5685, 126.9760),
      LatLng(37.5685, 126.9800),
      LatLng(37.5645, 126.9780),
    ];

    await service.updatePlaygroundPinZone(polygon);

    final draft = await service.loadDraft();
    expect(draft?.areaType, GameAreaType.polygon);
    expect(draft?.playgroundPinPoints, polygon);
    expect(draft?.playgroundCenter, isNull);
    expect(draft?.playgroundRadiusInMeters, isNull);
    expect(draft?.jailCenter, isNull);
    expect(draft?.jailRadiusInMeters, isNull);
  });
}
