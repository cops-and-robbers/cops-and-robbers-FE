final RegExp _version = RegExp(r'^\d{1,9}\.\d{1,9}\.\d{1,9}$');

/// 스토어에 아직 없는 버전인지 (심사 빌드, 내부 테스트 빌드).
///
/// 출시 때 올리는 값이 [minimumVersion]일 때도 [latestVersion]일 때도 있어 둘 다보다 높아야 한다.
/// 하나라도 `숫자.숫자.숫자`로 읽지 못하면 false다. 콘솔에 값을 잘못 넣었을 때
/// 모든 사용자가 점검을 건너뛰지 않게 한다.
bool isUnreleasedVersion({
  required String appVersion,
  required String minimumVersion,
  required String latestVersion,
}) {
  final versions = [appVersion, minimumVersion, latestVersion];
  if (!versions.every(_version.hasMatch)) return false;
  return _isHigher(appVersion, minimumVersion) &&
      _isHigher(appVersion, latestVersion);
}

bool _isHigher(String a, String b) {
  final partsA = a.split('.').map(int.parse).toList();
  final partsB = b.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    if (partsA[i] != partsB[i]) return partsA[i] > partsB[i];
  }
  return false;
}
