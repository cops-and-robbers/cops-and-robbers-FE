import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/session/data/models/session_creation_draft_model.dart';

/// 세션 생성 Draft 데이터 로컬 저장소 서비스
///
/// SharedPreferences를 활용하여 세션 생성 과정에서 수집한 데이터를 임시 저장합니다.
/// 사용자가 앱을 나갔다가 다시 돌아와도 이어서 진행할 수 있도록 지원합니다.
///
/// **단일 책임**: 세션 생성 draft 데이터의 저장/조회/삭제만 담당
///
/// **사용 예시**:
/// ```dart
/// final service = SessionDraftStorageService();
///
/// // 전체 저장
/// await service.saveDraft(draft);
///
/// // 조회
/// final draft = await service.loadDraft();
///
/// // 특정 필드 업데이트
/// await service.updatePlaygroundZone(center, radius);
///
/// // 삭제
/// await service.clearDraft();
/// ```
class SessionDraftStorageService {
  /// SharedPreferences 저장 키
  static const String _key = 'session_creation_draft';

  // ============================================
  // 전체 Draft 저장/조회/삭제
  // ============================================

  /// Draft 데이터를 로컬 저장소에 저장
  ///
  /// **사용 시점**: 각 단계 완료 시 (구역 설정, 게임 설정)
  Future<void> saveDraft(SessionCreationDraftModel draft) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(draft.toJson());
      await prefs.setString(_key, jsonString);
      // TODO: 로그는 디버깅용으로만 사용중
      if (kDebugMode) {
        debugPrint('✅ SessionDraft 저장 완료: $jsonString');
      }
    } catch (e, stack) {
      debugPrint('❌ SessionDraft 저장 실패: $e');
      debugPrint('Stack: $stack');
      // 저장 실패해도 계속 진행 (비필수 기능)
    }
  }

  /// Draft 데이터를 로컬 저장소에서 조회
  ///
  /// **사용 시점**: 각 페이지 진입 시 (기존 데이터 복원)
  ///
  /// **반환값**: 저장된 데이터가 있으면 반환, 없으면 null
  Future<SessionCreationDraftModel?> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);

      if (jsonString == null) {
        debugPrint('ℹ️ SessionDraft 없음 (첫 시작)');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final draft = SessionCreationDraftModel.fromJson(json);
      if (kDebugMode) {
        debugPrint('✅ SessionDraft 로드 완료: $jsonString');
      }
      return draft;
    } catch (e, stack) {
      debugPrint('❌ SessionDraft 로드 실패: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  /// Draft 데이터를 로컬 저장소에서 삭제
  ///
  /// **사용 시점**: 세션 생성 API 성공 시, 명시적 취소 시
  Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      debugPrint('✅ SessionDraft 삭제 완료');
    } catch (e, stack) {
      debugPrint('❌ SessionDraft 삭제 실패: $e');
      debugPrint('Stack: $stack');
    }
  }

  // ============================================
  // 특정 필드 업데이트 (부분 수정)
  // ============================================

  /// 플레이그라운드 구역 정보 업데이트
  ///
  /// **사용 시점**: SetupPlaygroundPage에서 설정 완료 시
  Future<void> updatePlaygroundZone(LatLng center, double radius) async {
    try {
      final currentDraft = await loadDraft();
      final updatedDraft = (currentDraft ?? const SessionCreationDraftModel())
          .copyWith(playgroundCenter: center, playgroundRadiusInMeters: radius);
      await saveDraft(updatedDraft);
      if (kDebugMode) {
        debugPrint('✅ 플레이그라운드 업데이트: center=$center, radius=${radius}m');
      }
    } catch (e, stack) {
      debugPrint('❌ 플레이그라운드 업데이트 실패: $e');
      debugPrint('Stack: $stack');
    }
  }

  /// 감옥 구역 정보 업데이트
  ///
  /// **사용 시점**: SetupPrisonPage에서 설정 완료 시
  Future<void> updatePrisonZone(LatLng center, double radius) async {
    try {
      final currentDraft = await loadDraft();
      final updatedDraft = (currentDraft ?? const SessionCreationDraftModel())
          .copyWith(jailCenter: center, jailRadiusInMeters: radius);
      await saveDraft(updatedDraft);
      debugPrint('✅ 감옥 업데이트: center=$center, radius=${radius}m');
    } catch (e, stack) {
      debugPrint('❌ 감옥 업데이트 실패: $e');
      debugPrint('Stack: $stack');
    }
  }

  /// 최대 참가자 수 업데이트
  ///
  /// **사용 시점**: SessionSettingsPage에서 설정 완료 시
  Future<void> updateMaxParticipants(int maxParticipants) async {
    try {
      final currentDraft = await loadDraft();
      final updatedDraft = (currentDraft ?? const SessionCreationDraftModel())
          .copyWith(maxParticipants: maxParticipants);
      await saveDraft(updatedDraft);
      debugPrint('✅ 최대 참가자 수 업데이트: $maxParticipants명');
    } catch (e, stack) {
      debugPrint('❌ 최대 참가자 수 업데이트 실패: $e');
      debugPrint('Stack: $stack');
    }
  }

  /// 게임 설정 정보 업데이트
  ///
  /// **사용 시점**: GameSettingsPage에서 설정 완료 시
  Future<void> updateGameSettings({
    required int roundDurationMinutes,
    required int locationShareMinutes,
    required int policeWaitMinutes,
  }) async {
    try {
      final currentDraft = await loadDraft();
      final updatedDraft = (currentDraft ?? const SessionCreationDraftModel())
          .copyWith(
            roundDurationMinutes: roundDurationMinutes,
            locationShareMinutes: locationShareMinutes,
            policeWaitMinutes: policeWaitMinutes,
          );
      await saveDraft(updatedDraft);
      debugPrint('✅ 게임 설정 업데이트 완료');
    } catch (e, stack) {
      debugPrint('❌ 게임 설정 업데이트 실패: $e');
      debugPrint('Stack: $stack');
    }
  }
}
