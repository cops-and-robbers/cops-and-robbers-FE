import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../user/presentation/providers/user_provider.dart';

part 'agreement_provider.freezed.dart';
part 'agreement_provider.g.dart';

/// 약관 동의 제출 결과
enum AgreementSubmitResult {
  /// 제출 성공
  success,

  /// 네트워크 미연결
  offline,

  /// 필수 약관 미체크 (버튼이 UI에서 막혀야 하지만 방어)
  missingRequired,

  /// API 또는 기타 예외 발생
  failure,
}

/// 약관 동의 화면 상태
///
/// 4개 체크박스 + 제출 중 여부를 담는 불변 상태.
@freezed
class AgreementState with _$AgreementState {
  const factory AgreementState({
    @Default(false) bool termsOfService,
    @Default(false) bool privacyPolicy,
    @Default(false) bool locationTerms,
    @Default(false) bool marketing,
    @Default(false) bool isSubmitting,
  }) = _AgreementState;

  const AgreementState._();

  /// 필수 약관 3종 모두 체크되었는지 여부
  bool get hasAllRequired => termsOfService && privacyPolicy && locationTerms;

  /// 4개(필수+선택) 모두 체크되었는지 여부
  bool get allAgreed => hasAllRequired && marketing;
}

/// 약관 동의 화면 전용 Notifier
///
/// 체크박스 상태 관리 + `PUT /api/user/agreements` 제출을 담당합니다.
/// 제출 성공 시 AuthNotifier의 requiresAgreement를 false로 갱신하는 책임은
/// 호출자(AgreementPage)가 담당합니다 (Provider 간 강결합 회피).
@riverpod
class AgreementNotifier extends _$AgreementNotifier {
  /// 마지막 submit 에러 (UI에서 스낵바 표시용)
  AppException? lastError;

  @override
  AgreementState build() => const AgreementState();

  // 제출 중에는 체크박스 변경을 무시한다.
  // 서버 요청이 날아간 뒤 사용자가 토글하면 화면 표시값과 서버 저장값이 어긋나므로,
  // 동의 이력의 정합성을 지키기 위해 토글·일괄설정 모두 가드한다.
  void toggleTerms() {
    if (state.isSubmitting) return;
    state = state.copyWith(termsOfService: !state.termsOfService);
  }

  void togglePrivacy() {
    if (state.isSubmitting) return;
    state = state.copyWith(privacyPolicy: !state.privacyPolicy);
  }

  void toggleLocation() {
    if (state.isSubmitting) return;
    state = state.copyWith(locationTerms: !state.locationTerms);
  }

  void toggleMarketing() {
    if (state.isSubmitting) return;
    state = state.copyWith(marketing: !state.marketing);
  }

  /// 4개를 일괄 [value]로 설정
  void toggleAll(bool value) {
    if (state.isSubmitting) return;
    state = state.copyWith(
      termsOfService: value,
      privacyPolicy: value,
      locationTerms: value,
      marketing: value,
    );
  }

  /// 약관 동의 제출
  ///
  /// 결과:
  /// - [AgreementSubmitResult.offline]: 네트워크 미연결 — 스낵바 표시하고 재시도
  /// - [AgreementSubmitResult.missingRequired]: 필수 미체크 — UI에서 막혀야 함
  /// - [AgreementSubmitResult.failure]: API 에러 — [lastError] 확인 후 스낵바
  /// - [AgreementSubmitResult.success]: 성공 — 호출자가 AuthNotifier 갱신 필요
  Future<AgreementSubmitResult> submit() async {
    if (state.isSubmitting) return AgreementSubmitResult.failure;
    if (!state.hasAllRequired) return AgreementSubmitResult.missingRequired;

    lastError = null;

    final connectivity = ref.read(connectivityServiceProvider);
    final isConnected = await connectivity.isConnected();
    if (!isConnected) {
      debugPrint('⚠️ [AgreementNotifier] 네트워크 미연결 — 제출 취소');
      return AgreementSubmitResult.offline;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.updateAgreements(marketing: state.marketing);
      debugPrint('✅ [AgreementNotifier] 약관 동의 저장 성공');
      state = state.copyWith(isSubmitting: false);
      return AgreementSubmitResult.success;
    } catch (e) {
      debugPrint('❌ [AgreementNotifier] 약관 동의 저장 실패: $e');
      lastError = e is AppException
          ? e
          : ServerException(
              // message는 로그/디버그용 — 사용자 노출은 messageKey 경유
              message: 'temporary error, please retry',
              messageKey: 'errorTemporaryRetry',
              originalException: e,
            );
      state = state.copyWith(isSubmitting: false);
      return AgreementSubmitResult.failure;
    }
  }
}
