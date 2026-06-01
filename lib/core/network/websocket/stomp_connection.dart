// STOMP 연결 공통 타입
//
// Chat, Lobby 등 STOMP 기반 DataSource에서 공유하는 타입입니다.

/// STOMP 연결 상태
enum StompConnectionState { disconnected, connecting, connected, error }

/// STOMP ERROR 프레임에서 파싱된 에러 정보
class StompErrorInfo {
  // 백엔드 v2.8.0+에서 추가된 에러 코드 (예: 'ACCESS_TOKEN_EXPIRED')
  // 이전 버전 호환을 위해 optional 처리
  final String? errorCode;
  final String title;
  final int status;
  final String detail;
  final String instance;

  const StompErrorInfo({
    this.errorCode,
    required this.title,
    required this.status,
    required this.detail,
    required this.instance,
  });

  factory StompErrorInfo.fromJson(Map<String, dynamic> json) {
    return StompErrorInfo(
      errorCode: json['errorCode'] as String?,
      title: json['title'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      detail: json['detail'] as String? ?? '',
      instance: json['instance'] as String? ?? '',
    );
  }

  bool get isAuthExpired => status == 401 && instance == 'STOMP';
}
