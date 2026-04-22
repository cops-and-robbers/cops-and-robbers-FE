import 'dart:convert';

/// 도둑 체포용 QR 페이로드
///
/// 참가자 ID와 만료시각을 담는 값 객체. 도둑 측에서 QR을 만들 때 사용하고,
/// 경찰 측에서 스캔된 문자열을 파싱·검증할 때 동일한 클래스를 공유한다.
/// 이 모델을 통해 생성/파싱을 단일 지점에서 관리하여 포맷 불일치를 방지한다.
///
/// 인코딩 포맷: `{"pid": <int>, "exp": <Unix millisecond int>}`
class QrPayload {
  const QrPayload({required this.participantId, required this.expiresAt});

  /// 도둑의 참가자 ID
  final int participantId;

  /// 이 페이로드의 만료시각 (이 시각 이후 스캔된 QR은 무효 처리)
  final DateTime expiresAt;

  /// 현재 시각 기준으로 [ttl]만큼 유효한 새 페이로드를 만든다.
  ///
  /// 도둑 다이얼로그가 열릴 때 호출되어 신선한 만료시각을 부여한다.
  factory QrPayload.freshFor({
    required int participantId,
    required DateTime now,
    required Duration ttl,
  }) {
    return QrPayload(participantId: participantId, expiresAt: now.add(ttl));
  }

  /// 스캔된 원본 문자열을 파싱한다. 형식 오류 시 `null` 반환.
  ///
  /// [QrScannerPage] 의 `onParse` 콜백에 그대로 대입할 수 있도록
  /// `T? Function(String)` 시그니처에 맞춰 정의한다.
  static QrPayload? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      // JSON 디코더는 정수를 int 또는 num으로 반환할 수 있어 양쪽 모두 허용.
      final pid = decoded['pid'];
      final exp = decoded['exp'];
      if (pid is! num) return null;
      if (exp is! num) return null;

      return QrPayload(
        participantId: pid.toInt(),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(exp.toInt()),
      );
    } catch (_) {
      return null;
    }
  }

  /// QR 이미지에 인코딩할 JSON 문자열을 생성한다.
  String toRaw() {
    return jsonEncode({
      'pid': participantId,
      'exp': expiresAt.millisecondsSinceEpoch,
    });
  }

  /// [now] 시점 기준 만료 여부를 판정한다.
  ///
  /// `expiresAt`과 정확히 같은 시각도 만료로 취급 (경계 닫힘).
  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);
}
