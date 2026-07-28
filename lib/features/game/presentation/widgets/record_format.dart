import 'package:intl/intl.dart';

/// 이동 거리를 값과 단위로 분리 — 결과 카드에서 숫자(44px)와 단위(24px) 폰트가 다르다.
///
/// 1km 미만은 정수 m, 이상은 소수 2자리. 단위 `Km`의 대문자 K는 디자인 시안 표기를 따른다.
({String value, String unit}) formatDistanceParts(double meters) {
  if (meters < 1000) return (value: '${meters.round()}', unit: 'm');
  return (value: (meters / 1000).toStringAsFixed(2), unit: 'Km');
}

/// 게임 종료 일시 — 로케일 독립 숫자 포맷(`2026.06.19 19:28`).
String formatRecordDate(DateTime dt) =>
    DateFormat('yyyy.MM.dd HH:mm').format(dt);

/// `durationSeconds`(초)를 "분:초" 포맷으로 변환.
///
/// - 초는 2자리 0 패딩 (`"5:07"`)
/// - 분은 60분 이상도 cap 없이 누적 (`3661 → "61:01"`)
String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
