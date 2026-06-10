import 'package:geolocator/geolocator.dart';

/// 도둑 위치를 서버로 전송할지 결정하는 순수 정책 함수.
///
/// 통합된 단일 GPS 스트림은 `distanceFilter: 0`으로 모든 위치 틱을 받으므로,
/// 기존에 OS가 담당하던 10m 이동 필터를 코드 레벨 거리 계산으로 대체한다.
/// 다음을 모두 만족할 때만 전송한다:
/// - 체포되지 않음
/// - 마지막 전송 이후 5초 이상 경과 (서버 부하 throttle)
/// - 마지막 전송 위치에서 10m 이상 이동 (이전 위치가 없으면 거리 조건은 통과)
bool shouldSendLocation({
  required DateTime? lastSentTime,
  required DateTime now,
  required double? lastLat,
  required double? lastLng,
  required double newLat,
  required double newLng,
  required bool isArrested,
}) {
  if (isArrested) return false;

  if (lastSentTime != null && now.difference(lastSentTime).inSeconds < 5) {
    return false;
  }

  if (lastLat != null && lastLng != null) {
    final distance = Geolocator.distanceBetween(
      lastLat,
      lastLng,
      newLat,
      newLng,
    );
    if (distance < 10.0) return false;
  }

  return true;
}
