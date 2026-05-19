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
/// 4개 체크박스 + 초기 로드/제출 중 여부를 담는 불변 상태.
/// [isLoading]은 진입 직후 서버 동의 상태를 가져오는 동안 true이며,
/// 이 사이 토글/제출이 응답 값을 덮어쓰지 않도록 가드 용도로 사용된다.
@freezed
class AgreementState with _$AgreementState {
  const factory AgreementState({
    @Default(false) bool termsOfService,
    @Default(false) bool privacyPolicy,
    @Default(false) bool locationTerms,
    @Default(false) bool marketing,
    @Default(true) bool isLoading,
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
///
/// [build] 진입 시 `GET /api/user/agreements`를 호출하여 서버에 저장된
/// 현재 동의 상태로 체크박스를 초기화합니다. 백엔드가 정책 갱신으로 특정
/// 약관만 false로 되돌리는 경우, 이미 동의한 약관은 체크된 상태로 표시되어
/// 사용자가 변경된 약관만 새로 체크하면 되도록 합니다.
@riverpod
class AgreementNotifier extends _$AgreementNotifier {
  /// 마지막 submit 에러 (UI에서 스낵바 표시용)
  AppException? lastError;

  @override
  AgreementState build() {
    // dispose 이후 비동기 콜백이 state를 건드리면 Riverpod이 throw하므로,
    // 명시적 플래그로 가드한다 (일반 Notifier에는 ref.mounted가 없음).
    var disposed = false;
    ref.onDispose(() => disposed = true);

    // build()는 동기 유지, 초기 로드는 microtask로 미룬다.
    // 첫 frame은 isLoading=true 상태로 그리고, 응답 도착 시 state를 갱신해
    // 자연스러운 rebuild가 일어나도록 한다.
    Future.microtask(() => _loadInitial(isDisposed: () => disposed));
    return const AgreementState();
  }

  /// 서버에서 현재 동의 상태를 조회하여 체크박스 초기값을 채운다.
  ///
  /// 실패 시 기본값(전부 false)을 유지하여 사용자가 직접 체크하고 진행할 수
  /// 있도록 폴백한다. 진입 시 1회만 실행되는 초기화이므로 별도 재시도 UI는
  /// 두지 않고, 디버그 로그만 남긴다.
  Future<void> _loadInitial({required bool Function() isDisposed}) async {
    try {
      final repo = ref.read(userRepositoryProvider);
      final status = await repo.getAgreements();
      if (isDisposed()) return;
      state = state.copyWith(
        termsOfService: status.termsOfService,
        privacyPolicy: status.privacyPolicy,
        locationTerms: status.locationTerms,
        marketing: status.marketing,
        isLoading: false,
      );
      debugPrint('✅ [AgreementNotifier] 초기 동의 상태 로드 성공');
    } catch (e) {
      if (isDisposed()) return;
      // 폴백: 전부 미체크 상태로 둠. UI는 체크박스가 활성화되어 사용자가
      // 직접 체크하여 진행할 수 있다.
      state = state.copyWith(isLoading: false);
      debugPrint('⚠️ [AgreementNotifier] 초기 동의 상태 로드 실패: $e (전부 미체크 폴백)');
    }
  }

  // 초기 로드/제출 중에는 체크박스 변경을 무시한다.
  // 비동기 응답이 사용자 토글을 덮어쓰지 않도록 isLoading도 가드한다.
  // 동의 이력의 정합성을 지키기 위해 토글·일괄설정 모두 동일하게 가드한다.
  void toggleTerms() {
    if (state.isLoading || state.isSubmitting) return;
    state = state.copyWith(termsOfService: !state.termsOfService);
  }

  void togglePrivacy() {
    if (state.isLoading || state.isSubmitting) return;
    state = state.copyWith(privacyPolicy: !state.privacyPolicy);
  }

  void toggleLocation() {
    if (state.isLoading || state.isSubmitting) return;
    state = state.copyWith(locationTerms: !state.locationTerms);
  }

  void toggleMarketing() {
    if (state.isLoading || state.isSubmitting) return;
    state = state.copyWith(marketing: !state.marketing);
  }

  /// 4개를 일괄 [value]로 설정
  void toggleAll(bool value) {
    if (state.isLoading || state.isSubmitting) return;
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
    if (state.isLoading || state.isSubmitting) {
      return AgreementSubmitResult.failure;
    }
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
