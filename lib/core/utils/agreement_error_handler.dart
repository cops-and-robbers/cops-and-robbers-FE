import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import '../network/api_error_response.dart';

/// 백엔드가 RFC 7807 응답으로 내려주는 "필수 약관 미동의" 에러의 errorCode 식별자.
///
/// title(한국어 문자열)이 아닌 머신 식별자를 비교하므로 로케일과 무관하다.
const String requiredTermsErrorCode = 'REQUIRED_TERMS_NOT_AGREED';

/// 에러에서 RFC 7807 응답을 추출합니다.
///
/// [AppException]의 `originalException`에서 DioException을 꺼내는 경우와
/// DioException을 직접 캐치한 경우(home_page `_joinRoom`) 모두 대응합니다.
ApiErrorResponse? _extractApiError(Object? error) {
  if (error is AppException && error.originalException is DioException) {
    return ApiErrorResponse.tryParse(
      (error.originalException as DioException).response?.data,
    );
  }
  if (error is DioException) {
    return ApiErrorResponse.tryParse(error.response?.data);
  }
  return null;
}

/// "필수 약관 미동의" 에러인지 판별합니다.
///
/// 백엔드의 RFC 7807 응답 `errorCode`가 머신 식별자와 일치하면 true.
///
/// 실제 처리(스낵바 + `/agreement` 리디렉트)는 전역
/// [RequiredTermsInterceptor]가 담당한다. 화면 호출부는 이 판별만 써서
/// **자신의 일반 에러 처리를 건너뛰면 된다** — 인터셉터가 이미 안내하므로
/// 원인 모를 에러 스낵바가 리디렉트 직전에 겹치는 것을 막는다.
bool isRequiredTermsMissingError(Object? error) {
  final api = _extractApiError(error);
  return api?.errorCode == requiredTermsErrorCode;
}
