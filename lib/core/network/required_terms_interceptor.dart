import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../utils/agreement_error_handler.dart';

/// 이 처리를 타면 안 되는 경로 — 약관 제출 자체.
///
/// BE `TermsAgreementInterceptor`의 제외 경로 3개 중 이 하나만 적는다.
/// `PUT /api/user/agreements`는 인터셉터에서 빠져 있지만
/// `UserService.updateTermsAgreement`가 필수 항목이 모두 true가 아니면 같은
/// errorCode를 직접 던진다 — 약관 화면의 제출 실패를 "약관 화면으로 보내라"로
/// 읽으면 안 된다.
/// 나머지 두 경로(`/api/auth/**`·`/api/user/me`)는 이 errorCode를 낼 **REST**
/// 코드 경로가 서버에 없어 적지 않는다 — 도달할 수 없는 목록은 서버가 바뀌어도
/// 아무도 고치지 않아 썩는다. (`CommunityChatService`도 같은 코드를 던지지만
/// STOMP라 Dio를 타지 않아 애초에 이 인터셉터의 사정이 아니다.)
///
/// 이 목록은 BE `WebConfig`의 제외 목록과 짝이다. BE가 `/api/user/me` 제외를
/// 풀면 `AuthNotifier.build()`의 초기 조회가 이 처리를 깨우게 되므로 함께 본다.
const String _agreementSubmitPath = ApiEndpoints.agreements;

/// 필수 약관 미동의(400) 전역 처리 인터셉터
///
/// 백엔드가 필수 약관 검증을 `/api/**` 전역 인터셉터로 올린 뒤로
/// (BE #184) 이 400은 게임 생성·방 참가뿐 아니라 커뮤니티·마이페이지·공지
/// 어디서든 날 수 있다. 화면마다 처리하면 화면을 늘릴 때마다 같은 누락이
/// 재발하므로 HTTP 클라이언트 한 곳에서 받는다.
///
/// **동작**: errorCode로 판별(로케일 무관) → [onRequiredTermsNotAgreed] →
/// `AuthNotifier.markNeedsAgreement()` → `app_router.dart` redirect step 2가
/// `/agreement`로 보냄. 안내 문구는 목적지인 약관 화면이 표시한다
/// (인터셉터에는 BuildContext가 없다 — 강제 로그아웃의 `messageKey`와 같은 방식).
///
/// 에러는 **그대로 전파한다**. 호출부의 로딩 해제·상태 정리가 계속 돌아야 하고,
/// 일반 에러 스낵바만 [isRequiredTermsMissingError]로 건너뛰면 된다.
class RequiredTermsInterceptor extends Interceptor {
  RequiredTermsInterceptor({required this.onRequiredTermsNotAgreed});

  /// 필수 약관 미동의가 감지됐을 때 실행할 동작
  final VoidCallback onRequiredTermsNotAgreed;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.uri.path != _agreementSubmitPath &&
        isRequiredTermsMissingError(err)) {
      if (kDebugMode) {
        debugPrint('🚨 [RequiredTerms] 필수 약관 미동의 400 → /agreement 리디렉트');
      }
      onRequiredTermsNotAgreed();
    }

    handler.next(err);
  }
}
