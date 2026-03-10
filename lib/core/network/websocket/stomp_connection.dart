// STOMP 연결 공통 타입
//
// Chat, Lobby 등 STOMP 기반 DataSource에서 공유하는 타입입니다.

/// STOMP 연결 상태
enum StompConnectionState { disconnected, connecting, connected, error }

/// STOMP ERROR 프레임에서 파싱된 에러 정보
class StompErrorInfo {
  final String title;
  final int status;
  final String detail;
  final String instance;

  const StompErrorInfo({
    required this.title,
    required this.status,
    required this.detail,
    required this.instance,
  });

  factory StompErrorInfo.fromJson(Map<String, dynamic> json) {
    return StompErrorInfo(
      title: json['title'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      detail: json['detail'] as String? ?? '',
      instance: json['instance'] as String? ?? '',
    );
  }

  bool get isAuthExpired => status == 401 && instance == 'STOMP';
}
