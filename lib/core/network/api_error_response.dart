/// 백엔드 공통 에러 응답 모델 (RFC 7807 Problem Details)
///
/// 백엔드의 모든 에러 응답은 이 형식을 따릅니다:
/// ```json
/// {
///   "title": "유효하지 않은 입력값",
///   "status": 400,
///   "detail": "idToken: 소셜 인증 토큰(ID Token)은 필수입니다.",
///   "instance": "/api/auth/login"
/// }
/// ```
///
/// [API_SPEC.md - 6. 공통 스키마 - ErrorResponse] 참조
class ApiErrorResponse {
  /// 에러 제목 (예: "유효하지 않은 입력값", "소셜 로그인 실패")
  final String title;

  /// HTTP 상태 코드
  final int status;

  /// 에러 상세 설명 (사용자에게 표시할 메시지)
  final String detail;

  /// 요청 경로 (예: "/api/auth/login")
  final String instance;

  const ApiErrorResponse({
    required this.title,
    required this.status,
    required this.detail,
    required this.instance,
  });

  /// JSON Map에서 ApiErrorResponse 생성
  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      title: json['title'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      detail: json['detail'] as String? ?? '',
      instance: json['instance'] as String? ?? '',
    );
  }

  /// 응답 데이터에서 안전하게 파싱 시도
  ///
  /// 파싱 실패 시 null 반환 (백엔드가 RFC 7807 형식이 아닌 경우)
  static ApiErrorResponse? tryParse(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;

    // title과 detail이 모두 없으면 RFC 7807 형식이 아닌 것으로 판단
    if (data['title'] == null && data['detail'] == null) return null;

    return ApiErrorResponse.fromJson(data);
  }

  @override
  String toString() {
    return '[$status] $title | $detail (instance: $instance)';
  }
}
