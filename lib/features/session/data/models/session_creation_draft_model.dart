import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/converters/latlng_converter.dart';

part 'session_creation_draft_model.freezed.dart';
part 'session_creation_draft_model.g.dart';

/// 세션 생성 임시 저장 데이터 모델
///
/// 사용자가 세션 생성 과정에서 입력한 데이터를 로컬 저장소에 임시 저장하여,
/// 앱을 나갔다가 다시 돌아와도 이어서 진행할 수 있도록 합니다.
///
/// **생명주기**:
/// - 저장: 각 단계 완료 시 (구역 설정, 게임 설정)
/// - 조회: 각 페이지 진입 시
/// - 삭제: 세션 생성 API 성공 시 또는 명시적 취소 시
///
/// **사용 예시**:
/// ```dart
/// // 구역 설정 후 저장
/// final draft = SessionCreationDraftModel(
///   playgroundCenter: LatLng(37.5665, 126.978),
///   playgroundRadiusInMeters: 1000,
///   jailCenter: LatLng(37.5665, 126.978),
///   jailRadiusInMeters: 100,
/// );
/// await SessionDraftStorageService().saveDraft(draft);
/// ```
@freezed
class SessionCreationDraftModel with _$SessionCreationDraftModel {
  const factory SessionCreationDraftModel({
    // ============================================
    // 구역 정보 (1단계: 구역 설정)
    // ============================================

    /// 플레이그라운드 중심 좌표
    @LatLngConverter() LatLng? playgroundCenter,

    /// 플레이그라운드 반경 (미터)
    double? playgroundRadiusInMeters,

    /// 감옥 중심 좌표
    @LatLngConverter() LatLng? jailCenter,

    /// 감옥 반경 (미터)
    double? jailRadiusInMeters,

    // ============================================
    // 게임 설정 (2단계: 인원 설정, 3단계: 기본정보 설정)
    // ============================================

    /// 라운드 시간 (분)
    int? roundDurationMinutes,

    /// 위치 공유 간격 (분)
    int? locationShareMinutes,

    /// 경찰 대기 시간 (분)
    int? policeWaitMinutes,

    /// 최대 참가자 수
    int? maxParticipants,
  }) = _SessionCreationDraftModel;

  factory SessionCreationDraftModel.fromJson(Map<String, dynamic> json) =>
      _$SessionCreationDraftModelFromJson(json);
}
